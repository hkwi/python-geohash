# wrapper to C++ call to do some argument handling in R

gh_decode = function(geohashes, coord_loc = 'c', include_delta = FALSE) {
  coord_loc = switch(
    tolower(coord_loc),
    'centroid' = , 'c' = 0L,
    'southwest' = , 'sw' = 1L,
    'south' = , 's' = 2L,
    'southeast' = , 'se' = 3L,
    'east' = , 'e' = 4L,
    'northeast' = , 'ne' = 5L,
    'north' = , 'n' = 6L,
    'northwest' = , 'nw' = 7L,
    'west' = , 'w' = 8L,
    stop('Unrecognized coordinate location; please use ',
         "'c' for centroid or a cardinal direction; see ?gh_decode")
  )
  gh_decode_(geohashes, coord_loc, include_delta)
}
