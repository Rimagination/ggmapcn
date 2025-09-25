#' Check and Download Geospatial Data
#'
#' @description
#' Ensure required geodata files exist locally. The function searches and reuses
#' existing files (when \code{overwrite = FALSE}) \emph{before} attempting any
#' network download, in the following order:
#' \enumerate{
#'   \item user-provided \strong{local_dirs}
#'   \item installed package \strong{extdata} (even if not writable)
#'   \item per-user cache \strong{tools::R_user_dir("ggmapcn","data")}
#' }
#' If no valid local file is found (or \code{overwrite = TRUE}), the function
#' downloads from mirrors \emph{in order}. By default, a China-friendly CDN
#' (jsDelivr) is tried first, then GitHub raw.
#'
#' Robust features: multiple mirrors, atomic writes, resume, timeouts, retries,
#' safe checksum checks, and correct \code{curl} progress callback.
#'
#' @param files Character vector of file names. If `NULL`, all known files are used.
#' @param overwrite Logical. Force re-download even if a non-empty file exists.
#'   Default `FALSE`.
#' @param quiet Logical. Suppress progress and messages. Default `FALSE`.
#' @param max_retries Integer. Max retry attempts per (mirror, file). Default `3`.
#' @param mirrors Character vector of base URLs (end with `/`). Tried in order.
#'   Default: jsDelivr first, then GitHub raw.
#' @param use_checksum Logical. Verify SHA-256 when available. Default `TRUE`.
#' @param checksums Named character vector of SHA-256 digests (names = file names).
#'   If `NULL`, built-in defaults are used for known files; unknown files skip verification.
#' @param resume Logical. Try HTTP range resume if a `.part` exists (only for
#'   writable dirs). Default `TRUE`.
#' @param local_dirs Character vector of directories to search \emph{before}
#'   any download. If a matching non-empty file is found and \code{overwrite = FALSE},
#'   it is returned immediately.
#'
#' @return Character vector of absolute file paths (NA for failures).
#'
#' @examples
#' \donttest{
#' # Basic: ensure default files exist
#' check_geodata()
#'
#' # Single file: reuse existing file if present (default overwrite = FALSE)
#' check_geodata(files = "boundary.rda")
#'
#' # Force re-download a file (e.g., suspected corruption)
#' check_geodata(files = "boundary.rda", overwrite = TRUE)
#'
#' # Search local folders first; skip download if a valid file is found there
#' check_geodata(
#'   files = c("boundary.rda", "world.rda"),
#'   local_dirs = c(getwd())  # add more directories if needed
#' )
#'
#' # Provide your own mirror order (first tried wins)
#' check_geodata(
#'   files = "boundary.rda",
#'   mirrors = c(
#'     "https://cdn.jsdelivr.net/gh/Rimagination/ggmapcn-data@main/data/",
#'     "https://raw.githubusercontent.com/Rimagination/ggmapcn-data/main/data/"
#'   )
#' )
#' }
#'
#' @export
#' @importFrom curl curl_download new_handle handle_setopt
#' @importFrom tools R_user_dir
#' @importFrom digest digest
#' @importFrom stats runif
#'
check_geodata <- function(files = NULL,
                          overwrite = FALSE,
                          quiet = FALSE,
                          max_retries = 3,
                          mirrors = NULL,
                          use_checksum = TRUE,
                          checksums = NULL,
                          resume = TRUE,
                          local_dirs = NULL) {

  # ---- helpers --------------------------------------------------------------
  known <- known_files()
  if (is.null(files)) files <- names(known)
  invalid <- setdiff(files, names(known))
  if (length(invalid)) stop("Invalid file names requested: ", paste(invalid, collapse = ", "))

  # mirrors: CDN (CN) first
  if (is.null(mirrors)) {
    mirrors <- c(
      "https://cdn.jsdelivr.net/gh/Rimagination/ggmapcn-data@main/data/",
      "https://raw.githubusercontent.com/Rimagination/ggmapcn-data/main/data/"
    )
  }

  # checksums (safe getter)
  if (is.null(checksums)) {
    checksums <- vapply(known, `[[`, character(1), "sha256")
    names(checksums) <- names(known)
  }
  has_checksum <- function(f) {
    x <- checksums[[f]]
    is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
  }

  # canonical dirs
  ext_dir   <- system.file("extdata", package = "ggmapcn")
  cache_dir <- tools::R_user_dir("ggmapcn", "data")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  is_writable <- function(dir) {
    if (!nzchar(dir) || !dir.exists(dir)) return(FALSE)
    tf <- file.path(dir, sprintf(".perm_test_%08x", as.integer(runif(1, 0, 1e9))))
    ok <- tryCatch({ file.create(tf); file.exists(tf) }, warning = function(w) FALSE, error = function(e) FALSE)
    if (ok) unlink(tf)
    isTRUE(ok)
  }
  ext_writable   <- nzchar(ext_dir) && is_writable(ext_dir)
  cache_writable <- is_writable(cache_dir)

  if (!quiet) {
    message(sprintf("extdata dir: %s (writable = %s)", if (nzchar(ext_dir)) ext_dir else "<none>", ext_writable))
    message(sprintf("cache   dir: %s (writable = %s)", cache_dir, cache_writable))
  }

  # verify checksum if provided
  verify_file <- function(path, fname) {
    if (!use_checksum || !has_checksum(fname)) return(TRUE)
    got <- digest::digest(path, algo = "sha256", file = TRUE)
    identical(tolower(got), tolower(checksums[[fname]]))
  }

  # try reuse in a list of dirs (no download)
  try_reuse_in_dirs <- function(fname, dirs) {
    for (d in dirs) {
      if (!nzchar(d) || !dir.exists(d)) next
      cand <- file.path(d, fname)
      if (file.exists(cand) && file.info(cand)$size > 0) {
        if (verify_file(cand, fname)) {
          return(normalizePath(cand, winslash = "/", mustWork = FALSE))
        } else if (!quiet) {
          warning(fname, ": found at ", cand, " but checksum mismatch; ignoring.")
        }
      }
    }
    return(NA_character_)
  }

  # curl plumbing
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
  prog_cb <- function(file_name, quiet) {
    function(dt, dn, ut, un) {
      if (!quiet) {
        pct <- if (is.finite(dt) && dt > 0) sprintf("%6.2f%%", 100 * dn / dt) else "  ..  "
        cat(sprintf("\rDownloading %-28s %s", substr(file_name, 1, 28), pct))
      }
      0
    }
  }
  backoff <- function(k) { base <- 2^(k - 1); jitter <- runif(1, 0, 1); min(30, base + jitter) }

  fetch_one <- function(url, dest, fname, can_resume) {
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    part <- paste0(dest, ".part")
    if (!can_resume && file.exists(part)) unlink(part)
    resume_from <- if (can_resume && file.exists(part)) file.info(part)$size else NULL

    ok <- FALSE; last_err <- NULL
    for (k in seq_len(max_retries)) {
      h <- mk_handle(resume_from = resume_from)
      curl::handle_setopt(h, progressfunction = prog_cb(basename(dest), quiet))
      err <- try({ curl::curl_download(url, destfile = part, handle = h, quiet = TRUE) }, silent = TRUE)

      if (inherits(err, "try-error")) {
        last_err <- conditionMessage(attr(err, "condition"))
      } else if (!file.exists(part) || file.info(part)$size == 0) {
        last_err <- "empty file / zero size"
      } else if (has_checksum(fname) && use_checksum) {
        got <- digest::digest(part, algo = "sha256", file = TRUE)
        if (!identical(tolower(got), tolower(checksums[[fname]]))) {
          last_err <- sprintf("checksum mismatch: got %s, want %s", got, checksums[[fname]])
        } else last_err <- NULL
      } else {
        last_err <- NULL
      }

      if (is.null(last_err)) { ok <- TRUE; break }
      if (!quiet) { cat("\n"); warning(sprintf("Attempt %d failed: %s", k, last_err)) }
      if (k < max_retries) { Sys.sleep(backoff(k)); resume_from <- NULL }
    }
    if (!quiet) cat("\n")
    if (!ok) return(FALSE)

    if (file.exists(dest)) unlink(dest)
    file.rename(part, dest)
    TRUE
  }

  try_download_to_dir <- function(target_dir, fname, can_resume) {
    dest <- file.path(target_dir, fname)
    success <- FALSE
    if (!quiet) message("Fetching ", fname, " into: ", target_dir)
    for (m in mirrors) {
      url <- paste0(m, fname)
      if (!quiet) message("URL: ", url)
      if (fetch_one(url, dest, fname, can_resume)) { success <- TRUE; break }
    }
    list(ok = success, path = if (success) dest else NA_character_)
  }

  # ---- main loop ------------------------------------------------------------
  out <- character(length(files))

  for (i in seq_along(files)) {
    fname <- files[i]

    # A) pre-check & reuse when overwrite=FALSE
    if (!overwrite) {
      # A1) user local dirs
      if (length(local_dirs)) {
        hit <- try_reuse_in_dirs(fname, local_dirs)
        if (!is.na(hit)) { out[i] <- hit; if (!quiet) message("Using existing local file (local_dirs): ", hit); next }
      }
      # A2) extdata
      if (nzchar(ext_dir)) {
        hit <- try_reuse_in_dirs(fname, ext_dir)
        if (!is.na(hit)) { out[i] <- hit; if (!quiet) message("Using existing extdata file: ", hit); next }
      }
      # A3) cache
      hit <- try_reuse_in_dirs(fname, cache_dir)
      if (!is.na(hit)) { out[i] <- hit; if (!quiet) message("Using existing cache file: ", hit); next }
    }

    # B) need download (either overwrite=TRUE or not found/invalid)
    # B1) prefer extdata if writable
    tried_ext <- FALSE
    if (ext_writable) {
      tried_ext <- TRUE
      res <- try_download_to_dir(ext_dir, fname, can_resume = resume)
      if (res$ok) { out[i] <- res$path; if (!quiet) message("Saved to extdata: ", res$path); next }
      if (!quiet) warning("extdata download failed for ", fname, "; falling back to cache.")
    } else if (nzchar(ext_dir) && !quiet) {
      message("extdata not writable; skip downloading into extdata for ", fname)
    }

    # B2) fallback: cache (writable)
    res2 <- try_download_to_dir(cache_dir, fname, can_resume = TRUE)
    if (res2$ok) {
      out[i] <- res2$path; if (!quiet) message("Saved to cache: ", res2$path)
    } else {
      out[i] <- NA_character_
      warning("Failed to obtain ", fname, " from all mirrors (extdata", if (tried_ext) "" else " not tried", " and cache).")
    }
  }

  out
}

