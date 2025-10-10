#' Compass and North Arrow Styles
#'
#' @description
#' A collection of style constructors that return `grid` grobs for use with
#' `annotation_compass(style = ...)`. These styles provide different visual
#' appearances for a compass or north arrow drawn as an annotation.
#'
#' @details
#' Exported constructors documented under this topic:
#' \itemize{
#'   \item \code{north_arrow_classic()}
#'   \item \code{north_arrow_solid()}
#'   \item \code{compass_rose_simple()}
#'   \item \code{compass_rose_classic()}
#'   \item \code{compass_rose_circle()}
#'   \item \code{compass_guiding_fish()}
#'   \item \code{compass_sinan()}
#' }
#'
#' Each constructor returns a grob ready to be passed to \code{annotation_compass(style = ...)}.
#' All styles include an "N" (or cardinal labels) to indicate north.
#'
#' @param fill Fill color(s) for polygons. Vectorized for alternating fills in some styles.
#' @param line_col Stroke color for outlines.
#' @param line_width Stroke width for outlines (numeric).
#' @param text_col Text color for labels.
#' @param text_size Text font size for labels (points).
#' @param text_face Text font face (e.g., "plain", "bold").
#' @param text_family Text font family.
#' @param labels Character vector of cardinal labels, usually `c("N","E","S","W")`.
#' @param sharpness Controls star-point sharpness in rose styles, numeric in [0, 1].
#' @param size Global size scaler (used by some styles).
#' @param ring_ratio Inner/outer radius ratio for ringed styles (0 < value < 1).
#' @param ring_width Stroke width of ring outlines (numeric).
#' @param n_seg Number of ring segments (integer).
#' @param fish_col Fill color for fish shape (guiding fish style).
#' @param fish_shift Vertical shift for fish shape (guiding fish style).
#' @param square_pad Padding around the outer square (Sinan style), fraction of box side.
#' @param ring_outer Outer ring radius (Sinan style), expressed in npc units (0..1).
#' @param label_offset Label offset from the square edges (Sinan style), npc units.
#' @param spoon_fill Fill color for spoon glyph (Sinan style).
#' @param spoon_col Stroke color for spoon glyph (Sinan style).
#' @param spoon_scale Scale factor for spoon glyph (Sinan style).
#' @param inner_fill Fill color for inner disk (Sinan style).
#' @param square_width,outer_width,inner_width,spoon_width Stroke widths for respective elements in Sinan style.
#'
#' @return A `grid` graphical object (grob).
#'
#' @seealso
#' [annotation_compass] for adding the compass to a ggplot.
#'
#' @examples
#' # Standalone preview
#' grid::grid.newpage(); grid::grid.draw(north_arrow_classic())
#' grid::grid.newpage(); grid::grid.draw(north_arrow_solid())
#' grid::grid.newpage(); grid::grid.draw(compass_rose_simple())
#' grid::grid.newpage(); grid::grid.draw(compass_rose_classic())
#' grid::grid.newpage(); grid::grid.draw(compass_rose_circle())
#' grid::grid.newpage(); grid::grid.draw(compass_guiding_fish())
#' grid::grid.newpage(); grid::grid.draw(compass_sinan())
#'
#' # Use in ggplot
#' \donttest{
#' if (requireNamespace("ggplot2", quietly = TRUE) &&
#'     requireNamespace("sf", quietly = TRUE)) {
#'   nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'   p <- ggplot2::ggplot() +
#'     ggplot2::geom_sf(data = nc, fill = "grey90") +
#'     ggplot2::theme_minimal()
#'
#'   p + annotation_compass(location = "tr", style = north_arrow_classic())
#'   p + annotation_compass(location = "bl", style = compass_sinan())
#' }
#' }
#'
#' @name compass-styles
#' @importFrom grid polygonGrob circleGrob rectGrob xsplineGrob linesGrob textGrob
#' @importFrom grid gList gTree viewport unit gpar grobTree
NULL


