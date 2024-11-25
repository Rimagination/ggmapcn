#' Elevation Map of China Layer for ggplot2
#'
#' @description
#' `basemap_dem` adds a digital elevation model (DEM) raster map of China as a layer to ggplot2.
#' The function ensures the output map remains rectangular, regardless of the chosen projection.
#' It supports displaying the DEM either within China's boundary or in a larger rectangular area
#' around China. Users can provide their own DEM data using the `data` parameter, or the default
#' built-in DEM data will be used.
#'
#' @param data Optional. A `terra` raster object for custom DEM data. If `NULL` (default), the function
#'   uses the built-in DEM data (`gebco_2024.tif`).
#' @param crs Coordinate reference system (CRS) for the projection. Defaults to the CRS of the DEM data.
#'   Users can specify other CRS strings (e.g., `"EPSG:4326"` or custom projections).
#' @param within_china Logical. If `TRUE`, displays only the DEM within China's boundary.
#'   If `FALSE`, displays the DEM for a larger rectangular area around China, determined by `extent`. Default is `FALSE`.
#' @param extent Numeric vector of length 4. Specifies the rectangular bounds in WGS84 CRS (`xmin, xmax, ymin, ymax`).
#'   Used when `within_china = FALSE`. Default is `c(77, 130, -10, 60)`.
#' @param maxcell Maximum number of cells for rendering (to improve performance). Defaults to `1e6`.
#' @param na.rm Logical. If `TRUE`, removes missing values. Default is `FALSE`.
#' @param ... Additional parameters passed to `geom_spatraster`.
#'
#' @examples
#' # Define Azimuthal Equidistant projection centered on China
#' china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"
#'
#' # Example 1: Display full rectangular area around China using default extent
#' ggplot() +
#'   basemap_dem(within_china = FALSE) +
#'   tidyterra::scale_fill_hypso_tint_c(
#'     palette = "gmt_globe",
#'     breaks = c(-10000, -5000, 0, 2000, 5000, 8000)
#'   ) +
#'   theme_minimal()
#'
#' # Example 2: Display DEM with custom extent
#' ggplot() +
#'   basemap_dem(within_china = FALSE, extent = c(105, 123, 2, 23))+
#'   theme_minimal()
#'
#' # Example 3: Display only China's DEM and boundaries using built-in DEM data
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
basemap_dem <- function(data = NULL,
                        crs = NULL,
                        within_china = FALSE,
                        extent = c(77, 130, -10, 60),
                        maxcell = 1e6,
                        na.rm = FALSE,
                        ...) {

  # If no custom data is provided, use the default DEM raster of Asia
  if (is.null(data)) {
    dem_path <- system.file("extdata", "gebco_2024.tif", package = "ggmapcn")
    if (dem_path == "") {
      stop("DEM file not found. Ensure 'gebco_2024.tif' is in the package's extdata folder.")
    }
    dem_raster <- terra::rast(dem_path)
  } else {
    # Use the user-provided custom DEM data
    dem_raster <- data
  }

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
    # Use the specified extent for cropping
    bbox <- terra::ext(extent)
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
