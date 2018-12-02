context('Geohash encoder')

test_that('geohash encoder works', {
  # test defaults on scalar input
  expect_equal(gh_encode(0.1234, 5.6789), 's0h09n')

  # test precision argument
  expect_equal(gh_encode(0.1234, 5.6789, 12L), 's0h09nrnzgqv')
  # maximum precision
  expect_equal(gh_encode(0.1234, 5.6789, 28L), 's0h09nrnzgqv8je0f4jp6njn00')
  # truncation beyond there
  expect_warning(out <- gh_encode(0.1234, 5.6789, 29L),
                 'Precision is limited', fixed = TRUE)
  expect_equal(out, 's0h09nrnzgqv8je0f4jp6njn00')

  # geohash cells are _left closed, right open_: [x1, x2) x [y1, y2), see:
  #   http://geohash.org/s000
  expect_equal(gh_encode(0, 0, 1L), 's')
})
