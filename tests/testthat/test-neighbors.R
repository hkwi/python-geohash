context('Geohash neighborhood')

test_that('geohash adjacency list works', {
  my_turtle_beach = 'w0zpp8'
  ty_turtle_beach = 'sws374'
  xunantunich = 'd5095x0'

  expect_equal(gh_neighbors(my_turtle_beach),
               list(southwest = "w0znzr", south = "w0znzx",
                    southeast = "w0znzz", east = "w0zppb",
                    northeast = "w0zppc", north = "w0zpp9",
                    northwest = "w0zpp3", west = "w0zpp2"))
  # commonwealthers *shakes fist*
  expect_equal(gh_neighbours(my_turtle_beach),
               list(southwest = "w0znzr", south = "w0znzx",
                    southeast = "w0znzz", east = "w0zppb",
                    northeast = "w0zppc", north = "w0zpp9",
                    northwest = "w0zpp3", west = "w0zpp2"))

  # input precision doesn't matter; vectors work
  expect_equal(gh_neighbors(c(my_turtle_beach, ty_turtle_beach, xunantunich)),
               list(southwest = c("w0znzr", "sws36c", "d5095qz"),
                    south = c("w0znzx", "sws371", "d5095wb"),
                    southeast = c("w0znzz", "sws373", "d5095wc"),
                    east = c("w0zppb", "sws376", "d5095x1"),
                    northeast = c("w0zppc", "sws377", "d5095x3"),
                    north = c("w0zpp9", "sws375", "d5095x2"),
                    northwest = c("w0zpp3", "sws36g", "d5095rr"),
                    west = c("w0zpp2", "sws36f", "d5095rp")))

  # global boundary geohashes
  expect_equal(gh_neighbors(c('5', 'u', 'pv', 'zry')),
               list(southwest = c(NA, "e", "ps", "zrt"),
                    south = c(NA, "s", "pu", "zrw"),
                    southeast = c(NA, "t", "0h", "zrx"),
                    east = c("h", "v", "0j", "zrz"),
                    northeast = c("k", NA, "0n", NA),
                    north = c("7", NA, "py", NA),
                    northwest = c("6", NA, "pw", NA),
                    west = c("4", "g", "pt", "zrv")))
})
