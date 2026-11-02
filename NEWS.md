ggmapcn 0.3.1
=============

IMPROVEMENTS
------------

- Update the bundled provincial dataset to the latest local Tianditu source.
  Its `name` field now contains the previous English `name_en` values;
  Chinese names are in `name_cn`, and `gb` contains source codes. Existing
  filters and joins using the previous fields need to be updated.
- Update the bundled boundary dataset, including the two Guangdong–Macao
  boundary segments and Chinese boundary type names in `name_cn`.
- Rebuild the bundled `China_mask.gpkg` from the provincial polygons so the
  mask matches the bundled provincial dataset.
- Store downloaded map data in the user cache instead of the installed package;
  continue to reuse files from the previous user data directory.
- Provide the package logo as a PNG file for HTML help and reference manuals.
- Add options to `annotation_graticule()` for line transparency and label
  formatting, font, transparency, and rotation, while preserving existing
  positional arguments and the `alpha` argument passed through `...`.
- Clarify the package description and default dataset delivery, and render
  Markdown in the help documentation.

ggmapcn 0.3.0
=============

NEW FEATURES
------------

- **New function: `annotation_graticule()`**  
  Adds a projection-aware global graticule system with customizable spacing, labeling,
  and automatic antimeridian handling.

MAJOR IMPROVEMENTS
-------------------

- **Major redesign of `geom_world()`**  
  Fully rebuilt global basemap system using world polygons, coastlines, and
  boundaries; improved antimeridian handling; more reliable behavior under complex
  projections; and clearer, more consistent styling controls.

- **Major redesign of the external data workflow (`check_geodata()`)**  
  The data-management system has been rewritten to meet CRAN size limits and improve
  reliability. Required datasets are now located or retrieved automatically using a
  priority search (local directories → package extdata → user cache), with retry,
  resume, and mirror fallbacks. The data-retrieval helper returns `NA` when files
  cannot be obtained. Functions using default map datasets call this workflow
  internally.

IMPROVEMENTS
------------

- More robust CRS parsing, including reliable extraction of `lon_0` from PROJ strings.
- Better stability with `coord_sf()`, especially for global projections and shifted
  central meridians.
- Updated documentation and examples, including usage of the new world dataset
  (`world_countries.rda`, `world_coastlines.rda`, `world_boundaries.rda`).
- More consistent rendering across projections such as Robinson, Mollweide, and
  shifted longitude systems.
