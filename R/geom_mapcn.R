#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn()` draws China's administrative units with a simple, opinionated
#' interface. When `data` is `NULL`, it loads packaged map data for the requested
#' administrative level, optionally applies attribute-based filtering, removes
#' internal clipping rows, and reprojects the layer to the target CRS.
#'
#' In typical use, `geom_mapcn()` is combined with `geom_boundary_cn()` to draw
#' coastlines, national borders, and other boundary features on top of the
#' administrative polygons.
#'
#' @details
#' If `data` is `NULL`, `geom_mapcn()` selects one of the packaged datasets:
#'
#' * `admin_level = "province"` → `China_sheng.rda`
#' * `admin_level = "city"`     → `China_shi.rda`
#' * `admin_level = "county"`   → `China_xian.rda`
#'
#' The file is ensured to exist locally via `check_geodata()`, which may reuse
#' an existing copy in the package `extdata` directory or user cache, or download
#' it from the external repository when necessary. The `.rda` file is then
#' loaded from the resolved path, and the main `sf` object is extracted.
#'
#' A special row labelled `"Boundary Line"` (used for technical clipping) is
#' removed automatically when present. Attribute-based filtering can be applied
#' using `filter_attribute` and `filter` before reprojecting to the target CRS.
#'
#' @param data An `sf` object with geometries to draw. If `NULL`, the function
#'   loads the packaged dataset corresponding to `admin_level`.
#' @param admin_level Administrative level to plot. One of `"province"`
#'   (default), `"city"`, or `"county"`. These map to packaged files
#'   `China_sheng.rda`, `China_shi.rda`, and `China_xian.rda`, respectively.
#' @param crs Coordinate reference system used for plotting. Defaults to an
#'   azimuthal equidistant projection centered on China:
#'   `"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"`.
#'   Accepts PROJ strings or EPSG codes (e.g., `"EPSG:4326"`).
#' @param color Border color for polygons. Default `"black"`.
#' @param fill Fill color for polygons. Default `"white"`.
#' @param linewidth Border line width. Default `0.1`. For older `ggplot2`
#'   versions, use `size` instead of `linewidth`.
#' @param filter_attribute Optional name of an attribute column used to filter
#'   features (e.g., `"name_en"`).
#' @param filter Optional character vector of values to keep in
#'   `filter_attribute` (e.g., `c("Beijing", "Shanghai")`). If supplied together
#'   with `filter_attribute`, features are subsetted accordingly. If no features
#'   remain after filtering, an error is thrown.
#' @param mapping Optional aesthetics mapping passed to `ggplot2::geom_sf()`.
#'   This is useful when additional aesthetics (e.g., `fill`) should be mapped
#'   from columns in `data`.
#' @param ... Additional arguments forwarded to `ggplot2::geom_sf()`.
#'
#' @return
#' A `ggplot2` layer that can be added to a plot.
#'
#' @examples
#' # 1. Basic provincial map (recommended: combine with geom_boundary_cn)
#' ggplot() +
#'   geom_mapcn() +
#'   geom_boundary_cn() +
#'   theme_minimal()
#'
#' # 2. City-level map with custom fill and boundaries
#' ggplot() +
#'   geom_mapcn(
#'     admin_level = "city",
#'     fill = "grey95",
#'     color = "grey60"
#'   ) +
#'   geom_boundary_cn(province_color = "grey40") +
#'   theme_bw()
#'
#' # 3. Filter by attribute (e.g., English names) and highlight selected provinces
#' ggplot() +
#'   geom_mapcn(
#'     filter_attribute = "name_en",
#'     filter = c("Beijing", "Shanghai"),
#'     fill = "tomato"
#'   ) +
#'   geom_boundary_cn() +
#'   theme_minimal()
#'
#' # 4. Use a different projection (e.g., Albers equal-area)
#' albers_cn <- "+proj=aea +lat_1=25 +lat_2=47 +lat_0=0 +lon_0=105 +datum=WGS84"
#'
#' ggplot() +
#'   geom_mapcn(crs = albers_cn, linewidth = 0.3) +
#'   geom_boundary_cn(crs = albers_cn) +
#'   coord_sf(crs = albers_cn) +
#'   theme_minimal()
#'
#' @importFrom sf st_crs st_transform
#' @importFrom dplyr filter
#' @importFrom rlang sym
#' @export
geom_mapcn <- function(
    data = NULL,
    admin_level = "province",
    crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
    color = "black",
    fill = "white",
    linewidth = 0.1,
    filter_attribute = NULL,
    filter = NULL,
    mapping = NULL,
    ...
) {
  # 1) Load packaged data when `data` is NULL --------------------------------
  if (is.null(data)) {
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.rda",
      "city"     = "China_shi.rda",
      "county"   = "China_xian.rda",
      stop("Invalid `admin_level`. Choose one of 'province', 'city', or 'county'.")
    )

    # Ensure the file is available locally (may download or reuse extdata/cache)
    paths <- check_geodata(files = file_name, quiet = TRUE)

    if (is.na(paths[1])) {
      stop(
        "Failed to obtain '", file_name, "'. ",
        "The file could not be found locally or downloaded. ",
        "If you are working in a restricted network environment, ",
        "please download the file manually from the ggmapcn data repository ",
        "and place it in one of the directories searched by `check_geodata()`."
      )
    }

    file_path <- paths[1]

    # Load the .rda into a clean environment and extract the main sf object
    env <- new.env(parent = emptyenv())
    base::load(file_path, envir = env)

    # By convention, use the file stem as object name
    obj_name <- sub("\\.rda$", "", basename(file_name))
    obj_names <- ls(envir = env, all.names = TRUE)

    if (obj_name %in% obj_names) {
      obj <- get(obj_name, envir = env, inherits = FALSE)
    } else if (length(obj_names) == 1L) {
      # Fallback: single object in the file
      obj <- get(obj_names[1L], envir = env, inherits = FALSE)
    } else {
      stop(
        "Could not determine the map object inside '", file_name, "'. ",
        "Expected an object named '", obj_name, "'."
      )
    }

    if (!inherits(obj, "sf")) {
      stop(
        "Object loaded from '", file_name,
        "' is not an 'sf' object."
      )
    }

    data <- obj
  }

  # 2) Basic type check ------------------------------------------------------
  if (!inherits(data, "sf")) {
    stop(
      "The input `data` must be an 'sf' object ",
      "(or leave it NULL to use the packaged map data)."
    )
  }

  # 3) Drop the special \"Boundary Line\" row if present ---------------------
  drop_idx <- rep(FALSE, nrow(data))
  if ("name_en" %in% names(data)) {
    drop_idx <- drop_idx | (toupper(data$name_en) == "BOUNDARY LINE")
  }
  if ("name" %in% names(data)) {
    drop_idx <- drop_idx | (toupper(data$name) == "BOUNDARY LINE")
  }
  if (any(drop_idx)) {
    data <- data[!drop_idx, , drop = FALSE]
  }

  # 4) Attribute-based filtering --------------------------------------------
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% names(data))) {
      stop(sprintf("Column '%s' not found in data.", filter_attribute))
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
    if (nrow(data) == 0L) {
      stop("No features matched the provided filter; nothing to plot.")
    }
  }

  # 5) Reproject if necessary (guard against missing CRS) --------------------
  data_crs <- try(sf::st_crs(data), silent = TRUE)
  needs_transform <- !inherits(data_crs, "try-error") &&
    !is.null(data_crs) &&
    !is.null(data_crs$input) &&
    !identical(data_crs$input, crs)

  if (isTRUE(needs_transform)) {
    data <- sf::st_transform(data, crs = crs)
  }

  # 6) Build geom_sf layer ---------------------------------------------------
  ggplot2::geom_sf(
    data    = data,
    mapping = mapping,
    color   = color,
    fill    = fill,
    linewidth = linewidth,
    ...
  )
}
