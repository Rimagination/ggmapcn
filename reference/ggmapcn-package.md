# ggmapcn: China-Focused Mapping Tools with Optional Global Support for ggplot2

\*\*ggmapcn\*\* provides lightweight, ready-to-use tools for drawing
China and world maps with \*ggplot2\*. It bundles clean geodata and
offers simple, projection-aware helpers for basemaps, graticules,
compasses, and scale bars.

## Details

\## Main Features

\- \*\*World maps\*\*: \`geom_world()\` draws a complete global basemap
with countries, coastlines, boundaries, and optional ocean fill.

\- \*\*China maps\*\*: \`geom_mapcn()\` and \`geom_boundary_cn()\`
provide provincial, prefecture-level maps and coastlines.

\- \*\*Annotation tools\*\*: - \`annotation_graticule()\` — global
graticules with projection-aware labels. - \`annotation_scalebar()\` —
scale bar with automatic units and CRS detection. -
\`annotation_compass()\` — north arrow with several styles.

\- \*\*Projection helper\*\*: - \`coord_proj()\` — specify geographic
\`xlim\`/\`ylim\` in degrees and automatically transform to any
projection.

\- \*\*Geodata management\*\*: - \`check_geodata()\` locates bundled
world and China datasets and ensures graceful behaviour when data or
internet resources are unavailable.

\## Integration

All functions return standard \*ggplot2\* layers and work seamlessly
with \`sf\` objects, custom projections, and \`coord_sf()\`.

## See also

Useful links:

- <https://rimagination.github.io/ggmapcn/>

- Report bugs at <https://github.com/Rimagination/ggmapcn/issues>

## Author

**Maintainer**: Liang Ren <rl23@mails.tsinghua.edu.cn>
([ORCID](https://orcid.org/0000-0002-2360-7900))
