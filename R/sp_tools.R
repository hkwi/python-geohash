# https://epsg.io/4326
wgs = function() sp::CRS('+init=epsg:4326')

gh_to_sp = function(geohashes) {
  if (!requireNamespace('sp', quietly = TRUE)) {
    stop("This function requires an installation of sp; ",
         "install.packages('sp') to proceed.")
  }
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
  if (!requireNamespace('sp', quietly = TRUE)) {
    stop("This function requires an installation of sp; ",
         "install.packages('sp') to proceed.")
  }
  UseMethod('gh_to_spdf')
}

gh_to_spdf.default = function(gh, ...) {
  sp::SpatialPolygonsDataFrame(
    gh_to_sp(gh),
    data = data.frame(row.names = gh, ID = seq_along(gh))
  )
}

gh_to_spdf.data.frame = function(gh_df, gh_col = 'gh', ...) {
  if (is.na(idx <- match(gh_col, names(gh_df))))
    stop('Searched for geohashes at a column named "',
         gh_col, '", but found nothing.')
  sp::SpatialPolygonsDataFrame(
    gh_to_sp(gh_df[[idx]]), data = gh_df, match.ID = FALSE
  )
}
