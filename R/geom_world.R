#' Plot World Map with Customizable Options
#'
#' @description
#' A wrapper around [ggplot2::geom_sf()] for visualizing world maps with customizable options.
#' This function allows for custom projections, filtering specific countries or regions, and detailed
#' aesthetic customizations for borders and fills.
#'
#' @param data An `sf` object containing world map data. If `NULL`, the default world map data
#'   from the package will be loaded from a `.rda` file.
#' @param crs A character string specifying the target coordinate reference system (CRS) for the map projection.
#'   Defaults to `"+proj=longlat +datum=WGS84"`.
#' @param color A character string specifying the border color for administrative boundaries. Default is `"black"`.
#' @param fill A character string specifying the fill color for administrative areas. Default is `"white"`.
#' @param linewidth A numeric value specifying the line width for administrative boundaries. Default is `0.5`.
#' @param filter_attribute A character string specifying the column name used for filtering countries or regions.
#'   Default is `"SOC"`, which refers to the ISO 3166-1 alpha-3 country code in the default dataset.
#' @param filter A character vector specifying the values to filter specific countries or regions. Default is `NULL`.
#' @param ... Additional parameters passed to [ggplot2::geom_sf()], such as `size`, `alpha`, or `lty`.
#'
#' @return A `ggplot2` layer for world map visualization.
#'
#' @details
#' This function simplifies the process of creating world maps by combining the functionality of `geom_sf`
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
#' \donttest{
#'   # Plot the default world map
#'   ggplot() +
#'     geom_world() +
#'     theme_minimal()
#'
#'   # Using Robinson projection with central meridian at 0°
#'   ggplot() +
#'     geom_world(crs = "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m") +
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
#' }
#' @importFrom sf st_transform
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

  # Ensure the required 'world.rda' file is available
  check_geodata(files = c("world.rda"), quiet = TRUE)

  # Load default world map data if no data is provided
  if (is.null(data)) {
    file_path <- system.file("extdata", "world.rda", package = "ggmapcn")
    if (file_path == "") {
      stop("Default world map data not found in the package's 'extdata' directory.")
    }

    # Load the .rda file
    load(file_path)

    # Dynamically generate the object name based on the .rda file name
    object_name <- gsub("\\.rda$", "", basename(file_path))  # Get object name by stripping ".rda"

    # Check if the object exists in the environment
    if (!exists(object_name)) {
      stop(paste("The object", object_name, "was not found in the .rda file."))
    }

    # Retrieve the object from the environment
    data <- get(object_name)

    # Ensure the loaded object is of class 'sf'
    if (!inherits(data, "sf")) {
      stop("The loaded object is not an 'sf' object. Please check the .rda file.")
    }
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
