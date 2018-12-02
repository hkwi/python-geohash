\name{gh_encode}
\alias{gh_encode}

\title{
  Geohash encoding
}
\description{
  Convert latitude/longitude coordinates into geohash-encoded strings
}
\usage{
gh_encode(latitude, longitude, precision = 6L)
}
\arguments{
  \item{latitude}{ \code{numeric} vector of input latitude (y) coordinates. }
  \item{longitude}{ \code{numeric} vector of input longitude (x) coordinates. }
  \item{precision}{ Positive \code{integer} scalar controlling the 'zoom level' -- how many characters should be used in the output. }
}
\details{
  \code{precision} is limited to at most 28. This level of precision encodes locations on the globe at a nanometer scale and is already more than enough for basically all applications.
}
\value{
  \code{character} vector of geohashes corresponding to the input.
}
\references{
  \url{http://geohash.org/} ( Gustavo Niemeyer's original geohash service )\cr
  \url{https://github.com/hkwi/python-geohash} ( Hiroaki Kawai's original Python implementation )
}
\author{
  Michael Chirico
}

\examples{
# scalar input is treated as a vector
gh_encode(2.345, 6.789)

# geohashes are left-closed, right-open, so boundary coordinates are
#   associated to the east and/or north
gh_encode(0, 0)
}
