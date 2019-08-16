context('GIS tools')

test_that('gh_to_sp works', {
  mauritius = c("mk2u", "mk2e", "mk2g", "mk35", "mk3h",
                "mk3j", "mk2v", "mk2t", "mk2s")

  ghSP = gh_to_sp(mauritius)

  expect_is(ghSP, 'SpatialPolygons')
  expect_length(ghSP, 9L)
  expect_equal(sapply(ghSP@polygons, slot, 'ID'), mauritius)
  expect_equal(ghSP['mk2u', ]@polygons[[1L]]@Polygons[[1L]]@coords,
               matrix(c(57.3046875, 57.3046875, 57.65625, 57.65625,
                        57.3046875, -20.390625, -20.21484375,
                        -20.21484375, -20.390625, -20.390625),
                      nrow = 5L, ncol = 2L))
  if (!requireNamespace('sp')) {
    skip("sp installation required for testing CRS equality")
  } else {
    expect_equal(ghSP@proj4string,
                 sp::CRS("+init=epsg:4326"))
  }

  # duplicate inputs dropped
  expect_warning(ghSP2 <- gh_to_sp(rep(mauritius, 2L)),
                 'duplicate input geohashes', fixed = TRUE)
  expect_equal(ghSP, ghSP2)
})

test_that('gh_to_spdf.default works', {
  urumqi = c("tzy3", "tzy0", "tzy2", "tzy8", "tzy9",
             "tzyd", "tzy6", "tzy4", "tzy1")

  ghSPDF = gh_to_spdf(urumqi)

  expect_is(ghSPDF, 'SpatialPolygonsDataFrame')
  expect_length(ghSPDF, 9L)
  expect_equal(sapply(ghSPDF@polygons, slot, 'ID'), urumqi)
  expect_equal(ghSPDF['tzy2', ]@polygons[[1L]]@Polygons[[1L]]@coords,
               matrix(c(87.5390625, 87.5390625, 87.890625,
                        87.890625, 87.5390625, 43.59375, 43.76953125,
                        43.76953125, 43.59375, 43.59375),
                      nrow = 5L, ncol = 2L))
  if (!requireNamespace('sp')) {
    skip("sp installation required for testing CRS equality")
  } else {
    expect_equal(ghSPDF@proj4string,
                 sp::CRS("+init=epsg:4326"))
  }
  DF = data.frame(ID = 1:9, row.names = urumqi)
  expect_equal(ghSPDF@data, DF)
  # check also duplicated input (#11)
  expect_warning(ghSPDF2 <- gh_to_spdf(rep(urumqi, 2L)),
                 'Detected 9 duplicate input geohashes; removing', fixed = TRUE)
  expect_equal(ghSPDF2@data, DF)
})

test_that('gh_to_spdf.data.frame works', {
  urumqi = c("tzy3", "tzy0", "tzy2", "tzy8", "tzy9",
             "tzyd", "tzy6", "tzy4", "tzy1")
  DF = data.frame(
    gh = urumqi,
    V = c(-1.08, 0.03, -0.68, -2.59, -0.02, 0.72, 0.68, 1.14, 0.47)
  )
  ghSPDF = gh_to_spdf(DF)

  expect_is(ghSPDF, 'SpatialPolygonsDataFrame')
  expect_length(ghSPDF, 9L)
  expect_equal(sapply(ghSPDF@polygons, slot, 'ID'), urumqi)
  expect_equal(ghSPDF['tzy2', ]@polygons[[1L]]@Polygons[[1L]]@coords,
               matrix(c(87.5390625, 87.5390625, 87.890625,
                        87.890625, 87.5390625, 43.59375, 43.76953125,
                        43.76953125, 43.59375, 43.59375),
                      nrow = 5L, ncol = 2L))
  if (!requireNamespace('sp')) {
    skip("sp installation required for testing CRS equality")
  } else {
    expect_equal(ghSPDF@proj4string,
                 sp::CRS("+init=epsg:4326"))
  }
  expect_equal(ghSPDF@data, DF)

  # duplicated inputs (#11)
  expect_warning(ghSPDF2 <- gh_to_spdf(rbind(DF, DF)),
                 'Detected 9 duplicate input geohashes; removing', fixed = TRUE)
  expect_equal(ghSPDF2@data, DF)

  # different gh_col
  names(DF) = c('geohash', 'V')
  ghSPDF = gh_to_spdf(DF, gh_col = 'geohash')
  expect_is(ghSPDF, 'SpatialPolygonsDataFrame')
  expect_length(ghSPDF, 9L)

  # missing gh_col
  expect_error(gh_to_spdf(DF), 'Searched for geohashes', fixed = TRUE)
})

test_that('gh_to_sf works', {
  baku = c("tp5my", "tp5mt", "tp5mw", "tp5mx", "tp5mz",
           "tp5qp", "tp5qn", "tp5qj", "tp5mv")

  ghSF = gh_to_sf(baku)

  expect_is(ghSF, 'sf')
  expect_equal(ghSF$ID, 1:9)
  expect_length(ghSF$geometry, 9L)

  expect_is(ghSF$geometry[1L], 'sfc')
  expect_is(ghSF$geometry[1L][[1L]], 'sfg')
  expect_equal(ghSF$geometry[1L][[1L]][[1L]],
               matrix(c(49.833984375, 49.833984375, 49.8779296875,
                        49.8779296875, 49.833984375, 40.3857421875,
                        40.4296875, 40.4296875, 40.3857421875, 40.3857421875),
                      nrow = 5L, ncol = 2L))
})

test_that('gh_covering works', {
  banjarmasin = sp::SpatialPoints(cbind(
    c(114.605, 114.5716, 114.627, 114.5922, 114.6321,
      114.5804, 114.6046, 114.6028, 114.6232, 114.5792),
    c(-3.3346, -3.2746, -3.2948, -3.3424, -3.3523,
      -3.3304, -3.3005, -3.3141, -3.326, -3.3552)
  ))

  # core
  banjarmasin_cover = gh_covering(banjarmasin)
  sp::proj4string(banjarmasin) = sp::CRS("+init=epsg:4326")
  # use gUnaryUnion to overcome rgeos bug as reported 2019-08-16
  expect_true(!any(is.na(sp::over(banjarmasin, banjarmasin_cover))))
  expect_equal(sort(rownames(banjarmasin_cover@data))[1:10],
               c("qx3kzj", "qx3kzm", "qx3kzn", "qx3kzp", "qx3kzq",
                 "qx3kzr", "qx3kzt", "qx3kzv", "qx3kzw", "qx3kzx"))
  expect_length(banjarmasin_cover, 112L)

  # arguments
  expect_length(gh_covering(banjarmasin, 5L), 9L)
  banjarmasin_tight = gh_covering(banjarmasin, minimal = TRUE)
  expect_equal(sort(rownames(banjarmasin_tight@data))[1:10],
               c("qx3kzm", "qx3kzx", "qx3mp3", "qx3mpb", "qx3mpu",
                 "qx3mpz", "qx3mr5", "qx3sbt", "qx3t06", "qx3t22"))
  expect_length(banjarmasin_tight, 10L)

  # errors
  expect_error(gh_covering(4L), 'Object to cover must be Spatial', fixed = TRUE)
})
