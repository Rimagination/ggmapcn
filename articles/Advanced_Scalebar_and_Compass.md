# Advanced scale bar and compass annotations

## 1. Setup

This vignette shows how to use the advanced options in
[`annotation_scalebar()`](https://rimagination.github.io/ggmapcn/reference/annotation_scalebar.md)
and
[`annotation_compass()`](https://rimagination.github.io/ggmapcn/reference/annotation_compass.md)
from **ggmapcn**.

``` r
library(ggplot2)
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
library(ggmapcn)

nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

base_geo <- ggplot() +
  geom_sf(data = nc, fill = "grey90", color = "grey40") +
  theme_minimal()
base_geo
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-2-1.png)

## 2. Basic scale bar in a projected CRS

``` r
base_proj <- base_geo +
  coord_sf(crs = 32617) +
  theme(axis.title = element_blank())

base_proj +
  annotation_scalebar(location = "bl")
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-3-1.png)

``` r

base_proj +
  annotation_scalebar(
    location   = "tr",
    width_hint = 0.5
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-3-2.png)

## 3. Scale bar styles

``` r
p_segment <- base_proj +
  annotation_scalebar(
    location = "bl",
    style    = "segment",
    label_show = "all"
  )

p_ticks <- base_proj +
  annotation_scalebar(
    location = "br",
    style    = "ticks"
  )

p_bar <- base_proj +
  annotation_scalebar(
    location = "tl",
    style    = "bar",
    bar_cols = c("black", "white")
  )

p_segment
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-4-1.png)

``` r
p_ticks
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-4-2.png)

``` r
p_bar
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-4-3.png)

``` r

base_proj +
  annotation_scalebar(
    location     = "bl",
    fixed_width  = 100000,
    display_unit = "km",
    line_col     = "red"
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-4-4.png)

## 4. Geographic CRS: approx_m vs degrees

``` r
base_geo +
  coord_sf(crs = 4326) +
  annotation_scalebar(
    location        = "bl",
    geographic_mode = "approx_m"
  )
#> Warning: Scale bar is approximate in geographic CRS (degrees). Distances vary
#> with latitude. For accuracy, use a projected CRS, or set `geographic_mode =
#> "degrees"`.
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-5-1.png)

``` r

base_geo +
  coord_sf(crs = 4326) +
  annotation_scalebar(
    location        = "bl",
    geographic_mode = "degrees"
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-5-2.png)

## 5. Basic compass (grid north)

``` r
base_geo +
  annotation_compass(
    location = "tl",
    style    = north_arrow_classic()
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-6-1.png)

``` r

base_geo +
  annotation_compass(
    location = "tl",
    height   = grid::unit(1.8, "cm"),
    width    = grid::unit(1.8, "cm"),
    pad_x    = grid::unit(0.7, "cm"),
    pad_y    = grid::unit(0.7, "cm")
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-6-2.png)

## 6. True north (requires projection)

``` r
base_lcc <- base_geo +
  coord_sf(crs = "+proj=lcc +lon_0=-100 +lat_1=33 +lat_2=45") +
  theme(axis.title = element_blank())

base_lcc +
  annotation_compass(
    which_north = "true",
    location    = "br",
    style       = compass_rose_simple()
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-7-1.png)

``` r

base_lcc +
  annotation_compass(
    which_north = "grid",
    rotation    = 30,
    location    = "tr",
    style       = north_arrow_solid()
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-7-2.png)

## 7. Compass styles

``` r
p_classic <- base_proj +
  annotation_compass(
    location = "tl",
    style    = north_arrow_classic()
  )

p_rose <- base_proj +
  annotation_compass(
    location = "br",
    style    = compass_rose_classic()
  )

p_sinan <- base_proj +
  annotation_compass(
    location = "tl",
    style    = compass_sinan()
  )

p_classic
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-8-1.png)

``` r
p_rose
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-8-2.png)

``` r
p_sinan
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-8-3.png)

## 8. Combine scale bar + compass

``` r
base_proj +
  annotation_scalebar(
    location   = "bl",
    style      = "ticks",
    width_hint = 0.3
  ) +
  annotation_compass(
    location = "tl",
    style    = compass_rose_circle()
  )
```

![](Advanced_Scalebar_and_Compass_files/figure-html/unnamed-chunk-9-1.png)
