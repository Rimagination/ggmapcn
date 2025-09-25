#' Plot China Map with Customizable Options
#'
#' @description
#' `geom_mapcn` provides a flexible interface for visualizing China's administrative boundaries.
#' Users can select administrative levels (province, city, or county), apply custom projections,
#' and filter specific regions.
#'
#' @return A `ggplot2` layer (of class `ggproto`) for visualizing China's administrative boundaries.
#' This layer can be added to a `ggplot` object to generate maps with customizable projections,
#' border colors, fill colors, and more.
#'
#' @name geom_mapcn
#'
#' @param data An `sf` object containing China's map data. If `NULL`, the function loads the package's default map.
#'   Users can select provincial, municipal, or county-level maps using the `admin_level` parameter.
#' @param admin_level A character string specifying the administrative level of the map.
#'   Options are `"province"` (default), `"city"`, or `"county"`. The corresponding `.rda` files
#'   (`China_sheng.rda`, `China_shi.rda`, `China_xian.rda`) must be located in the package's `extdata` folder.
#' @param crs A string specifying the Coordinate Reference System (CRS). Defaults to
#'   `"+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"`. Users can specify other CRS strings
#'   (e.g., `"EPSG:4326"`).
#' @param color Border color. Default is `"black"`.
#' @param fill Fill color. Default is `"white"`.
#' @param linewidth Line width for borders. Default is `0.5`.
#'   Note: `linewidth` is used to control the border width in `ggplot2` version 3.3.0 or higher. Use `size` for earlier versions.
#' @param filter_attribute Column name for filtering regions (e.g., `"name_en"`).
#' @param filter A character vector of values to filter specific regions (e.g., `c("Beijing", "Shanghai")`).
#' @param ... Additional parameters passed to `geom_sf`.
#'
#' @examples
#' # Plot provincial map (default)
#' ggplot() +
#'   geom_mapcn() +
#'   theme_minimal()
#'
#' # Filter specific provinces
#' ggplot() +
#'   geom_mapcn(filter_attribute = "name_en", filter = c("Beijing", "Shanghai"), fill = "red") +
#'   theme_minimal()
#'
#' # Use a Mercator projection
#' ggplot() +
#'   geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
#'   theme_minimal()
#'
#' @importFrom sf st_read st_transform st_crs
#' @importFrom dplyr filter
#' @export
geom_mapcn <- function(
    data = NULL,
    admin_level = "province",
    crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
    color = "black",
    fill = "white",
    linewidth = 0.5,
    filter_attribute = NULL,
    filter = NULL,
    ...
) {
  # Required files based on admin_level
  required_files <- c("China_sheng.rda", "China_shi.rda", "China_xian.rda")

  # Ensure required geospatial data is available
  check_geodata(files = required_files, quiet = TRUE)

  # If data is not provided, load the corresponding .rda file based on admin_level
  if (is.null(data)) {
    # Determine which file to load based on admin_level
    file_name <- switch(
      admin_level,
      "province" = "China_sheng.rda",
      "city" = "China_shi.rda",
      "county" = "China_xian.rda",
      stop("Invalid admin_level. Choose from 'province', 'city', or 'county'.")
    )

    # Get the file path for the .rda file
    file_path <- system.file("extdata", file_name, package = "ggmapcn")

    if (file_path == "") {
      stop(paste("Map file", file_name, "not found in extdata folder."))
    }

    # Load the .rda file
    load(file_path)

    # Dynamically generate the object name based on the .rda file name
    object_name <- gsub("\\.rda$", "", file_name)  # Remove ".rda" to get the object name

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

  # Ensure data is an sf object
  if (!inherits(data, "sf")) {
    stop("The input 'data' must be an sf object.")
  }

  # Apply filter if provided
  if (!is.null(filter) && !is.null(filter_attribute)) {
    if (!(filter_attribute %in% colnames(data))) {
      stop(paste0("The filter_attribute '", filter_attribute, "' does not exist in the data."))
    }
    data <- dplyr::filter(data, !!rlang::sym(filter_attribute) %in% filter)
  }

  # Transform CRS if necessary
  if (sf::st_crs(data)$input != crs) {
    data <- sf::st_transform(data, crs = crs)
  }

  # Return the ggplot layer
  ggplot2::geom_sf(data = data, color = color, fill = fill, linewidth = linewidth, ...)
}