# ---------- north_arrow_classic ------------------------------------------------
#' @rdname compass-styles
#' @export
north_arrow_classic <- function(
    fill = c("white", "black"),
    line_col = "black",
    line_width = 2,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  width <- 0.25
  indent <- 0.3
  y_coords <- c(tip = 0.85, bottom = 0.0, indent = indent)

  outline_x <- c(0.5, 0.5 - width, 0.5, 0.5 + width)
  outline_y <- c(y_coords["tip"], y_coords["bottom"], y_coords["indent"], y_coords["bottom"])

  fill_x <- c(0.5, 0.5 - width, 0.5, 0.5, 0.5 + width, 0.5)
  fill_y <- c(y_coords["tip"], y_coords["bottom"], y_coords["indent"],
              y_coords["tip"], y_coords["bottom"], y_coords["indent"])
  fill_id <- c(1, 1, 1, 2, 2, 2)

  center_line_x <- c(0.5, 0.5)
  center_line_y <- c(y_coords["indent"], y_coords["tip"])

  text_x <- 0.5
  text_y <- 0.9

  children <- grid::gList(
    grid::polygonGrob(x = fill_x, y = fill_y, id = fill_id,
                      gp = grid::gpar(fill = fill, col = NA)),
    grid::polygonGrob(x = outline_x, y = outline_y,
                      gp = grid::gpar(fill = NA, col = line_col, lwd = line_width)),
    grid::linesGrob(x = center_line_x, y = center_line_y,
                    gp = grid::gpar(col = line_col, lwd = 1)),
    grid::textGrob("N", x = text_x, y = text_y, vjust = 0,
                   gp = grid::gpar(col = text_col, fontsize = text_size,
                                   fontface = text_face, fontfamily = text_family))
  )

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}


# ---------- north_arrow_solid --------------------------------------------------
#' @rdname compass-styles
#' @export
north_arrow_solid <- function(
    fill = "black",
    line_col = "black",
    line_width = 1,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  width <- 0.5
  indent_ratio <- 0.2
  arrow_height <- 0.85

  arrow_x <- c(0.5, 0.5 - width / 2, 0.5, 0.5 + width / 2)
  arrow_y <- c(arrow_height, 0, arrow_height * indent_ratio, 0)

  text_x <- 0.5
  text_y <- 0.9

  children <- grid::gList(
    grid::polygonGrob(
      x = arrow_x, y = arrow_y,
      gp = grid::gpar(fill = fill, col = line_col, lwd = line_width)
    ),
    grid::textGrob("N", x = text_x, y = text_y, vjust = 0,
                   gp = grid::gpar(col = text_col, fontsize = text_size,
                                   fontface = text_face, fontfamily = text_family))
  )

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}


