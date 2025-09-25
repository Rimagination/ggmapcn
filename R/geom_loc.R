#' @title Visualize Spatial Point Data
#'
#' @description
#' `geom_loc` is a wrapper around \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}} designed
#' for visualizing spatial point data. It supports both \code{sf} objects and tabular data frames
#' with longitude and latitude columns, automatically transforming them into the specified
#' coordinate reference system (CRS).
#'
#' @return A ggplot2 layer for visualizing spatial point data, either from an `sf` object or a tabular data frame
#'   with longitude and latitude columns, after transforming the data to the specified coordinate reference system (CRS).
#'
#' @family ggplot2.utils
#'
#' @name geom_loc
#'
#' @param data A data frame, tibble, or \code{sf} object containing spatial point data.
#' @param lon A character string. The name of the longitude column in \code{data}
#'   (required if \code{data} is tabular).
#' @param lat A character string. The name of the latitude column in \code{data}
#'   (required if \code{data} is tabular).
#' @param crs A character string. The target coordinate reference system (CRS) for the data.
#'   Defaults to \code{"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"}.
#' @param mapping Aesthetic mappings created by \code{\link[ggplot2:aes]{ggplot2::aes()}},
#'   such as \code{color} or \code{size}.
#' @param ... Additional parameters passed to \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}},
#'   such as \code{size}, \code{alpha}, or \code{color}.
#'
#' @details
#' This function simplifies the process of visualizing spatial data in ggplot2 by automatically
#' handling CRS transformations and providing an interface for both \code{sf} and tabular data.
#' If the input is a tabular data frame, it will be converted to an \code{sf} object using the
#' specified longitude and latitude columns.
#'
#' See \code{\link[ggplot2:geom_sf]{ggplot2::geom_sf()}} for details on additional parameters
#' and aesthetics.
#'
#' @seealso
#' \code{\link[ggmapcn]{geom_boundary_cn}}
#'
#' @examples
#' # Generate a random dataset with latitude and longitude
#' set.seed(123)
#' data_sim <- data.frame(
#'   Longitude = runif(100, 80, 120),
#'   Latitude = runif(100, 28, 40),
#'   Category = sample(c("Type A", "Type B", "Type C"), 100, replace = TRUE)
#' )
#'
#' # Visualize the data with China's boundaries
#' ggplot() +
#'   geom_boundary_cn() +
#'   geom_loc(
#'     data = data_sim, lon = "Longitude", lat = "Latitude",
#'     mapping = aes(color = Category), size = 1, alpha = 0.7
#'   ) +
#'   theme_minimal()
#'
#' @export
geom_loc <- function(data, lon = NULL, lat = NULL,
                     crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
                     mapping = ggplot2::aes(), ...) {

  # Convert tabular data to sf if necessary
  if (!inherits(data, "sf")) {
    if (is.null(lon) || is.null(lat)) {
      stop("Both 'lon' and 'lat' must be specified for tabular data.")
    }
    data <- sf::st_as_sf(data, coords = c(lon, lat), crs = 4326, remove = FALSE)
  }

  # Transform data to the specified CRS
  data <- sf::st_transform(data, crs = crs)

  # Plot as an sf layer with specified mapping
  ggplot2::geom_sf(data = data, mapping = mapping, ...)
}
