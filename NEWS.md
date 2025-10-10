# ggmapcn 0.2.0

## NEW FEATURES

* Added the `annotation_compass()` function to add a powerful and highly customizable compass/north arrow to maps.
  * Supports alignment to "grid" north or "true" north via the which_north argument.
  * Can be easily placed in any corner of the plot panel using the location argument.

* Introduced a family of built-in style constructors (compass-styles) for `annotation_compass()` to support a wide range of visual appearances:
  * Classic Styles: `north_arrow_classic()` and `north_arrow_solid()`.
  * Compass Rose Styles: `compass_rose_simple()`, `compass_rose_classic()`, and `compass_rose_circle()`.
  * Original Chinese-Themed Styles: Added two unique styles, `compass_guiding_fish()` (Guiding Fish) and `compass_sinan()` (Sinan), inspired by ancient Chinese navigational instruments to add a cultural touch to maps.
  
* Added the annotation_scalebar() function to add a projection-aware and intelligent scale bar.
  * The function automatically detects the map's Coordinate Reference System (CRS) to select appropriate units and breaks.
  * Supports several common styles, including "segment", "bar", and "ticks".
  
