#' Add a Spatially-Aware Scale Bar
#'
#' @description
#' `annotation_scalebar()` adds a projection-aware scale bar to a `ggplot2` map.
#' It detects the map's CRS and chooses a readable width and units automatically.
#' Robust fallbacks prevent "zero-length unit" errors and allow the scale bar
#' to render even when CRS information is limited.
#'
#' Supported styles:
#' - `"segment"` (minimal horizontal bar with ticks and labels)
#' - `"ticks"` (baseline + vertical ticks)
#' - `"bar"` (alternating black/white blocks)
#'
#' @details
#' * If a **projected CRS** is in use (e.g., UTM/AEQD with meters), the scale bar
#'   is accurate in native units.
#' * If a **geographic CRS** (EPSG:4326, degrees) is in use, distances vary with
#'   latitude. The `geographic_mode` parameter controls how to display the scale:
#'   - `"approx_m"` (default): approximate meters/kilometers using great-circle
#'     distance at the panel's center latitude. A warning is issued.
#'   - `"degrees"`: display raw degree units (e.g., `1°`) without converting to meters.
#' * You can also override the width with `fixed_width` (in native CRS units).
#'
#' @section Dependencies:
#' Requires **ggplot2**, **sf**, and **grid**.
#'
#' @param mapping,data Standard ggplot2 layer arguments (typically unused).
#' @param ... Additional parameters passed to the layer (rarely needed).
#' @param location Character. One of `"bl"`, `"br"`, `"tr"`, `"tl"`. Placement relative
#'   to panel edges. Default: `"bl"`.
#' @param style Character. Scale bar style: `"segment"` (default), `"bar"`, or `"ticks"`.
#' @param fixed_width Numeric. Force the bar width in *native CRS units* (e.g., meters).
#'   Overrides automatic width selection.
#' @param crs_unit Character. Units of the CRS (e.g., `"m"`, `"ft"`, `"°"`). Usually
#'   auto-detected; set only when auto-detection is not possible.
#' @param crs `sf::st_crs` object or proj string. Fallback CRS if the plot does not
#'   provide one (e.g., when not using `coord_sf()`).
#' @param display_unit Character. Force display units (e.g., `"m"`, `"km"`). Ignored
#'   when `geographic_mode = "degrees"`.
#' @param unit_labels Named character vector for i18n, e.g., `c(km = "Kilometers", m = "Meters", "°" = "°")`.
#' @param width_hint Numeric in (0, 1]. Target fraction of panel width used by the bar.
#'   Default: `0.25`.
#' @param unit_category Character: `"metric"` (default) or `"imperial"`. Affects auto-promotion
#'   (m→km, ft→mi).
#' @param bar_cols Character(2). Colors for `"bar"` style alternating blocks. Default: `c("black", "white")`.
#' @param line_width Numeric. Line thickness for outlines/ticks. Default: `1`.
#' @param height `grid::unit`. Bar height. Default: `unit(0.25, "cm")`.
#' @param pad_x,pad_y `grid::unit`. Padding from panel edges. Default: `0.25 cm`.
#' @param text_pad `grid::unit`. Gap between bar and labels. Default: `0.15 cm`.
#' @param text_cex,text_face,text_family Font settings for labels. Defaults: `0.7`, `NULL`, `""`.
#' @param tick_height Numeric in [0,1]. Relative height of interior ticks for `"ticks"` style. Default: `0.6`.
#' @param segments Integer. For `"segment"` style, number of major divisions; if `NULL`,
#'   an automatic, readable choice is used.
#' @param label_show Which ticks get labels: `"ends"` (default), `"all"`, `"major"`,
#'   numeric frequency (e.g., `2`), or a numeric vector of indices (1-based).
#' @param minor_tick_height Numeric in [0,1]. For `"segment"` style, minor ticks’ relative height. Default: `0`.
#' @param geographic_mode Character. For **geographic CRS** only:
#'   - `"approx_m"`: approximate meters/kilometers (default; warns about approximation)
#'   - `"degrees"`: display degrees directly (no metric conversion)
#' @param text_col,line_col Colors for labels and outlines/ticks. Defaults: `"black"`, `"black"`.
#'
#' @return A `ggplot2` layer object representing the scale bar.
#'
#' @examplesIf require("ggplot2") && require("sf")
#' nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' base_plot <- ggplot2::ggplot() +
#'   ggplot2::geom_sf(data = nc, fill = "grey90") +
#'   ggplot2::theme_minimal()
#'
#' # Example 1: Projected CRS (accurate, auto-sized)
#' base_plot + ggplot2::coord_sf(crs = 32617) +
#'   annotation_scalebar(location = "bl")
#'
#' # Example 2: Ticks style, top-right
#' base_plot + ggplot2::coord_sf(crs = 32617) +
#'   annotation_scalebar(location = "tr", style = "ticks")
#'
#' # Example 3: Geographic CRS (EPSG:4326), approximate meters (warns)
#' base_plot + ggplot2::coord_sf(crs = 4326) +
#'   annotation_scalebar(location = "bl", geographic_mode = "approx_m")
#'
#' # Example 4: Geographic CRS, display in degrees
#' base_plot + ggplot2::coord_sf(crs = 4326) +
#'   annotation_scalebar(location = "bl", geographic_mode = "degrees")
#'
#' # Example 5: Force a 100 km bar (projected CRS)
#' base_plot + ggplot2::coord_sf(crs = 32617) +
#'   annotation_scalebar(location = "bl", fixed_width = 100000, display_unit = "km")
#'
#' @export
#' @import ggplot2
#' @importFrom grid unit unit.c gpar segmentsGrob textGrob gList rectGrob grobWidth nullGrob
#' @importFrom sf st_is_longlat st_coordinates st_transform st_as_sf st_crs st_sfc st_point
annotation_scalebar <- function(mapping = NULL, data = NULL, ...,
                                location = "bl",
                                style = "segment",
                                fixed_width = NULL,
                                crs_unit = NULL,
                                crs = NULL,
                                display_unit = NULL,
                                unit_labels = NULL,
                                width_hint = 0.25,
                                unit_category = "metric",
                                bar_cols = c("black", "white"),
                                line_width = 1,
                                height = grid::unit(0.25, "cm"),
                                pad_x = grid::unit(0.25, "cm"),
                                pad_y = grid::unit(0.25, "cm"),
                                text_pad = grid::unit(0.15, "cm"),
                                text_cex = 0.7,
                                text_face = NULL,
                                text_family = "",
                                tick_height = 0.6,
                                segments = NULL,
                                label_show = "ends",
                                minor_tick_height = 0.5,
                                geographic_mode = c("approx_m", "degrees"),
                                text_col = "black",
                                line_col = "black") {

  geographic_mode <- match.arg(geographic_mode)

  # Prepare per-panel constants as "data" for the Geom
  layer_data <- data.frame(
    location = location,
    width_hint = width_hint,
    unit_category = unit_category,
    text_col = text_col,
    line_col = line_col
  )

  ggplot2::layer(
    data = layer_data,
    mapping = mapping,
    stat = ggplot2::StatIdentity,
    geom = GeomScaleBar,
    position = ggplot2::PositionIdentity,
    show.legend = FALSE,
    inherit.aes = FALSE,
    params = list(
      ...,
      style = style,
      fixed_width = fixed_width,
      crs_unit = crs_unit,
      crs = crs,
      display_unit = display_unit,
      unit_labels = unit_labels,
      bar_cols = bar_cols,
      line_width = line_width,
      height = height,
      pad_x = pad_x,
      pad_y = pad_y,
      text_pad = text_pad,
      text_cex = text_cex,
      text_face = text_face,
      text_family = text_family,
      tick_height = tick_height,
      segments = segments,
      label_show = label_show,
      minor_tick_height = minor_tick_height,
      geographic_mode = geographic_mode
    )
  )
}

