#' Plot Mainland Boundary and Coastline for China
#'
#' A ggplot2 layer for plotting China's mainland boundary and coastline with customizable colors and line widths.
#'
#' @param mainland_color Character. The color for the mainland boundary. Default is "black".
#' @param mainland_size Numeric. The line width for the mainland boundary. Default is `0.5`.
#' @param coastline_color Character. The color for the coastline. Default is "skyblue".
#' @param coastline_size Numeric. The line width for the coastline. Default is `0.5`.
#' @param crs Character. The coordinate reference system (CRS) for the projection.
#'   Defaults to "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs".
#'   Users can specify other CRS strings to customize the projection (e.g., "+proj=merc" for Mercator).
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @return A ggplot2 layer displaying China's mainland boundary and coastline with specified styles.
#'
#' @examples
#' \dontrun{
#' # Plot China's boundary with default settings
#' ggplot2::ggplot() +
#'   geom_boundary_cn(
#'     mainland_color = "black",
#'     mainland_size = 0.5,
#'     coastline_color = "#00A0E9",
#'     coastline_size = 0.5
#'   ) +
#'   theme_minimal()
#' }
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 geom_sf
#' @importFrom sf st_read st_transform
#' @export
geom_boundary_cn <- function(mainland_color = "black", mainland_size = 0.5,
                             coastline_color = "skyblue", coastline_size = 0.5,
                             crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs", ...) {
  # Load the boundary data
  file_path <- "inst/extdata/boundary.geojson"  # Replace with your actual path if needed
  boundary <- st_read(file_path, quiet = TRUE)

  # Apply the specified projection
  boundary <- st_transform(boundary, crs = crs)

  # Split the data into mainland and coastline based on the name attribute
  mainland <- boundary[boundary$name == "mainland", ]
  coastline <- boundary[boundary$name == "coastline", ]

  # Create ggplot layers for mainland and coastline
  list(
    geom_sf(data = mainland, color = mainland_color, size = mainland_size, ...),
    geom_sf(data = coastline, color = coastline_color, size = coastline_size, ...)
  )
}
