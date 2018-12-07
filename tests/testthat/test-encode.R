context('Geohash encoder')

test_that('geohash encoder works', {
  y = 0.1234; x = 5.6789
  # test defaults on scalar input
  expect_equal(gh_encode(y, x), 's0h09n')
  expect_equal(gh_encode(-y, -x), '7zgzqc')

  # all level-1 centroids to be sure my manual logic for precision = 1 works
  expect_equal(gh_encode(c(-67.5, -67.5, -22.5, -22.5, -67.5, -67.5, -22.5,
                           -22.5, 22.5, 22.5, 67.5, 67.5, 22.5, 22.5, 67.5,
                           67.5, -67.5, -67.5, -22.5, -22.5, -67.5, -67.5,
                           -22.5, -22.5, 22.5, 22.5, 67.5, 67.5, 22.5, 22.5,
                           67.5, 67.5),
                         c(-157.5, -112.5, -157.5, -112.5, -67.5, -22.5,
                           -67.5, -22.5, -157.5, -112.5, -157.5, -112.5,
                           -67.5, -22.5, -67.5, -22.5, 22.5, 67.5, 22.5,
                           67.5, 112.5, 157.5, 112.5, 157.5, 22.5, 67.5,
                           22.5, 67.5, 112.5, 157.5, 112.5, 157.5),
                         precision = 1L),
               c("0", "1", "2", "3", "4", "3", "6", "7", "8", "9", "b", "c",
                 "d", "e", "f", "g", "h", "j", "k", "m", "n", "p", "q", "r",
                 "s", "t", "u", "v", "w", "x", "z", "z"))

  # geohash cells are _left closed, right open_: [x1, x2) x [y1, y2), see:
  #   http://geohash.org/s000
  expect_equal(gh_encode(0, 0, 1L), 's')

  # test precision argument
  expect_equal(gh_encode(y, x, 12L), 's0h09nrnzgqv')
  # maximum precision
  n = as.integer(ceiling(.4*(log2(180) - log2(.Machine$double.eps)) + c(0, .2)))
  n = -1L + if (length(unique(n)) == 1L || n[1L] %% 2L) n[1L] else n[2L]
  expect_equal(gh_encode(y, x, n),
               substring('s0h09nrnzgqv8je0f4jp6njn00', 1L, n))
  # truncation beyond there
  expect_warning(out <- gh_encode(y, x, 27L),
                 'Precision is limited', fixed = TRUE)
  expect_equal(out, substring('s0h09nrnzgqv8je0f4jp6njn00', 1L, n))

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
