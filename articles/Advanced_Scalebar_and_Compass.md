# Advanced scale bar and compass annotations

## 1. Setup

This vignette demonstrates how to use the advanced customization options
available in
[`annotation_scalebar()`](https://rimagination.github.io/ggmapcn/reference/annotation_scalebar.md)
and
[`annotation_compass()`](https://rimagination.github.io/ggmapcn/reference/annotation_compass.md)
from the **ggmapcn** package.

We will use the standard North Carolina shapefile provided by the `sf`
package as our base map.

``` r
library(ggplot2)
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
library(ggmapcn)

# Load example data
nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

# Create a base map object
base_geo <- ggplot() +
  geom_sf(data = nc, fill = "grey90", color = "grey40") +
  theme_minimal()

base_geo
```

![A base map of North Carolina with grey fill and minimal
theme.](Advanced_Scalebar_and_Compass_files/figure-html/setup-1.png)

## 2. Scale bars in a projected CRS

Scale bars are most accurate when used with a projected Coordinate
Reference System (CRS). Here, we project the map to EPSG:32617 (UTM Zone
17N).

You can control the position using `location` (e.g., `"bl"` for
bottom-left, `"tr"` for top-right) and adjust the relative width using
`width_hint`.

``` r
base_proj <- base_geo +
  coord_sf(crs = 32617) +
  theme(axis.title = element_blank())

# Default scale bar at bottom-left
base_proj +
  annotation_scalebar(location = "bl")
```

![Two maps of North Carolina. The first shows a scale bar in the bottom
left. The second shows a wider scale bar in the top
right.](Advanced_Scalebar_and_Compass_files/figure-html/proj_scale-1.png)

``` r

# Top-right scale bar with custom width hint
base_proj +
  annotation_scalebar(
    location   = "tr",
    width_hint = 0.5
  )
```

![Two maps of North Carolina. The first shows a scale bar in the bottom
left. The second shows a wider scale bar in the top
right.](Advanced_Scalebar_and_Compass_files/figure-html/proj_scale-2.png)

## 3. Scale bar styles

[`annotation_scalebar()`](https://rimagination.github.io/ggmapcn/reference/annotation_scalebar.md)
supports multiple styles: `"segment"`, `"ticks"`, and `"bar"`. You can
also customize colors and text visibility.

``` r
# 1. Segment style
p_segment <- base_proj +
  annotation_scalebar(
    location = "bl",
    style    = "segment",
    label_show = "all"
  )
p_segment
```

![A map showing the 'segment' style scale
bar.](Advanced_Scalebar_and_Compass_files/figure-html/styles_1-1.png)

``` r
# 2. Ticks style
p_ticks <- base_proj +
  annotation_scalebar(
    location = "br",
    style    = "ticks"
  )
p_ticks
```

![A map showing the 'ticks' style scale
bar.](Advanced_Scalebar_and_Compass_files/figure-html/styles_2-1.png)

``` r
# 3. Bar style with custom colors
p_bar <- base_proj +
  annotation_scalebar(
    location = "tl",
    style    = "bar",
    bar_cols = c("black", "white")
  )
p_bar
```

![A map showing the 'bar' style scale bar with black and white
blocks.](Advanced_Scalebar_and_Compass_files/figure-html/styles_3-1.png)

You can also set a fixed distance width (e.g., 100km) and change the
line colors:

``` r
base_proj +
  annotation_scalebar(
    location     = "bl",
    fixed_width  = 100000,   # 100 km in meters
    display_unit = "km",
    line_col     = "red"
  )
```

![A map with a red scale bar fixed to 100km
length.](Advanced_Scalebar_and_Compass_files/figure-html/styles_custom-1.png)

## 4. Geographic CRS: Approx distance vs. Degrees

When plotting unprojected data (Latitude/Longitude, EPSG:4326), accurate
distance calculation is difficult.

- `geographic_mode = "approx_m"`: Attempts to calculate distances in
  meters (approximation).
- `geographic_mode = "degrees"`: Shows the scale in decimal degrees.

``` r
# Approximate meters
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

![Two maps comparing scale bars. One shows distance in kilometers, the
other in
degrees.](Advanced_Scalebar_and_Compass_files/figure-html/geo_mode-1.png)

``` r

# Degrees
base_geo +
  coord_sf(crs = 4326) +
  annotation_scalebar(
    location        = "bl",
    geographic_mode = "degrees"
  )
```

![Two maps comparing scale bars. One shows distance in kilometers, the
other in
degrees.](Advanced_Scalebar_and_Compass_files/figure-html/geo_mode-2.png)

## 5. Basic compass (Grid North)

Add a north arrow using
[`annotation_compass()`](https://rimagination.github.io/ggmapcn/reference/annotation_compass.md).
You can adjust the size and padding using
[`grid::unit()`](https://rdrr.io/r/grid/unit.html).

``` r
# Default classic arrow
base_geo +
  annotation_compass(
    location = "tl",
    style    = north_arrow_classic()
  )
```

![Two maps showing basic north arrows. One is standard size, the other
is larger with
padding.](Advanced_Scalebar_and_Compass_files/figure-html/compass_basic-1.png)

``` r

# Custom size and padding
base_geo +
  annotation_compass(
    location = "tl",
    height   = grid::unit(0.8, "cm"),
    width    = grid::unit(0.8, "cm"),
    pad_x    = grid::unit(0.3, "cm"),
    pad_y    = grid::unit(0.3, "cm")
  )
```

![Two maps showing basic north arrows. One is standard size, the other
is larger with
padding.](Advanced_Scalebar_and_Compass_files/figure-html/compass_basic-2.png)

## 6. True North vs. Grid North

In many projections (like Lambert Conformal Conic), “Grid North”
(straight up on the page) is different from “True North” (the direction
to the North Pole).

Use `which_north = "true"` to automatically calculate the convergence
angle and rotate the compass.

``` r
# Define a Lambert Conformal Conic projection
base_lcc <- base_geo +
  coord_sf(crs = "+proj=lcc +lon_0=-100 +lat_1=33 +lat_2=45") +
  theme(axis.title = element_blank())

# True North (automatically rotated)
base_lcc +
  annotation_compass(
    which_north = "true",
    location    = "br",
    style       = compass_rose_simple()
  )
```

![Two maps demonstrating north arrows. The first shows a rotated compass
rose pointing to True North. The second shows a manually rotated Grid
North
arrow.](Advanced_Scalebar_and_Compass_files/figure-html/true_north-1.png)

``` r

# Grid North with manual rotation
base_lcc +
  annotation_compass(
    which_north = "grid",
    rotation    = 30,
    location    = "tr",
    style       = north_arrow_solid()
  )
```

![Two maps demonstrating north arrows. The first shows a rotated compass
rose pointing to True North. The second shows a manually rotated Grid
North
arrow.](Advanced_Scalebar_and_Compass_files/figure-html/true_north-2.png)

## 7. Compass styles

**ggmapcn** provides various styles, including the unique
[`compass_sinan()`](https://rimagination.github.io/ggmapcn/reference/compass-styles.md)
(referencing the ancient Chinese compass).

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

![Three maps showing different compass styles: Classic, Rose, and Sinan
(Si
Nan).](Advanced_Scalebar_and_Compass_files/figure-html/compass_styles-1.png)

``` r
p_rose
```

![Three maps showing different compass styles: Classic, Rose, and Sinan
(Si
Nan).](Advanced_Scalebar_and_Compass_files/figure-html/compass_styles-2.png)

``` r
p_sinan
```

![Three maps showing different compass styles: Classic, Rose, and Sinan
(Si
Nan).](Advanced_Scalebar_and_Compass_files/figure-html/compass_styles-3.png)

## 8. Combining scale bar and compass

Finally, you can layer both annotations onto a single map.

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

![A final map combining a ticks-style scale bar at the bottom left and a
compass rose at the top
left.](Advanced_Scalebar_and_Compass_files/figure-html/combine-1.png)