# ---------- compass_rose_simple ------------------------------------------------
#' @rdname compass-styles
#' @export
compass_rose_simple <- function(
    fill = c("white", "black"),
    line_col = "black",
    line_width = 1,
    sharpness = 0.7,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  inset <- 0.25 + (sharpness * 0.2)
  y_scale <- 0.85
  coords <- list(
    center =   c(0.5, 0.5 * y_scale),
    n_tip =    c(0.5, 1.0 * y_scale),
    e_tip =    c(1.0, 0.5 * y_scale),
    s_tip =    c(0.5, 0.0 * y_scale),
    w_tip =    c(0.0, 0.5 * y_scale),
    ne_inner = c(1 - inset, (0.5 + (0.5 * (1 - (inset / 0.5)))) * y_scale),
    se_inner = c(1 - inset, (0.5 - (0.5 * (1 - (inset / 0.5)))) * y_scale),
    sw_inner = c(inset,     (0.5 - (0.5 * (1 - (inset / 0.5)))) * y_scale),
    nw_inner = c(inset,     (0.5 + (0.5 * (1 - (inset / 0.5)))) * y_scale)
  )

  x_coords <- c(
    coords$center[1], coords$nw_inner[1], coords$n_tip[1],
    coords$center[1], coords$n_tip[1],    coords$ne_inner[1],
    coords$center[1], coords$ne_inner[1], coords$e_tip[1],
    coords$center[1], coords$e_tip[1],    coords$se_inner[1],
    coords$center[1], coords$se_inner[1], coords$s_tip[1],
    coords$center[1], coords$s_tip[1],    coords$sw_inner[1],
    coords$center[1], coords$sw_inner[1], coords$w_tip[1],
    coords$center[1], coords$w_tip[1],    coords$nw_inner[1]
  )
  y_coords <- c(
    coords$center[2], coords$nw_inner[2], coords$n_tip[2],
    coords$center[2], coords$n_tip[2],    coords$ne_inner[2],
    coords$center[2], coords$ne_inner[2], coords$e_tip[2],
    coords$center[2], coords$e_tip[2],    coords$se_inner[2],
    coords$center[2], coords$se_inner[2], coords$s_tip[2],
    coords$center[2], coords$s_tip[2],    coords$sw_inner[2],
    coords$center[2], coords$sw_inner[2], coords$w_tip[2],
    coords$center[2], coords$w_tip[2],    coords$nw_inner[2]
  )
  ids <- rep(1:8, each = 3)

  children <- grid::gList(
    grid::polygonGrob(x = x_coords, y = y_coords, id = ids,
                      gp = grid::gpar(fill = fill, col = line_col, lwd = line_width)),
    grid::textGrob("N", x = 0.5, y = 0.9, vjust = 0,
                   gp = grid::gpar(col = text_col, fontsize = text_size,
                                   fontface = text_face, fontfamily = text_family))
  )

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}
# ---------- compass_rose_classic ----------------------------------------------
#' @rdname compass-styles
#' @export
compass_rose_classic <- function(
    fill = c("white", "black"),
    line_col = "black",
    line_width = 1.5,
    sharpness = 0.6,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  center <- c(0.5, 0.5)
  padding <- 0.05
  text_radius <- 0.5 - padding
  cardinal_r <- text_radius - 0.08
  inter_card_r <- cardinal_r * 0.6 * (1 - sharpness)

  angles_rad <- (c(90, 45, 0, 315, 270, 225, 180, 135)) * pi / 180
  radii <- rep(c(cardinal_r, inter_card_r), 4)

  star_coords <- data.frame(
    x = center[1] + radii * cos(angles_rad),
    y = center[2] + radii * sin(angles_rad)
  )

  x_coords <- c()
  y_coords <- c()
  for (i in 1:8) {
    p_current <- as.numeric(star_coords[i, ])
    p_next <- as.numeric(star_coords[ifelse(i == 8, 1, i + 1), ])
    x_coords <- c(x_coords, center[1], p_current[1], p_next[1])
    y_coords <- c(y_coords, center[2], p_current[2], p_next[2])
  }
  ids <- rep(1:8, each = 3)
  fill <- rep(fill, 4)

  labels <- c("N", "E", "S", "W")
  label_coords <- data.frame(
    x = center[1] + c(0, text_radius, 0, -text_radius),
    y = center[2] + c(text_radius, 0, -text_radius, 0)
  )

  children <- grid::gList(
    grid::polygonGrob(x = x_coords, y = y_coords, id = ids,
                      gp = grid::gpar(fill = fill, col = line_col, lwd = line_width)),
    grid::textGrob(labels, x = label_coords$x, y = label_coords$y,
                   hjust = c(0.5, 0, 0.5, 1), vjust = c(0, 0.5, 1, 0.5),
                   gp = grid::gpar(col = text_col, fontsize = text_size,
                                   fontface = text_face, fontfamily = text_family))
  )

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}


