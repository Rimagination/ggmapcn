#' Check and retrieve required geodata files
#'
#' @description
#' Ensures that external geospatial data files required by \pkg{ggmapcn} are
#' available locally. Existing files are reused when \code{overwrite = FALSE};
#' missing files are downloaded from remote mirrors when possible. If all
#' mirrors fail (for example, due to network restrictions), the function fails
#' gracefully by returning \code{NA} for the affected files without raising
#' warnings or errors, in line with CRAN policy.
#'
#' @details
#' Because CRAN enforces strict limits on package size, several large datasets
#' are hosted externally rather than bundled in the package. \code{check_geodata()}
#' locates or retrieves these files using the following priority:
#' \enumerate{
#'   \item user-specified \code{local_dirs}
#'   \item the package \code{extdata} directory
#'   \item the per-user cache directory via \code{tools::R_user_dir("ggmapcn", "data")}
#' }
#'
#' High-level mapping functions such as \code{geom_mapcn()} and \code{geom_world()}
#' call \code{check_geodata()} internally, so most users do not need to invoke it
#' directly. However, running it explicitly can be useful to pre-fetch or verify
#' required files.
#'
#' On networks that cannot reliably access \code{cdn.jsdelivr.net} or
#' \code{raw.githubusercontent.com}, downloads may time out and the corresponding
#' entries in the returned vector will be \code{NA}. In such cases, users may
#' manually download the required files from the data repository and place them
#' into a directory supplied through \code{local_dirs}, the package \code{extdata}
#' directory, or the user cache directory so that downloads are skipped.
#'
#' Note: recent versions of \code{geom_world()} use the following world datasets:
#' \code{world_countries.rda}, \code{world_coastlines.rda}, and
#' \code{world_boundaries.rda}. The legacy \code{world.rda} file is no longer
#' used.
#'
#' @param files Character vector of file names. If \code{NULL}, all known files
#'   are processed.
#' @param overwrite Logical; if \code{TRUE}, forces re-download even when a
#'   non-empty file already exists.
#' @param quiet Logical; if \code{TRUE}, suppresses progress output and
#'   messages.
#' @param max_retries Integer; number of retry attempts per file and mirror.
#' @param mirrors Character vector of base URLs ending with \code{/}. If
#'   \code{NULL}, package defaults are used.
#' @param use_checksum Logical; if \code{TRUE}, verifies SHA-256 checksums when
#'   available.
#' @param checksums Optional named character vector of SHA-256 digests.
#'   If \code{NULL}, defaults derived from \code{known_files()} are used.
#' @param resume Logical; whether to attempt HTTP range resume for partially
#'   downloaded \code{.part} files.
#' @param local_dirs Character vector of directories to search prior to any
#'   download attempt.
#'
#' @return
#' A character vector of absolute file paths. Any file that cannot be obtained
#' is returned as \code{NA}.
#'
#' @examplesIf interactive() && curl::has_internet()
#' # Ensure that all default datasets are available (downloads only if needed)
#' check_geodata()
#'
#' # Datasets used by geom_world()
#' check_geodata(c(
#'   "world_countries.rda",
#'   "world_coastlines.rda",
#'   "world_boundaries.rda"
#' ))
#'
#' # China administrative boundaries
#' check_geodata(c("China_sheng.rda", "China_shi.rda", "China_xian.rda"))
#'
#' # Reuse files manually placed in the working directory
#' check_geodata("world_countries.rda", local_dirs = getwd())
#'
#' @export
#' @importFrom curl curl_download new_handle handle_setopt
#' @importFrom tools R_user_dir
#' @importFrom digest digest
#' @importFrom stats runif
check_geodata <- function(files = NULL,
                          overwrite = FALSE,
                          quiet = FALSE,
                          max_retries = 3,
                          mirrors = NULL,
                          use_checksum = TRUE,
                          checksums = NULL,
                          resume = TRUE,
                          local_dirs = NULL) {

  # ---- known files ---------------------------------------------------------
  known <- known_files()
  if (is.null(files)) {
    files <- names(known)
  }

  invalid <- setdiff(files, names(known))
  if (length(invalid)) {
    # Only invalid names cause an error; network failures do not.
    stop("Invalid file names requested: ", paste(invalid, collapse = ", "))
  }

  # ---- mirrors -------------------------------------------------------------
  if (is.null(mirrors)) {
    mirrors <- c(
      "https://cdn.jsdelivr.net/gh/Rimagination/ggmapcn-data@main/data/",
      "https://raw.githubusercontent.com/Rimagination/ggmapcn-data/main/data/"
    )
  }

  # ---- checksums -----------------------------------------------------------
  if (is.null(checksums)) {
    checksums <- vapply(known, `[[`, character(1), "sha256")
    names(checksums) <- names(known)
  }

  has_checksum <- function(f) {
    x <- checksums[[f]]
    is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
  }

  verify_file <- function(path, fname) {
    if (!use_checksum || !has_checksum(fname)) return(TRUE)
    got <- digest::digest(path, algo = "sha256", file = TRUE)
    identical(tolower(got), tolower(checksums[[fname]]))
  }

  # ---- canonical directories -----------------------------------------------
  ext_dir   <- system.file("extdata", package = "ggmapcn")
  cache_dir <- tools::R_user_dir("ggmapcn", "data")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  }

  is_writable <- function(dir) {
    if (!nzchar(dir) || !dir.exists(dir)) return(FALSE)
    tf <- file.path(dir, sprintf(".perm_test_%08x", as.integer(runif(1, 0, 1e9))))
    ok <- tryCatch({
      file.create(tf)
      file.exists(tf)
    }, warning = function(w) FALSE,
    error   = function(e) FALSE)
    if (ok) unlink(tf)
    isTRUE(ok)
  }

  ext_writable   <- nzchar(ext_dir) && is_writable(ext_dir)
  cache_writable <- is_writable(cache_dir)

  if (!quiet) {
    message(sprintf("extdata dir: %s (writable = %s)",
                    if (nzchar(ext_dir)) ext_dir else "<none>", ext_writable))
    message(sprintf("cache   dir: %s (writable = %s)",
                    cache_dir, cache_writable))
  }

  # ---- reuse existing local files ------------------------------------------
  find_local <- function(fname, dirs) {
    for (d in dirs) {
      if (!nzchar(d) || !dir.exists(d)) next
      cand <- file.path(d, fname)
      if (file.exists(cand) && file.info(cand)$size > 0) {
        if (verify_file(cand, fname)) {
          return(normalizePath(cand, winslash = "/", mustWork = FALSE))
        } else if (!quiet) {
          message(fname, ": found at ", cand,
                  " but checksum mismatch; ignoring this copy.")
        }
      }
    }
    NA_character_
  }

  # ---- curl helpers --------------------------------------------------------
  mk_handle <- function(resume_from = NULL) {
    h <- curl::new_handle(
      noprogress       = FALSE,
      timeout          = 300,
      connecttimeout   = 30,
      low_speed_limit  = 10,
      low_speed_time   = 30,
      followlocation   = TRUE,
      useragent        = "ggmapcn/check_geodata (curl)"
    )
    if (!is.null(resume_from) && resume_from > 0) {
      curl::handle_setopt(h, resume_from = as.numeric(resume_from))
    }
    h
  }

  backoff <- function(k) {
    base   <- 2^(k - 1)
    jitter <- runif(1, 0, 1)
    min(30, base + jitter)
  }

  # Download a single URL to dest (with optional resume and checksum)
  fetch_one <- function(url, dest, fname, allow_resume) {
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    part <- paste0(dest, ".part")

    if (!allow_resume && file.exists(part)) {
      unlink(part)
    }
    resume_from <- if (allow_resume && file.exists(part)) {
      file.info(part)$size
    } else {
      NULL
    }

    ok <- FALSE
    last_err <- NULL

    for (k in seq_len(max_retries)) {
      h <- mk_handle(resume_from)
      err <- try(
        curl::curl_download(url, destfile = part, handle = h, quiet = TRUE),
        silent = TRUE
      )

      if (inherits(err, "try-error")) {
        last_err <- conditionMessage(attr(err, "condition"))
      } else if (!file.exists(part) || file.info(part)$size == 0) {
        last_err <- "empty file / zero size"
      } else if (use_checksum && has_checksum(fname)) {
        got <- digest::digest(part, algo = "sha256", file = TRUE)
        if (!identical(tolower(got), tolower(checksums[[fname]]))) {
          last_err <- sprintf(
            "checksum mismatch: got %s, expected %s",
            got, checksums[[fname]]
          )
        } else {
          last_err <- NULL
        }
      } else {
        last_err <- NULL
      }

      if (is.null(last_err)) {
        ok <- TRUE
        break
      }

      if (!quiet) {
        message(sprintf("Download attempt %d for '%s' failed: %s",
                        k, fname, last_err))
      }

      if (k < max_retries) {
        Sys.sleep(backoff(k))
        # Next attempt starts from scratch to avoid issues with unsupported range.
        resume_from <- NULL
      }
    }

    if (!ok) {
      if (!quiet) {
        message(
          "Giving up on '", fname,
          "' from URL: ", url,
          " (last error: ", last_err, ")."
        )
      }
      return(FALSE)
    }

    if (file.exists(dest)) {
      unlink(dest)
    }
    file.rename(part, dest)
    TRUE
  }

  # Try to download into a target directory ----------------------------------
  try_download <- function(target_dir, fname, allow_resume) {
    dest <- file.path(target_dir, fname)

    if (!quiet) {
      message("Fetching '", fname, "' into: ", target_dir)
    }

    success <- FALSE
    for (m in mirrors) {
      url <- paste0(m, fname)
      if (!quiet) {
        message("  Trying URL: ", url)
      }
      if (fetch_one(url, dest, fname, allow_resume)) {
        success <- TRUE
        break
      }
    }

    if (!success && !quiet) {
      message(
        "All mirrors failed for '", fname, "'. Returning NA.\n",
        "If downloads remain unavailable, you can place the file manually into:\n",
        "  - a directory supplied via local_dirs,\n",
        "  - the extdata directory: ", ext_dir, ",\n",
        "  - or the user cache directory: ", cache_dir
      )
    }

    list(ok = success, path = if (success) dest else NA_character_)
  }

  # ---- main loop -----------------------------------------------------------
  out <- character(length(files))

  for (i in seq_along(files)) {
    fname <- files[i]

    # A) reuse: local_dirs -> extdata -> cache -------------------------------
    if (!overwrite) {
      if (length(local_dirs)) {
        loc <- find_local(fname, local_dirs)
        if (!is.na(loc)) {
          out[i] <- loc
          if (!quiet) {
            message("Using existing local file (local_dirs): ", loc)
          }
          next
        }
      }

      if (nzchar(ext_dir)) {
        loc <- find_local(fname, ext_dir)
        if (!is.na(loc)) {
          out[i] <- loc
          if (!quiet) {
            message("Using existing extdata file: ", loc)
          }
          next
        }
      }

      loc <- find_local(fname, cache_dir)
      if (!is.na(loc)) {
        out[i] <- loc
        if (!quiet) {
          message("Using existing cache file: ", loc)
        }
        next
      }
    }

    # B) download if needed --------------------------------------------------
    if (ext_writable) {
      res <- try_download(ext_dir, fname, allow_resume = resume)
      if (res$ok) {
        out[i] <- res$path
        if (!quiet) {
          message("Saved to extdata: ", res$path)
        }
        next
      } else if (!quiet) {
        message(
          "Download into extdata failed for '", fname,
          "'. Falling back to user cache."
        )
      }
    } else if (nzchar(ext_dir) && !quiet) {
      message(
        "extdata not writable; skip downloading into extdata for '",
        fname, "'."
      )
    }

    if (cache_writable) {
      res2 <- try_download(cache_dir, fname, allow_resume = TRUE)
      out[i] <- res2$path
      if (res2$ok && !quiet) {
        message("Saved to cache: ", res2$path)
      }
    } else {
      out[i] <- NA_character_
      if (!quiet) {
        message(
          "Cache directory is not writable; cannot download '",
          fname, "'. Returning NA."
        )
      }
    }
  }

  out
}


#' Known geodata files
#'
#' @keywords internal
#' @noRd
known_files <- function() {
  list(
    "China_sheng.rda"        = list(path = "China_sheng.rda",        sha256 = NA_character_),
    "China_shi.rda"          = list(path = "China_shi.rda",          sha256 = NA_character_),
    "China_xian.rda"         = list(path = "China_xian.rda",         sha256 = NA_character_),
    "boundary.rda"           = list(path = "boundary.rda",           sha256 = NA_character_),
    "buffer_line.rda"        = list(path = "buffer_line.rda",        sha256 = NA_character_),
    "China_mask.gpkg"        = list(path = "China_mask.gpkg",        sha256 = NA_character_),
    "world_countries.rda"    = list(path = "world_countries.rda",    sha256 = NA_character_),
    "world_coastlines.rda"   = list(path = "world_coastlines.rda",   sha256 = NA_character_),
    "world_boundaries.rda"   = list(path = "world_boundaries.rda",   sha256 = NA_character_),
    "gebco_2024_China.tif"   = list(path = "gebco_2024_China.tif",   sha256 = NA_character_),
    "vege_1km_projected.tif" = list(path = "vege_1km_projected.tif", sha256 = NA_character_)
  )
}
