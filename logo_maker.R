library(sp)
library(rgeos)
library(data.table)
library(viridis)

diamond1 = cbind(c(0, 40*sqrt(3), 40*sqrt(3), 0, 0),
                 c(0, 40, -40, -80, 0))
diamond2 = cbind(c(0, -40*sqrt(3), -40*sqrt(3), 0, 0),
                 c(0, 40, -40, -80, 0))
diamond3 = cbind(c(0, 40*sqrt(3), 0, -40*sqrt(3), 0),
                 c(80, 40, 0, 40, 80))

hexSP = SpatialPolygons(list(Polygons(list(Polygon(diamond1)), ID = 1L),
                             Polygons(list(Polygon(diamond2)), ID = 2L),
                             Polygons(list(Polygon(diamond3)), ID = 3L)))

base32 = c(0:9, setdiff(letters, c('a', 'i', 'l', 'o')))
gh2 = do.call(paste0, expand.grid(base32, base32))
grd = gh_decode(gh2, include_delta = TRUE)
grdSP = with(grd, SpatialPolygons(lapply(seq_along(latitude), function(ii) {
  y = latitude[ii] + c(-1, -1, 1, 1, -1) * delta_latitude[1L]
  x = longitude[ii] + c(-1, 1, 1, -1, -1) * delta_longitude[2L]
  Polygons(list(Polygon(cbind(x, y))), ID = ii)
})))

grdSP = grdSP[gIntersects(grdSP, gUnaryUnion(hexSP), byid = TRUE), ]

grd_diamond = gIntersection(grdSP, hexSP, byid = TRUE, drop_lower_td = TRUE)

intDT =
  setDT(tstrsplit(sapply(grd_diamond@polygons, slot, 'ID'), ' ', fixed = TRUE))
intDT[ , area := sapply(grd_diamond@polygons, slot, 'area')]
areaDT = intDT[ , keyby = .(ID = V1),
                .(diamond = as.integer(V2[which.max(area)]))]
setDF(areaDT, rownames = areaDT$ID)
grdSPDF = SpatialPolygonsDataFrame(grdSP, areaDT)

# kilt-y option
plot(grd_diamond, col = viridis(length(grd_diamond)), border = NA)
plot(hexSP, lwd = 5L, add = TRUE)

# lego option
quartzFonts(
  avenir = c("Avenir Next Condensed Medium", "Avenir Black",
             "Avenir Book Oblique", "Avenir Black Oblique")
)
plot(grdSPDF, col = viridis(3L)[grdSPDF$diamond], border = NA)
text(0, 40, labels = 'geohashTools', col = 'red',
     family = 'avenir', font = 4L, cex =3)
