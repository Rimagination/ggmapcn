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
  Fully rebuilt global basemap system with bundled world polygons, coastlines, and
  boundaries; improved antimeridian handling; more reliable behavior under complex
  projections; and clearer, more consistent styling controls.

- **Major redesign of the external data workflow (`check_geodata()`)**  
  The data-management system has been rewritten to meet CRAN size limits and improve
  reliability. Required datasets are now located or retrieved automatically using a
  priority search (local directories → package extdata → user cache), with retry,
  resume, mirror fallbacks, and fully graceful failure. All mapping functions now
  call this workflow internally.

IMPROVEMENTS
------------

- More robust CRS parsing, including reliable extraction of `lon_0` from PROJ strings.
- Better stability with `coord_sf()`, especially for global projections and shifted
  central meridians.
- Updated documentation and examples, including usage of the new world dataset
  (`world_countries.rda`, `world_coastlines.rda`, `world_boundaries.rda`).
- More consistent rendering across projections such as Robinson, Mollweide, and
  shifted longitude systems.
