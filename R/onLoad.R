#Internal globals
# nocov start
.global = new.env(parent = emptyenv())
setPackageName("geohashTools", .global)

.onLoad <- function(libname, pkgname) {
  # inverting gh_delta(n)[1] < epsilon depends on parity of n
  n = as.integer(ceiling(.4*(log2(180) - log2(.Machine$double.eps)) + c(0, .2)))
  .global$GH_MAX_PRECISION =
    if (length(unique(n)) == 1L || n[1L] %% 2L) n[1L] else n[2L]
}
# nocov end