# ---------- compass_rose_circle -----------------------------------------------
#' @rdname compass-styles
#' @export
compass_rose_circle <- function(
    fill = "white",
    line_col = "black",
    line_width = 3,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  center <- c(0.5, 0.5)
  max_r <- 0.45

  n_pointer_x <- center[1] + c(-max_r * 0.15, max_r * 0.15, 0)
  n_pointer_y <- center[2] + c(max_r * 0.3, max_r * 0.3, max_r * 0.98)

  angles_rad <- c(0, -90, -180, -270) * pi / 180
  rotated_coords <- sapply(angles_rad, function(angle) {
    x_shifted <- n_pointer_x - center[1]
    y_shifted <- n_pointer_y - center[2]
    x_rot <- x_shifted * cos(angle) - y_shifted * sin(angle) + center[1]
    y_rot <- x_shifted * sin(angle) + y_shifted * cos(angle) + center[2]
    c(x_rot, y_rot)
  })

  pointers_grob <- grid::polygonGrob(
    x = rotated_coords[1:3, ], y = rotated_coords[4:6, ],
    id = rep(1:4, each = 3),
    gp = grid::gpar(fill = line_col, col = NA)
  )

  circle_grob <- grid::circleGrob(
    x = center[1], y = center[2], r = max_r * 0.5,
    gp = grid::gpar(fill = fill, col = line_col, lwd = line_width)
  )

  labels <- c("N", "E", "S", "W")
  label_coords <- data.frame(
    x = center[1] + c(0, max_r, 0, -max_r),
    y = center[2] + c(max_r, 0, -max_r, 0)
  )

  text_grob <- grid::textGrob(
    label = labels, x = label_coords$x, y = label_coords$y,
    hjust = c(0.5, 0, 0.5, 1), vjust = c(0, 0.5, 1, 0.5),
    gp = grid::gpar(col = text_col, fontsize = text_size,
                    fontface = text_face, fontfamily = text_family)
  )

  children <- grid::gList(pointers_grob, circle_grob, text_grob)

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}


# ---------- compass_guiding_fish ----------------------------------------------
#' @rdname compass-styles
#' @export
compass_guiding_fish <- function(
    size = 1,
    ring_ratio = 0.2,
    ring_width = 2,
    n_seg = 16,
    fish_col = "black",
    fish_shift = -0.03,
    text_col = "black",
    text_size = 12,
    text_face = "plain",
    text_family = ""
) {
  center <- 0.5
  outer_r <- 0.42 * size
  inner_r <- outer_r * (1 - ring_ratio)
  if (inner_r <= 0) stop("`ring_ratio` too large: inner radius <= 0")

  fish_shape_x <- c(0.10, 0.40, 0.75, 0.95, 0.87, 0.87, 0.95, 0.75, 0.40)
  fish_shape_y <- c(0.50, 0.57, 0.52, 0.58, 0.52, 0.48, 0.42, 0.48, 0.43)
  x_rot <- center - (fish_shape_y - center)
  y_rot <- center + (fish_shape_x - center)

  rel_scale <- (inner_r / outer_r) * 0.9
  scale_factor <- size * rel_scale
  fish_x <- center + (x_rot - center) * scale_factor
  fish_y <- center + (y_rot - center) * scale_factor + fish_shift * size

  fish_grob <- grid::xsplineGrob(
    x = fish_x, y = fish_y,
    shape = -0.4, open = FALSE,
    gp = grid::gpar(fill = fish_col, col = NA)
  )
  eye_grob <- grid::circleGrob(
    x = 0.5, y = 0.28 + fish_shift * size,
    r = 0.015 * (scale_factor / 0.85),
    gp = grid::gpar(fill = "white", col = NA)
  )

  theta <- seq(0, 2*pi, length.out = n_seg + 1)
  ring_grobs <- lapply(seq_len(n_seg), function(i) {
    outer <- cbind(center + outer_r * cos(seq(theta[i], theta[i+1], length.out = 30)),
                   center + outer_r * sin(seq(theta[i], theta[i+1], length.out = 30)))
    inner <- cbind(center + inner_r * cos(seq(theta[i+1], theta[i], length.out = 30)),
                   center + inner_r * sin(seq(theta[i+1], theta[i], length.out = 30)))
    coords <- rbind(outer, inner)
    grid::polygonGrob(
      x = coords[,1], y = coords[,2],
      gp = grid::gpar(
        fill = ifelse(i %% 2, "black", "white"),
        col = "black", lwd = ring_width
      )
    )
  })

  dirs <- c("N","W","S","E")
  ang  <- c(90, 180, 270, 0) * pi/180
  tx   <- center + (outer_r + 0.05*size) * cos(ang)
  ty   <- center + (outer_r + 0.05*size) * sin(ang)
  text_grob <- grid::textGrob(
    dirs, x = tx, y = ty,
    hjust = c(0.5,1,0.5,0), vjust = c(0,0.5,1,0.5),
    gp = grid::gpar(
      col = text_col,
      fontsize = text_size * size,
      fontface = text_face,
      fontfamily = text_family
    )
  )

  children <- do.call(grid::gList,
                      c(ring_grobs, list(fish_grob, eye_grob, text_grob)))

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}


