## Test environments

* Windows 11 x64, R-devel 4.7.0 (2026-11-01 r90825).
* Source tarball built on Windows 11 x64 with R 4.6.2.
* Targeted regression tests also run on Windows 11 x64 with R 4.5.3.

## R CMD check results

The source tarball was built with vignettes and checked with
`R CMD check --as-cran`: 0 errors, 0 warnings, and 0 notes. The check included
examples, tests, vignette rebuilding, and the PDF manual.

The world and basic-map vignettes in an earlier development build were also
rendered with an empty data cache and HTTP(S) proxies configured to reject
connections. Examples requiring unavailable external data were displayed without
being evaluated.

## Submission comments

This update addresses the CRAN notice about package logos in HTML help and
reference manuals. The logo is provided as `man/figures/logo.png`.

The update also includes previously unpublished options for
`annotation_graticule()`, while preserving existing positional arguments and
the `alpha` argument passed through `...`.

The bundled provincial and boundary datasets have been updated, and the China
mask has been rebuilt from the updated provincial polygons. In the provincial
dataset, `name` now contains English names and Chinese names are in `name_cn`;
existing filters and joins using the previous fields may need to be updated.
Downloads now go to the user cache rather than the installed package, with the
previous user data directory retained as a read-only fallback.

The package description and help text clarify the default datasets and their
storage requirements, with data-source descriptions aligned with the accepted
package manuscript.
