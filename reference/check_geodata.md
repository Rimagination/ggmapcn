# Check and Download Geospatial Data

Ensure required geodata files exist locally. The function searches and
reuses existing files (when `overwrite = FALSE`) *before* attempting any
network download, in the following order:

1.  user-provided **local_dirs**

2.  installed package **extdata** (even if not writable)

3.  per-user cache **tools::R_user_dir("ggmapcn","data")**

If no valid local file is found (or `overwrite = TRUE`), the function
downloads from mirrors *in order*. By default, a China-friendly CDN
(jsDelivr) is tried first, then GitHub raw.

When internet access is unavailable or all mirrors fail, the function
*fails gracefully*: it returns `NA` for the corresponding files and
prints an informative message (no error or warning is thrown unless
invalid file names are requested).

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

  Character vector of file names. If \`NULL\`, all known files are used.

- overwrite:

  Logical. Force re-download even if a non-empty file exists. Default
  \`FALSE\`.

- quiet:

  Logical. Suppress progress and messages. Default \`FALSE\`.

- max_retries:

  Integer. Max retry attempts per (mirror, file). Default \`3\`.

- mirrors:

  Character vector of base URLs (end with \`/\`). Tried in order.
  Default: jsDelivr first, then GitHub raw.

- use_checksum:

  Logical. Verify SHA-256 when available. Default \`TRUE\`.

- checksums:

  Named character vector of SHA-256 digests (names = file names). If
  \`NULL\`, built-in defaults are used for known files; unknown files
  skip verification.

- resume:

  Logical. Try HTTP range resume if a \`.part\` exists (only for
  writable dirs). Default \`TRUE\`.

- local_dirs:

  Character vector of directories to search *before* any download. If a
  matching non-empty file is found and `overwrite = FALSE`, it is
  returned immediately.

## Value

Character vector of absolute file paths (NA for failures).

## Examples

``` r
if (FALSE) { # interactive() && curl::has_internet()
# Basic: ensure default files exist (may download if not found locally)
check_geodata()

# Single file: reuse existing file if present (default overwrite = FALSE)
check_geodata(files = "boundary.rda")

# Force re-download a file (e.g., suspected corruption)
check_geodata(files = "boundary.rda", overwrite = TRUE)

# Search local folders first; skip download if a valid file is found there
check_geodata(
  files = c("boundary.rda", "world.rda"),
  local_dirs = c(getwd())  # add more directories if needed
)

# Provide your own mirror order (first tried wins)
check_geodata(
  files = "boundary.rda",
  mirrors = c(
    "https://cdn.jsdelivr.net/gh/Rimagination/ggmapcn-data@main/data/",
    "https://raw.githubusercontent.com/Rimagination/ggmapcn-data/main/data/"
  )
)
}
```
