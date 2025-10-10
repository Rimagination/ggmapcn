#' Add a Spatially-Aware Compass
#'
#' @description
#' `annotation_compass()` adds a compass (north arrow) to a `ggplot2` map.
#' It can be aligned to **grid north** (top of the plot) or **true north**
#' (geographic north). Styles can be supplied as a grob or a function returning
#' a grob (e.g., `north_arrow_classic()`, `compass_sinan()`).
#'
#' @details
#' * `"grid"` north: compass points straight up in the plotting space (no CRS needed).
#' * `"true"` north: compass rotates toward geographic North Pole using the plot CRS.
#'   This requires a valid CRS available via `coord_sf()` or injected by setting
#'   `layer$geom_params$crs`.
#' * You can override any auto-rotation by providing `rotation` (degrees CCW).
#' * The layer is annotation-like: it draws once per panel using the panel bounds.
#'
#' @param mapping,data Standard ggplot2 arguments (typically unused).
#' @param ... Additional parameters passed to the layer (rarely needed).
#' @param location Character. One of `"tl"`, `"tr"`, `"bl"`, `"br"` indicating
#'   top/bottom + left/right placement. Default: `"bl"`.
#' @param which_north Character. `"grid"` (default) or `"true"`.
#' @param height,width `grid::unit`. Compass box dimensions. Defaults: `1.5 cm`.
#' @param pad_x,pad_y `grid::unit`. Padding from panel edges. Defaults: `0.5 cm`.
#' @param rotation Numeric. Fixed rotation in degrees (counter-clockwise).
#'   When provided, it overrides `"grid"`/`"true"` logic.
#' @param style A grob, `gList`/`gTree`, or a function returning a grob
#'   (e.g., `north_arrow_classic()`). Default: `north_arrow_classic()`.
#'
#' @return A `ggplot2` layer object.
#' @seealso [compass-styles]
#' @export
#' @import ggplot2
#' @importFrom grid unit gList gTree viewport is.grob rectGrob circleGrob polygonGrob textGrob gpar nullGrob
#' @importFrom sf st_is_longlat st_coordinates st_transform st_as_sf st_crs st_sfc st_point
#'
#' @examples
#' nc <- sf::st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
#'
#' base <- ggplot2::ggplot() +
#'   ggplot2::geom_sf(data = nc, fill = "grey90") +
#'   ggplot2::theme_minimal()
#'
#' # Example 1: Grid north (no CRS required), bottom-left
#' base + annotation_compass()
#'
#' # Example 2: Custom style & position (top-left)
#' base + annotation_compass(location = "tl", style = compass_sinan())
#'
#' # Example 3: True north (requires a CRS)
#' base +
#'   ggplot2::coord_sf(crs = "+proj=lcc +lon_0=-100 +lat_1=33 +lat_2=45") +
#'   annotation_compass(which_north = "true")
#'
annotation_compass <- function(mapping = NULL, data = NULL, ...,
                               location = "bl",
                               which_north = "grid",
                               height = unit(1.5, "cm"),
                               width  = unit(1.5, "cm"),
                               pad_x  = unit(0.5, "cm"),
                               pad_y  = unit(0.5, "cm"),
                               rotation = NULL,
                               style = north_arrow_classic()) {

  layer_data <- data.frame(
    location    = location,
    which_north = which_north
  )

  ggplot2::layer(
    data = layer_data,
    mapping = ggplot2::aes(location = location, which_north = which_north),
    stat = ggplot2::StatIdentity,
    geom = GeomCompass,
    position = ggplot2::PositionIdentity,
    show.legend = FALSE,
    inherit.aes = FALSE,
    params = list(
      ...,
      height = height,
      width  = width,
      pad_x  = pad_x,
      pad_y  = pad_y,
      rotation = rotation,
      style = style
    )
  )
}

