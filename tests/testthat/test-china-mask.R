test_that("the bundled mask matches the bundled provincial polygons", {
  mask_path <- system.file("extdata", "China_mask.gpkg", package = "ggmapcn")
  province_path <- system.file("extdata", "China_sheng.rda", package = "ggmapcn")
  expect_true(nzchar(mask_path))
  expect_true(nzchar(province_path))

  mask <- sf::st_read(mask_path, layer = "China_mask", quiet = TRUE)
  env <- new.env(parent = emptyenv())
  load(province_path, envir = env)
  province <- env$China_sheng
  types <- as.character(sf::st_geometry_type(province))
  polygons <- province[types %in% c("POLYGON", "MULTIPOLYGON"), ]

  expect_equal(nrow(mask), 1L)
  expect_equal(nrow(polygons), 34L)
  expect_equal(sf::st_crs(mask)$epsg, 4490L)
  expect_identical(as.character(sf::st_geometry_type(mask)), "MULTIPOLYGON")

  old_s2 <- sf::sf_use_s2()
  tryCatch({
    suppressMessages(sf::sf_use_s2(TRUE))
    expect_true(all(sf::st_is_valid(mask)))
    suppressMessages(sf::sf_use_s2(FALSE))
    expect_true(all(sf::st_is_valid(mask)))
    coverage <- suppressMessages(sf::st_union(sf::st_geometry(polygons)))
    expect_true(as.logical(sf::st_equals(sf::st_geometry(mask), coverage, sparse = FALSE)))
  }, finally = suppressMessages(sf::sf_use_s2(old_s2)))
})
