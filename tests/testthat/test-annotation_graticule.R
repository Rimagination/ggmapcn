test_that("existing positional arguments keep their meaning", {
  layers <- annotation_graticule(
    c(-20, 20), c(-10, 10), 4326, 10, 10,
    "grey70", 0.3, "dashed", "red", 3, 5, NULL, NULL,
    c("left", "bottom")
  )
  labels <- ggplot2::ggplot_build(ggplot2::ggplot() + layers)$data[[2]]

  expect_gt(nrow(labels), 0)
  expect_equal(unique(labels$colour), "red")
})

test_that("legacy and new line transparency arguments work", {
  args <- list(xlim = c(-20, 20), ylim = c(-10, 10), crs = 4326)
  line_alpha <- function(layers) {
    lines <- ggplot2::ggplot_build(ggplot2::ggplot() + layers)$data[[1]]
    unique(lines$alpha)
  }

  expect_warning(legacy <- do.call(annotation_graticule, c(args, list(alpha = 0.25))), NA)
  expect_equal(line_alpha(legacy), 0.25)

  expect_warning(current <- do.call(annotation_graticule, c(args, list(line_alpha = 0.5))), NA)
  expect_equal(line_alpha(current), 0.5)

  expect_warning(both <- do.call(annotation_graticule, c(args, list(alpha = 0.25, line_alpha = 0.75))), NA)
  expect_equal(line_alpha(both), 0.75)
})

test_that("new label formatting options are applied", {
  layers <- annotation_graticule(
    xlim = c(-20, 20), ylim = c(-10, 10), crs = 4326,
    label_format = function(x) paste0("value:", x),
    label_angle = 25
  )
  labels <- ggplot2::ggplot_build(ggplot2::ggplot() + layers)$data[[2]]

  expect_gt(nrow(labels), 0)
  expect_true(all(startsWith(labels$label, "value:")))
  expect_equal(unique(labels$angle), 25)
})
