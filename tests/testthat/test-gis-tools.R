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
  expect_equal(ghSP@proj4string,
               CRS("+init=epsg:4326"))

  # simulate missing sp
  requireNamespace = function(...) FALSE
  expect_error(gh_to_sp(mauritius),
               'requires an installation of sp', fixed = TRUE)
  rm(requireNamespace)

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
  expect_equal(ghSPDF@proj4string,
               CRS("+init=epsg:4326"))
  expect_equal(ghSPDF@data, data.frame(ID = 1:9, row.names = urumqi))

  # simulate missing sp
  requireNamespace = function(...) FALSE
  expect_error(gh_to_spdf(urumqi),
               'requires an installation of sp', fixed = TRUE)
  rm(requireNamespace)
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
  expect_equal(ghSPDF@proj4string,
               CRS("+init=epsg:4326"))
  expect_equal(ghSPDF@data, DF)

  # different gh_col
  names(DF) = c('geohash', 'V')
  ghSPDF = gh_to_spdf(DF, gh_col = 'geohash')
  expect_is(ghSPDF, 'SpatialPolygonsDataFrame')
  expect_length(ghSPDF, 9L)

  # missing gh_col
  expect_error(gh_to_spdf(DF), 'Searched for geohashes', fixed = TRUE)
})