#' @keywords internal
#' @noRd
GeomCompass <- ggplot2::ggproto(
  "GeomCompass", ggplot2::Geom,
  extra_params = c("na.rm", "crs"),
  required_aes = c("location", "which_north"),
  default_aes  = ggplot2::aes(location = "bl", which_north = "grid"),

  draw_panel = function(data, panel_params, coordinates,
                        height, width, pad_x, pad_y,
                        rotation = NULL, style,
                        crs = NULL) {

    which_north <- data$which_north[1]
    location    <- data$location[1]

    xr <- panel_params$x_range
    yr <- panel_params$y_range
    if (is.null(xr) || is.null(yr) ||
        !all(is.finite(xr)) || !all(is.finite(yr)) ||
        (xr[2] - xr[1]) == 0 || (yr[2] - yr[1]) == 0) {
      return(grid::nullGrob())
    }

    if (is.function(style)) style <- style()
    if (!is_grob_like(style)) {
      stop("Invalid `style`: must be a grob or grob-like object, ",
           "or a function returning a grob.", call. = FALSE)
    }

    if (is.null(rotation)) {
      rotation <- 0
      if (identical(which_north, "true")) {
        plot_crs <- if (!is.null(panel_params$crs)) panel_params$crs else crs
        if (!is.null(plot_crs)) {
          bounds <- c(
            l = unname(xr[1]), r = unname(xr[2]),
            b = unname(yr[1]), t = unname(yr[2])
          )
          x0 <- bounds[substr(location, 2, 2)]
          y0 <- bounds[substr(location, 1, 1)]
          rotation <- -1 * true_north(x = x0, y = y0, crs = plot_crs)
        } else {
          warning("`which_north = 'true'` requires a CRS. ",
                  "Add coord_sf() or inject `layer$geom_params$crs`.",
                  call. = FALSE)
        }
      }
    }

    adj_x <- as.numeric(grepl("r", location))
    adj_y <- as.numeric(grepl("t", location))
    origin_x <- grid::unit(adj_x, "npc") +
      (0.5 - adj_x) * 2 * (pad_x + 0.5 * width)
    origin_y <- grid::unit(adj_y, "npc") +
      (0.5 - adj_y) * 2 * (pad_y + 0.5 * height)

    grid::gTree(
      children = grid::gList(style),
      vp = grid::viewport(
        x = origin_x, y = origin_y,
        height = height, width = width,
        angle = rotation
      )
    )
  }
)

#' @keywords internal
#' @noRd
is_grob_like <- function(x) {
  grid::is.grob(x) || inherits(x, "gList") || inherits(x, "gTree")
}

#' @keywords internal
#' @noRd
# Compute the angle (degrees CCW) from grid-north to true-north
true_north <- function(x, y, crs, delta_crs = 0.1, delta_lat = 0.1) {
  pt_crs <- sf::st_sfc(sf::st_point(c(x, y)), crs = crs)
  pt_ll <- sf::st_transform(pt_crs, crs = 4326)
  ll <- as.data.frame(sf::st_coordinates(pt_ll))
  pt_ll_north <- sf::st_sfc(sf::st_point(c(ll$X, ll$Y + delta_lat)), crs = 4326)
  pt_crs_north <- sf::st_transform(pt_ll_north, crs = crs)
  a0 <- as.data.frame(sf::st_coordinates(pt_crs))
  a1 <- as.data.frame(sf::st_coordinates(pt_crs_north))
  a <- c(x = a1$X - a0$X, y = a1$Y - a0$Y)
  b <- c(x = 0, y = delta_crs)
  num <- sum(a * b)
  den <- sqrt(sum(a * a)) * sqrt(sum(b * b))
  if (!is.finite(num) || !is.finite(den) || den == 0) return(0)
  theta <- acos(max(-1, min(1, num / den)))
  cross <- a[1] * b[2] - a[2] * b[1]
  theta * 180 / pi * sign(cross)[1]
}

#' Classic North Arrow Style (Minimal)
#' @rdname compass-styles
#' @export
north_arrow_classic <- function() {
  grid::gList(
    grid::polygonGrob(
      x = c(0.50, 0.00, 0.50, 1.00),
      y = c(1.00, 0.00, 0.20, 0.00),
      gp = grid::gpar(fill = "black", col = "black")
    ),
    grid::textGrob("N", y = 0.85, gp = grid::gpar(col = "black"))
  )
}

#' Sinan (Ancient Chinese Compass) Style (Simplified)
#' @rdname compass-styles
#' @export
compass_sinan <- function() {
  grid::gList(
    grid::rectGrob(gp = grid::gpar(fill = "#EFE6D0", col = "#9D8D6F")),
    grid::circleGrob(r = 0.45, gp = grid::gpar(col = "#9D8D6F")),
    grid::polygonGrob(
      x = c(0.50, 0.62, 0.92, 0.72, 0.50, 0.28, 0.08, 0.38),
      y = c(0.52, 0.92, 0.72, 0.52, 0.64, 0.52, 0.32, 0.12),
      gp = grid::gpar(fill = "#C05A41", col = "black")
    )
  )
}
