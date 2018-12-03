context('Geohash encoder')

test_that('geohash encoder works', {
  y = 0.1234; x = 5.6789
  # test defaults on scalar input
  expect_equal(gh_encode(y, x), 's0h09n')

  # geohash cells are _left closed, right open_: [x1, x2) x [y1, y2), see:
  #   http://geohash.org/s000
  expect_equal(gh_encode(0, 0, 1L), 's')

  # test precision argument
  expect_equal(gh_encode(y, x, 12L), 's0h09nrnzgqv')
  # maximum precision
  # TODO: figure out what's going on. works fine in Python.
  #expect_equal(gh_encode(y, x, 26L), 's0h09nrnzgqv8je0f4jp6njn')
  # truncation beyond there
  # TODO: figure out what's going on. works fine in Python.
  #expect_warning(out <- gh_encode(y, x, 27L),
  #               'Precision is limited', fixed = TRUE)
  expect_equal(out, 's0h09nrnzgqv8je0f4jp6njn')

  # implicit integer truncation
  expect_equal(gh_encode(y, x, 1.04), 's')

  # invalid precision
  expect_error(gh_encode(y, x, 0), 'Precision is measured', fixed = TRUE)

  # invalid input
  expect_error(gh_encode(90, x), 'Invalid latitude at index 1', fixed = TRUE)
  expect_error(gh_encode(-91, x), 'Invalid latitude at index 1', fixed = TRUE)
  expect_error(gh_encode(c(y, 90), c(x, x)),
               'Invalid latitude at index 2', fixed = TRUE)
  expect_error(gh_encode(y, x, c(5, 6)),
               'More than one precision value', fixed = TRUE)
  expect_error(gh_encode(c(y, y), x),
               'Inputs must be the same size', fixed = TRUE)

  # semi-valid auto-corrected input -- 180 --> -180 by wrapping
  expect_equal(gh_encode(y, 180), '80008n')
  expect_equal(gh_encode(y, 29347590823475982734), 'sb18en')

  # missing input
  expect_equal(gh_encode(c(y, NA), c(x, NA)), c('s0h09n', NA_character_))
})