#' @rdname annotation_scalebar
#' @export
GeomScaleBar <- ggplot2::ggproto(
  "GeomScaleBar", ggplot2::Geom,
  extra_params = c("na.rm", "crs"),
  handle_na = function(data, params) data,
  # Defaults here are overwritten by layer_data from annotation_scalebar()
  default_aes = ggplot2::aes(
    width_hint = 0.25, location = "bl", unit_category = "metric",
    text_col = "black", line_col = "black"
  ),
  draw_panel = function(self, data, panel_params, coordinates,
                        style, fixed_width, crs_unit, crs,
                        display_unit, unit_labels,
                        bar_cols, line_width, height,
                        pad_x, pad_y, text_pad, text_cex,
                        text_face, text_family, tick_height,
                        segments, label_show, minor_tick_height,
                        geographic_mode) {

    # Ensure finite, non-degenerate panel ranges
    x_range <- panel_params$x_range
    y_range <- panel_params$y_range
    if (is.null(x_range) || is.null(y_range) ||
        !all(is.finite(x_range)) || !all(is.finite(y_range)) ||
        (x_range[2] - x_range[1]) == 0 || (y_range[2] - y_range[1]) == 0) {
      return(grid::nullGrob())
    }

    # Read per-layer details (first row)
    details <- data[1, intersect(
      c("width_hint", "location", "unit_category", "text_col", "line_col"),
      names(data)
    )]

    # Prefer panel CRS; else fallback to injected crs (may be NULL)
    sf_crs <- if (!is.null(panel_params$crs)) panel_params$crs else crs

    sf_bbox <- c(
      xmin = x_range[1], xmax = x_range[2],
      ymin = y_range[1], ymax = y_range[2]
    )

    # Compute parameters for drawing
    params <- scalebar_params(
      sf_bbox = sf_bbox,
      crs_unit = crs_unit,
      widthhint = details$width_hint,
      unitcategory = details$unit_category,
      sf_crs = sf_crs,
      fixed_width = fixed_width,
      display_unit = display_unit,
      unit_labels = unit_labels,
      geographic_mode = geographic_mode
    )

    # Draw grobs
    grob_scalebar(
      params = params,
      style = style,
      location = details$location,
      bar_cols = bar_cols,
      line_width = line_width,
      line_col = details$line_col,
      height = height,
      pad_x = pad_x,
      pad_y = pad_y,
      text_pad = text_pad,
      text_cex = text_cex,
      text_col = details$text_col,
      text_face = text_face,
      text_family = text_family,
      tick_height = tick_height,
      segments = segments,
      label_show = label_show,
      minor_tick_height = minor_tick_height
    )
  }
)

