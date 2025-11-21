# World map overview with geom_world()

## 1. Introduction

[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
provides a convenient global base map for `ggplot2`. It comes bundled
with country polygons, coastlines, and political/administrative
boundaries.

Key features include: \* **Automatic CRS transformation**: Seamlessly
projects data to your desired Coordinate Reference System. \*
**Antimeridian splitting**: Handles the “Pacific wrap-around” issue
automatically when changing central meridians. \* **Layer control**:
Toggles for ocean background and administrative boundaries.

## 2. Basic usage

### 2.1 Default WGS84 map

By default,
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
plots the map using the WGS84 standard.

``` r
ggplot() +
  geom_world() +
  theme_void()
```

![A standard world map using WGS84 projection with default
styling.](World_Map_Overview_files/figure-html/basic_map-1.png)

### 2.2 Explicit CRS specification

You can specify the CRS directly within the function.

``` r
ggplot() +
  geom_world(crs = 4326) +
  coord_sf(crs = 4326) +
  theme_void()
```

![A world map explicitly set to EPSG:4326
projection.](World_Map_Overview_files/figure-html/explicit_crs-1.png)

### 2.3 Hiding the ocean layer

For a cleaner look, you can remove the blue ocean background and change
the land fill color.

``` r
ggplot() +
  geom_world(
    show_ocean   = FALSE,
    country_fill = "grey90"
  ) +
  theme_minimal()
```

![A world map with the blue ocean layer removed, showing grey countries
on a white
background.](World_Map_Overview_files/figure-html/hide_ocean-1.png)

### 2.4 Hiding administrative boundaries

If you only need continental landmasses without internal country
borders, set `show_admin_boundaries = FALSE`.

``` r
ggplot() +
  geom_world(
    show_admin_boundaries = FALSE,
    country_fill          = "white"
  ) +
  theme_minimal()
```

![A world map showing continental landmasses without internal country
borders.](World_Map_Overview_files/figure-html/hide_admin-1.png)

Combining both options creates a minimalist silhouette map:

``` r
ggplot() +
  geom_world(
    show_ocean            = FALSE,
    show_admin_boundaries = FALSE
  ) +
  theme_minimal()
```

![A minimalist world map showing only land shapes with no ocean or
borders.](World_Map_Overview_files/figure-html/minimal_map-1.png)

## 3. Projections

[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
shines when working with different map projections. It automatically
projects the underlying polygons.

### 3.1 Robinson projection

``` r
crs_robin <- "+proj=robin +datum=WGS84"

ggplot() +
  geom_world(crs = crs_robin) +
  coord_sf(crs = crs_robin) +
  theme_void()
```

![A world map using the Robinson
projection.](World_Map_Overview_files/figure-html/robinson-1.png)

### 3.2 Robinson projection centred at 150°E

Changing the central meridian (centering the map on the Pacific) is
often difficult in standard ggplot2.
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
handles the polygon splitting automatically.

``` r
crs_robin_150 <- "+proj=robin +lon_0=150 +datum=WGS84"

ggplot() +
  geom_world(crs = crs_robin_150) +
  coord_sf(crs = crs_robin_150) +
  theme_void()
```

![A Robinson projection world map centered on the Pacific Ocean (150
degrees
East).](World_Map_Overview_files/figure-html/robin_pacific-1.png)

### 3.3 Geographic CRS with shifted central meridian

``` r
crs_wgs84_150 <- "+proj=longlat +datum=WGS84 +lon_0=150"

ggplot() +
  geom_world(crs = crs_wgs84_150) +
  coord_sf(crs = crs_wgs84_150) +
  theme_void()
```

![A rectangular projection world map centered on 150 degrees
East.](World_Map_Overview_files/figure-html/wgs84_pacific-1.png)

## 4. Axis labels and gridlines

A common issue with
[`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html) is
that gridlines appear, but axis labels (coordinates) disappear. This
often occurs when: \* `expand = TRUE` extends the map beyond ±180° or
±90°. \* The CRS lacks a geographic datum. \* Solid layers (like the
ocean polygon) are drawn *on top* of the panel grid.

**Recommended pattern for reliable axis labels:** Use `expand = FALSE`
inside `coord_sf` and set `panel.ontop = TRUE` in the theme.

``` r
ggplot() +
  geom_world() +
  coord_sf(
    crs    = 4326,
    expand = FALSE,
    datum  = sf::st_crs(4326)
  ) +
  theme_minimal() +
  theme(panel.ontop = TRUE)
```

![A world map with clear longitude and latitude axis labels and
gridlines drawn on top of the land
layer.](World_Map_Overview_files/figure-html/axis_labels-1.png)

## 5. Graticule annotation (meridians & parallels)

[`annotation_graticule()`](https://rimagination.github.io/ggmapcn/reference/annotation_graticule.md)
provides precise control over meridians and parallels. Unlike standard
gridlines, these are annotation layers that: \* Are generated in WGS84
and transformed to your target CRS. \* Allow for custom line spacing
(`lon_step`, `lat_step`) and label placement.

### 5.1 Global WGS84 map with graticules

``` r
ggplot() +
  geom_world() +
  annotation_graticule(
    lon_step     = 60,
    lat_step     = 30,
    label_offset = 5
  ) +
  coord_sf(
    crs    = 4326,
    expand = FALSE,
    datum  = sf::st_crs(4326)
  ) +
  theme_void() +
  theme(panel.ontop = TRUE)
#> Spherical geometry (s2) switched off
#> Spherical geometry (s2) switched on
```

![A world map with custom graticule lines labeled every 60 degrees
longitude and 30 degrees
latitude.](World_Map_Overview_files/figure-html/graticule_global-1.png)

### 5.2 Robinson projection

Note how the graticules curve naturally with the projection.

``` r
crs_robin <- "+proj=robin +datum=WGS84"

ggplot() +
  geom_world(crs = crs_robin) +
  annotation_graticule(
    crs          = crs_robin,
    lon_step     = 30,
    lat_step     = 15,
    label_offset = 3e5
  ) +
  coord_sf(crs = crs_robin) +
  theme_void()
#> Spherical geometry (s2) switched off
#> Spherical geometry (s2) switched on
```

![A Robinson projection map with curved graticule
lines.](World_Map_Overview_files/figure-html/graticule_robin-1.png)

### 5.3 Regional China map (clean axis labels)

For regional maps, the recommended pattern is to: 1. Use
[`annotation_graticule()`](https://rimagination.github.io/ggmapcn/reference/annotation_graticule.md)
to draw the lines but hide its internal labels (`label_color = NA`). 2.
Use standard
[`labs()`](https://ggplot2.tidyverse.org/reference/labs.html) or
`coord_sf` labels for the axes. 3. Keep the region exact with
`expand = FALSE`.

``` r
cn_xlim <- c(70, 140)
cn_ylim <- c(0, 60)

ggplot() +
  geom_world() +
  annotation_graticule(
    xlim         = cn_xlim,
    ylim         = cn_ylim,
    crs          = 4326,
    lon_step     = 10,
    lat_step     = 10,
    label_color  = NA,
    label_offset = 1,
    label_size   = 3.5
  ) +
  coord_sf(
    xlim   = cn_xlim,
    ylim   = cn_ylim,
    expand = FALSE
  ) +
  labs(
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_bw()
#> Spherical geometry (s2) switched off
#> Spherical geometry (s2) switched on
```

![A regional map of China and surrounding areas with clean axis labels
and specific graticule
limits.](World_Map_Overview_files/figure-html/region_cn-1.png)

## 6. Highlighting selected countries

You can create “highlight” maps by layering
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
calls. The first call draws the base (e.g., white), and the second call
filters for specific countries to color them.

### 6.1 Highlighting China

``` r
ggplot() +
  geom_world(
    country_fill = "white",
    show_frame   = TRUE
  ) +
  geom_world(
    filter_attribute = "SOC",
    filter           = "CHN",
    country_fill     = "red"
  ) +
  theme_void()
```

![A world map with China highlighted in
red.](World_Map_Overview_files/figure-html/highlight_cn-1.png)

### 6.2 Highlighting multiple countries

Pass a vector of ISO codes to highlight multiple regions.

``` r
focus <- c("CHN", "JPN", "KOR")

ggplot() +
  geom_world(
    country_fill = "grey95",
    show_frame   = TRUE
  ) +
  geom_world(
    filter_attribute = "SOC",
    filter           = focus,
    country_fill     = "#f57f17"
  ) +
  theme_void()
```

![A world map highlighting China, Japan, and South Korea in
orange.](World_Map_Overview_files/figure-html/highlight_multi-1.png)

## 7. Summary

This vignette introduced how to: \* Draw global maps using
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md).
\* Control ocean and administrative boundary layers. \* Work with
different projections. \* Avoid missing axis labels in
[`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html). \*
Add custom meridians/parallels with
[`annotation_graticule()`](https://rimagination.github.io/ggmapcn/reference/annotation_graticule.md).
\* Highlight individual or groups of countries.
