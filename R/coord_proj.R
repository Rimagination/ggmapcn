#' Coordinate System with Transformed Limits for Custom Projections
#'
#' @description
#' `coord_proj` is a wrapper around \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf()}}.
#' It simplifies specifying map limits (`xlim`, `ylim`) in longitude and latitude (WGS84 CRS)
#' and automatically transforms them into the specified CRS for accurate projections.
#'
#' This function extends the functionality of \code{coord_sf()} to seamlessly handle user-specified
#' geographic boundaries in any projection, ensuring accurate mapping.
#'
#' @param crs A character string specifying the coordinate reference system (CRS) for the projection
#'   (e.g., `"EPSG:4326"` or custom projections like `"+proj=merc"`).
#' @param xlim Longitude range (in degrees) to display, as a numeric vector of length 2.
#' @param ylim Latitude range (in degrees) to display, as a numeric vector of length 2.
#' @param expand Logical, whether to expand the plot limits. Default is `TRUE`.
#' @param default_crs A character string specifying the CRS of the input `xlim` and `ylim`.
#'   Default is `"EPSG:4326"`.
#' @param ... Additional arguments passed to \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf()}}.
#'
#' @return A ggplot2 \code{coord_sf} object with the transformed limits.
#'
#' @examples
#'
#' # World map with default projection and limits
#' ggplot() +
#'   geom_world() +
#'   coord_proj(
#'     crs = "+proj=longlat +datum=WGS84",
#'     xlim = c(-180, 180),
#'     ylim = c(-90, 90),
#'     expand=FALSE
#'   ) +
#'   theme_minimal()
#'
#' # Focused view with Azimuthal Equidistant projection
#' china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"
#' ggplot() +
#'   geom_world(fill = "lightblue") +
#'   coord_proj(
#'     crs = china_proj,
#'     xlim = c(60, 140),
#'     ylim = c(-10, 50)
#'   ) +
#'   theme_minimal()
#'
#' # Display a small map of the South China Sea Islands with a custom projection
#' ggplot() +
#'   geom_boundary_cn() +
#'   theme_bw() +
#'   coord_proj(
#'     crs = china_proj,
#'     expand = FALSE,
#'     xlim = c(105, 123),
#'     ylim = c(2, 23)
#'   )
#'
#' @seealso
#' \code{\link[ggplot2:coord_sf]{ggplot2::coord_sf}}, \code{\link[ggmapcn:geom_world]{geom_world}}
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

  # Ensure CRS is specified
  if (is.null(crs)) {
    stop("You must specify a CRS for `coord_proj()`.")
  }

  # Transform the limits if xlim and ylim are provided
  if (!is.null(xlim) && !is.null(ylim)) {
    # Create a bounding box in the default CRS
    bbox <- sf::st_bbox(c(xmin = xlim[1], ymin = ylim[1], xmax = xlim[2], ymax = ylim[2]), crs = sf::st_crs(default_crs))
    bbox_sf <- sf::st_as_sfc(bbox)

    # Transform the bounding box to the specified CRS
    bbox_transformed <- sf::st_transform(bbox_sf, crs)
    bbox_coords <- sf::st_bbox(bbox_transformed)

    # Extract transformed xlim and ylim
    xlim <- c(bbox_coords["xmin"], bbox_coords["xmax"])
    ylim <- c(bbox_coords["ymin"], bbox_coords["ymax"])
  }

  # Return the `coord_sf` object with the transformed limits
  ggplot2::coord_sf(crs = crs, xlim = xlim, ylim = ylim, expand = expand, ...)
}
