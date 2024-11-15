#' Plot China Map with Custom Projection
#'
#' A ggplot2 layer to plot China's provincial map with a customizable projection.
#'
#' @param data `sf` object with China's map data, or `NULL` to load the package's default map.
#' @param crs The coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings (e.g., "+proj=merc" for Mercator) or use EPSG codes (e.g., "epsg:4326") to customize the projection.
#' @param color Border color for provinces. Default is "black".
#' @param fill Fill color for provinces. Default is "white".
#' @param size Numeric. The width of the border lines for provinces. Default is `0.5`.
#' @param ... Additional parameters for `geom_sf`.
#' @return A ggplot2 layer of China's provincial boundaries.
#' @source China map data provided by Tianditu, available at \url{https://cloudcenter.tianditu.gov.cn/administrativeDivision}
#' @import ggplot2
#' @importFrom sf st_read st_transform
#' @export
#' @examples
#' \dontrun{
#' # Default map
#' ggplot() +
#'   geom_mapcn()
#'
#' # Load the China provincial map data from the package
#' china_path <- system.file("extdata", "China_sheng.geojson", package = "ggmapcn")
#' china_data <- sf::st_read(china_path, quiet = TRUE)
#'
#' # Use Albers Equal Area Conic projection
#' ggplot() +
#'   geom_mapcn(data=china_data, crs = "+proj=aea +lat_1=25 +lat_2=47 +lon_0=110")+
#'   theme_bw() # Apply a black-and-white theme for a clean look
#' }
#'
geom_mapcn <- function(data = NULL, mapping = aes(), color = "grey", fill = "white", crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs", size = 0.2, ...) {
  library(ggplot2)
  library(sf)

  # Load default China province data if no data is provided
  if (is.null(data)) {
    prov_path <- system.file("extdata", "China_sheng.geojson", package = "ggmapcn")
    data <- sf::st_read(prov_path, quiet = TRUE)
  }

  # Apply the user-specified or default projection
  data <- sf::st_transform(data, crs = crs)

  # Create the ggplot2 layer with specified size
  geom_sf(data = data, mapping = mapping, color = color, fill = fill, size = size, ...)
}
