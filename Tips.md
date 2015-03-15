# Precision #
Most computers calculate floating point numbers in 'float' or 'double' as defined in [IEEE\_754](http://en.wikipedia.org/wiki/IEEE_754-2008). If your system use double, maximum geohash length is 22. Longer geohash might be rounded when calculating in 'double'. With 'float', use 10 chars. Python use 'double' for the representation of float(), so you may set precision at most 22 chars.

```
>>> geohash.encode(35, 135, precision=22)
'xn0p0581b0bh2n0p0581b0'
>>> geohash.encode(35, 135, precision=50)
'xn0p0581b0bh2n0p0581b00000000000000000000000000000'
```

This is off-topic but worth noting, when you display a floating number in decimal, use 17 digits for double representation. See also http://docs.python.org/tutorial/floatingpoint.html for detail.
```
>>> num=1.0/3.0
>>> print repr(num)
0.33333333333333331
>>> print "%.16e" % (num,)
3.3333333333333331e-001
```

You can use geohash code as a short data representation of geometric coordinates.
```
>>> import json
>>> import geohash
>>> json.dumps({'lat':35.466188,'lon':139.622715})
'{"lat": 35.466188000000002, "lon": 139.622715}'
>>> json.dumps({'code':geohash.encode(35.466188,139.622715)})
'{"code": "xn73c0qjt0dh"}'
```

Longer code can be represent more precise location. The following chart shows the precision in meter. Choose the length what you want in querying nearby locations. Please note, the length you represent a location is one, and the length in query is another. You don't have to store short geohash to point the location because you use that short geohash for querying. Store long geohash, and you can query with short prefix.
![http://python-geohash.googlecode.com/svn/wiki/precision.png](http://python-geohash.googlecode.com/svn/wiki/precision.png)


# Nearby Location #
Suppose you have a geohash, and want to find nearby information. All you have to do is query a database with 9 neighboring geohashes. geohash.expand() is useful for this.

![http://python-geohash.googlecode.com/svn/wiki/nearby.png](http://python-geohash.googlecode.com/svn/wiki/nearby.png)

You can use this technique in jpgrid and jpiarea, too. jpgrid.expand() and jpiarea.expand() will return neighboring codes.

# Coding #
There're four codes of geohash, quadtree, jpgrid and jpiarea in this library. I'd like to describe the difference to help you choose the best one for your purpose.

If you already have a grid data which is based on one of those, use the same one. If you're going to handle the data of Japan's goverment census, use jpgrid. Use jpiare for NTT DoCoMo's iArea.

Because of the coding algorithms, the code length and grid size are in inverse proportion.
Geohash has large steps, and can encode small grid size in short code length. On the other hand, quadtree has small steps, and consume long code length to point the same grid, but this means you can control more flexibly over the grid size. If you felt the geohash steps are too large, you might want to migrate to quadtree.

![http://python-geohash.googlecode.com/svn/wiki/coding.png](http://python-geohash.googlecode.com/svn/wiki/coding.png)

One more difference is the shape of the grid. When the latitudes is around 0 degree, the grid is always square in quadtree, but if latitude is around 60 degree, it is always not a square but a rectangle. With geohash of which the length is odd, the shape is square when latitude is around 60 degree.

There're many other coding systems. If you'd like to ask for support, please put it in the  Issue tracker.
  * [georef](http://en.wikipedia.org/wiki/Georef)
  * [maidenhead](http://en.wikipedia.org/wiki/Maidenhead_Locator_System)
  * [QDGC](http://en.wikipedia.org/wiki/QDGC)
  * and more in [Wikipedia](http://en.wikipedia.org/wiki/Geocoding)

# Spatial Index #
You might hear of [R-TREE](http://en.wikipedia.org/wiki/R-tree) or PR-TREE as a spatial index. Geohash prefix match is almost the same algorithm of tree search. The difference is data balancing. So you don't have to worry about that you don't use R-TREE.

# Google App Engine #
## String Prefix Match ##
When you have a geohash, you want to perform a query with string prefix match.

The simplest way is described at http://code.google.com/appengine/docs/python/datastore/queriesandindexes.html#Introducing_Indexes . In case you use geohash, you can query like this:
```
querycode = 'ezs42'
db.GqlQuery("SELECT * FROM MyModel WHERE geohashcode >= :1 AND geohashcode < :2", querycode, querycode+"{")
```

This works fine because '{' (ascii code 123) is larger than 'z' (ascii code 122).

Another approach is StringListProperty. In this case, you must extract all prefix hashcode when you store the geohash. When you query, you can use any length prefix.
```
m = MyModel()
m.geohashcodes = ['e', 'ez', 'ezs', 'ezs4', 'ezs42']
m.put()
db.GqlQuery("SELECT * FROM MyModel WHERE geohashcodes = :1", "ezs4")
```

This approach allows you to query nearby locations like this.
```
db.GqlQuery("SELECT * FROM MyModel WHERE geohashcodes IN :1", geohash.expand("ezs4"))
```

If you want to find entities in a specific grid, the latter seems to be slightly lighter in CPU consumption although storage amount gets bigger (based on the results when I tested on GAE with 10,000 entities in 2009-09-11).

## Nearby Locations ##
Querying entities in nearby grids, you can do like this in storing time.
```
m = MyModel()
m.geohashcode = 'ezs42'
m.nearby = []
for o in range(len(1,m.geohashcode)):
  for c in geohash.expand(m.geohashcode[0:o]):
    m.nearby.append(c)
m.put()
```

You simply query nearby entities like this because querying against StringListProperty works as an [inverted index](http://en.wikipedia.org/wiki/Inverted_index). Choose the size of distance by the length of code, shorter geocode covers large area. You never have to perform inequality.
```
db.GqlQuery("SELECT * FROM MyModel WHERE nearby = :1", 'ezs4')
db.GqlQuery("SELECT * FROM MyModel WHERE nearby = :1", 'ezef')
```

Another approach is described in http://code.google.com/appengine/articles/geosearch.html .