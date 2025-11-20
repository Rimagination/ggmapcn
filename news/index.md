# Changelog

## ggmapcn 0.3.0

### NEW FEATURES

Major upgrade to geom_world():

- geom_world() is now a complete global basemap generator with bundled
  country polygons, coastlines, ocean layers, and administrative
  boundaries.
- Automatic antimeridian splitting using st_break_antimeridian(),
  respecting the central meridian of the target CRS.
- Projection-aware world outline generation for both geographic and
  projected CRS.
- Fully customizable visual components, including ocean, coastlines,
  country fill, administrative boundaries, and outer frame.
- Improved country filtering mode: when filter is supplied, only the
  selected countries are drawn, without ocean or background layers.
- More robust behavior under non-zero lon_0 and complex projections.

New annotation_graticule():

- Adds a flexible global graticule generator with meridians, parallels,
  and edge labels.
- Graticules are generated in WGS84 and then transformed into the map
  CRS.
- Supports antimeridian splitting when lon_0 is non-zero.
- Labels can be placed on any combination of edges: left, right, top,
  bottom.
- Fine control over spacing, offsets, units, and line style.
- Works for both global and regional extents.

### IMPROVEMENTS

- Improved CRS parsing and detection across functions, including robust
  extraction of lon_0 from PROJ strings.
- More stable interaction with coord_sf(), especially for global maps
  where expand and datum previously caused missing axis labels.
- Documentation has been expanded with clearer examples, including
  projection usage, filtering behaviour, and styling controls.
- Improved rendering reliability when handling projections such as
  Robinson, Mollweide, and shifted long-lat systems.
