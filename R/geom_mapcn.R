#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn` is a wrapper around \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}} designed
#' to visualize China's administrative boundaries with additional features such as filtering
#' and support for custom projections.
#'
#' @return A \pkg{ggplot2} layer for visualizing China's administrative boundaries.
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
#' @param crs A character string specifying the target coordinate reference system (CRS).
#'   Defaults to \code{"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"}.
#'   Users can specify other CRS strings or EPSG codes (e.g., \code{"EPSG:4326"}).
#' @param color A character string specifying the border color. Default is \code{"black"}.
#' @param fill A character string specifying the fill color. Default is \code{"white"}.
#' @param linewidth A numeric value specifying the line width for borders. Default is \code{0.5}.
#' @param filter_attribute A character string specifying the column name to use for filtering administrative regions.
#'   For example, use \code{"name_en"} for filtering by English province names. Default is \code{NULL}, meaning no filtering is applied.
#' @param filter A character vector specifying the values to filter specific regions.
#'   For example, use \code{filter = c("Beijing", "Shanghai")} to visualize these regions only.
#'   Default is \code{NULL}, meaning no filtering is applied.
#' @param ... Additional parameters passed to \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}}, such as \code{alpha}.
#'
#' @details
#' This function simplifies the process of visualizing China's administrative boundaries
#' with customizable projections, filtering, and flexible aesthetics. Users can:
#' - Select administrative levels (province, city, county) via the \code{admin_level} parameter.
#' - Filter specific regions using \code{filter_attribute} and \code{filter}.
#' - Apply custom projections and styling options.
#'
#' See \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}} for details on additional parameters and aesthetics.
#'
#' @seealso
#' \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}}, \code{\link[sf:st_transform]{sf::st_transform()}},
#' \code{\link[sf:st_read]{sf::st_read()}}
#'
#' @examples
#' # Plot the default provincial map
#' ggplot() +
#'   geom_mapcn() +
#'   theme_minimal()
#'
#' # Use the municipal-level map
#' ggplot() +
#'   geom_mapcn(admin_level = "city", color = "blue", fill = "lightblue") +
#'   theme_minimal()
#'
#' # Filter to display only specific provinces
#' ggplot() +
#'   geom_mapcn(filter_attribute = "name_en", filter = c("Beijing", "Shanghai"), fill = "red") +
#'   theme_minimal()
#'
#' # Apply a Mercator projection
#' ggplot() +
#'   geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
#'   theme_minimal()
#'
#' @import ggplot2
#' @importFrom sf st_read st_transform
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
  library(ggplot2)
  library(sf)
  library(dplyr)
  library(rlang)

  # Load the appropriate map data based on admin_level
  if (is.null(data)) {
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.geojson",
      "city" = "China_shi.geojson",
      "county" = "China_xian.geojson",
      stop("Invalid admin_level. Choose from 'province', 'city', or 'county'.")
    )
    file_path <- system.file("extdata", file_name, package = "ggmapcn")
    data <- sf::st_read(file_path, quiet = TRUE)
  }

  # Ensure the input data is an sf object
  if (!inherits(data, "sf")) {
    stop("The input 'data' must be an sf object.")
  }

  # Apply filtering if specified
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% colnames(data))) {
      stop(paste0("The filter_attribute '", filter_attribute, "' does not exist in the data."))
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
  }

  # Apply the user-specified or default projection
  if (sf::st_crs(data)$input != crs) {
    data <- sf::st_transform(data, crs = crs)
  }

  # Create the ggplot2 layer
  plot <- geom_sf(data = data, color = color, fill = fill, linewidth = linewidth, ...)

  return(plot)
}
