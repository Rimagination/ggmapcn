#' Elevation Map of China Layer for ggplot2
#'
#' @description
#' `basemap_dem` adds a digital elevation model (DEM) raster map of China as a layer to ggplot2.
#' The function ensures the output map remains rectangular, regardless of the chosen projection.
#' It supports displaying the DEM either within China's boundary or in a larger rectangular area
#' around China.
#'
#' @param crs Coordinate reference system (CRS) for the projection. Defaults to the CRS of the DEM data.
#'   Users can specify other CRS strings (e.g., `"EPSG:4326"` or custom projections).
#' @param within_china Logical. If `TRUE`, displays only the DEM within China's boundary.
#'   If `FALSE`, displays the DEM for a larger rectangular area around China. Default is `FALSE`.
#' @param maxcell Maximum number of cells for rendering (to improve performance). Defaults to `1e6`.
#' @param na.rm Logical. If `TRUE`, removes missing values. Default is `FALSE`.
#' @param ... Additional parameters passed to `geom_spatraster`.
#'
#' @seealso
#' \code{\link[ggmapcn]{geom_boundary_cn}}
#'
#' @examples
#' # Define Azimuthal Equidistant projection centered on China
#' china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"
#'
#' # Example 1: Display full rectangular area around China
#' ggplot() +
#'   basemap_dem(within_china = FALSE) +
#'   tidyterra::scale_fill_hypso_tint_c(
#'     palette = "gmt_globe",
#'     breaks = c(-10000, -5000, 0, 2000, 5000, 8000)
#'   ) +
#'   theme_minimal()
#'
#' # Example 2: Display only China's DEM and boundaries
#' ggplot() +
#'   basemap_dem(crs = china_proj, within_china = TRUE) +
#'   geom_boundary_cn(crs = china_proj) +
#'   tidyterra::scale_fill_hypso_c(
#'     palette = "dem_print",
#'     breaks = c(0, 2000, 4000, 6000),
#'     limits = c(0, 7000)
#'   ) +
#'   labs(fill = "Elevation (m)") +
#'   theme_minimal()
#'
#' @export
basemap_dem <- function(crs = NULL,
                        within_china = FALSE,
                        maxcell = 1e6,
                        na.rm = FALSE,
                        ...) {

  # Load DEM raster of Asia from the package's extdata directory
  dem_path <- system.file("extdata", "gebco_2024.tif", package = "ggmapcn")
  if (dem_path == "") {
    stop("DEM file not found. Ensure 'gebco_2024.tif' is in the package's extdata folder.")
  }
  dem_raster <- terra::rast(dem_path)

  if (within_china) {
    # Load China's boundary for masking
    china_boundary_path <- system.file("extdata", "China_sheng.geojson", package = "ggmapcn")
    if (china_boundary_path == "") {
      stop("China boundary file not found. Ensure 'China_sheng.geojson' is in the package's extdata folder.")
    }
    china_boundary <- terra::vect(china_boundary_path)

    # Ensure CRS of China boundary matches DEM data
    if (!is.null(crs)) {
      # Reproject DEM to the specified CRS
      dem_raster <- terra::project(dem_raster, crs, method = "bilinear")
      # Reproject China boundary to the same CRS
      china_boundary <- terra::project(china_boundary, crs)
    } else {
      # Align China boundary with the original DEM CRS
      china_boundary <- terra::project(china_boundary, terra::crs(dem_raster))
    }

    # Mask DEM with China's boundary
    dem_raster <- terra::crop(dem_raster, china_boundary, mask = TRUE)
  } else {
    # Default rectangular bounding box around China
    china_extent <- c(60, 140, 0, 55) # Approximate bounds for China and surroundings
    bbox <- terra::ext(china_extent)
    bbox <- terra::vect(bbox, crs = "EPSG:4326")

    if (!is.null(crs)) {
      # Reproject DEM and bounding box
      dem_raster <- terra::project(dem_raster, crs, method = "bilinear")
      bbox_proj <- terra::project(bbox, crs)
      extent_proj <- terra::ext(bbox_proj)
      dem_raster <- terra::crop(dem_raster, extent_proj)
    } else {
      dem_raster <- terra::crop(dem_raster, bbox)
    }
  }

  # Create the ggplot2 layer
  dem_layer <- geom_spatraster(
    data = dem_raster,
    maxcell = maxcell,
    na.rm = na.rm,
    ...
  )

  return(dem_layer)
}
