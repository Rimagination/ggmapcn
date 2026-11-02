local_geodata <- function() {
  root <- tempfile("ggmapcn-geodata-")
  dirs <- list(
    extdata = file.path(root, "package"),
    cache = file.path(root, "cache"),
    legacy = file.path(root, "legacy")
  )
  dir.create(dirs$extdata, recursive = TRUE)
  dir.create(dirs$legacy, recursive = TRUE)
  mirror <- file.path(root, "mirror")
  dir.create(mirror)

  f <- check_geodata
  env <- new.env(parent = environment(f))
  env$geodata_directories <- function() dirs
  environment(f) <- env

  mirror_path <- normalizePath(mirror, winslash = "/", mustWork = TRUE)
  mirror_url <- paste0("file://", if (.Platform$OS.type == "windows") "/" else "",
                       utils::URLencode(mirror_path), "/")
  list(check = f, dirs = dirs, mirror = mirror, url = mirror_url)
}

test_that("local and bundled data are reused without writing to the package", {
  x <- local_geodata()
  fname <- "China_sheng.rda"
  bundled <- file.path(x$dirs$extdata, fname)
  writeLines("bundled", bundled)
  before <- tools::md5sum(bundled)

  expect_equal(x$check(fname, quiet = TRUE), normalizePath(bundled, winslash = "/"))
  expect_false(dir.exists(x$dirs$cache))
  expect_identical(tools::md5sum(bundled), before)

  local <- file.path(x$dirs$legacy, fname)
  writeLines("local", local)
  expect_equal(x$check(fname, local_dirs = x$dirs$legacy, quiet = TRUE),
               normalizePath(local, winslash = "/"))
  expect_identical(tools::md5sum(bundled), before)
})

test_that("refreshes use the cache and never replace bundled data", {
  x <- local_geodata()
  fname <- "boundary.rda"
  bundled <- file.path(x$dirs$extdata, fname)
  writeLines("bundle version 1", bundled)
  writeLines("refreshed data", file.path(x$mirror, fname))

  cached <- x$check(fname, overwrite = TRUE, mirrors = x$url, quiet = TRUE)
  expect_equal(normalizePath(cached, winslash = "/"),
               normalizePath(file.path(x$dirs$cache, fname), winslash = "/"))
  expect_equal(readLines(cached), "refreshed data")
  expect_equal(readLines(bundled), "bundle version 1")
  expect_equal(x$check(fname, quiet = TRUE), normalizePath(cached, winslash = "/"))

  # A changed bundled file takes precedence after a package update.
  writeLines("bundle version 2", bundled)
  expect_equal(x$check(fname, quiet = TRUE), normalizePath(bundled, winslash = "/"))
})

test_that("legacy files remain available and failed downloads return NA", {
  x <- local_geodata()
  fname <- "China_shi.rda"
  legacy <- file.path(x$dirs$legacy, fname)
  writeLines("legacy data", legacy)
  expect_equal(x$check(fname, quiet = TRUE), normalizePath(legacy, winslash = "/"))

  writeLines("fresh data", file.path(x$mirror, fname))
  cached <- x$check(fname, overwrite = TRUE, mirrors = x$url, quiet = TRUE)
  expect_equal(readLines(cached), "fresh data")
  expect_equal(x$check(fname, quiet = TRUE), normalizePath(cached, winslash = "/"))
  expect_equal(readLines(legacy), "legacy data")

  absent <- x$check("China_xian.rda", mirrors = x$url, max_retries = 1, quiet = TRUE)
  expect_true(is.na(absent))
})

test_that("mapping functions report unavailable data clearly", {
  without_data <- function(f) {
    env <- new.env(parent = environment(f))
    env$check_geodata <- function(files, ...) rep(NA_character_, length(files))
    environment(f) <- env
    f
  }

  expect_error(without_data(geom_world)(), "world_countries.rda")
  expect_error(without_data(geom_buffer_cn)(), "buffer_line.rda")
  expect_error(without_data(basemap_dem)(), "gebco_2024_China.tif")
  expect_error(without_data(basemap_vege)(), "vege_1km_projected.tif")
})

test_that("buffer rendering reads the paths returned by the resolver", {
  root <- tempfile("ggmapcn-buffer-")
  dir.create(root)
  lines <- c(
    list(sf::st_linestring(matrix(c(-0.4, 0, 0.4, 0), ncol = 2, byrow = TRUE))),
    lapply(seq_len(10), function(i) {
      x <- -0.4 + i * 0.08
      sf::st_linestring(matrix(c(x, 0.3, x, 0.4), ncol = 2, byrow = TRUE))
    })
  )
  buffer_line <- sf::st_sf(name = c("mainland", rep("ten_segment_line", 10)),
                           geometry = sf::st_sfc(lines, crs = 4326))
  line_path <- file.path(root, "buffer_line.rda")
  save(buffer_line, file = line_path)

  ring <- matrix(c(-0.2, -0.2, 0.2, -0.2, 0.2, 0.2,
                   -0.2, 0.2, -0.2, -0.2), ncol = 2, byrow = TRUE)
  mask <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_polygon(list(ring)), crs = 4326))
  mask_path <- file.path(root, "China_mask.gpkg")
  sf::st_write(mask, mask_path, quiet = TRUE)

  f <- geom_buffer_cn
  env <- new.env(parent = environment(f))
  env$check_geodata <- function(files, ...) c(line_path, mask_path)
  environment(f) <- env
  layers <- suppressWarnings(f(crs = "+proj=merc +datum=WGS84 +units=m"))
  expect_silent(ggplot2::ggplot_build(ggplot2::ggplot() + layers))
})

test_that("a custom DEM outside the mask does not need a download", {
  raster <- terra::rast(ncols = 4, nrows = 4, xmin = 60, xmax = 140,
                        ymin = -10, ymax = 60, crs = "EPSG:4326")
  terra::values(raster) <- seq_len(16)
  f <- basemap_dem
  env <- new.env(parent = environment(f))
  env$check_geodata <- function(...) stop("Unexpected data download")
  environment(f) <- env
  expect_silent(f(data = raster, within_china = FALSE))
})
