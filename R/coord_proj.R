#' Coordinate System with Geographic Limits Automatically Transformed to a Projection
#'
#' @description
#' `coord_proj()` extends \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf()}} by
#' allowing users to specify map limits (`xlim`, `ylim`) in geographic coordinates
#' (longitude/latitude, WGS84). These limits are automatically transformed into the
#' target projected CRS, ensuring that maps display the intended region correctly
#' under any projection.
#'
#' This wrapper is particularly useful because \code{coord_sf()} interprets
#' `xlim` and `ylim` as *projected* coordinates. Passing longitude/latitude
#' directly to \code{coord_sf()} results in incorrect map extents unless the CRS
#' is WGS84. `coord_proj()` provides a safe, projection-aware workflow that
#' requires no manual calculation of projected bounding boxes.
#'
#' @param crs Character string specifying the output coordinate reference system
#'   (e.g., `"EPSG:4326"`, `"EPSG:3857"`, or a PROJ string such as
#'   `"+proj=aeqd +lat_0=35 +lon_0=105"`). Required.
#' @param xlim Numeric vector of length 2. Longitude limits in degrees (WGS84).
#' @param ylim Numeric vector of length 2. Latitude limits in degrees (WGS84).
#' @param expand Logical. Passed to \code{coord_sf()}. Default: `TRUE`.
#' @param default_crs Character. CRS of `xlim` and `ylim`. Default: `"EPSG:4326"`.
#' @param ... Additional arguments passed to \code{coord_sf()}.
#'
#' @return A \code{ggplot2::coord_sf} object with automatically transformed limits.
#'
#' @examples
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
#'
#' # Example 2: South China Sea region using geom_mapcn + geom_boundary_cn
#' ggplot() +
#'   geom_mapcn(fill = "white") +
#'   geom_boundary_cn() +
#'   theme_bw() +
#'   coord_proj(
#'     crs = china_proj,
#'     expand = FALSE,
#'     xlim = c(105, 126),   # lon range
#'     ylim = c(2, 23)       # lat range
#'   )
#'
#' @seealso
#' \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}},
#' \code{\link[ggmapcn:geom_world]{geom_world}},
#' \code{\link[ggmapcn:geom_mapcn]{geom_mapcn}}
#'
#' @import ggplot2
#' @importFrom sf st_bbox st_as_sfc st_transform st_crs
#' @export
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

  # If xlim/ylim provided, convert them from WGS84 → target CRS
  if (!is.null(xlim) && !is.null(ylim)) {

    # Build the bounding box in the default CRS (WGS84)
    bbox <- sf::st_bbox(
      c(xmin = xlim[1], xmax = xlim[2],
        ymin = ylim[1], ymax = ylim[2]),
      crs = sf::st_crs(default_crs)
    )

    # Convert bbox to sf geometry and transform
    bbox_sf <- sf::st_as_sfc(bbox)

    bbox_transformed <- sf::st_transform(bbox_sf, crs)
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
