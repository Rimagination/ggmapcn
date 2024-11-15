#' Plot Buffered Layers for China's Boundary
#'
#' This function creates a ggplot2 layer for displaying buffered areas around China's boundaries,
#' including both the mainland boundary and the ten-segment line. Buffers with user-defined distances
#' are generated around each boundary, providing flexibility in projection and appearance.
#'
#' @param mainland_dist Numeric. The buffer distance (in meters) for the mainland boundary.
#' @param ten_line_dist Numeric. The buffer distance (in meters) for each segment of the ten-segment line.
#'   If not specified, it defaults to the same value as `mainland_dist`.
#' @param crs Character. The coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings to customize the projection (e.g., "+proj=merc" for Mercator).
#' @param color Character. The border color for the buffer area. Default is `NA` (transparent).
#' @param fill Character. The fill color for the buffer area. Default is `"#D2D5EB"`.
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @return A ggplot2 layer displaying buffered areas around China's boundaries,
#'   with customizable buffer distances for the mainland boundary and the ten-segment line,
#'   using the specified projection.
#'
#' @examples
#' \dontrun{
#' # Plot buffers with specified distances for mainland and ten-segment line
#' ggplot() +
#'   geom_buffer_cn(
#'     mainland_dist = 10000,
#'     ten_line_dist = 5000
#'   ) +
#'   theme_minimal()
#' }
#' @import ggplot2
#' @importFrom sf st_read st_transform st_buffer st_as_sf st_geometry
#' @export
geom_buffer_cn <- function(mainland_dist = 20000,
                           ten_line_dist = NULL,
                           crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
                           color = NA,
                           fill = "#D2D5EB",
                           ...) {

  # Direction vector: alternate directions for each ten-segment line
  ten_line_direction <- c(1, -1, -1, -1, -1, -1, 1, 1, 1, 1)

  # If ten_line_dist is NULL, set it equal to mainland_dist
  if (is.null(ten_line_dist)) {
    ten_line_dist <- mainland_dist
  }

  # Load the boundary data
  file_path <- system.file("extdata", "buffer_line.geojson", package = "ggmapcn")
  data <- sf::st_read(file_path, quiet = TRUE)

  # Apply specified or default projection
  data <- sf::st_transform(data, crs = crs)

  # Create buffer for mainland boundary
  mainland_buffer <- sf::st_buffer(data[data$name == "mainland", ], dist = mainland_dist)

  # Apply buffer to each segment of the ten-segment line using specified distances and directions
  ten_segment_buffers <- mapply(function(line, dir) {
    sf::st_buffer(line, dist = ten_line_dist * dir, singleSide = TRUE)
  }, split(data[data$name == "ten_segment_line", ], seq_len(nrow(data[data$name == "ten_segment_line", ]))),
  ten_line_direction, SIMPLIFY = FALSE)

  # Combine ten-segment line buffers into an sf object
  ten_segment_buffers <- do.call(rbind, ten_segment_buffers)

  # Set name attribute for ten-segment buffers
  ten_segment_buffers$name <- "ten_segment_buffer"

  # Convert mainland buffer to sf with name attribute
  mainland_buffer <- sf::st_as_sf(data.frame(name = "mainland_buffer", geometry = sf::st_geometry(mainland_buffer)))

  # Combine mainland and ten-segment buffers
  buffer_data <- rbind(mainland_buffer, ten_segment_buffers)

  # Return ggplot2 layer
  geom_sf(data = buffer_data, color = color, fill = fill, ...)
}
