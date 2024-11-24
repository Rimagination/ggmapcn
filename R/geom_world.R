#' Plot World Map with Customizable Options
#'
#' @description
#' `geom_world` is a wrapper around [ggplot2::geom_sf()] designed
#' for visualizing world maps with added flexibility. It allows custom projections,
#' filtering specific countries or regions, and detailed aesthetic customizations for borders and fills.
#'
#' @param data An `sf` object containing world map data. If `NULL`, the function loads the package's
#'   default `world.geojson` dataset.
#' @param crs A character string. The target coordinate reference system (CRS) for the map projection.
#'   Defaults to `"+proj=longlat +datum=WGS84"`.
#' @param color A character string specifying the border color for administrative boundaries. Default is `"black"`.
#' @param fill A character string specifying the fill color for administrative areas. Default is `"white"`.
#' @param linewidth A numeric value specifying the line width for administrative boundaries. Default is `0.5`.
#' @param filter_attribute A character string specifying the column name to use for filtering countries or regions.
#'   Default is `"SOC"`, which refers to the ISO 3166-1 alpha-3 country code in the default dataset.
#' @param filter A character vector specifying the values to filter specific countries or regions. Default is `NULL`.
#' @param ... Additional parameters passed to [ggplot2::geom_sf()], such as `size`,
#'   `alpha`, or `lty`.
#'
#' @return A `ggplot2` layer for world map visualization.
#'
#' @details
#' `geom_world` simplifies the process of creating world maps by combining the functionality of `geom_sf`
#' with user-friendly options for projections, filtering, and custom styling.
#' Key features include:
#' - **Custom projections**: Easily apply any CRS to the map.
#' - **Filtering by attributes**: Quickly focus on specific countries or regions.
#' - **Flexible aesthetics**: Customize fill, borders, transparency, and other visual properties.
#'
#' @seealso
#' [ggplot2::geom_sf()], [sf::st_transform()],
#' [sf::st_read()]
#'
#' @examples
#'   # Plot the default world map
#'   ggplot() +
#'     geom_world() +
#'     theme_minimal()
#'
#'   # Apply Mercator projection
#'   ggplot() +
#'     geom_world(crs = "+proj=merc") +
#'     theme_minimal()
#'
#'   # Filter specific countries (e.g., China and its neighbors)
#'   china_neighbors <- c("CHN", "AFG", "BTN", "MMR", "LAO", "NPL", "PRK", "KOR",
#'                        "KAZ", "KGZ", "MNG", "IND", "BGD", "TJK", "PAK", "LKA", "VNM")
#'   ggplot() +
#'     geom_world(filter = china_neighbors) +
#'     theme_minimal()
#'
#'   # Background map + Highlight specific region
#'   ggplot() +
#'     geom_world(fill = "gray80", color = "gray50", alpha = 0.5) +
#'     geom_world(filter = c("CHN"), fill = "red", color = "black", linewidth = 1.5) +
#'     theme_minimal()
#'
#'   # Customize styles with transparency and bold borders
#'   ggplot() +
#'     geom_world(fill = "lightblue", color = "darkblue", linewidth = 1, alpha = 0.8) +
#'     theme_void()
#'
#' @importFrom sf st_read st_transform
#' @importFrom ggplot2 geom_sf
#' @export
geom_world <- function(
    data = NULL,
    crs = "+proj=longlat +datum=WGS84",
    color = "black",
    fill = "white",
    linewidth = 0.5,
    filter_attribute = "SOC",
    filter = NULL,
    ...
) {
  # Load default world map data if no data is provided
  if (is.null(data)) {
    file_path <- system.file("extdata", "world.geojson", package = "ggmapcn")
    if (file_path == "") {
      stop("Default world map data not found in the package's 'extdata' directory.")
    }
    data <- sf::st_read(file_path, quiet = TRUE)
  }

  # Ensure the input data is an sf object
  if (!inherits(data, "sf")) {
    stop("The input 'data' must be an sf object.")
  }

  # Apply filtering if specified
  if (!is.null(filter)) {
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
  plot <- ggplot2::geom_sf(data = data, color = color, fill = fill, linewidth = linewidth, ...)

  return(plot)
}
