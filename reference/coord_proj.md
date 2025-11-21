# Coordinate System with Geographic Limits Automatically Transformed to a Projection

\`coord_proj()\` extends
[`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
by allowing users to specify map limits (\`xlim\`, \`ylim\`) in
geographic coordinates (longitude/latitude, WGS84). These limits are
automatically transformed into the target projected CRS, ensuring that
maps display the intended region correctly under any projection.

This wrapper is particularly useful because
[`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
interprets \`xlim\` and \`ylim\` as \*projected\* coordinates. Passing
longitude/latitude directly to
[`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
results in incorrect map extents unless the CRS is WGS84.
\`coord_proj()\` provides a safe, projection-aware workflow that
requires no manual calculation of projected bounding boxes.

## Usage

``` r
coord_proj(
  crs = NULL,
  xlim = NULL,
  ylim = NULL,
  expand = TRUE,
  default_crs = "EPSG:4326",
  ...
)
```

## Arguments

- crs:

  Character string specifying the output coordinate reference system
  (e.g., \`"EPSG:4326"\`, \`"EPSG:3857"\`, or a PROJ string such as
  \`"+proj=aeqd +lat_0=35 +lon_0=105"\`). Required.

- xlim:

  Numeric vector of length 2. Longitude limits in degrees (WGS84).

- ylim:

  Numeric vector of length 2. Latitude limits in degrees (WGS84).

- expand:

  Logical. Passed to
  [`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  Default: \`TRUE\`.

- default_crs:

  Character. CRS of \`xlim\` and \`ylim\`. Default: \`"EPSG:4326"\`.

- ...:

  Additional arguments passed to
  [`coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Value

A
[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)
object with automatically transformed limits.

## See also

[`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html),
[`geom_world`](https://rimagination.github.io/ggmapcn/reference/geom_world.md),
[`geom_mapcn`](https://rimagination.github.io/ggmapcn/reference/geom_mapcn.md)

## Examples

``` r
# Example 1: China (AEQD projection) with geographic limits
china_proj <- "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"

ggplot() +
  geom_world(crs = china_proj) +
  coord_proj(
    crs = china_proj,
    xlim = c(60, 140),
    ylim = c(-10, 50)
  ) +
  theme_minimal()
#> Spherical geometry (s2) switched off
#> Spherical geometry (s2) switched on



# Example 2: South China Sea region using geom_mapcn + geom_boundary_cn
ggplot() +
  geom_mapcn(fill = "white") +
  geom_boundary_cn() +
  theme_bw() +
  coord_proj(
    crs = china_proj,
    expand = FALSE,
    xlim = c(105, 126),   # lon range
    ylim = c(2, 23)       # lat range
  )

```
