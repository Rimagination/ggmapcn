#' Plot China Map with Custom Projection
#'
#' A ggplot2 layer to plot China's provincial map with a customizable projection.
#'
#' @param data `sf` object with China's map data, or `NULL` to load the package's default map.
#' @param mapping Aesthetic mappings from ggplot2.
#' @param color Border color for provinces. Default is "black".
#' @param fill Fill color for provinces. Default is "#ffff99".
#' @param crs Coordinate reference system (CRS) for the projection. Default is
#' "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs". Use other CRS strings to customize.
#' @param size Numeric. The width of the border lines for provinces. Default is `0.5`.
#' @param ... Additional parameters for `geom_sf`.
#' @return A ggplot2 layer of China's provincial boundaries.
#' @source China map data provided by Tianditu, available at \url{https://cloudcenter.tianditu.gov.cn/administrativeDivision}
#' @import ggplot2
#' @importFrom sf st_read st_transform
#' @export
#' @examples
#' \dontrun{
#' # Default China map
#' ggplot2::ggplot() + geom_mapcn()
#'
#' # Load package data explicitly and use custom projection
#' china_path <- system.file("extdata", "China_sheng.geojson", package = "ggmapcn")
#' china_data <- st_read(china_path, quiet = TRUE)
#' ggplot2::ggplot() + geom_mapcn(data = china_data, crs = "+proj=merc", size = 0.7)
#' }
geom_mapcn <- function(data = NULL, mapping = aes(), color = "grey", fill = "#ffff99", crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs", size = 0.2, ...) {
  library(ggplot2)
  library(sf)

  # Load default China province data if no data is provided
  if (is.null(data)) {
    prov_path <- system.file("extdata", "China_sheng.geojson", package = "ggmapcn")
    data <- st_read(prov_path, quiet = TRUE)
  }

  # Apply the user-specified or default projection
  data <- st_transform(data, crs = crs)

  # Create the ggplot2 layer with specified size
  geom_sf(data = data, mapping = mapping, color = color, fill = fill, size = size, ...)
}
