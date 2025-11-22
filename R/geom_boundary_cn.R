#' Plot Boundaries of China
#'
#' @description
#' Draw China's administrative boundaries and optional map decorations
#' (compass and scale bar). Each boundary category (mainland, coastline,
#' provinces, etc.) can be styled independently. The boundary data are
#' reprojected to the specified CRS before plotting.
#'
#' @param crs Character or `sf::crs`. Target coordinate reference system for
#'   plotting. Defaults to an azimuthal equidistant projection centered on China
#'   (`+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs`).
#' @param compass Logical. If `TRUE`, add a compass pointing to true north in
#'   the top-left corner. Default: `FALSE`.
#' @param scale Logical. If `TRUE`, add a scale bar in the bottom-left corner.
#'   Default: `FALSE`.
#'
#' @param mainland_color Character. Line color for the mainland boundary.
#'   Default: `"black"`.
#' @param mainland_size Numeric. Line width for the mainland boundary.
#'   Default: `0.2`.
#' @param mainland_linetype Character. Line type for the mainland boundary.
#'   Default: `"solid"`.
#'
#' @param coastline_color Character. Line color for coastlines.
#'   Default: `"blue"`.
#' @param coastline_size Numeric. Line width for coastlines.
#'   Default: `0.1`.
#' @param coastline_linetype Character. Line type for coastlines.
#'   Default: `"solid"`.
#'
#' @param ten_segment_line_color Character. Line color for the South China Sea
#'   ten-segment line. Default: `"black"`.
#' @param ten_segment_line_size Numeric. Line width for the ten-segment line.
#'   Default: `0.2`.
#' @param ten_segment_line_linetype Character. Line type for the ten-segment line.
#'   Default: `"solid"`.
#'
#' @param SAR_boundary_color Character. Line color for Hong Kong and Macau SAR
#'   boundaries. Default: `"grey40"`.
#' @param SAR_boundary_size Numeric. Line width for SAR boundaries.
#'   Default: `0.1`.
#' @param SAR_boundary_linetype Character. Line type for SAR boundaries.
#'   Default: `"dashed"`.
#'
#' @param undefined_boundary_color Character. Line color for undefined or
#'   disputed boundaries. Default: `"black"`.
#' @param undefined_boundary_size Numeric. Line width for undefined boundaries.
#'   Default: `0.2`.
#' @param undefined_boundary_linetype Character. Line type for undefined
#'   boundaries. Default: `"dotdash"`.
#'
#' @param province_color Character. Line color for provincial boundaries.
#'   Default: `"transparent"`.
#' @param province_size Numeric. Line width for provincial boundaries.
#'   Default: `0.1`.
#' @param province_linetype Character. Line type for provincial boundaries.
#'   Default: `"solid"`.
#'
#' @param ... Additional arguments passed to `ggplot2::geom_sf()` (e.g., `alpha`).
#'
#' @return A list of `ggplot2` layers. If the boundary dataset cannot be
#'   obtained, an empty list is returned.
#'
#' @export
#' @import ggplot2
#' @importFrom sf st_transform st_crs
#'
#' @examplesIf requireNamespace("sf", quietly = TRUE)
#'
#' # Example 1: Basic China map
#' ggplot() +
#'   geom_boundary_cn() +
#'   theme_minimal()
#'
#' # Example 2: Add compass and scale bar (easy mode)
#' ggplot() +
#'   geom_boundary_cn(compass = TRUE, scale = TRUE) +
#'   theme_minimal()
#'
#' # Example 3: Custom styling
#' ggplot() +
#'   geom_boundary_cn(
#'     coastline_color  = "steelblue",
#'     province_color   = "grey70",
#'     province_linetype = "dashed"
#'   ) +
#'   theme_minimal()
#'
#' # Example 4: Advanced usage with a custom projected CRS (Albers)
#' albers_cn <- "+proj=aea +lat_1=25 +lat_2=47 +lat_0=0 +lon_0=105 +datum=WGS84 +units=m +no_defs"
#'
#' ggplot() +
#'   geom_boundary_cn(crs = albers_cn) +
#'   annotation_compass(location = "tl", which_north = "true") +
#'   annotation_scalebar(location = "bl", fixed_width = 500000, display_unit = "km") +
#'   coord_sf(crs = albers_cn) +
#'   theme_minimal()
#'
geom_boundary_cn <- function(
    crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
    compass = FALSE,
    scale = FALSE,
    mainland_color = "black", mainland_size = 0.2, mainland_linetype = "solid",
    coastline_color = "blue", coastline_size = 0.1, coastline_linetype = "solid",
    ten_segment_line_color = "black", ten_segment_line_size = 0.2, ten_segment_line_linetype = "solid",
    SAR_boundary_color = "grey40", SAR_boundary_size = 0.1, SAR_boundary_linetype = "dashed",
    undefined_boundary_color = "black", undefined_boundary_size = 0.2, undefined_boundary_linetype = "dotdash",
    province_color = "transparent", province_size = 0.1, province_linetype = "solid",
    ...) {

  # Ensure boundary dataset exists (do not error if not available)
  files <- check_geodata(files = "boundary.rda", overwrite = FALSE, quiet = TRUE)

  if (is.na(files[1])) {
    message(
      "Boundary dataset 'boundary.rda' is not available. ",
      "No boundary layers will be drawn. ",
      "If you are working in a restricted network environment, ",
      "please download 'boundary.rda' manually and place it in a directory ",
      "searched by `check_geodata()`."
    )
    return(list())
  }

  # Load boundary object into a clean environment
  env <- new.env(parent = emptyenv())
  base::load(files[1], envir = env)

  if (!exists("boundary", envir = env, inherits = FALSE)) {
    stop("Object 'boundary' not found inside 'boundary.rda'.")
  }
  boundary <- get("boundary", envir = env, inherits = FALSE)

  # Reproject boundary data
  boundary <- tryCatch(
    sf::st_transform(boundary, crs = crs),
    error = function(e) {
      warning("Failed to transform CRS. Returning original boundary geometry.")
      boundary
    }
  )

  # Split by category (safe subsetting)
  get_layer_data <- function(name) {
    boundary[boundary$name == name, , drop = FALSE]
  }

  mainland           <- get_layer_data("mainland")
  coastline          <- get_layer_data("coastline")
  ten_segment_line   <- get_layer_data("ten_segment_line")
  SAR_boundary       <- get_layer_data("SAR_boundary")
  undefined_boundary <- get_layer_data("undefined_boundary")
  province           <- get_layer_data("province")

  # Build layers
  layers <- list(
    ggplot2::geom_sf(
      data = mainland,
      color = mainland_color,
      linewidth = mainland_size,
      linetype = mainland_linetype,
      ...
    ),
    ggplot2::geom_sf(
      data = coastline,
      color = coastline_color,
      linewidth = coastline_size,
      linetype = coastline_linetype,
      ...
    ),
    ggplot2::geom_sf(
      data = ten_segment_line,
      color = ten_segment_line_color,
      linewidth = ten_segment_line_size,
      linetype = ten_segment_line_linetype,
      ...
    ),
    ggplot2::geom_sf(
      data = SAR_boundary,
      color = SAR_boundary_color,
      linewidth = SAR_boundary_size,
      linetype = SAR_boundary_linetype,
      ...
    ),
    ggplot2::geom_sf(
      data = undefined_boundary,
      color = undefined_boundary_color,
      linewidth = undefined_boundary_size,
      linetype = undefined_boundary_linetype,
      ...
    ),
    ggplot2::geom_sf(
      data = province,
      color = province_color,
      linewidth = province_size,
      linetype = province_linetype,
      ...
    )
  )

  # Convert CRS string to object (for downstream annotations)
  crs_obj <- tryCatch(sf::st_crs(crs), error = function(e) NULL)

  # Optional compass
  if (compass) {
    compass_layer <- annotation_compass(location = "tl", which_north = "true")
    compass_layer$geom_params$crs <- crs_obj
    layers <- append(layers, list(compass_layer))
  }

  # Optional scale bar
  if (scale) {
    scale_layer <- annotation_scalebar(location = "bl")
    scale_layer$geom_params$crs <- crs_obj
    layers <- append(layers, list(scale_layer))
  }

  layers
}
