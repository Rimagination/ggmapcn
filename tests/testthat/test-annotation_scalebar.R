test_that("segment and ticks styles draw ticks on different sides of the baseline", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)

  for (divisions in c(1, 2)) {
    params <- list(widthnpc = 0.3, widthu = 100, majordivs = divisions,
                   majordivnpc = 0.3 / divisions, unit = "km", labeltext = "100 km")
    args <- list(
      params = params, location = "bl", bar_cols = c("black", "white"),
      line_width = 1, line_col = "black", height = grid::unit(1, "cm"),
      pad_x = grid::unit(1, "cm"), pad_y = grid::unit(1, "cm"),
      text_pad = grid::unit(0.2, "cm"), text_cex = 0.7, text_col = "black",
      text_face = NULL, text_family = "", tick_height = 0.5,
      segments = NULL, label_show = "ends", minor_tick_height = 0.5
    )
    make_grobs <- function(style) do.call(grob_scalebar, c(list(style = style), args))
    segment <- make_grobs("segment")
    ticks <- make_grobs("ticks")
    cm <- function(x) grid::convertY(x, "cm", valueOnly = TRUE)

    expect_equal(cm(segment[[2]]$y0), cm(segment[[1]]$y0))
    expect_true(all(cm(segment[[2]]$y1) > cm(segment[[1]]$y0)))
    expect_true(all(cm(ticks[[2]]$y0) < cm(ticks[[1]]$y0)))
    expect_true(all(cm(ticks[[2]]$y1) > cm(ticks[[1]]$y0)))
    expect_equal(segment[[3]]$label, ticks[[3]]$label)
  }
})

test_that("ticks scale bar renders through the public layer", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  points <- sf::st_as_sf(data.frame(x = c(-2, 2), y = c(-1, 1)),
                         coords = c("x", "y"), crs = 4326)
  plot <- ggplot2::ggplot() + ggplot2::geom_sf(data = points) +
    ggplot2::coord_sf(crs = 3857) +
    annotation_scalebar(style = "ticks", fixed_width = 100000)
  expect_s3_class(ggplot2::ggplotGrob(plot), "gtable")
})
