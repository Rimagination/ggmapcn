#' ggmapcn: Customizable China and World Map Visualizations
#'
#' A 'ggplot2' extension centered on China’s map visualization, with
#' additional support for styled global basemaps. Provides customizable
#' projections, boundary styles, graticules, scale bars, and buffer zones
#' for thematic maps, suitable for spatial data analysis and cartographic
#' visualization.
#'
#' Main features:
#' - Projection-aware compass (`annotation_compass()`), scale bar
#'   (`annotation_scalebar()`), and graticule annotation
#'   (`annotation_graticule()`).
#' - Built-in geodata management via `check_geodata()`.
#' - Multiple compass styles (classic, rose, Sinan, guiding fish, etc.).
#' - Seamless integration with 'ggplot2' and 'sf' workflows.
#' - Pre-styled global basemap via `geom_world()` and China-focused layers
#'   such as `geom_mapcn()` and `geom_boundary_cn()`.
#'
#' @keywords package
"_PACKAGE"
