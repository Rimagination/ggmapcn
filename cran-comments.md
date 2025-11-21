## Test environments
* R-hub: ubuntu-gcc-release, fedora-clang-devel, debian-gcc-patched
* win-builder: R-devel
* Local Windows 11, R 4.4.1

## R CMD check results
0 errors | 0 warnings | 0 notes

## Submission Comments

Dear CRAN team,

This is a major update for `ggmapcn`, raising the version to 0.3.0.

Key changes:

1. **New function: `annotation_graticule()`**  
   Provides a projection-aware global graticule system with customizable spacing, 
   labeling, and automatic antimeridian handling.

2. **Major redesign of `geom_world()`**  
   The global basemap system has been rebuilt for better projection handling, 
   antimeridian behavior, and consistent styling.

3. **Major redesign of external-data management (`check_geodata()`)**  
   Rewritten to meet CRAN network-resource policy.  
   All network operations now fail gracefully with informative messages and never
   generate warnings or errors when resources are unavailable.

4. **Documentation updates**  
   All examples and articles have been revised to reflect the new world datasets
   (`world_countries.rda`, `world_coastlines.rda`, `world_boundaries.rda`).

All changes follow CRAN policies, especially regarding optional internet use and
graceful fallback behavior.

Thank you for your consideration.