#' Known geodata files and metadata
#'
#' @return A named list. Each element is a list with fields:
#'   \itemize{
#'     \item \code{path}   File name (same as the element's name)
#'     \item \code{sha256} SHA-256 digest or \code{NA_character_} if unknown
#'   }
#' @keywords internal
#' @noRd
known_files <- function() {
  # TODO: Fill official SHA-256 values when available
  list(
    "China_sheng.rda"         = list(path = "China_sheng.rda",         sha256 = NA_character_),
    "China_shi.rda"           = list(path = "China_shi.rda",           sha256 = NA_character_),
    "China_xian.rda"          = list(path = "China_xian.rda",          sha256 = NA_character_),
    "boundary.rda"            = list(path = "boundary.rda",            sha256 = NA_character_),
    "buffer_line.rda"         = list(path = "buffer_line.rda",         sha256 = NA_character_),
    "China_mask.gpkg"         = list(path = "China_mask.gpkg",         sha256 = NA_character_),
    "world.rda"               = list(path = "world.rda",               sha256 = NA_character_),
    "gebco_2024_China.tif"    = list(path = "gebco_2024_China.tif",    sha256 = NA_character_),
    "vege_1km_projected.tif"  = list(path = "vege_1km_projected.tif",  sha256 = NA_character_)
  )
}
