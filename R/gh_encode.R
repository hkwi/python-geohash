# wrapper to C++ call to do some argument handling in R

gh_encode = function(latitude, longitude, precision = 6L) {
  if (length(precision) != 1L)
    stop("More than one precision value detected; precision is fixed on input (for now)")
  if (precision < 1L) stop('Invalid precision. Precision is measured in ',
                           'characters, must be at least 1.')
  if (precision > .global$GH_MAX_PRECISION) {
    warning('Precision is limited to ', .global$GH_MAX_PRECISION,
            ' characters; truncating')
    precision = .global$GH_MAX_PRECISION
  }

  gh_encode_(latitude, longitude, as.integer(precision))
}
