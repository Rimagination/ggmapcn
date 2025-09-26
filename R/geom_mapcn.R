#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn()` plots China's administrative boundaries with a simple,
#' opinionated interface. It loads packaged map data when `data` is `NULL`,
#' removes the special row labeled `"Boundary Line"`, supports optional
#' attribute-based filtering, and can reproject to a user-specified CRS.
#'
#' @param data An `sf` object of geometries to draw. If `NULL`, the function
#'   loads the packaged dataset for the chosen `admin_level`.
#' @param admin_level Administrative level to plot. One of `"province"`
#'   (default), `"city"`, or `"county"`. These correspond to packaged
#'   files `China_sheng.rda`, `China_shi.rda`, and `China_xian.rda`.
#' @param crs Coordinate Reference System to use for plotting. Defaults to an
#'   Azimuthal Equidistant projection centered on China:
#'   `"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"`.
#'   Accepts proj strings or EPSG codes (e.g., `"EPSG:4326"`).
#' @param color Border color. Default `"black"`.
#' @param fill Fill color. Default `"white"`.
#' @param linewidth Border line width. Default `0.5`.
#'   For older `ggplot2` versions, use `size` instead of `linewidth`.
#' @param filter_attribute Optional column name used to filter features
#'   (e.g., `"name_en"`).
#' @param filter Optional character vector of values to keep (e.g.,
#'   `c("Beijing","Shanghai")`). If supplied with `filter_attribute`,
#'   features are filtered accordingly. If the result is empty, an error
#'   is thrown.
#' @param mapping Optional aesthetics mapping passed to `geom_sf()`.
#'   Useful when you already have aesthetics to apply (e.g., fill).
#' @param ... Additional arguments forwarded to `ggplot2::geom_sf()`.
#'
#' @return A `ggplot2` layer.
#'
#' @examples
#' # Basic provincial map
#' ggplot2::ggplot() +
#'   geom_mapcn() +
#'   ggplot2::theme_minimal()
#'
#' # Filter by names stored in the data (e.g., English names)
#' ggplot2::ggplot() +
#'   geom_mapcn(filter_attribute = "name_en",
#'              filter = c("Beijing", "Shanghai"),
#'              fill = "red") +
#'   ggplot2::theme_minimal()
#'
#' # Use a different projection
#' ggplot2::ggplot() +
#'   geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
#'   ggplot2::theme_minimal()
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
    linewidth = 0.5,
    filter_attribute = NULL,
    filter = NULL,
    mapping = NULL,
    ...
) {
  # Select the packaged file if data is not supplied
  if (is.null(data)) {
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.rda",
      "city"     = "China_shi.rda",
      "county"   = "China_xian.rda",
      stop("Invalid `admin_level`. Choose one of 'province', 'city', or 'county'.")
    )
    # Ensure the file is available locally (download if missing)
    check_geodata(files = file_name, quiet = TRUE)
    # Load the file into an sf object
    data <- load_map_data(file_name, package = "ggmapcn")
  }

  # Must be sf
  if (!inherits(data, "sf")) {
    stop("The input `data` must be an 'sf' object (or leave it NULL to use packaged data).")
  }

  # Drop the special "Boundary Line" row if present
  drop_idx <- rep(FALSE, nrow(data))
  if ("name_en" %in% names(data)) drop_idx <- drop_idx | (toupper(data$name_en) == "BOUNDARY LINE")
  if ("name"    %in% names(data)) drop_idx <- drop_idx | (toupper(data$name)    == "BOUNDARY LINE")
  if (any(drop_idx)) data <- data[!drop_idx, , drop = FALSE]

  # Attribute-based filtering
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% names(data))) {
      stop(sprintf("Column '%s' not found in data.", filter_attribute))
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
    if (nrow(data) == 0) {
      stop("No features matched the provided filter; nothing to plot.")
    }
  }

  # Reproject if necessary (guard against missing CRS)
  data_crs <- try(sf::st_crs(data), silent = TRUE)
  needs_transform <- !inherits(data_crs, "try-error") &&
    !is.null(data_crs) &&
    !is.null(data_crs$input) &&
    !identical(data_crs$input, crs)
  if (isTRUE(needs_transform)) {
    data <- sf::st_transform(data, crs = crs)
  }

  ggplot2::geom_sf(
    data = data,
    mapping = mapping,
    color = color,
    fill = fill,
    linewidth = linewidth,
    ...
  )
}

# ---- Internal helper (not exported, not documented) -------------------------

#' Load a packaged `.rda` map from inst/extdata (internal)
#'
#' @param file_name Name of the `.rda` file (e.g., "China_sheng.rda").
#' @param package   Package name; defaults to "ggmapcn".
#' @return An `sf` object loaded from the `.rda` file.
#' @keywords internal
#' @noRd
load_map_data <- function(file_name, package = "ggmapcn") {
  file_path <- system.file("extdata", file_name, package = package)
  if (identical(file_path, "")) {
    stop(sprintf("Map file '%s' not found in the package extdata.", file_name))
  }

  env <- new.env(parent = emptyenv())
  base::load(file_path, envir = env)

  obj_name <- sub("\\.rda$", "", file_name)
  if (!exists(obj_name, envir = env, inherits = FALSE)) {
    stop(sprintf("Object '%s' not found inside '%s'.", obj_name, file_name))
  }

  obj <- get(obj_name, envir = env, inherits = FALSE)
  if (!inherits(obj, "sf")) {
    stop(sprintf("Object '%s' in '%s' is not an 'sf' object.", obj_name, file_name))
  }
  obj
}
