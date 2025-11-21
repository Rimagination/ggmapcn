# Add a Spatially-Aware Compass

\`annotation_compass()\` adds a compass (north arrow) to a ggplot map.
It can align to \*\*grid north\*\* (top of the panel) or \*\*true
north\*\* (geographic north). Styles are provided as grobs or functions
returning grobs (for example \`north_arrow_classic()\`,
\`compass_sinan()\`).

## Usage

``` r
annotation_compass(
  mapping = NULL,
  data = NULL,
  ...,
  location = "bl",
  which_north = "grid",
  height = unit(1.5, "cm"),
  width = unit(1.5, "cm"),
  pad_x = unit(0.5, "cm"),
  pad_y = unit(0.5, "cm"),
  rotation = NULL,
  style = north_arrow_classic()
)
```

## Arguments

- mapping, data:

  Standard ggplot2 layer arguments (typically unused).

- ...:

  Additional parameters passed to the layer (rarely needed).

- location:

  Character; one of \`"tl"\`, \`"tr"\`, \`"bl"\`, \`"br"\`, indicating
  top/bottom and left/right placement. Default: \`"bl"\`.

- which_north:

  Character; \`"grid"\` (default) or \`"true"\`.

- height, width:

  \`grid::unit\`. Compass box dimensions. Defaults: \`1.5 cm\`.

- pad_x, pad_y:

  \`grid::unit\`. Padding from panel edges. Defaults: \`0.5 cm\`.

- rotation:

  Numeric. Fixed rotation in degrees (counter-clockwise). When supplied,
  it overrides \`"grid"\` / \`"true"\` behavior.

- style:

  A grob, \`gList\` / \`gTree\`, or a function returning a grob (for
  example \`north_arrow_classic()\`). Default:
  \`north_arrow_classic()\`.

## Value

A ggplot2 layer object.

## Details

\* \`"grid"\` north: the compass points straight up in plotting space
(no CRS required). \* \`"true"\` north: the compass rotates toward the
geographic North Pole using the plot CRS. This requires a valid CRS
supplied by \`coord_sf()\` or injected via \`layer\$geom_params\$crs\`.
\* A fixed \`rotation\` (degrees counter-clockwise) always overrides the
automatic \`"grid"\` / \`"true"\` logic. \* The layer is
annotation-like: it draws once per panel based on the panel bounds.

## See also

\[compass-styles\]

## Examples

``` r
nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

base <- ggplot() +
  geom_sf(data = nc, fill = "grey90") +
  theme_minimal()

# Example 1: Grid north (no CRS required), bottom-left
base + annotation_compass()


# Example 2: Custom style & position (top-left)
base + annotation_compass(location = "tl", style = compass_sinan())


# Example 3: True north (requires a CRS)
base +
  coord_sf(crs = "+proj=lcc +lon_0=-100 +lat_1=33 +lat_2=45") +
  annotation_compass(location = "br", which_north = "true")
```
