# World map overview with geom_world()

## 1. Introduction

[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
provides a convenient global base map for `ggplot2`. It comes bundled
with country polygons, coastlines, and political/administrative
boundaries.

Key features include:

- **Automatic CRS transformation**: Seamlessly projects data to your
  desired Coordinate Reference System.
- **Antimeridian splitting**: Handles the “Pacific wrap-around” issue
  automatically when changing central meridians.
- **Layer control**: Toggles for ocean background and administrative
  boundaries.

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
often occurs when:

- `expand = TRUE` extends the map beyond ±180° or ±90°.
- The CRS lacks a geographic datum.
- Solid layers (like the ocean polygon) are drawn *on top* of the panel
  grid.

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
gridlines, these are annotation layers that:

- Are generated in WGS84 and transformed to your target CRS.
- Allow for custom line spacing (`lon_step`, `lat_step`) and label
  placement.

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
```

![A Robinson projection map with curved graticule
lines.](World_Map_Overview_files/figure-html/graticule_robin-1.png)

### 5.3 Regional China map (clean axis labels)

For regional maps, the recommended pattern is to:

1.  Use
    [`annotation_graticule()`](https://rimagination.github.io/ggmapcn/reference/annotation_graticule.md)
    to draw the lines but hide its internal labels (`label_color = NA`).
2.  Use standard
    [`labs()`](https://ggplot2.tidyverse.org/reference/labs.html) or
    `coord_sf` labels for the axes.
3.  Keep the region exact with `expand = FALSE`.

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

## 7. Visualizing Custom Data

Users can also merge external datasets (e.g., GDP, population, or other
metrics) with the map data to create choropleth maps. This requires
accessing the underlying spatial data using `check_geodata` and `load`.

### 7.1 Merging external metrics

First, ensure the necessary geospatial data files are available and load
them. Then, merge your custom data using the ISO country code (SOC).

``` r
# 1. Ensure data availability and GET FILE PATHS
map_files <- check_geodata(c("world_countries.rda", "world_coastlines.rda"))
#> extdata dir: /home/runner/work/_temp/Library/ggmapcn/extdata (writable = TRUE)
#> cache   dir: /home/runner/.local/share/R/ggmapcn (writable = TRUE)
#> Using existing extdata file: /home/runner/work/_temp/Library/ggmapcn/extdata/world_countries.rda
#> Using existing extdata file: /home/runner/work/_temp/Library/ggmapcn/extdata/world_coastlines.rda

# 2. Load the world countries data (object name: 'countries')
load(map_files[1])

# 3. Create custom data: Real 2023 Population Estimates (Top 25+ major nations)
# Unit: Millions
custom_data <- data.frame(
  iso_code = c("CHN", "IND", "USA", "IDN", "PAK", "NGA", "BRA", "BGD", 
               "RUS", "MEX", "JPN", "ETH", "PHL", "EGY", "VNM", "COD", 
               "TUR", "IRN", "DEU", "THA", "GBR", "FRA", "ITA", "ZAF", 
               "KOR", "ESP", "COL", "CAN", "AUS", "SAU"),
  pop_mil  = c(1425.7, 1428.6, 339.9, 277.5, 240.5, 223.8, 216.4, 172.9, 
               144.4, 128.5, 123.3, 126.5, 117.3, 112.7, 98.9, 102.3, 
               85.8, 89.2, 83.2, 71.8, 67.7, 64.7, 58.9, 60.4, 
               51.7, 47.5, 52.1, 38.8, 26.6, 36.9)
)

# 4. Merge custom data with the 'countries' object
# Note: Use 'all.x = TRUE' to preserve the map geometry for all countries
merged_data <- merge(
  countries, 
  custom_data, 
  by.x  = "SOC", 
  by.y  = "iso_code", 
  all.x = TRUE
)

# 5. Plot with layering strategy
ggplot() +
  # Layer 1: Data Fill (No borders, just color)
  geom_sf(
    data  = merged_data, 
    aes(fill = pop_mil), 
    color = "transparent"
  ) +
  # Layer 2: World Boundaries (Transparent fill, standard borders)
  geom_world(
    country_fill = NA, 
    show_ocean   = FALSE
  ) +
  # Styling
  scale_fill_viridis_c(
    option    = "plasma", 
    na.value  = "grey95", 
    direction = -1,      # Reverse color scale so dark = high population
    name      = "Population (Millions)"
  ) +
  theme_void() +
  theme(legend.position = "bottom")
```

![A world map with countries colored by GDP using a continuous color
scale.](World_Map_Overview_files/figure-html/custom_data_gdp-1.png)

This workflow highlights a key design philosophy: by accessing raw
spatial data via
[`check_geodata()`](https://rimagination.github.io/ggmapcn/reference/check_geodata.md)
and processing it with
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html), you
gain complete flexibility to visualize custom datasets. At the same
time, overlaying
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
ensures that the final map retains the consistent, high-quality basemap
and administrative boundary styles provided by `ggmapcn`.