# ===== Internal helpers =====================================================

#' @keywords internal
#' @noRd
scalebar_params <- function(sf_bbox, crs_unit = NULL, sf_crs = NULL,
                            widthhint = 0.25, unitcategory = "metric",
                            fixed_width = NULL, display_unit = NULL,
                            unit_labels = NULL,
                            geographic_mode = "approx_m") {

  # Validate widthhint
  if (is.null(widthhint) || !is.finite(widthhint) || widthhint <= 0 || widthhint > 1) {
    widthhint <- 0.25
  }

  # Base panel width in native units of the current CRS
  plotwidth_base <- (sf_bbox["xmax"] - sf_bbox["xmin"])
  if (!is.finite(plotwidth_base) || plotwidth_base <= 0) {
    plotwidth_base <- 1 # guard against zero/invalid width
  }

  # Determine unitcategory
  unitcategory <- match.arg(unitcategory, c("metric", "imperial"))

  # Determine CRS units
  plot_crs_unit <- NULL

  if (!is.null(sf_crs)) {
    if (sf::st_is_longlat(sf_crs)) {
      # Geographic CRS (degrees)
      if (identical(geographic_mode, "approx_m")) {
        # Warn about approximation (once per call)
        warning("Scale bar is approximate in geographic CRS (degrees). ",
                "Distances vary with latitude. For accuracy, use a projected CRS, ",
                "or set `geographic_mode = \"degrees\"`.", call. = FALSE)

        # Estimate width in meters at mid-latitude using great-circle distance
        point_coords <- expand.grid(
          x = c(sf_bbox["xmin"], sf_bbox["xmax"]),
          y = c(sf_bbox["ymin"], mean(c(sf_bbox["ymin"], sf_bbox["ymax"])), sf_bbox["ymax"])
        )
        latlon_coords <- sf::st_coordinates(
          sf::st_transform(sf::st_as_sf(point_coords, coords = c("x","y"), crs = sf_crs), 4326)
        )
        widths <- c(
          .geodist(latlon_coords[1,], latlon_coords[2,]),
          .geodist(latlon_coords[3,], latlon_coords[4,]),
          .geodist(latlon_coords[5,], latlon_coords[6,])
        )
        plotwidth_base <- widths[2] # take center row estimate
        plot_crs_unit  <- "m"
      } else {
        # geographic_mode == "degrees": display in degrees directly
        plotwidth_base <- (sf_bbox["xmax"] - sf_bbox["xmin"])
        plot_crs_unit  <- "\u00B0"
      }
    } else {
      # Projected CRS
      plotwidth_base <- (sf_bbox["xmax"] - sf_bbox["xmin"])
      detected_unit  <- sf::st_crs(sf_crs)$units
      if (!is.null(detected_unit) && nzchar(detected_unit)) {
        plot_crs_unit <- detected_unit
      }
    }
  }

  # Fallback if still unknown (no CRS available)
  if (is.null(plot_crs_unit)) {
    plot_crs_unit <- if (!is.null(crs_unit) && nzchar(crs_unit)) crs_unit else "unknown"
    if (!is.finite(plotwidth_base) || plotwidth_base <= 0) {
      plotwidth_base <- (sf_bbox["xmax"] - sf_bbox["xmin"])
      if (!is.finite(plotwidth_base) || plotwidth_base <= 0) plotwidth_base <- 1
    }
  }

  # Choose base width (in native units)
  if (!is.null(fixed_width) && is.finite(fixed_width) && fixed_width > 0) {
    widthu_base <- fixed_width
    # Heuristic divisions
    if      (widthu_base %% 5 == 0) majordivs <- 5
    else if (widthu_base %% 4 == 0) majordivs <- 4
    else if (widthu_base %% 2 == 0) majordivs <- 2
    else                            majordivs <- 1
  } else {
    targetwidth_base <- plotwidth_base * widthhint
    if (identical(plot_crs_unit, "\u00B0") && identical(geographic_mode, "degrees")) {
      widthu_base <- targetwidth_base
      majordivs   <- 2
    } else {
      power10      <- floor(log10(max(targetwidth_base, 1)))
      candidates   <- c(1, 2, 5, 10)
      options      <- candidates * (10^power10)
      best_idx     <- which.min(abs(options - targetwidth_base))
      widthu_base  <- options[best_idx]
      majordivs    <- candidates[best_idx]
    }
  }

  # Defensive guards
  if (!is.finite(widthu_base) || widthu_base <= 0) widthu_base <- 1
  if (!is.finite(majordivs)   || majordivs < 1)    majordivs   <- 1

  # Auto-promotion for display
  auto_unit <- plot_crs_unit
  auto_widthu_display <- widthu_base

  if (identical(plot_crs_unit, "m") && identical(unitcategory, "metric") && widthu_base >= 1000) {
    auto_unit <- "km"
    auto_widthu_display <- widthu_base / 1000
  } else if (identical(plot_crs_unit, "ft") && identical(unitcategory, "imperial") && widthu_base >= 5280) {
    auto_unit <- "mi"
    auto_widthu_display <- widthu_base / 5280
  } else if (identical(plot_crs_unit, "\u00B0")) {
    auto_unit <- "\u00B0"
    auto_widthu_display <- widthu_base
  }

  # Override display unit if requested (not for degrees mode)
  final_unit <- if (!is.null(display_unit) && nzchar(display_unit) && !identical(plot_crs_unit, "\u00B0")) {
    display_unit
  } else auto_unit

  widthu_display <- auto_widthu_display
  if (!is.null(display_unit) && nzchar(display_unit) && !identical(plot_crs_unit, "\u00B0")) {
    conv <- if (identical(unitcategory, "metric")) c(m = 1, km = 1000) else c(ft = 1, mi = 5280)
    if (!is.null(conv[final_unit])) {
      widthu_display <- widthu_base / conv[final_unit]
    }
  }

  # Label text (i18n if provided)
  display_unit_text <- if (!is.null(unit_labels) && !is.null(unit_labels[[final_unit]])) {
    unit_labels[[final_unit]]
  } else {
    final_unit
  }

  widthnpc    <- widthu_base / plotwidth_base
  if (!is.finite(widthnpc) || widthnpc <= 0) widthnpc <- 1e-6
  majordivnpc <- widthnpc / majordivs

  list(
    widthnpc = widthnpc,
    widthu   = widthu_display,
    majordivs = majordivs,
    majordivnpc = majordivnpc,
    unit = display_unit_text,
    labeltext = paste(widthu_display, display_unit_text)
  )
}

