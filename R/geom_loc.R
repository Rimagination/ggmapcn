#' Add Spatial Point Data Layer with Color by Grouping
#'
#' `geom_loc` is a flexible function that adds spatial data to a ggplot, supporting both `sf` and tabular data frames.
#' It allows color mapping based on a grouping variable in the data.
#'
#' @param data A data frame, tibble, or `sf` object.
#' @param lon Character. The name of the longitude column in `data` (required if `data` is tabular).
#' @param lat Character. The name of the latitude column in `data` (required if `data` is tabular).
#' @param crs Character. Coordinate reference system (CRS) to which the data should be transformed. Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#' @param mapping Aesthetic mappings created by `aes()`, such as `color`.
#' @param ... Additional aesthetic mappings passed to `geom_sf`, such as `size`, `alpha`.
#'
#' @return A ggplot layer displaying spatial data as points in the specified CRS.
#'
#' @examples
#' # Example with tabular data from the package
#' data(pollen) # Load the example data provided by the package
#' ggplot() +
#'   geom_loc(
#'     data = pollen, lon = "Longitude", lat = "Latitude",
#'     mapping = aes(color = `Sample type`), size = 1, alpha = 0.7
#'   ) +
#'   labs(title = "Sample Points on Map")
#'
#' @export
geom_loc <- function(data, lon = NULL, lat = NULL,
                     crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
                     mapping = aes(), ...) {
  library(sf)

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
  geom_sf(data = data, mapping = mapping, ...)
}
