\name{gh_neighbors}
\alias{gh_neighbors}
\alias{gh_neighbours}

\title{
  Geohash neighborhoods
}
\description{
  Return the geohashes adjacent to input geohashes
}
\usage{
gh_neighbors(geohashes, self = TRUE)
gh_neighbours(geohashes, self = TRUE)
}
\arguments{
  \item{geohashes}{ \code{character} vector of input geohashes. There's no need for all inputs to be of the same precision. }
  \item{self}{ Should the input also be returned as a list element? Convenient for one-line usage / piping }
}
\details{
  North/south-pole adjacent geohashes are missing three of their neighbors; these will be returned as \code{NA_character_}.
}
\value{
  \code{list} with \code{character} vector entries in the direction relative to the input geohashes indicated by their name (e.g. \code{value$south} gives all of the \emph{southern} neighbors of the input \code{geohashes}).

  The order is \code{self} (if \code{self = TRUE}), \code{southwest}, \code{south}, \code{southeast}, \code{east}, \code{northeast}, \code{north}, \code{northwest}, \code{west} (somewhat arbitrarily).
}
\references{
  \url{http://geohash.org/} ( Gustavo Niemeyer's original geohash service )\cr
  \url{https://github.com/hkwi/python-geohash} ( Hiroaki Kawai's original Python implementation )
}
\author{
  Michael Chirico
}

\examples{
gh_neighbors('d7q8u4')
}
