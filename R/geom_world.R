#' Convenient global basemap layer for ggplot2
#'
#' @description
#' `geom_world()` draws a styled global basemap using bundled country
#' polygons, coastlines, and administrative boundary data. It automatically
#' handles antimeridian splitting and CRS transformation, and supports
#' optional country filtering for focused maps.
#'
#' @details
#' This function supersedes an earlier, much simpler version of `geom_world()`
#' that was a thin wrapper around `ggplot2::geom_sf()` and required users to
#' supply their own map data. The current implementation:
#'
#' - always uses bundled world map data (countries, coastlines, boundaries),
#' - exposes dedicated arguments for ocean fill, coastlines, and different
#'   types of administrative boundaries,
#' - and has a different argument set and default behaviour compared to
#'   the original version.
#'
#' If you are upgrading from an older development version of **ggmapcn**,
#' please review your existing calls to `geom_world()` and the examples
#' below, as some arguments have been renamed or removed.
#'
#' To silence the one-time redesign warning in a session, you can set:
#'
#' ```r
#' options(ggmapcn.geom_world_silence_redesign = TRUE)
#' ```
#'
#' @param crs Coordinate reference system for the basemap. Accepts a numeric
#'   EPSG code, a PROJ string, or an `sf::crs` object. The default is `4326`,
#'   corresponding to WGS84 longitude–latitude.
#'
#' @param filter_attribute Name of the column in the `countries` dataset used
#'   for filtering. Default `"SOC"`.
#'
#' @param filter Character vector specifying which values of `filter_attribute`
#'   to retain. If `NULL` (default), no filtering is applied. When non-`NULL`,
#'   only the selected countries are drawn, and the ocean, coastlines,
#'   administrative boundaries, and optional frame are all omitted.
#'
#' @param show_ocean Logical; draw an ocean background polygon. Default `TRUE`.
#'   Ignored when `filter` is not `NULL`.
#'
#' @param show_admin_boundaries Logical; draw administrative and political
#'   boundaries (international, regional, undefined/disputed, and military
#'   demarcation lines). Default `TRUE`. Ignored when `filter` is not `NULL`.
#'
#' @param show_frame Logical; draw an outer frame following the projected
#'   outline of the world. Default `FALSE`. Ignored when `filter` is not `NULL`.
#'
#' @param ocean_fill Fill colour for the ocean polygon. Default `"#c7e8fb"`.
#'
#' @param frame_color Colour of the outer frame line. Default `"grey20"`.
#' @param frame_size  Line width of the outer frame. Default `0.1`.
#' @param frame_linetype Line type of the outer frame. Default `"solid"`.
#'
#' @param country_fill Fill colour for country polygons. Default `"grey90"`.
#' @param country_boundary_color Colour of country boundary outlines.
#'   Default `"transparent"`.
#' @param country_boundary_size Width of country boundary outlines.
#'   Default `0.1`.
#' @param country_boundary_linetype Line type of country boundaries.
#'   Default `"solid"`.
#'
#' @param coastline_color Colour of the coastline layer. Default `"#26ace7"`.
#' @param coastline_size  Line width of coastlines. Default `0.1`.
#' @param coastline_linetype Line type of coastlines. Default `"solid"`.
#'
#' @param international_boundary_color Colour for international boundary lines.
#'   Default `"grey20"`.
#' @param international_boundary_size Width for international boundaries.
#'   Default `0.1`.
#' @param international_boundary_linetype Line type for international
#'   boundaries. Default `"solid"`.
#'
#' @param regional_boundary_color Colour for regional boundaries (e.g. states).
#'   Default `"grey20"`.
#' @param regional_boundary_size Width for regional boundaries. Default `0.1`.
#' @param regional_boundary_linetype Line type for regional boundaries.
#'   Default `"dashed"`.
#'
#' @param undefined_boundary_color Colour for undefined or disputed boundaries.
#'   Default `"grey20"`.
#' @param undefined_boundary_size Width for undefined boundaries. Default `0.1`.
#' @param undefined_boundary_linetype Line type for undefined boundaries.
#'   Default `"longdash"`.
#'
#' @param military_boundary_color Colour for military demarcation lines.
#'   Default `"grey20"`.
#' @param military_boundary_size Width for military demarcation lines.
#'   Default `0.05`.
#' @param military_boundary_linetype Line type for military demarcation lines.
#'   Default `"dotted"`.
#'
#' @param ... Additional arguments passed to `ggplot2::geom_sf()`.
#'
#' @return A list of `ggplot2` layers representing the world map (or a
#'   filtered subset), ready to be added to a ggplot.
#'
#' @examples
#' library(ggplot2)
#'
#' # 1. Simplest world map
#' ggplot() +
#'   geom_world() +
#'   theme_void()
#'
#' # 2. World map with long–lat axes
#' ggplot() +
#'   geom_world() +
#'   coord_sf(
#'     crs    = 4326,
#'     expand = FALSE,
#'     datum  = sf::st_crs(4326)
#'   ) +
#'   theme_minimal() +
#'   theme(panel.ontop = TRUE)
#'
#' # 3. Without ocean layer
#' ggplot() +
#'   geom_world(show_ocean = FALSE) +
#'   theme_minimal()
#'
#' # 4. Without administrative boundaries
#' ggplot() +
#'   geom_world(show_admin_boundaries = FALSE) +
#'   theme_minimal()
#'
#' # 5. Robinson projection centred at 150°E
#' crs_robin_150 <- "+proj=robin +lon_0=150 +datum=WGS84"
#' ggplot() +
#'   geom_world(crs = crs_robin_150) +
#'   coord_sf(crs = crs_robin_150) +
#'   theme_void()
#'
#' # 6. Highlight China
#' ggplot() +
#'   geom_world(
#'     country_fill = "grey95", show_frame   = TRUE) +
#'   geom_world(
#'     filter_attribute = "SOC",
#'     filter           = "CHN",
#'     country_fill     = "red",
#'     country_boundary_color = "black"
#'   ) +
#'   theme_void()
#'
#' @export
#'
#' @import ggplot2
#' @importFrom sf st_crs st_as_sfc st_bbox st_transform st_break_antimeridian
#'   st_is_longlat st_geometry_type st_union st_convex_hull sf_use_s2 st_sfc
#'   st_point st_as_sf st_is_empty
#' @importFrom dplyr filter
#' @importFrom rlang sym
geom_world <- function(
    crs  = 4326,
    filter_attribute = "SOC",
    filter = NULL,
    show_ocean            = TRUE,
    show_admin_boundaries = TRUE,
    show_frame            = FALSE,
    ocean_fill                    = "#c7e8fb",
    frame_color                   = "black",
    frame_size                    = 0.2,
    frame_linetype                = "solid",
    country_fill                  = "grey90",
    country_boundary_color        = "transparent",
    country_boundary_size         = 0.1,
    country_boundary_linetype     = "solid",
    coastline_color               = "#26ace7",
    coastline_size                = 0.1,
    coastline_linetype            = "solid",
    international_boundary_color  = "grey20",
    international_boundary_size   = 0.1,
    international_boundary_linetype = "solid",
    regional_boundary_color       = "grey20",
    regional_boundary_size        = 0.1,
    regional_boundary_linetype    = "dashed",
    undefined_boundary_color      = "grey20",
    undefined_boundary_size       = 0.1,
    undefined_boundary_linetype   = "longdash",
    military_boundary_color       = "grey20",
    military_boundary_size        = 0.05,
    military_boundary_linetype    = "dotted",
    ...
) {
  ## ---- one-time redesign warning -----------------------------------------
  if (!isTRUE(getOption("ggmapcn.geom_world_silence_redesign", FALSE))) {
    if (!isTRUE(getOption("ggmapcn.geom_world_redesign_warned", FALSE))) {
      warning(
        "geom_world() has been redesigned; its interface and defaults ",
        "have changed compared to earlier development versions. ",
        "See ?geom_world for details.",
        call. = FALSE
      )
      options(ggmapcn.geom_world_redesign_warned = TRUE)
    }
  }

  ## helper: parse lon_0 from CRS
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

  ## helper: safe transform with optional antimeridian cut
  st_transform_safe <- function(x, crs_target, lon0) {
    crs_obj <- sf::st_crs(crs_target)

    if (!is.null(lon0) && sf::st_is_longlat(x)) {
      gtype <- unique(as.character(sf::st_geometry_type(x)))
      need_cut <- !all(gtype %in% c("POINT", "MULTIPOINT"))
      if (need_cut && lon0 != 0) {
        x <- suppressMessages(
          suppressWarnings(
            sf::st_break_antimeridian(x, lon_0 = lon0)
          )
        )
      }
    }

    x <- sf::st_transform(x, crs_obj)

    # Drop empty geometries to avoid geom_sf() warnings
    if (inherits(x, "sf")) {
      empty <- sf::st_is_empty(x)
      if (any(empty)) {
        x <- x[!empty, , drop = FALSE]
      }
    }

    x
  }

  ## helper: world outline in target CRS
  make_world_outline <- function(crs_target, lon0) {
    crs_obj <- sf::st_crs(crs_target)

    # For geographic CRSs (including longlat + lon_0) use a rectangular bbox
    test_pt <- sf::st_sfc(sf::st_point(c(0, 0)), crs = crs_obj)
    is_longlat <- sf::st_is_longlat(test_pt)

    if (is_longlat) {
      bb <- sf::st_bbox(
        c(xmin = -180, xmax = 180, ymin = -90, ymax = 90),
        crs = crs_obj
      )
      outline <- sf::st_sf(geometry = sf::st_as_sfc(bb))
      return(outline)
    }

    # For projected CRSs, build the outline from a regular lon/lat grid
    lon <- seq(-180, 180, by = 2)
    lat <- seq(-90,   90, by = 2)

    pts_ll <- expand.grid(lon = lon, lat = lat) |>
      sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)

    pts_proj <- st_transform_safe(pts_ll, crs_obj, lon0)

    old_s2 <- sf::sf_use_s2()
    on.exit(sf::sf_use_s2(old_s2), add = TRUE)
    sf::sf_use_s2(FALSE)

    hull <- suppressMessages(
      sf::st_convex_hull(
        sf::st_union(pts_proj)
      )
    )

    sf::st_sf(geometry = hull)
  }

  ## 1. load bundled data via check_geodata()
  paths <- check_geodata(
    files = c("world_countries.rda",
              "world_coastlines.rda",
              "world_boundaries.rda"),
    quiet = TRUE
  )

  env <- new.env(parent = emptyenv())
  load(paths[1], envir = env)  # countries
  load(paths[2], envir = env)  # coastlines
  load(paths[3], envir = env)  # boundaries

  countries  <- env$countries
  coastlines <- env$coastlines
  boundaries <- env$boundaries

  ## 2. optional filtering on countries
  filtered_mode <- !is.null(filter)

  if (filtered_mode) {
    if (!(filter_attribute %in% names(countries))) {
      stop("filter_attribute '", filter_attribute,
           "' does not exist in the countries layer.")
    }
    countries <- dplyr::filter(
      countries,
      !!rlang::sym(filter_attribute) %in% filter
    )
    if (nrow(countries) == 0) {
      stop("No countries matched the provided filter; nothing to plot.")
    }
  }

  ## 3. CRS, lon_0, and world outline
  crs_obj <- sf::st_crs(crs)
  lon0    <- get_lon0_from_crs(crs_obj)

  outline_proj <- make_world_outline(crs_obj, lon0)

  ## 4. transform all layers safely
  countries_proj  <- st_transform_safe(countries,  crs_obj, lon0)
  coastlines_proj <- st_transform_safe(coastlines, crs_obj, lon0)
  boundaries_proj <- st_transform_safe(boundaries, crs_obj, lon0)

  ## 5. split boundaries by fixed column "Type"
  subset_boundary <- function(label) {
    idx <- boundaries_proj$Type == label
    boundaries_proj[idx, , drop = FALSE]
  }

  international_boundary <- subset_boundary("International boundary")
  regional_boundary      <- subset_boundary("Regional boundary")
  undefined_boundary     <- subset_boundary("Undefined international boundary")
  military_boundary      <- subset_boundary("Military demarcation line")

  ## 6. assemble ggplot layers
  layers <- list()

  # 6.1 ocean background (not drawn in filtered mode)
  if (show_ocean && !filtered_mode) {
    layers <- append(layers, list(
      ggplot2::geom_sf(
        data      = outline_proj,
        fill      = ocean_fill,
        color     = NA
      )
    ))
  }

  # 6.2 countries (always drawn)
  layers <- append(layers, list(
    ggplot2::geom_sf(
      data      = countries_proj,
      fill      = country_fill,
      color     = country_boundary_color,
      linewidth = country_boundary_size,
      linetype  = country_boundary_linetype,
      ...
    )
  ))

  # 6.3 coastlines (not drawn in filtered mode)
  if (!filtered_mode) {
    layers <- append(layers, list(
      ggplot2::geom_sf(
        data      = coastlines_proj,
        color     = coastline_color,
        linewidth = coastline_size,
        linetype  = coastline_linetype
      )
    ))
  }

  # 6.4 administrative boundaries (not drawn in filtered mode)
  if (show_admin_boundaries && !filtered_mode) {
    layers <- append(layers, list(
      ggplot2::geom_sf(
        data      = international_boundary,
        color     = international_boundary_color,
        linewidth = international_boundary_size,
        linetype  = international_boundary_linetype
      ),
      ggplot2::geom_sf(
        data      = regional_boundary,
        color     = regional_boundary_color,
        linewidth = regional_boundary_size,
        linetype  = regional_boundary_linetype
      ),
      ggplot2::geom_sf(
        data      = undefined_boundary,
        color     = undefined_boundary_color,
        linewidth = undefined_boundary_size,
        linetype  = undefined_boundary_linetype
      ),
      ggplot2::geom_sf(
        data      = military_boundary,
        color     = military_boundary_color,
        linewidth = military_boundary_size,
        linetype  = military_boundary_linetype
      )
    ))
  }

  # 6.5 outer frame (not drawn in filtered mode)
  if (show_frame && !filtered_mode) {
    layers <- append(layers, list(
      ggplot2::geom_sf(
        data      = outline_proj,
        fill      = NA,
        color     = frame_color,
        linewidth = frame_size,
        linetype  = frame_linetype
      )
    ))
  }

  layers
}
