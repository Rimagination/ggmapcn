# Elevation Map of China Layer for ggplot2

`basemap_dem()` adds a digital elevation model (DEM) raster layer to a
ggplot2 plot. It supports displaying elevation within China's boundary
or in a rectangular area around China. Users can supply a `terra` raster
through `data`. Otherwise,
[`check_geodata()`](https://rimagination.github.io/ggmapcn/reference/check_geodata.md)
locates or retrieves the default elevation dataset from the package's
companion data repository.

## Usage

``` r
basemap_dem(
  data = NULL,
  crs = NULL,
  within_china = FALSE,
  maxcell = 1e+06,
  na.rm = FALSE,
  ...
)
```

## Arguments

- data:

  Optional. A `terra` raster object for custom DEM data.

- crs:

  Coordinate reference system (CRS) for the projection. Defaults to the
  CRS of the DEM data. Users can specify other CRS strings (e.g.,
  `"EPSG:4326"` or custom projections).

- within_china:

  Logical. If `TRUE`, displays only the DEM within China's boundary. If
  `FALSE`, displays the DEM for a larger rectangular area around China.
  Default is `FALSE`.

- maxcell:

  Maximum number of cells for rendering (to improve performance).
  Defaults to `1e6`.

- na.rm:

  Logical. If `TRUE`, removes missing values. Default is `FALSE`.

- ...:

  Additional parameters passed to `geom_spatraster`.

## Value

A layer produced by
[`tidyterra::geom_spatraster()`](https://dieghernan.github.io/tidyterra/reference/geom_spatraster.html)
that can be added to a ggplot2 plot.

## Details

The default elevation layer is the China subset of GEBCO_2024. The
dataset is located or retrieved as `gebco_2024_China.tif` by
[`check_geodata()`](https://rimagination.github.io/ggmapcn/reference/check_geodata.md).

## References

GEBCO Compilation Group (2024). GEBCO 2024 Grid. NERC EDS British
Oceanographic Data Centre NOC. <https://www.gebco.net/>.

## See also

[`geom_boundary_cn`](https://rimagination.github.io/ggmapcn/reference/geom_boundary_cn.md)

## Examples

``` r
if (FALSE) { # interactive()
# \donttest{
# Before using the basemap_dem function, make sure the required data files are available.
# The required files are: "gebco_2024_China.tif" and "China_mask.gpkg".
# You can use check_geodata() to download them from GitHub if they are not available locally.

# Check and download the required data files if they are missing
check_geodata(files = c("gebco_2024_China.tif", "China_mask.gpkg"))

# Define the CRS for China (EPSG:4326 is a common global geographic coordinate system)
china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"

# Example 1: Display the rectangular area around China using the default DEM data
ggplot() +
  basemap_dem(within_china = FALSE) +
  tidyterra::scale_fill_hypso_tint_c(
    palette = "gmt_globe",
    breaks = c(-10000, -5000, 0, 2000, 5000, 8000)
  ) +
  theme_minimal()

# Example 2: Display only China's DEM and boundaries using the default DEM data
ggplot() +
  basemap_dem(crs = china_proj, within_china = TRUE) +
  geom_boundary_cn(crs = china_proj) +
  tidyterra::scale_fill_hypso_c(
    palette = "dem_print",
    breaks = c(0, 2000, 4000, 6000),
    limits = c(0, 7000)
  ) +
  labs(fill = "Elevation (m)") +
  theme_minimal()
# }
}
```
