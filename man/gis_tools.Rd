\name{gis_tools}
\alias{gh_to_sp}
\alias{gh_to_spdf}
\alias{gh_to_spdf.default}
\alias{gh_to_spdf.data.frame}
\alias{gh_to_sf}

\title{ Helpers for interfacing geohashes with sp/sf objects }
\description{
  These functions smooth the gateway between working with geohashes and geospatial information built for the major geospatial packages in R, \code{\link[sp]{sp}} and \code{\link[sf]{sf}}.
}
\usage{
gh_to_sp(geohashes)
gh_to_spdf(\dots)
gh_to_sf(\dots)

\method{gh_to_spdf}{default}(geohashes, \dots)

\method{gh_to_spdf}{data.frame}(gh_df, gh_col = 'gh', \dots)
}

\arguments{
  \item{geohashes}{ \code{character} vector of geohashes to be converted to polygons. }
  \item{\dots}{ Arguments for subsequent methods. }
  \item{gh_df}{ \code{data.frame} which 1) contains a column of geohashes to be converted to polygons and 2) will serve as the \code{data} slot of the resultant \code{\link[sp]{SpatialPolygonsDataFrame}} object. }
  \item{gh_col}{ \code{character} column name saying where the geohashes are stored in \code{gh_df}. }
}
\details{
  \code{gh_to_sp} relies on the \code{\link{gh_decode}} function. Note in particular that this function accepts any length of geohash (geohash-6, geohash-4, etc.) and is agnostic to potential overlap, though duplicates will be caught and excluded.

  \code{gh_to_spdf.data.frame} will use \code{match.ID = FALSE} in the call to \code{SpatialPolygonsDataFrame}. Please file an issue if you'd like this to be more flexible.

  \code{gh_to_sf} is just a wrapper of \code{\link[sf]{st_as_sf}} around \code{gh_to_spdf}; as such it requires both \code{sp} and \code{sf} packages to work.
}
\value{
  For \code{gh_to_sp}, a \code{\link[sp]{SpatialPolygons}} object.

  For \code{gh_to_spdf}, a \code{\link[sp]{SpatialPolygonsDataFrame}} object.

  For \code{gh_to_sf}, a \code{\link[sf]{sf}} object.
}

\examples{
  # get the neighborhood of this geohash in downtown Apia as an sp object
  downtown = '2jtc5x'
  apia_nbhd = unlist(gh_neighbors(downtown))
  apia_sp = gh_to_sp(apia_nbhd)

  apia_sf = gh_to_sf(apia_nbhd)
}
