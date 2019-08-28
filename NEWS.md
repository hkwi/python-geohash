# `geohashTools` NEWS

## v0.2.4

### BUG FIXES

 1. CRAN submission again detected memory issues (accessing memory beyond which was declared for an array), reproduced & fixed in [#18](https://github.com/MichaelChirico/geohashTools/pull/18); the original fix also led to an uninitialized access error, [#21](https://github.com/MichaelChirico/geohashTools/issues/21).
 
 2. CRAN submission also detected a type mismatch error, [#20](https://github.com/MichaelChirico/geohashTools/issues/20).

## v0.2.2

### NEW FEATURES

 1. `gh_covering` for generating a covering of an input polygon in geohashes, [#7](https://github.com/MichaelChirico/geohashTools/issues/7).

### BUG FIXES

 1. CRAN submission detected some memory issues in the C++ code which have now hopefully been fixed in [#12](https://github.com/MichaelChirico/geohashTools/pull/12).
 
 2. `gh_to_spdf` failed with duplicate inputs, [#11](https://github.com/MichaelChirico/geohashTools/issues/11). Duplicates are removed with warning.
 
 3. `gh_neighbors('')` failed, [#16](https://github.com/MichaelChirico/geohashTools/issues/16).

# Updates only tracked here since v0.2.2
