# geohash module #

## Basic geohash routines ##
geohash module provides geohash routines.
  * geohash.**encode**(_latitude, longitude`[`, precision`]`_)
> Create a geohash string from two floating numbers of latitude and longitude. `Precision` defaults to `12`, which is usually sufficient for most cases.
```
>>> geohash.encode(42.6, -5.6)
'ezs42e44yx96'
>>> geohash.encode(42.6, -5.6, precision=5)
'ezs42'
```

  * geohash.**decode**(_hashcode`[`, delta`]`_)
> Decodes a geohash string into two floating numbers of latitude and longitude. The value is the center coordinate of specified geohash area. `delta` is optional argument to get the width and height of the area. If you want to get the left-bottom coordinate, use **bbox()** instead.
```
>>> geohash.decode('ezs42')
(42.60498046875, -5.60302734375)
>>> geohash.decode('ezs42',True)
(42.60498046875, -5.60302734375, 0.02197265625, 0.02197265625)
>>> geohash.decode_exactly('ezs42')
(42.60498046875, -5.60302734375, 0.02197265625, 0.02197265625)
```

  * geohash.**decode\_exactly**(_hashcode_)
> Alias for **decode()** with delta is `True`.

  * geohash.**bbox**(_hashcode_)
> Bounding box for a geohash hashcode. This method returns a dictionary with keys of "s", "e", "w" and "n" which means South, East, West and North respectively.
```
>>> geohash.bbox('ezs42')
{'s': 42.5830078125, 'e': -5.5810546875, 'w': -5.625, 'n': 42.626953125}
```

  * geohash.**neighbors**(_hashcode_)
> This method returns a neighboring geohash codes around specified one. See also **expand()**.

  * geohash.**expand**(_hashcode_)
> When you want to get neighbor codes of a specific code, use neighbors(). expand() includes the center code together with neighbors(). This method is useful to get a key in use of database query.
```
>>> geohash.neighbors('ezs42')
['ezefr', 'ezs43', 'ezefx', 'ezs48', 'ezs49', 'ezefp', 'ezs40', 'ezs41']
>>> geohash.expand('ezs42')
['ezefr', 'ezs43', 'ezefx', 'ezs48', 'ezs49', 'ezefp', 'ezs40', 'ezs41', 'ezs42']
```

> ![http://python-geohash.googlecode.com/svn/wiki/neighbors.png](http://python-geohash.googlecode.com/svn/wiki/neighbors.png)



## Uint64 routines ##
For most of our use case, 64bit representation is sufficient and it can be calculated **very fast** in most computers. So please do consider using 64bit integer representation instead of geohash. geohash and 64bit representations can be converted from each other.

geohash module also provide a set of uint64 (64 bit unsigned integer) representation routines.

  * geohash.**encode\_uint64**(_latitude, longitude_)
> This function encodes geometric coordinates of two doubles into one unsinged 64 bit integer.
```
>>> geohash.encode_uint64(42.6, -5.6)
8066018626445464163
```

  * geohash.**decode\_uint64**(_ui64_)
> This function decode one 64 bit unsigned integer into two doubles.
```
>>> geohash.decode_uint64(8066018626445464163)
(42.59999998379499, -5.600000051781535)
```

  * geohash.**expand\_uint64**(_ui64`[`, precision`]`_)
> This function returns integer ranges that cover the expanded area of specified ui64, unsigned 64 bit integer. The ranges are list of two element tuples, which means lower boundary and higher boundary. If the element has None, then you don't have to check that boundary.

> `precision` is the number of bits, defaults to `50`. 50 bits is equivalent to 10 chars in geohash. Value must be in 0 to 64, because there we have 64 bits.

### Examples ###
With geohash, we usually need a string which length is 8 or 9, 10 chars. That means we need at most 50bits. 32bit is not sufficient but 64bit is OK. So the two can be converted each other, while you use a geohash of less than 13 chars.

```
>>> import geohash
>>> hex(geohash.encode_uint64(0.0, 0.0))
'0xc000000000000000'
>>> geohash.encode(0.0, 0.0)
's00000000000'
```

Suppose you have a database and a many coordinate samples in it. For example, you have following schema of sqlite3. Unfortunatelly, sqlite3 does not support unsigned 64 bit integer directly, so we would shift the integer to signed 64 bit integer.
```
CREATE TABLE samples (
 geoint INTEGER,
 geohash TEXT,
 desc TEXT
)
```

Geohash is a good representation because it makes easy to query a small area with a single data key. However, it use a string prefix match. And string prefix match could be calculated in integer range comparison with good control over the precision.

```
import sqlite3
import geohash

#### below is uint64 example ####
precision = 50
shift = 64-precision
lo = geohash.encode_uint64(0.0, 0.0) & (0xFFFFFFFFFFFFFFFF<<shift)
hi = lo + (1<<shift)
cur = sqlite3.connect("samples.db").cursor()
cur.execute("SELECT * FROM samples WHERE geoint>=? AND geoint<?", (lo-(1<<63), hi-(1<<63)))
cur.fetchall()

#### below is basic geohash example ####
hashcode = geohash.encode(0.0, 0.0, 10)
cur = sqlite3.connect("samples.db").cursor()
cur.execute("SELECT * FROM samples WHERE geohash LIKE ?", (hashcode+"%",))
cur.fetchall()
```

Following shows how to perform near-by search with geohash.
```
import sqlite3
import geohash

db = sqlite3.connect("samples.db")
cur = db.cursor()
scans = [x+"%" for x in geohash.expand(geohash.encode(0,0,4))]
conds = " OR ".join(("geohash LIKE ?",)*len(scans))
if conds:
	cur.execute("SELECT * FROM samples WHERE "+conds, scans)
else:
	cur.execute("SELECT * FROM samples")

cur.fetchall()
```

With uint64, you can get the ranges by expand\_uint64. The following code runs about 4 times faster than above geohash string code.
```
import sqlite3
import geohash
ui = geohash.encode_uint64(0,0)

conds = []
param = []
for hilo in geohash.expand_uint64(ui, 20):
  if hilo[0] and hilo[1]:
    conds.append("(geoint>=? AND geoint<?)")
    param.append(hilo[0]-(1<<63))
    param.append(hilo[1]-(1<<63))
  elif hilo[0]:
    conds.append("geoint>=?")
    param.append(hilo[0]-(1<<63))
  elif hilo[1]:
    conds.append("geoint<?")
    param.append(hilo[1]-(1<<63))

cur = sqlite3.connect("samples.db").cursor()
if conds:
  cur.execute("SELECT * FROM samples WHERE " + " OR ".join(conds), param)
else:
  cur.execute("SELECT * FROM samples")

cur.fetchall()
```