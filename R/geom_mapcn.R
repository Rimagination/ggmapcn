#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn` provides a flexible interface for visualizing China's administrative boundaries.
#' Users can select administrative levels (province, city, or county), apply custom projections,
#' and filter specific regions.
#'
#' @return A ggplot2 layer for visualizing China's administrative boundaries.
#'
#' @name geom_mapcn
#'
#' @param data An \code{sf} object containing China's map data. If \code{NULL},
#'   the function loads the package's default map. Users can select provincial,
#'   municipal, or county-level maps using the \code{admin_level} parameter.
#' @param admin_level A character string specifying the administrative level of the map.
#'   Options are \code{"province"} (default), \code{"city"}, or \code{"county"}.
#'   The corresponding GeoJSON files (\code{China_sheng.geojson}, \code{China_shi.geojson},
#'   \code{China_xian.geojson}) must be located in the package's \code{extdata} folder.
#' @param crs Coordinate Reference System (CRS). Defaults to
#'   \code{"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"}.
#'   Users can specify other CRS strings (e.g., \code{"EPSG:4326"}).
#' @param color Border color. Default is \code{"black"}.
#' @param fill Fill color. Default is \code{"white"}.
#' @param linewidth Line width for borders. Default is \code{0.5}.
#' @param filter_attribute Column name for filtering regions (e.g., \code{"name_en"}).
#' @param filter Character vector of values to filter specific regions (e.g., \code{c("Beijing", "Shanghai")}).
#' @param ... Additional parameters passed to \code{geom_sf}.
#'
#' @examples
#' # Plot provincial map
#' ggplot() +
#'   geom_mapcn() +
#'   theme_minimal()
#'
#' # Filter specific provinces
#' ggplot() +
#'   geom_mapcn(filter_attribute = "name_en", filter = c("Beijing", "Shanghai"), fill = "red") +
#'   theme_minimal()
#'
#' # Use a Mercator projection
#' ggplot() +
#'   geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
#'   theme_minimal()
#'
#' @import ggplot2
#' @importFrom sf st_read st_transform st_crs
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
  # Load map data if not provided
  if (is.null(data)) {
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.geojson",
      "city" = "China_shi.geojson",
      "county" = "China_xian.geojson",
      stop("Invalid admin_level. Choose from 'province', 'city', or 'county'.")
    )
    file_path <- system.file("extdata", file_name, package = "ggmapcn")
    if (file_path == "") {
      stop(paste("Map file", file_name, "not found in extdata folder."))
    }
    data <- sf::st_read(file_path, quiet = TRUE)
  }

  # Ensure data is an sf object
  if (!inherits(data, "sf")) {
    stop("The input 'data' must be an sf object.")
  }

  # Validate filtering
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% colnames(data))) {
      stop(paste0("The filter_attribute '", filter_attribute, "' does not exist in the data."))
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
  }

  # Transform CRS if necessary
  if (sf::st_crs(data)$input != crs) {
    data <- sf::st_transform(data, crs = crs)
  }

  # Create ggplot layer
  geom_sf(data = data, color = color, fill = fill, linewidth = linewidth, ...)
}
