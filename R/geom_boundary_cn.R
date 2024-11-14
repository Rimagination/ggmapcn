#' Plot Boundaries of China
#'
#' Draws various types of boundaries for China, including mainland boundaries, coastlines, ten-segment line, special administrative region (SAR) boundaries, and undefined boundaries. Each boundary type can be customized in terms of color, line width, and line type.
#'
#' @param crs Character. Coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings to customize the projection (e.g., "+proj=merc" for Mercator).
#' @param mainland_color Character. Color for the mainland boundary. Default is "black".
#' @param mainland_size Numeric. Line width for the mainland boundary. Default is `0.5`.
#' @param mainland_linetype Character. Line type for the mainland boundary. Default is `"solid"`.
#' @param coastline_color Character. Color for the coastline. Default is "blue".
#' @param coastline_size Numeric. Line width for the coastline. Default is `0.3`.
#' @param coastline_linetype Character. Line type for the coastline. Default is `"solid"`.
#' @param ten_segment_line_color Character. Color for the ten-segment line. Default is `"black"`.
#' @param ten_segment_line_size Numeric. Line width for the ten-segment line. Default is `0.5`.
#' @param ten_segment_line_linetype Character. Line type for the ten-segment line. Default is `"solid"`.
#' @param SAR_boundary_color Character. Color for the SAR boundary. Default is `"grey"`.
#' @param SAR_boundary_size Numeric. Line width for the SAR boundary. Default is `0.5`.
#' @param SAR_boundary_linetype Character. Line type for the SAR boundary. Default is `"dashed"`.
#' @param undefined_boundary_color Character. Color for the undefined boundary. Default is `"lightgrey"`.
#' @param undefined_boundary_size Numeric. Line width for the undefined boundary. Default is `0.5`.
#' @param undefined_boundary_linetype Character. Line type for the undefined boundary. Default is `"longdash"`.
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @return A ggplot2 layer displaying China's multi-segment boundaries with the specified styles.
#'
#' @examples
#' \dontrun{
#' # Plot China's boundaries with default settings
#' ggplot() +
#'   geom_boundary_cn() +
#'   theme_minimal()
#' }
#' @importFrom sf st_read st_transform
#' @export
geom_boundary_cn <- function(
    crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
    mainland_color = "black", mainland_size = 0.5, mainland_linetype = "solid",
    coastline_color = "blue", coastline_size = 0.3, coastline_linetype = "solid",
    ten_segment_line_color = "black", ten_segment_line_size = 0.5, ten_segment_line_linetype = "solid",
    SAR_boundary_color = "grey", SAR_boundary_size = 0.5, SAR_boundary_linetype = "dashed",
    undefined_boundary_color = "black", undefined_boundary_size = 0.5, undefined_boundary_linetype = "longdash",
    ...) {

  # Load the boundary data
  file_path <- system.file("extdata", "boundary.geojson", package = "ggmapcn")
  boundary <- st_read(file_path, quiet = TRUE)

  # Apply the specified projection
  boundary <- st_transform(boundary, crs = crs)

  # Split the data into different types based on the name attribute
  mainland <- boundary[boundary$name == "mainland", ]
  coastline <- boundary[boundary$name == "coastline", ]
  ten_segment_line <- boundary[boundary$name == "ten_segment_line", ]
  SAR_boundary <- boundary[boundary$name == "SAR_boundary", ]
  undefined_boundary <- boundary[boundary$name == "undefined_boundary", ]

  # Create ggplot layers for each boundary type with specified styles
  list(
    geom_sf(data = mainland, color = mainland_color, size = mainland_size, linetype = mainland_linetype, ...),
    geom_sf(data = coastline, color = coastline_color, size = coastline_size, linetype = coastline_linetype, ...),
    geom_sf(data = ten_segment_line, color = ten_segment_line_color, size = ten_segment_line_size, linetype = ten_segment_line_linetype, ...),
    geom_sf(data = SAR_boundary, color = SAR_boundary_color, size = SAR_boundary_size, linetype = SAR_boundary_linetype, ...),
    geom_sf(data = undefined_boundary, color = undefined_boundary_color, size = undefined_boundary_size, linetype = undefined_boundary_linetype, ...)
  )
}