#' @keywords internal
#' @noRd
grob_scalebar <- function(params, style, location,
                          bar_cols, line_width, line_col, height,
                          pad_x, pad_y, text_pad, text_cex,
                          text_col, text_face, text_family, tick_height,
                          segments, label_show, minor_tick_height) {
  style    <- match.arg(style, c("segment", "ticks", "bar"))
  location <- match.arg(location, c("bl", "br", "tr", "tl"))

  # Ensure valid major divisions
  if (is.null(params$majordivs) || !is.finite(params$majordivs) || params$majordivs < 1) {
    params$majordivs <- 1
  }

  # Placement anchors
  adj_x <- as.numeric(grepl("r", location)) # 0 left, 1 right
  adj_y <- as.numeric(grepl("t", location)) # 0 bottom, 1 top

  width    <- grid::unit(params$widthnpc, "npc")
  origin_x <- grid::unit(adj_x, "npc") - adj_x * width + (0.5 - adj_x) * 2 * pad_x
  origin_y <- grid::unit(adj_y, "npc") - adj_y * height + (0.5 - adj_y) * 2 * pad_y

  gp_text <- grid::gpar(cex = text_cex, col = text_col, fontfamily = text_family, fontface = text_face)

  if (identical(style, "segment")) {
    n_divs <- if (!is.null(segments) && is.finite(segments) && segments >= 1) as.integer(segments) else params$majordivs
    if (n_divs < 1) n_divs <- 1
    n_ticks <- n_divs + 1

    tick_interval_npc <- params$widthnpc / n_divs
    tick_pos_npc      <- (0:n_divs) * tick_interval_npc
    tick_interval_u   <- params$widthu / n_divs

    all_labels <- prettyNum((0:n_divs) * tick_interval_u, digits = 10, scientific = FALSE)

    tick_height_ratios <- rep(minor_tick_height, n_ticks)
    tick_height_ratios[c(1, n_ticks)] <- 1
    if (n_divs %% 2 == 0 && n_divs > 0) {
      mid_index <- (n_divs / 2) + 1
      tick_height_ratios[mid_index] <- 1
    }

    tick_y1 <- origin_y + height * tick_height_ratios

    # label indices
    indices_to_show <- integer(0)
    if (is.character(label_show)) {
      if (identical(label_show, "all")) indices_to_show <- seq_len(n_ticks)
      else if (identical(label_show, "ends")) indices_to_show <- c(1, n_ticks)
      else if (identical(label_show, "major")) indices_to_show <- which(tick_height_ratios == 1)
    } else if (is.numeric(label_show)) {
      if (length(label_show) == 1) {
        every_n <- max(1L, as.integer(label_show))
        indices_to_show <- union(seq(1, n_ticks, by = every_n), c(1, n_ticks))
      } else {
        indices_to_show <- unique(as.integer(label_show[label_show >= 1 & label_show <= n_ticks]))
      }
    }

    labels_to_show    <- all_labels[indices_to_show]
    tick_pos_to_show  <- tick_pos_npc[indices_to_show]

    # Append unit to the last label when shown
    labels_with_unit <- labels_to_show
    if (length(labels_with_unit) > 0 && n_ticks %in% indices_to_show) {
      last_idx <- which(indices_to_show == n_ticks)
      if (length(last_idx) > 0) {
        labels_with_unit[last_idx] <- paste(labels_to_show[last_idx], params$unit)
      }
    }

    # Avoid label overflow by offsetting bar a bit
    if (adj_x == 1 && n_ticks %in% indices_to_show) {
      last_grob <- grid::textGrob(label = labels_with_unit[length(labels_with_unit)], gp = gp_text)
      origin_x  <- origin_x - 0.5 * grid::grobWidth(last_grob)
    }
    if (adj_x == 0 && 1 %in% indices_to_show) {
      first_grob <- grid::textGrob(label = labels_with_unit[1], gp = gp_text)
      origin_x   <- origin_x + 0.5 * grid::grobWidth(first_grob)
    }

    horizontal_line <- grid::segmentsGrob(
      x0 = origin_x, y0 = origin_y,
      x1 = origin_x + width, y1 = origin_y,
      gp = grid::gpar(lwd = line_width, col = line_col)
    )

    vertical_ticks <- grid::segmentsGrob(
      x0 = origin_x + grid::unit(tick_pos_npc, "npc"), y0 = origin_y,
      x1 = origin_x + grid::unit(tick_pos_npc, "npc"), y1 = tick_y1,
      gp = grid::gpar(lwd = line_width, col = line_col)
    )

    bar_grob <- grid::gList(horizontal_line, vertical_ticks)

    text_grob <- grid::textGrob(
      label = labels_with_unit,
      x = origin_x + grid::unit(tick_pos_to_show, "npc"),
      y = origin_y + height + text_pad,
      hjust = 0.5, vjust = 0,
      gp = gp_text
    )

    return(grid::gList(bar_grob, text_grob))

  } else if (identical(style, "ticks")) {

    tick_x <- origin_x + grid::unit((seq_len(params$majordivs + 1) - 1) * params$majordivnpc, "npc")
    tick_y <- origin_y + grid::unit.c(height, rep(height * tick_height, max(0, params$majordivs - 1)), height)

    ticks <- grid::segmentsGrob(
      x0 = tick_x, y0 = origin_y,
      x1 = tick_x, y1 = tick_y,
      gp = grid::gpar(lwd = line_width, col = line_col)
    )

    baseline <- grid::segmentsGrob(
      x0 = origin_x, y0 = origin_y,
      x1 = origin_x + width, y1 = origin_y,
      gp = grid::gpar(lwd = line_width, col = line_col)
    )

    label <- grid::textGrob(
      label = params$labeltext,
      x = origin_x + width, y = origin_y + height + text_pad,
      hjust = 1, vjust = 0, gp = gp_text
    )

    return(grid::gList(baseline, ticks, label))

  } else { # "bar"
    block_x <- origin_x + grid::unit((seq_len(params$majordivs) - 1) * params$majordivnpc, "npc")

    rects <- grid::rectGrob(
      x = block_x, y = origin_y,
      width = grid::unit(params$majordivnpc, "npc"),
      height = height,
      hjust = 0, vjust = 0,
      gp = grid::gpar(fill = rep(bar_cols, length.out = params$majordivs), col = line_col, lwd = line_width)
    )

    label <- grid::textGrob(
      label = params$labeltext,
      x = origin_x + grid::unit(params$widthnpc, "npc"),
      y = origin_y + height + text_pad,
      hjust = 1, vjust = 0, gp = gp_text
    )

    return(grid::gList(rects, label))
  }
}

#' @keywords internal
#' @noRd
.geodist <- function(p1, p2) {
  # Great-circle distance (haversine) in meters
  R <- 6371000
  p1 <- p1 * pi / 180
  p2 <- p2 * pi / 180
  dlon <- p2[1] - p1[1]
  dlat <- p2[2] - p1[2]
  a <- sin(dlat / 2)^2 + cos(p1[2]) * cos(p2[2]) * sin(dlon / 2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R * c
}
