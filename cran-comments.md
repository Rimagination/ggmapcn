## R CMD Check Results

0 errors | 0 warnings | 0 note

* This is a new release (version 0.1.1).
* The following modifications have been made based on previous feedback:

### 1. Response to Previous Reviewer's Comments

#### 1.1 Missing `\value` Tags in `.Rd` Files
- **Issue**: The reviewer requested the addition of `\value` tags to the documentation of exported functions to describe the output structure.
- **Action Taken**: The missing `\value` tags have been added to all relevant `.Rd` files. Detailed descriptions of the output structure, including the class and type of the returned object, have been provided where applicable.

#### 1.2 Use of `\dontrun{}` in Examples
- **Issue**: The reviewer noted that `\dontrun{}` should only be used when examples cannot be executed due to external dependencies, and that executable examples should be unwrapped.
- **Action Taken**: All instances of `\dontrun{}` have been replaced with `\donttest{}` in examples where code execution is feasible within the time limit. Where applicable, examples have been unwrapped to ensure they run within 5 seconds.

#### 1.3 File Writing in User's Home Directory
- **Issue**: The reviewer flagged the use of file-writing functions that target the user's home directory by default.
- **Action Taken**: All file writing operations have been updated to use `tempdir()` instead of the user's home directory, as required by CRAN policies. This change applies to examples, tests, and vignettes.

#### 1.4 Missing Package Description Details
- **Issue**: The package description was too brief and lacked sufficient detail regarding the functionality and methods implemented.
- **Action Taken**: The `Description` field in the `DESCRIPTION` file has been updated to include more detailed information about the package's functionality, including the integration with `ggplot2`, customizable map projections, and styling options.

### 2. General Improvements
- **Documentation**: Several improvements have been made to enhance the clarity and completeness of the documentation. This includes better descriptions of function parameters, return values, and additional examples where necessary.
- **Code Cleanup**: The code has been refactored for improved readability and consistency.

### Summary

All issues raised in previous reviews have been addressed. I believe the package is now in compliance with CRAN's guidelines and look forward to further feedback.
