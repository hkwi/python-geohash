# get cell half-widths for a given geohash precision

gh_delta = function(precision) {
  if (length(precision) > 1L) stop("One precision at a time, please")
  45/2^((5*precision + c(-1, 1)*(precision %% 2))/2 - 1:2)
}
