\name{utils}
\alias{gh_delta}

\title{
  Geohash utilities
}
\description{
 Various common functions that arise when working often with geohashes
}
\usage{
gh_delta(precision)
}
\arguments{
  \item{precision}{ \code{integer} precision level desired. }
}
\note{
  \emph{Caveat coder}: not much is done in the way of consistency checking since this is a convenience function. So e.g. real-valued "precision"s will give results.
}
\value{
  Length-2 \code{numeric} vector; the first element is the \emph{latitude} (y-coordinate) half-width at the input \code{precision}, the second element is the \emph{longitude} (x-coordinate).
}
\references{
  \url{http://geohash.org/} ( Gustavo Niemeyer's original geohash service )\cr
  \url{https://github.com/hkwi/python-geohash} ( Hiroaki Kawai's original Python implementation )
}
\author{
  Michael Chirico
}

\examples{
  gh_delta(6)
}
