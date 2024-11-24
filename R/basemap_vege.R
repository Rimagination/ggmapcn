#' Vegetation Map of China Layer for ggplot2
#'
#' A ggplot2 layer to add a vegetation raster map of China with color-coded vegetation types.
#'
#' Adds a layer visualizing China’s vegetation distribution with a 1 km spatial resolution.
#' The default color table provides recommended colors suited for vegetation classification.
#'
#' @param color_table Data frame with vegetation type and corresponding colors.
#'   Should contain columns "code" (raster values), "type" (vegetation name), and "col" (hex color).
#'   The default color table follows the standard vegetation classification for China.
#' @param crs The coordinate reference system for the projection. If NULL, the default projection
#'   "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs" is used. Users can specify a different
#'   CRS if re-projection is needed.
#' @param maxcell Maximum number of cells for rendering (to improve performance).
#'   Defaults to 1e6.
#' @param use_coltab Logical, whether to use the color table for raster values. Default is TRUE.
#' @param na.rm Logical, if TRUE, remove missing values. Default is FALSE.
#' @param ... Additional parameters for `geom_spatraster`.
#' @return A ggplot2 layer object representing the vegetation map of China.
#' @import tidyterra
#' @import ggplot2
#' @references Zhang X, Sun S, Yong S, et al. (2007) \emph{Vegetation map of the People’s Republic of China (1:1000000)}. Geology Publishing House, Beijing.
#' @export
#' @examples
#' \dontrun{
#' # Add vegetation raster of China to a ggplot
#' ggplot() +
#'   basemap_vege() +
#'   theme_minimal()
#'
#' # Customize color table
#' custom_colors <- data.frame(
#'   code = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
#'   type = c(
#'     "Non-vegetated", "Needleleaf forest", "Needleleaf and broadleaf mixed forest",
#'     "Broadleaf forest", "Scrub", "Desert", "Steppe", "Grassland",
#'     "Meadow", "Swamp", "Alpine vegetation", "Cultivated vegetation"
#'   ),
#'   col = c(
#'     "#8D99B3", "#97B555", "#34BF36", "#9ACE30", "#2EC6C9", "#E5CE0E",
#'     "#5BB1ED", "#6494EF", "#7AB9CB", "#D97A80", "#B87701", "#FEB780"
#'   )
#' )
#' ggplot() +
#'   basemap_vege(color_table = custom_colors) +
#'   labs(fill = "Vegetation type group") +
#'   theme_minimal()
#' }
basemap_vege <- function(color_table = NULL,
                             crs = NULL,
                             maxcell = 1e6,
                             use_coltab = TRUE,
                             na.rm = FALSE,
                             ...) {
  library(terra)
  library(tidyterra)

  # Load vegetation raster of China from package's extdata directory
  vege_path <- system.file("extdata", "vege_1km_projected.tif", package = "ggmapcn")
  vege_raster <- terra::rast(vege_path)

  if (!is.null(crs)) {
    vege_raster <- terra::project(vege_raster, crs, method = "near")
  }

  # Default color table if none provided, following standard classification for China
  if (is.null(color_table)) {
    color_table <- data.frame(
      code = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
      type = c(
        "Non-vegetated", "Needleleaf forest", "Needleleaf and broadleaf mixed forest",
        "Broadleaf forest", "Scrub", "Desert", "Steppe", "Grassland",
        "Meadow", "Swamp", "Alpine vegetation", "Cultivated vegetation"
      ),
      col = c(
        "#8D99B3", "#97B555", "#34BF36", "#9ACE30", "#2EC6C9", "#E5CE0E",
        "#5BB1ED", "#6494EF", "#7AB9CB", "#D97A80", "#B87701", "#FEB780"
      )
    )
  }

  # Set levels and color table for the raster
  levels(vege_raster) <- color_table[, c("code", "type")]
  coltab(vege_raster) <- color_table[, c("code", "col")]

  # Return a ggplot2 layer with the raster in the specified CRS
  list(geom_spatraster(data = vege_raster, maxcell = maxcell, use_coltab = use_coltab, na.rm = na.rm, ...))
}
