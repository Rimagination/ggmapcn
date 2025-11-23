#' Global graticule annotation for ggplot2 maps
#'
#' @description
#' Draw global latitude-longitude graticules with degree labels as annotation
#' layers for `ggplot2` maps. Graticules are constructed in geographic
#' coordinates (EPSG:4326) over a user-defined window (given by `xlim`/`ylim`,
#' default: the full globe), optionally split at the antimeridian according to
#' the target CRS, and then transformed into the map CRS. Regional maps usually
#' do not need this function and can rely on the default `coord_sf()` axes.
#'
#' @details
#' Graticules are always generated in WGS84 longitude-latitude (EPSG:4326).
#' When a non-zero central meridian (`lon_0`) is detected in the target CRS,
#' meridians and parallels can be split at the antimeridian via
#' `sf::st_break_antimeridian()` before being transformed, which avoids
#' unexpected line wrapping in projections centred away from 0 degrees.
#'
#' Latitude labels at +/-90 degrees are always omitted. When drawing a full-globe
#' longitude-latitude map with a 0 degree central meridian (that is, when `xlim` and
#' `ylim` are both `NULL` and the CRS is geographic with `lon_0 = 0`),
#' longitude labels at +/-180 degrees are omitted (the corresponding graticule lines may
#' still be drawn).
#'
#' @param xlim Numeric vector of length 2 giving the longitude range in degrees
#'   as `c(xmin, xmax)` in longitude-latitude (WGS84, EPSG:4326). Longitudes are
#'   interpreted in `[-180, 180]`. If both `xlim` and `ylim` are `NULL`
#'   (default), the full globe `(-180, 180)` is used.
#'
#' @param ylim Numeric vector of length 2 giving the latitude range in degrees
#'   as `c(ymin, ymax)` in longitude-latitude (WGS84, EPSG:4326). Latitudes are
#'   interpreted in `[-90, 90]`. If both `xlim` and `ylim` are `NULL`
#'   (default), the full globe `(-90, 90)` is used.
#'
#' @param crs Target coordinate reference system for the graticule, given
#'   as a PROJ string or `sf::crs` object. This should match the CRS used in
#'   your map layers and `coord_sf()`. The default is a WGS84 longitude-
#'   latitude definition.
#'
#' @param lon_step Spacing in degrees between meridians. Default is `60`.
#' @param lat_step Spacing in degrees between parallels. Default is `30`.
#'
#' @param line_color Line colour for graticule lines. Default is `"grey70"`.
#' @param line_width Line width for graticule lines. Default is `0.3`.
#' @param line_type Line type for graticule lines. Default is `"dashed"`.
#'
#' @param label_color Text colour for labels. Default is `"grey30"`.
#' @param label_size Text size for labels, passed to `ggplot2::geom_text()`.
#'   Default is `3`.
#'
#' @param label_offset Common offset applied to all labels, in the units of the
#'   target CRS. For geographic CRSs (degrees), this is interpreted as degrees
#'   (default `5`). For projected CRSs (e.g. metres), you typically need a much
#'   larger value (e.g. `3e5` for Robinson or azimuthal projections).
#' @param label_offset_lon Optional offset applied only to longitude labels.
#'   If supplied, this overrides `label_offset` for longitude labels.
#' @param label_offset_lat Optional offset applied only to latitude labels.
#'   If supplied, this overrides `label_offset` for latitude labels.
#'
#' @param sides Character vector indicating on which sides labels should be
#'   drawn. Any combination of `"bottom"`, `"top"`, `"left"`, `"right"`.
#'   Default is `c("left", "bottom")`.
#'
#' @param ... Additional arguments forwarded to `ggplot2::geom_sf()` for the
#'   graticule line layer (for example, `alpha`).
#'
#' @return A list of two `ggplot2` layers: a `geom_sf()` layer for graticule
#'   lines and a `geom_text()` layer for the labels.
#'
#' @examples
#' library(ggplot2)
#'
#' \donttest{
#' # 1. Graticule on a WGS84 world map
#' ggplot() +
#'   geom_world() +
#'   annotation_graticule(
#'     lon_step     = 60,
#'     lat_step     = 30,
#'     label_offset = 5
#'   ) +
#'   coord_sf(crs = "+proj=longlat +datum=WGS84") +
#'   theme_void()
#'
#' # 2. Robinson projection centred at 150E
#' crs_robin_150 <- "+proj=robin +lon_0=150 +datum=WGS84"
#'
#' ggplot() +
#'   geom_world(crs = crs_robin_150) +
#'   annotation_graticule(
#'     crs           = crs_robin_150,
#'     lon_step      = 30,
#'     lat_step      = 15,
#'     label_offset = 3e5
#'   ) +
#'   coord_sf(crs = crs_robin_150) +
#'   theme_void()
#'
#' # 3. Regional China map (long-lat) with graticule lines and axis labels
#' cn_xlim <- c(70, 140)
#' cn_ylim <- c(0, 60)
#'
#' ggplot() +
#'   geom_world() +
#'   annotation_graticule(
#'     xlim          = cn_xlim,
#'     ylim          = cn_ylim,
#'     crs           = 4326,
#'     lon_step      = 10,
#'     lat_step      = 10,
#'     label_color   = NA,    # draw only lines; use axis labels instead
#'     label_offset = 1,
#'     label_size    = 3.5
#'   ) +
#'   coord_sf(
#'     xlim   = cn_xlim,
#'     ylim   = cn_ylim,
#'     expand = FALSE
#'   ) +
#'   labs(
#'     x = "Longitude",
#'     y = "Latitude"
#'   ) +
#'   theme_bw()
#' }
#'
#' @export
#' @importFrom sf st_crs st_sfc st_linestring st_as_sf st_transform
#'   st_is_empty st_coordinates st_geometry_type st_break_antimeridian
#'   sf_use_s2 st_is_longlat st_point
#' @importFrom ggplot2 geom_sf geom_text aes
#' @importFrom utils globalVariables
annotation_graticule <- function(
    xlim             = NULL,
    ylim             = NULL,
    crs              = "+proj=longlat +datum=WGS84",
    lon_step         = 60,
    lat_step         = 30,
    line_color       = "grey70",
    line_width       = 0.3,
    line_type        = "dashed",
    label_color      = "grey30",
    label_size       = 3,
    label_offset     = 5,
    label_offset_lon = NULL,
    label_offset_lat = NULL,
    sides            = c("left", "bottom"),
    ...
) {
  sides <- match.arg(
    sides,
    choices = c("bottom", "top", "left", "right"),
    several.ok = TRUE
  )

  ## ---- helpers: label formatting (ASCII compliant) -----------------------

  format_lat <- function(v) {
    v_round <- round(v)
    if (abs(v_round) < 1e-8) {
      "0\u00B0"  # \u00B0 is the Unicode escape for degree symbol
    } else if (v_round > 0) {
      sprintf("%d\u00B0N", v_round)
    } else {
      sprintf("%d\u00B0S", abs(v_round))
    }
  }

  format_lon <- function(v) {
    v_round <- round(v)
    if (abs(v_round) < 1e-8) {
      "0\u00B0"
    } else if (abs(abs(v_round) - 180) < 1e-8) {
      "180\u00B0"
    } else if (v_round > 0) {
      sprintf("%d\u00B0E", v_round)
    } else {
      sprintf("%d\u00B0W", abs(v_round))
    }
  }

  ## ---- helper: extract lon_0 from crs ------------------------------------

  get_lon0_from_crs <- function(crs_obj) {
    s <- crs_obj$input
    if (is.null(s) || is.na(s)) s <- crs_obj$wkt
    s <- as.character(s)

    if (length(s) == 0 || s == "") return(0)

    # numeric EPSG or "EPSG:xxxx"
    if (grepl("^[0-9]+$", s) || grepl("^EPSG:", s, ignore.case = TRUE)) {
      return(0)
    }

    m <- regexpr("lon_0\\s*=\\s*(-?[0-9.]+)", s, perl = TRUE)
    if (m[1] == -1) return(0)

    lon0_str <- regmatches(s, m)
    lon0_num <- sub("lon_0\\s*=\\s*", "", lon0_str)
    as.numeric(lon0_num)
  }

  ## ---- CRS ----------------------------------------------------------------

  crs_obj <- sf::st_crs(crs)
  if (is.na(crs_obj)) {
    stop("crs is not a valid coordinate reference system.")
  }
  lon0 <- get_lon0_from_crs(crs_obj)

  tmp_geom   <- sf::st_sfc(sf::st_point(c(0, 0)), crs = crs_obj)
  is_longlat <- sf::st_is_longlat(tmp_geom)

  ## ---- label offsets ------------------------------------------------------

  if (!is.null(label_offset_lon)) {
    off_lon <- label_offset_lon
  } else {
    off_lon <- label_offset
  }

  if (!is.null(label_offset_lat)) {
    off_lat <- label_offset_lat
  } else {
    off_lat <- label_offset
  }

  ## ---- 1. Determine geographic window (in EPSG:4326) ----------------------

  if (is.null(xlim) && is.null(ylim)) {
    lon_range <- c(-180, 180)
    lat_range <- c(-90, 90)
  } else if (!is.null(xlim) && !is.null(ylim)) {
    if (!is.numeric(xlim) || length(xlim) != 2L || any(!is.finite(xlim))) {
      stop("`xlim` must be a numeric vector of length 2: c(xmin, xmax).")
    }
    if (!is.numeric(ylim) || length(ylim) != 2L || any(!is.finite(ylim))) {
      stop("`ylim` must be a numeric vector of length 2: c(ymin, ymax).")
    }
    lon_range <- xlim
    lat_range <- ylim
  } else {
    stop("Either both `xlim` and `ylim` must be NULL (full globe) or both supplied.")
  }

  lon_range <- sort(lon_range)
  lat_range <- sort(lat_range)

  lon_range <- pmax(pmin(lon_range, 180), -180)
  lat_range <- pmax(pmin(lat_range, 90), -90)

  if (lon_range[1] >= lon_range[2] || lat_range[1] >= lat_range[2]) {
    stop("Invalid xlim/ylim: xmin must be < xmax and ymin must be < ymax.")
  }

  ## ---- 2. Generate meridian/parallel positions within window --------------

  lon_vals <- seq(
    from = ceiling(lon_range[1] / lon_step) * lon_step,
    to   = floor(lon_range[2] / lon_step)  * lon_step,
    by   = lon_step
  )
  lat_vals <- seq(
    from = ceiling(lat_range[1] / lat_step) * lat_step,
    to   = floor(lat_range[2] / lat_step)  * lat_step,
    by   = lat_step
  )

  lat_seq <- seq(lat_range[1], lat_range[2], by = 1)
  lon_seq <- seq(lon_range[1], lon_range[2], by = 1)

  meridians <- lapply(lon_vals, function(lon) {
    sf::st_linestring(cbind(lon, lat_seq))
  })
  parallels <- lapply(lat_vals, function(lat) {
    sf::st_linestring(cbind(lon_seq, lat))
  })

  g_lines <- sf::st_sfc(c(meridians, parallels), crs = 4326)
  g_lines <- sf::st_as_sf(
    data.frame(
      type  = c(rep("meridian", length(meridians)),
                rep("parallel", length(parallels))),
      value = c(lon_vals, lat_vals)
    ),
    geometry = g_lines
  )

  ## ---- 3. Antimeridian handling and transform -----------------------------

  # [Modified] Suppress "Spherical geometry (s2) switched off" message
  s2_old <- suppressMessages(sf::sf_use_s2(FALSE))

  # [Modified] Suppress "Spherical geometry (s2) switched on" message on exit
  on.exit(suppressMessages(sf::sf_use_s2(s2_old)), add = TRUE)

  g_lines_cut <- g_lines

  if (is.null(xlim) && is.null(ylim) &&
      !is.null(lon0) && lon0 != 0 && sf::st_is_longlat(g_lines)) {
    gtype    <- unique(as.character(sf::st_geometry_type(g_lines)))
    need_cut <- !all(gtype %in% c("POINT", "MULTIPOINT"))
    if (need_cut) {
      g_lines_cut <- suppressWarnings(
        sf::st_break_antimeridian(g_lines, lon_0 = lon0)
      )
    }
  }

  g_lines_proj <- suppressWarnings(
    sf::st_transform(g_lines_cut, crs_obj)
  )
  g_lines_proj <- g_lines_proj[!sf::st_is_empty(g_lines_proj), ]

  ## ---- 4. Helper: get coordinates for one line ----------------------------

  get_line_coords <- function(tp, val) {
    idx <- which(
      g_lines_proj$type == tp &
        abs(g_lines_proj$value - val) < 1e-8
    )
    if (length(idx) == 0) return(NULL)
    coords_list <- lapply(idx, function(i) sf::st_coordinates(g_lines_proj[i, ]))
    do.call(rbind, coords_list)
  }

  ## ---- 5. Build label coordinates ----------------------------------------

  labels_list <- list()

  ## Longitude labels
  if (length(lon_vals) > 0) {
    for (lon in lon_vals) {

      ## skip +/-180 labels for full globe lon=0 maps
      if (is.null(xlim) && is.null(ylim) &&
          is_longlat &&
          abs(lon0) < 1e-8 &&
          abs(abs(lon) - 180) < 1e-8) {
        next
      }

      coords <- get_line_coords("meridian", lon)
      if (is.null(coords) || nrow(coords) == 0) next

      if ("bottom" %in% sides) {
        i <- which.min(coords[, "Y"])
        labels_list[[length(labels_list) + 1]] <- data.frame(
          x     = coords[i, "X"],
          y     = coords[i, "Y"] - off_lon,
          label = format_lon(lon),
          side  = "bottom",
          kind  = "lon",
          hjust = 0.5,
          vjust = 1,
          stringsAsFactors = FALSE
        )
      }

      if ("top" %in% sides) {
        i <- which.max(coords[, "Y"])
        labels_list[[length(labels_list) + 1]] <- data.frame(
          x     = coords[i, "X"],
          y     = coords[i, "Y"] + off_lon,
          label = format_lon(lon),
          side  = "top",
          kind  = "lon",
          hjust = 0.5,
          vjust = 0,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  ## Latitude labels
  if (length(lat_vals) > 0) {
    for (lat in lat_vals) {

      ## skip +/-90
      if (abs(lat) >= 90 - 1e-8) next

      coords <- get_line_coords("parallel", lat)
      if (is.null(coords) || nrow(coords) == 0) next

      if ("left" %in% sides) {
        i <- which.min(coords[, "X"])
        labels_list[[length(labels_list) + 1]] <- data.frame(
          x     = coords[i, "X"] - off_lat,
          y     = coords[i, "Y"],
          label = format_lat(lat),
          side  = "left",
          kind  = "lat",
          hjust = 1,
          vjust = 0.5,
          stringsAsFactors = FALSE
        )
      }

      if ("right" %in% sides) {
        i <- which.max(coords[, "X"])
        labels_list[[length(labels_list) + 1]] <- data.frame(
          x     = coords[i, "X"] + off_lat,
          y     = coords[i, "Y"],
          label = format_lat(lat),
          side  = "right",
          kind  = "lat",
          hjust = 0,
          vjust = 0.5,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(labels_list) > 0) {
    labels_df <- do.call(rbind, labels_list)
  } else {
    labels_df <- data.frame(
      x = numeric(0), y = numeric(0),
      label = character(0),
      side  = character(0),
      kind  = character(0),
      hjust = numeric(0),
      vjust = numeric(0),
      stringsAsFactors = FALSE
    )
  }

  ## ---- 6. ggplot layers ---------------------------------------------------

  line_layer <- ggplot2::geom_sf(
    data        = g_lines_proj,
    color       = line_color,
    linewidth   = line_width,
    linetype    = line_type,
    inherit.aes = FALSE,
    ...
  )

  if (nrow(labels_df) > 0) {
    label_layer <- ggplot2::geom_text(
      data        = labels_df,
      ggplot2::aes(
        x     = x,
        y     = y,
        label = label,
        hjust = hjust,
        vjust = vjust
      ),
      color       = label_color,
      size        = label_size,
      inherit.aes = FALSE
    )
  } else {
    # placeholder to keep return shape stable
    label_layer <- ggplot2::geom_text(
      data = data.frame(
        x     = NA_real_,
        y     = NA_real_,
        label = NA_character_
      ),
      ggplot2::aes(x = x, y = y, label = label),
      inherit.aes = FALSE
    )
  }

  list(line_layer, label_layer)
}

# Silence R CMD check NOTES for variables used in ggplot aes()
utils::globalVariables(c("x", "y", "label", "hjust", "vjust"))
