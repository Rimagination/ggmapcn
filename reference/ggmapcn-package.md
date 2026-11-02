# Customizable China and Global Map Visualizations

Provides layers and annotations for drawing maps of China and the world
with ggplot2. Supports map projections, administrative boundaries,
graticules, scale bars, north arrows, buffer zones, and raster overlays.
China administrative division data are derived from the *Tianditu*
geospatial information service, with separate layers for land borders,
coastlines, and maritime boundaries.

## Map layers

- **World maps**:
  [`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
  draws a global basemap with countries, coastlines, boundaries, and
  optional ocean fill.

- **China maps**:
  [`geom_mapcn()`](https://rimagination.github.io/ggmapcn/reference/geom_mapcn.md)
  and
  [`geom_boundary_cn()`](https://rimagination.github.io/ggmapcn/reference/geom_boundary_cn.md)
  provide provincial, prefecture-level maps and coastlines.

- **Annotation tools**:

  - [`annotation_graticule()`](https://rimagination.github.io/ggmapcn/reference/annotation_graticule.md)
    — global graticules with projection-aware labels.

  - [`annotation_scalebar()`](https://rimagination.github.io/ggmapcn/reference/annotation_scalebar.md)
    — scale bar with automatic units and CRS detection.

  - [`annotation_compass()`](https://rimagination.github.io/ggmapcn/reference/annotation_compass.md)
    — north arrow with several styles.

- **Projection helper**:

  - [`coord_proj()`](https://rimagination.github.io/ggmapcn/reference/coord_proj.md)
    — specify geographic `xlim`/`ylim` in degrees and automatically
    transform to any projection.

## Geospatial data

The package provides default boundary, world map, elevation, and
vegetation datasets for direct use by its mapping functions. Some files
are distributed in the installed package; larger files are hosted in the
companion [ggmapcn-data
repository](https://github.com/Rimagination/ggmapcn-data).
[`check_geodata()`](https://rimagination.github.io/ggmapcn/reference/check_geodata.md)
reuses local copies or retrieves missing default files. It returns `NA`
for files it cannot retrieve. Mapping functions require the
corresponding datasets to be available before plotting.

## Integration

Mapping and annotation functions return layers or lists of layers for
ggplot2.
[`check_geodata()`](https://rimagination.github.io/ggmapcn/reference/check_geodata.md)
returns file paths, and
[`coord_proj()`](https://rimagination.github.io/ggmapcn/reference/coord_proj.md)
returns a coordinate system.

## See also

Useful links:

- <https://rimagination.github.io/ggmapcn/>

- Report bugs at <https://github.com/Rimagination/ggmapcn/issues>

## Author

**Maintainer**: Liang Ren <rl23@mails.tsinghua.edu.cn>
([ORCID](https://orcid.org/0000-0002-2360-7900))
