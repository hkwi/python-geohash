context('Geohash utilities')

test_that('gh_delta works', {
  expect_equal(gh_delta(0), c(90, 180))

  expect_equal(gh_delta(8), c(8.58306884765625e-05, 0.000171661376953125))

  # one at a time, for now...
  expect_error(gh_delta(1:5), "One precision at a time", fixed = TRUE)
})
