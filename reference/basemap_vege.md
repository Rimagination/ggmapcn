# Vegetation Map of China Layer for ggplot2

Adds a vegetation raster map of China to a ggplot2 plot, with
color-coded vegetation types.

## Usage

``` r
basemap_vege(
  color_table = NULL,
  crs = NULL,
  maxcell = 1e+06,
  use_coltab = TRUE,
  na.rm = FALSE,
  ...
)
```

## Arguments

- color_table:

  A data frame containing vegetation types and their corresponding
  colors. It should have columns "code" (raster values), "type"
  (vegetation names), and "col" (hex color codes). If NULL, a default
  color table based on standard vegetation classifications for China is
  used.

- crs:

  A character string specifying the coordinate reference system for the
  projection. If NULL, the default projection "+proj=aeqd +lat_0=35
  +lon_0=105 +ellps=WGS84 +units=m +no_defs" is applied.

- maxcell:

  An integer indicating the maximum number of cells for rendering to
  improve performance. Defaults to 1e6.

- use_coltab:

  A logical value indicating whether to use the color table for raster
  values. Default is TRUE.

- na.rm:

  A logical value indicating whether to remove missing values. Default
  is FALSE.

- ...:

  Additional parameters passed to \`geom_spatraster\`.

## Value

A ggplot2 layer object representing the vegetation map of China.

## References

Zhang X, Sun S, Yong S, et al. (2007). \*Vegetation map of the People's
Republic of China (1:1000000)\*. Geology Publishing House, Beijing.

## Examples

``` r
# \donttest{
# Example1: Check and load the vegetation raster map

# Make sure the required raster data is available
check_geodata(files = c("vege_1km_projected.tif"))
#> extdata dir: /home/runner/work/_temp/Library/ggmapcn/extdata (writable = TRUE)
#> cache   dir: /home/runner/.local/share/R/ggmapcn (writable = TRUE)
#> Fetching 'vege_1km_projected.tif' into: /home/runner/work/_temp/Library/ggmapcn/extdata
#>   Trying URL: https://cdn.jsdelivr.net/gh/Rimagination/ggmapcn-data@main/data/vege_1km_projected.tif
#> Saved to extdata: /home/runner/work/_temp/Library/ggmapcn/extdata/vege_1km_projected.tif
#> [1] "/home/runner/work/_temp/Library/ggmapcn/extdata/vege_1km_projected.tif"

# Once the data is checked or downloaded, add the vegetation raster to a ggplot
ggplot() +
  basemap_vege() +
  theme_minimal()
#> <SpatRaster> resampled to 1000776 cells.
#> Warning: Removed 715308 rows containing missing values or values outside the scale range
#> (`geom_raster()`).


# Example2: Customize color table
custom_colors <- data.frame(
  code = 0:11,
  type = c(
    "Non-vegetated", "Needleleaf forest", "Needleleaf and broadleaf mixed forest",
    "Broadleaf forest", "Scrub", "Desert", "Steppe", "Grassland",
    "Meadow", "Swamp", "Alpine vegetation", "Cultivated vegetation"
  ),
  col = c(
    "#8D99B3", "#97B555", "#34BF36", "#9ACE30", "#2EC6C9", "#E5CE0E",
    "#5BB1ED", "#6494EF", "#7AB9CB", "#D97A80", "#B87701", "#FEB780"
  )
)
ggplot() +
  basemap_vege(color_table = custom_colors) +
  labs(fill = "Vegetation type group") +
  theme_minimal()
#> <SpatRaster> resampled to 1000776 cells.
#> Warning: Removed 715308 rows containing missing values or values outside the scale range
#> (`geom_raster()`).

# }
```
