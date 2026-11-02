#' Vegetation Map of China Layer for ggplot2
#'
#' Adds a vegetation raster map of China to a ggplot2 plot, with color-coded vegetation types.
#'
#' @details The default dataset is a 1 km raster representation of
#'   \emph{Vegetation Map of the People's Republic of China 1:1000000}
#'   (The Editorial Committee of Vegetation Map of China, Chinese Academy
#'   of Sciences, 2007). Its default colors follow Su et al. (2020).
#'   `check_geodata()` locates or retrieves `vege_1km_projected.tif`.
#'
#' @param color_table A data frame containing vegetation types and their corresponding colors.
#'   It should have columns "code" (raster values), "type" (vegetation names), and "col" (hex color codes).
#'   If NULL, a default color table based on standard vegetation classifications for China is used.
#' @param crs A character string specifying the coordinate reference system for the projection.
#'   If NULL, the default projection "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs" is applied.
#' @param maxcell An integer indicating the maximum number of cells for rendering to improve performance.
#'   Defaults to 1e6.
#' @param use_coltab A logical value indicating whether to use the color table for raster values. Default is TRUE.
#' @param na.rm A logical value indicating whether to remove missing values. Default is FALSE.
#' @param ... Additional parameters passed to `geom_spatraster`.
#' @return A ggplot2 layer object representing the vegetation map of China.
#' @importFrom tidyterra geom_spatraster
#' @importFrom terra levels coltab rast project
#' @references The Editorial Committee of Vegetation Map of China, Chinese
#'   Academy of Sciences (2007). \emph{Vegetation Map of the People's Republic
#'   of China 1:1000000}. Geological Publishing House, Beijing.
#'
#'   Su YJ, Guo QH, Hu TY, et al. (2020). An updated vegetation map of China
#'   (1:1000000). \emph{Science Bulletin}, 65(13), 1125–1136.
#' @export
#' @examplesIf interactive()
#' \donttest{
#' # Example1: Check and load the vegetation raster map
#'
#' # Make sure the required raster data is available
#' check_geodata(files = c("vege_1km_projected.tif"))
#'
#' # Once the data is checked or downloaded, add the vegetation raster to a ggplot
#' ggplot() +
#'   basemap_vege() +
#'   theme_minimal()
#'
#' # Example2: Customize color table
#' custom_colors <- data.frame(
#'   code = 0:11,
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

  # Locate the required vegetation raster.
  geodata_path <- check_geodata(files = c("vege_1km_projected.tif"), quiet = TRUE)
  if (is.na(geodata_path[1])) {
    stop("Could not locate or download 'vege_1km_projected.tif'.")
  }
  vege_raster <- terra::rast(geodata_path)

  # Reproject raster if a new CRS is provided
  if (!is.null(crs)) {
    vege_raster <- terra::project(vege_raster, crs, method = "near")
  }

  # Use default color table if none is provided
  if (is.null(color_table)) {
    color_table <- data.frame(
      code = 0:11,
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
  terra::coltab(vege_raster) <- color_table[, c("code", "col")]

  # Return a ggplot2 layer with the raster
  list(tidyterra::geom_spatraster(data = vege_raster, maxcell = maxcell, use_coltab = use_coltab, na.rm = na.rm, ...))
}
