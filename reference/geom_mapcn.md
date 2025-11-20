# Plot China Map with Customizable Options

\`geom_mapcn()\` plots China's administrative boundaries with a simple,
opinionated interface. It loads packaged map data when \`data\` is
\`NULL\`, removes the special row labeled \`"Boundary Line"\`, supports
optional attribute-based filtering, and can reproject to a
user-specified CRS.

## Usage

``` r
geom_mapcn(
  data = NULL,
  admin_level = "province",
  crs = "+proj=aeqd +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs",
  color = "black",
  fill = "white",
  linewidth = 0.5,
  filter_attribute = NULL,
  filter = NULL,
  mapping = NULL,
  ...
)
```

## Arguments

- data:

  An \`sf\` object of geometries to draw. If \`NULL\`, the function
  loads the packaged dataset for the chosen \`admin_level\`.

- admin_level:

  Administrative level to plot. One of \`"province"\` (default),
  \`"city"\`, or \`"county"\`. These correspond to packaged files
  \`China_sheng.rda\`, \`China_shi.rda\`, and \`China_xian.rda\`.

- crs:

  Coordinate Reference System to use for plotting. Defaults to an
  Azimuthal Equidistant projection centered on China: \`"+proj=aeqd
  +lat_0=35 +lon_0=105 +ellps=WGS84 +units=m +no_defs"\`. Accepts proj
  strings or EPSG codes (e.g., \`"EPSG:4326"\`).

- color:

  Border color. Default \`"black"\`.

- fill:

  Fill color. Default \`"white"\`.

- linewidth:

  Border line width. Default \`0.5\`. For older \`ggplot2\` versions,
  use \`size\` instead of \`linewidth\`.

- filter_attribute:

  Optional column name used to filter features (e.g., \`"name_en"\`).

- filter:

  Optional character vector of values to keep (e.g.,
  \`c("Beijing","Shanghai")\`). If supplied with \`filter_attribute\`,
  features are filtered accordingly. If the result is empty, an error is
  thrown.

- mapping:

  Optional aesthetics mapping passed to \`geom_sf()\`. Useful when you
  already have aesthetics to apply (e.g., fill).

- ...:

  Additional arguments forwarded to \`ggplot2::geom_sf()\`.

## Value

A \`ggplot2\` layer.

## Examples

``` r
# Basic provincial map
ggplot2::ggplot() +
  geom_mapcn() +
  ggplot2::theme_minimal()


# Filter by names stored in the data (e.g., English names)
ggplot2::ggplot() +
  geom_mapcn(filter_attribute = "name_en",
             filter = c("Beijing", "Shanghai"),
             fill = "red") +
  ggplot2::theme_minimal()


# Use a different projection
ggplot2::ggplot() +
  geom_mapcn(crs = "+proj=merc", linewidth = 0.7) +
  ggplot2::theme_minimal()

```
