# Check and retrieve required geodata files

Ensures that default geospatial data files provided by ggmapcn are
available locally. Existing files are reused when `overwrite = FALSE`;
missing files are downloaded from remote mirrors when possible. If all
mirrors fail (for example, due to network restrictions), the function
returns `NA` for the affected files.

## Usage

``` r
check_geodata(
  files = NULL,
  overwrite = FALSE,
  quiet = FALSE,
  max_retries = 3,
  mirrors = NULL,
  use_checksum = TRUE,
  checksums = NULL,
  resume = TRUE,
  local_dirs = NULL
)
```

## Arguments

- files:

  Character vector of file names. If `NULL`, all known files are
  processed.

- overwrite:

  Logical; if `TRUE`, forces re-download even when a non-empty file
  already exists. The refreshed file is saved in the user cache, without
  changing the installed package.

- quiet:

  Logical; if `TRUE`, suppresses progress output and messages.

- max_retries:

  Integer; number of retry attempts per file and mirror.

- mirrors:

  Character vector of base URLs ending with `/`. If `NULL`, package
  defaults are used.

- use_checksum:

  Logical; if `TRUE`, verifies SHA-256 checksums when available.

- checksums:

  Optional named character vector of SHA-256 digests. If `NULL`,
  defaults derived from `known_files()` are used.

- resume:

  Logical; whether to attempt HTTP range resume for partially downloaded
  `.part` files.

- local_dirs:

  Character vector of directories to search prior to any download
  attempt.

## Value

A character vector of absolute file paths. Any file that cannot be
obtained is returned as `NA`.

## Details

Default datasets are provided through the installed package and its
companion [data
repository](https://github.com/Rimagination/ggmapcn-data). Larger files
are hosted in that repository to keep the installation small.
`check_geodata()` locates or retrieves these files using the following
priority:

1.  user-specified `local_dirs`

2.  a refreshed copy in the per-user cache, if explicitly requested with
    `overwrite = TRUE` for the current bundled file

3.  the package `extdata` directory

4.  the per-user cache, followed by the legacy user data directory

Downloads are saved under `tools::R_user_dir("ggmapcn", "cache")`; the
installed package directory is only read. A refreshed copy of a bundled
file is used until the corresponding bundled file changes in a package
update.

High-level mapping functions such as
[`geom_mapcn()`](https://rimagination.github.io/ggmapcn/reference/geom_mapcn.md)
and
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
call `check_geodata()` internally, so most users do not need to invoke
it directly. However, running it explicitly can be useful to pre-fetch
or verify required files.

On networks that cannot reliably access `cdn.jsdelivr.net` or
`raw.githubusercontent.com`, downloads may time out and the
corresponding entries in the returned vector will be `NA`. In such
cases, users may manually download the required files from the data
repository and place them into a directory supplied through `local_dirs`
or the user cache directory so that downloads are skipped.

Note: recent versions of
[`geom_world()`](https://rimagination.github.io/ggmapcn/reference/geom_world.md)
use the following world datasets: `world_countries.rda`,
`world_coastlines.rda`, and `world_boundaries.rda`. The legacy
`world.rda` file is no longer used.

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Retrieve only the datasets used by geom_world()
check_geodata(c(
  "world_countries.rda",
  "world_coastlines.rda",
  "world_boundaries.rda"
))

# China administrative boundaries
check_geodata(c("China_sheng.rda", "China_shi.rda", "China_xian.rda"))

# Reuse files manually placed in the working directory
check_geodata("world_countries.rda", local_dirs = getwd())
}
```
