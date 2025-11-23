#' Coordinate System with Geographic Limits Automatically Transformed to a Projection
#'
#' @description
#' `coord_proj()` extends [ggplot2::coord_sf()] by allowing users to specify
#' map limits (`xlim`, `ylim`) in geographic coordinates (longitude/latitude, WGS84).
#' These limits are automatically transformed into the target projected CRS,
#' ensuring that maps display the intended region correctly under any projection.
#'
#' @details
#' This wrapper is particularly useful because [ggplot2::coord_sf()] interprets
#' `xlim` and `ylim` as *projected* coordinates (in the units of the target CRS).
#' Passing longitude/latitude directly to `coord_sf()` results in incorrect map
#' extents unless the output CRS is also WGS84.
#'
#' `coord_proj()` provides a safe, projection-aware workflow that calculates
#' the bounding box in WGS84, transforms it to the target CRS, and passes the
#' new limits to `coord_sf()`.
#'
#' @param crs Character string or object specifying the output coordinate
#'   reference system (e.g., `"EPSG:3857"`, `"+proj=robin"`, or an `sf::crs` object).
#'   **Required**.
#' @param xlim Numeric vector of length 2. Longitude limits in degrees (WGS84).
#' @param ylim Numeric vector of length 2. Latitude limits in degrees (WGS84).
#' @param expand Logical. Passed to [ggplot2::coord_sf()]. Default is `TRUE`.
#' @param default_crs Character or object. The CRS of the input `xlim` and `ylim`.
#'   Default is `"EPSG:4326"` (WGS84).
#' @param ... Additional arguments passed to [ggplot2::coord_sf()].
#'
#' @return A `CoordSf` object (specifically a result of `coord_sf()`) with
#'   automatically transformed limits.
#'
#' @seealso
#' * [ggplot2::coord_sf()] for the underlying function.
#' * [geom_world()] for the basemap layer.
#'
#' @examples
#' library(ggplot2)
#'
#' \donttest{
#' # Example 1: China (AEQD projection) with geographic limits
#' china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"
#'
#' ggplot() +
#'   geom_world(crs = china_proj) +
#'   coord_proj(
#'     crs = china_proj,
#'     xlim = c(60, 140),
#'     ylim = c(-10, 50)
#'   ) +
#'   theme_minimal()
#'
#' # Example 2: Zooming into a specific region
#' # Even though the map is projected (Robinson), we specify limits in Lat/Lon
#' crs_robin <- "+proj=robin +lon_0=0 +datum=WGS84"
#'
#' ggplot() +
#'   geom_world(crs = crs_robin) +
#'   coord_proj(
#'     crs = crs_robin,
#'     xlim = c(-20, 50), # Focus on Africa/Europe
#'     ylim = c(-40, 40)
#'   ) +
#'   theme_minimal()
#' }
#'
#' @export
#' @import ggplot2
#' @importFrom sf st_bbox st_as_sfc st_transform st_crs
coord_proj <- function(crs = NULL,
                       xlim = NULL,
                       ylim = NULL,
                       expand = TRUE,
                       default_crs = "EPSG:4326",
                       ...) {

  # Ensure CRS is provided
  if (is.null(crs)) {
    stop("You must specify a CRS for `coord_proj()`.")
  }

  # If xlim/ylim provided, convert them from WGS84 -> target CRS
  if (!is.null(xlim) && !is.null(ylim)) {

    # Build the bounding box in the default CRS (WGS84)
    bbox <- sf::st_bbox(
      c(xmin = xlim[1], xmax = xlim[2],
        ymin = ylim[1], ymax = ylim[2]),
      crs = sf::st_crs(default_crs)
    )

    # Convert bbox to sf geometry and transform
    bbox_sf <- sf::st_as_sfc(bbox)

    # Use suppressWarnings to avoid chatty sf projection warnings
    bbox_transformed <- suppressWarnings(sf::st_transform(bbox_sf, crs))
    bbox_coords <- sf::st_bbox(bbox_transformed)

    # Use transformed ranges
    xlim <- c(bbox_coords["xmin"], bbox_coords["xmax"])
    ylim <- c(bbox_coords["ymin"], bbox_coords["ymax"])
  }

  # Return projection-aware coord_sf()
  ggplot2::coord_sf(
    crs = crs,
    xlim = xlim,
    ylim = ylim,
    expand = expand,
    ...
  )
}
