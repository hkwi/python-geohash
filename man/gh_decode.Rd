\name{gh_decode}
\alias{gh_decode}

\title{
  Geohash decoding
}
\description{
  Convert geohash-encoded strings into latitude/longitude coordinates
}
\usage{
gh_decode(geohashes, include_delta = FALSE, coord_loc = 'c')
}
\arguments{
  \item{geohashes}{ \code{character} vector of input geohashes. There's no need for all inputs to be of the same precision. }
  \item{include_delta}{ \code{logical}; should the cell half-width delta be included in the output? }
  \item{coord_loc}{ \code{character} specifying where in the cell points should be mapped to; cell centroid is mapped by default; case-insensitive. See Details. }
}
\details{
  \code{coord_loc} can be the cell's center (\code{'c'} or \code{'centroid'}), or it can be any of the 8 corners (e.g. \code{'s'}/\code{'south'} for the midpoint of the southern boundary of the cell, or \code{'ne'}/\code{'northeast'} for the upper-right corner.
}
\value{
  \code{list} with the following entries:

  \item{latitude}{ \code{numeric} vector of latitudes (y-coordinates) corresponding to the input \code{geohashes}, with within-cell position dictated by \code{coord_loc} }
  \item{longitude}{ \code{numeric} vector of longitudes (x-coordinates) corresponding to the input \code{geohashes}, with within-cell position dictated by \code{coord_loc} }
  \item{delta_latitude}{ \code{numeric} vector of cell half-widths in the y direction (only included if \code{include_delta} is \code{TRUE} }
  \item{delta_longitude}{ \code{numeric} vector of cell half-widths in the x direction (only included if \code{include_delta} is \code{TRUE} }
}
\references{
  \url{http://geohash.org/} ( Gustavo Niemeyer's original geohash service )\cr
  \url{https://github.com/hkwi/python-geohash} ( Hiroaki Kawai's original Python implementation )
}
\author{
  Michael Chirico
}

\examples{
# Riddle me this
gh_decode('stq4s8c')

# Cell half-widths might be convenient to include for downstream analysis
gh_decode('tjmd79', include_delta = TRUE)
}
