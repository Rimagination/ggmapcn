#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn()` provides a flexible interface for visualizing China's
#' administrative boundaries. Users can select administrative levels
#' (province, city, or county), apply custom projections, and filter specific regions.
#'
#' This function automatically loads the packaged map data (`.rda` files in `extdata`)
#' if no input data is provided. A helper function `load_map_data()` ensures
#' correct loading and validation of map files.
#'
#' @param data An `sf` object containing China's map data. If `NULL`, the function
#'   loads the default dataset corresponding to the chosen `admin_level`.
#' @param admin_level Character string specifying administrative level:
#'   `"province"` (default), `"city"`, or `"county"`. Requires
#'   `China_sheng.rda`, `China_shi.rda`, or `China_xian.rda` in `extdata/`.
#' @param crs Coordinate Reference System (CRS). Defaults to an azimuthal
#'   equidistant projection centered on China
#'   (`+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs`).
#'   Accepts proj4 strings or EPSG codes (e.g., `"EPSG:4326"`).
#' @param color Border color. Default: `"black"`.
#' @param fill Fill color. Default: `"white"`.
#' @param linewidth Line width for borders. Default: `0.5`.
#'   Note: use `size` instead of `linewidth` for `ggplot2 < 3.3.0`.
#' @param filter_attribute Column name used for filtering regions (e.g., `"name_en"`).
#' @param filter Character vector of values to filter specific regions
#'   (e.g., `c("Beijing", "Shanghai")`).
#' @param ... Additional parameters passed to `geom_sf()`.
#'
#' @return A `ggplot2` layer object.
#'
#' @examples
#' # Example 1: Plot provincial map (default)
#' ggplot2::ggplot() +
#'   geom_mapcn() +
#'   ggplot2::theme_minimal()
#'
#' # Example 2: Filter specific provinces
#' ggplot2::ggplot() +
#'   geom_mapcn(filter_attribute = "name_en",
#'              filter = c("Beijing", "Shanghai"),
#'              fill = "red") +
#'   ggplot2::theme_minimal()
#'
#' # Example 3: Use a Mercator projection
#' ggplot2::ggplot() +
#'   geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
#'   ggplot2::theme_minimal()
#'
#' @importFrom sf st_transform st_crs
#' @importFrom dplyr filter
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
    ...
) {
  # Ensure required geodata is available
  check_geodata(files = c("China_sheng.rda", "China_shi.rda", "China_xian.rda"),
                quiet = TRUE)

  # Load default data if not provided
  if (is.null(data)) {
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.rda",
      "city"     = "China_shi.rda",
      "county"   = "China_xian.rda",
      stop("Invalid admin_level. Choose from 'province', 'city', or 'county'.")
    )
    data <- load_map_data(file_name, package = "ggmapcn")
  }

  # Validate input
  if (!inherits(data, "sf")) {
    stop("The input 'data' must be an 'sf' object.")
  }

  # Apply filtering if requested
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% colnames(data))) {
      stop("The filter_attribute '", filter_attribute, "' does not exist in the data.")
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
  }

  # Reproject if necessary
  if (sf::st_crs(data)$input != crs) {
    data <- sf::st_transform(data, crs = crs)
  }

  # Return ggplot layer
  ggplot2::geom_sf(
    data = data,
    color = color,
    fill = fill,
    linewidth = linewidth,
    ...
  )
}

#' Load packaged map data safely
#'
#' @description
#' Load a `.rda` map file from the package's `extdata/` into a temporary
#' environment and return the expected `sf` object.
#'
#' @param file_name Character scalar. Name of the `.rda` file
#'   (e.g., `"China_sheng.rda"`).
#' @param package Character scalar. Package name. Default: `"ggmapcn"`.
#'
#' @return An `sf` object from the `.rda` file.
#' @keywords internal
#' @noRd
load_map_data <- function(file_name, package = "ggmapcn") {
  file_path <- system.file("extdata", file_name, package = package)
  if (file_path == "") {
    stop("Map file ", file_name, " not found in package extdata folder.")
  }

  env <- new.env()
  load(file_path, envir = env)

  object_name <- gsub("\\.rda$", "", file_name)
  if (!exists(object_name, envir = env)) {
    stop("The object ", object_name, " was not found inside ", file_name, ".")
  }

  data <- get(object_name, envir = env)
  if (!inherits(data, "sf")) {
    stop("Object ", object_name, " in ", file_name, " is not an 'sf' object.")
  }

  return(data)
}
