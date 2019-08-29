# https://epsg.io/4326
wgs = function() sp::CRS('+init=epsg:4326')

check_suggested = function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("This function requires an installation of ", pkg,
         "; install.packages('", pkg, "') to proceed.")
  }
}

gh_to_sp = function(geohashes) {
  check_suggested('sp')
  gh = tolower(geohashes)
  if (anyDuplicated(gh) > 0L) {
    idx = which(duplicated(gh))
    warning("Detected ", length(idx), " duplicate input geohashes; removing")
    gh = gh[-idx]
  }
  gh_xy = gh_decode(gh, include_delta = TRUE)
  sp::SpatialPolygons(lapply(seq_along(gh), function(ii) {
    with(gh_xy, sp::Polygons(list(sp::Polygon(cbind(
      # the four corners of the current geohash
      longitude[ii] + c(-1, -1, 1, 1, -1) * delta_longitude[ii],
      latitude[ii] + c(-1, 1, 1, -1, -1) * delta_latitude[ii]
    ))), ID = gh[ii]))
    # gh_decode returns values in WSG 84
  }), proj4string = wgs())
}

gh_to_spdf = function(...) {
  check_suggested('sp')
  UseMethod('gh_to_spdf')
}

gh_to_spdf.default = function(geohashes, ...) {
  if (anyDuplicated(geohashes) > 0L) {
    idx = which(duplicated(geohashes))
    warning("Detected ", length(idx), " duplicate input geohashes; removing")
    geohashes = geohashes[-idx]
  }
  sp::SpatialPolygonsDataFrame(
    gh_to_sp(geohashes),
    data = data.frame(row.names = geohashes, ID = seq_along(geohashes))
  )
}

gh_to_spdf.data.frame = function(gh_df, gh_col = 'gh', ...) {
  if (is.na(idx <- match(gh_col, names(gh_df))))
    stop('Searched for geohashes at a column named "',
         gh_col, '", but found nothing.')
  gh = gh_df[[idx]]
  if (anyDuplicated(gh) > 0L) {
    idx = which(duplicated(gh))
    warning("Detected ", length(idx), " duplicate input geohashes; removing")
    gh = gh[-idx]
    gh_df = gh_df[-idx, , drop = FALSE]
  }
  sp::SpatialPolygonsDataFrame(
    gh_to_sp(gh), data = gh_df, match.ID = FALSE
  )
}

gh_covering = function(SP, precision = 6L, minimal = FALSE) {
  check_suggested('sp')
  if (!inherits(SP, 'Spatial'))
    stop("Object to cover must be Spatial (or subclass)")
  bb = sp::bbox(SP)
  delta = 2*gh_delta(precision)
  # TODO: actually goes through an encode-decode cycle -- more efficient to
  #   just build the cells directly by rounding to the precision's grid
  gh = with(expand.grid(
    latitude = seq(bb[2L, 'min'], bb[2L, 'max'] + delta[1L], by = delta[1L]),
    longitude = seq(bb[1L, 'min'], bb[1L, 'max'] + delta[2L], by = delta[2L])
  ), gh_encode(latitude, longitude, precision))
  if (is.na(prj4 <- sp::proj4string(SP))) sp::`proj4string<-`(SP, prj4 <- wgs())
  cover = sp::spTransform(gh_to_spdf(gh), prj4)
  if (minimal) {
    # slightly more efficient to use rgeos, but there's a bug preventing
    #   that version from working (reported 2019-08-16):
    #   cover[c(rgeos::gIntersects(cover, SP, byid = c(TRUE, FALSE))), ]
    return(cover[c(!is.na(sp::over(cover, SP))), ])
  } else return(cover)
}

gh_to_sf = function(...) {
  check_suggested('sf')
  sf::st_as_sf(gh_to_spdf(...))
}
