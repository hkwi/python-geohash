# wrapper to C++ call to do some argument handling in R

gh_encode = function(longitude, latitude, precision = 6L) {
  if (precision > 28L) {
    warning('Precision is limited to 28 characters (at the nanometer scale); truncating')
    precision = 28L
  }
  gh_encode_(longitude, latitude, as.integer(precision))
}
