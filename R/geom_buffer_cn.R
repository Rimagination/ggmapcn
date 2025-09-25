#' Plot Buffered Layers for China's Boundary
#'
#' Creates a ggplot2 layer for displaying buffered areas around China's boundaries,
#' including both the mainland boundary and the ten-segment line. Buffers with user-defined distances
#' are generated around each boundary, providing flexibility in projection and appearance.
#'
#' @param mainland_dist Numeric. The buffer distance (in meters) for the mainland boundary.
#' @param ten_line_dist Numeric. The buffer distance (in meters) for each segment of the ten-segment line.
#'   If not specified, it defaults to the same value as `mainland_dist`.
#' @param crs Character. The coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings (e.g., "+proj=merc" for Mercator).
#' @param color Character. The border color for the buffer area. Default is `NA` (transparent).
#' @param fill Character. The fill color for the buffer area. Default is `"#D2D5EB"`.
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @return A ggplot2 layer displaying buffered areas around China's boundaries,
#'   with customizable buffer distances for the mainland boundary and the ten-segment line,
#'   using the specified projection.
#'
#' @examples
#' \donttest{
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

  # Required files based on admin_level
  required_files <- c("buffer_line.rda", "China_mask.gpkg")

  # Ensure required geospatial data is available
  check_geodata(files = required_files, quiet = TRUE)

  # Direction vector: alternate directions for each ten-segment line
  ten_line_direction <- c(1, -1, -1, -1, -1, -1, 1, 1, 1, 1)

  # If ten_line_dist is NULL, set it equal to mainland_dist
  if (is.null(ten_line_dist)) {
    ten_line_dist <- mainland_dist
  }

  # Load the .rda file (this file contains the buffer data)
  file_path <- system.file("extdata", "buffer_line.rda", package = "ggmapcn")

  # Check if the file path is valid
  if (file_path == "") {
    stop("Map file 'buffer_line.rda' not found in extdata folder.")
  }

  # Load the .rda file containing the geospatial data
  load(file_path)

  # Dynamically generate the object name based on the .rda file name
  object_name <- gsub("\\.rda$", "", basename(file_path))  # Get object name by stripping ".rda"

  # Check if the object exists in the environment
  if (!exists(object_name)) {
    stop(paste("The object", object_name, "was not found in the .rda file."))
  }

  # Retrieve the object from the environment
  data <- get(object_name)

  # Ensure the object is of class 'sf'
  if (!inherits(data, "sf")) {
    stop("The loaded object is not an 'sf' object. Please check the .rda file.")
  }

  # Apply specified or default projection
  data <- sf::st_transform(data, crs = crs)

  # Create buffer for mainland boundary (outward buffer)
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

  # Load the China boundary (mask) data from China_mask.gpkg
  china_mask_path <- system.file("extdata", "China_mask.gpkg", package = "ggmapcn")
  if (china_mask_path == "") {
    stop("China mask file 'China_mask.gpkg' not found in extdata folder.")
  }
  china_mask <- sf::st_read(china_mask_path, quiet = TRUE)

  # Ensure CRS of China mask matches the buffer data CRS
  china_mask <- sf::st_transform(china_mask, crs)

  # Use st_difference to remove the inner buffer areas (inside China boundaries)
  buffer_data_masked <- sf::st_difference(buffer_data, china_mask)

  # Use st_geometry to extract only the geometry from the sf object
  buffer_data_masked <- sf::st_geometry(buffer_data_masked)

  # Return ggplot2 layer
  ggplot2::geom_sf(data = buffer_data_masked, color = color, fill = fill, ...)
}
