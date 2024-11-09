#' Plot Buffered Layers for China's Border
#'
#' A ggplot2 layer for creating buffered areas around China's border, including
#' both the mainland border and the ten-dash line. Generates a buffer with a specified distance
#' around the border.
#'
#' @param mainland_dist Numeric. The buffer distance (in meters) for the mainland border.
#'   The buffer distance for the ten-dash line will be half of this value.
#' @param crs Character. The coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings to customize the projection (e.g., "+proj=merc" for Mercator).
#' @param color Character. The color for the border of the buffer area. Default is `NA` (transparent).
#' @param fill Character. The fill color for the buffer area. Default is `"#D2D5EB"`.
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @return A ggplot2 layer displaying buffered areas around China's border,
#'   with the ten-dash line buffer at half the mainland buffer distance,
#'   using the specified projection.
#'
#' @examples
#' \dontrun{
#' # Plot buffers using geom_buffer_cn with default data and projection
#' ggplot2::ggplot() +
#'   geom_buffer_cn(
#'     mainland_dist = 10000
#'   ) +
#'   theme_minimal()
#'
#' # Plot with a custom projection (Mercator)
#' ggplot2::ggplot() +
#'   geom_buffer_cn(
#'     mainland_dist = 10000,
#'     fill="#BBB3D8",
#'     crs = "+proj=merc"
#'   ) +
#'   theme_minimal()
#' }
#' @import ggplot2
#' @importFrom sf st_read st_transform
#' @export
geom_buffer_cn <- function(mainland_dist = 20000, crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs", color = NA, fill = "#D2D5EB", ...) {
  library(sf)

  # Load the default buffer data
  file_path <- system.file("extdata", "buffer_line.geojson", package = "ggmapcn")
  data <- st_read(file_path, quiet = TRUE)

  # Apply the specified or default projection
  data <- st_transform(data, crs = crs)

  # Create buffers for mainland border and ten-dash line
  mainland_buffer <- st_buffer(data[data$name == "mainland_line", ], dist = mainland_dist)
  dashline_buffer <- st_buffer(data[data$name == "10_dashline", ], dist = mainland_dist / 2)

  # Convert to sf objects and add geometry column
  mainland_buffer <- st_as_sf(data.frame(name = "mainland_buffer", geometry = st_geometry(mainland_buffer)))
  dashline_buffer <- st_as_sf(data.frame(name = "dashline_buffer", geometry = st_geometry(dashline_buffer)))

  # Combine buffers
  buffer_data <- rbind(mainland_buffer, dashline_buffer)

  # Return ggplot2 layer
  geom_sf(data = buffer_data, color = color, fill = fill, ...)
}
