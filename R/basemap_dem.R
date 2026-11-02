#' Elevation Map of China Layer for ggplot2
#'
#' @description
#' `basemap_dem()` adds a digital elevation model (DEM) raster layer to a
#' \pkg{ggplot2} plot. It supports displaying elevation within China's
#' boundary or in a rectangular area around China. Users can supply a
#' `terra` raster through `data`. Otherwise, `check_geodata()` locates or
#' retrieves the default elevation dataset from the package's companion
#' data repository.
#'
#' @details The default elevation layer is the China subset of GEBCO_2024.
#'   The dataset is located or retrieved as `gebco_2024_China.tif` by
#'   `check_geodata()`.
#'
#' @param data Optional. A `terra` raster object for custom DEM data.
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
#' @return A layer produced by [tidyterra::geom_spatraster()] that can be
#'   added to a \pkg{ggplot2} plot.
#'
#' @references GEBCO Compilation Group (2024). GEBCO 2024 Grid.
#'   NERC EDS British Oceanographic Data Centre NOC.
#'   \url{https://www.gebco.net/}.
#'
#' @examplesIf interactive()
#' \donttest{
#' # Before using the basemap_dem function, make sure the required data files are available.
#' # The required files are: "gebco_2024_China.tif" and "China_mask.gpkg".
#' # You can use check_geodata() to download them from GitHub if they are not available locally.
#'
#' # Check and download the required data files if they are missing
#' check_geodata(files = c("gebco_2024_China.tif", "China_mask.gpkg"))
#'
#' # Define the CRS for China (EPSG:4326 is a common global geographic coordinate system)
#' china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"
#'
#' # Example 1: Display the rectangular area around China using the default DEM data
#' ggplot() +
#'   basemap_dem(within_china = FALSE) +
#'   tidyterra::scale_fill_hypso_tint_c(
#'     palette = "gmt_globe",
#'     breaks = c(-10000, -5000, 0, 2000, 5000, 8000)
#'   ) +
#'   theme_minimal()
#'
#' # Example 2: Display only China's DEM and boundaries using the default DEM data
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
#' }
#' @export
basemap_dem <- function(data = NULL,
                        crs = NULL,
                        within_china = FALSE,
                        maxcell = 1e6,
                        na.rm = FALSE,
                        ...) {

  # If no custom data is provided, use the default DEM raster of China
  if (is.null(data)) {
    # Get the path of the DEM data from check_geodata
    dem_path <- check_geodata(files = c("gebco_2024_China.tif"), quiet = TRUE)
    if (is.na(dem_path[1])) {
      stop("Could not locate or download 'gebco_2024_China.tif'.")
    }
    dem_raster <- terra::rast(dem_path)
  } else {
    # Use the user-provided custom DEM data (assumed to be a terra raster object)
    dem_raster <- data
  }

  if (!is.null(crs)) {
    dem_raster <- terra::project(dem_raster, crs, method = "bilinear")
  }

  if (within_china) {
    china_data_path <- check_geodata(files = "China_mask.gpkg", quiet = TRUE)
    if (is.na(china_data_path[1])) {
      stop("Could not locate or download 'China_mask.gpkg'.")
    }
    China_sheng <- terra::vect(china_data_path)
    China_sheng <- terra::project(China_sheng, terra::crs(dem_raster))
    # If 'within_china' is TRUE, crop DEM to the boundary of China
    dem_raster <- terra::crop(dem_raster, China_sheng, mask = TRUE)
  } else {
    # Default rectangular bounding box around China
    china_extent <- c(60, 140, -10, 60) # Approximate bounds for China and surroundings
    bbox <- terra::ext(china_extent)

    if (!is.null(crs)) {
      # Reproject the bounding box to the raster CRS
      bbox_proj <- terra::project(bbox, crs)
      extent_proj <- terra::ext(bbox_proj)
      dem_raster <- terra::crop(dem_raster, extent_proj)
    } else {
      dem_raster <- terra::crop(dem_raster, bbox)
    }
  }

  # Create the ggplot2 layer
  dem_layer <- tidyterra::geom_spatraster(
    data = dem_raster,
    maxcell = maxcell,
    na.rm = na.rm,
    ...
  )

  return(dem_layer)
}