# ---------- compass_sinan ------------------------------------------------------
#' @rdname compass-styles
#' @export
compass_sinan <- function(
    line_col     = "black",
    square_pad   = 0.10,
    ring_outer   = 0.35,
    ring_ratio   = 0.65,
    labels       = c("N","E","S","W"),
    text_size    = 12,
    text_face    = "plain",
    text_family  = "",
    text_col     = "black",
    label_offset = 0.05,
    spoon_fill   = "black",
    spoon_col    = "black",
    spoon_scale  = 0.8,
    inner_fill   = "lightgrey",
    square_width = 2,
    outer_width  = 2,
    inner_width  = 1,
    spoon_width  = 1
) {
  max_r <- (1 - 2 * square_pad) / 2
  r_out <- min(ring_outer, max_r * 0.999)
  r_in  <- r_out * ring_ratio
  shift_y <- -0.12

  square_grob <- grid::rectGrob(0.5, 0.5, 1 - 2*square_pad, 1 - 2*square_pad,
                                gp = grid::gpar(fill = NA, col = line_col, lwd = square_width))
  circle_outer <- grid::circleGrob(0.5, 0.5, r_out,
                                   gp = grid::gpar(fill = NA, col = line_col, lwd = outer_width))
  circle_inner <- grid::circleGrob(0.5, 0.5, r_in,
                                   gp = grid::gpar(fill = inner_fill, col = line_col, lwd = inner_width))

  handle <- grid::xsplineGrob(
    x = 0.5 + (c(0.49,0.47,0.46,0.50,0.54,0.53,0.51) - 0.5) * spoon_scale,
    y = 0.5 + (c(0.30,0.55,0.68,0.72,0.68,0.55,0.30) - 0.5) * spoon_scale + shift_y,
    shape = -0.5, open = FALSE,
    gp = grid::gpar(fill = spoon_fill, col = spoon_col, lwd = spoon_width)
  )

  theta <- seq(0, 2*pi, length.out = 200)
  ellipse <- grid::polygonGrob(
    x = 0.5 + (0.12*0.85*spoon_scale) * cos(theta),
    y = 0.5 + (0.78-0.5)*spoon_scale + shift_y + (0.15*0.85*spoon_scale) * sin(theta),
    gp = grid::gpar(fill = spoon_fill, col = spoon_col, lwd = spoon_width)
  )

  half_side <- (1 - 2 * square_pad) / 2
  coords <- data.frame(
    x = c(0.5, 0.5 + half_side + label_offset, 0.5, 0.5 - half_side - label_offset),
    y = c(0.5 + half_side + label_offset, 0.5, 0.5 - half_side - label_offset, 0.5),
    hjust = c(0.5, 0, 0.5, 1), vjust = c(0, 0.5, 1, 0.5)
  )
  text_grob <- grid::textGrob(labels, x = coords$x, y = coords$y,
                              hjust = coords$hjust, vjust = coords$vjust,
                              gp = grid::gpar(col = text_col, fontsize = text_size,
                                              fontface = text_face, fontfamily = text_family))

  children <- grid::gList(square_grob, circle_outer, circle_inner,
                          handle, ellipse, text_grob)

  grid::gTree(children = children,
              vp = grid::viewport(width = grid::unit(1,"snpc"), height = grid::unit(1,"snpc")))
}
