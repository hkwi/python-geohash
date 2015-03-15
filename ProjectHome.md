Geohash is a string representation of two dimensional geometric coordinates. This technique is well described at [Wikipedia Geohash](http://en.wikipedia.org/wiki/Geohash). It is basically, a form of [Z-order curve](http://en.wikipedia.org/wiki/Z-order_curve).

[Quadtree](http://en.wikipedia.org/wiki/Quadtree) can be used to construct a string representation. In this library, 0 for SW, 1 for SE, 2 for NW and 3 for NE.

Grid Square Code (JIS X 0410, search it in [JIS database](http://www.jisc.go.jp/app/JPS/JPSO0020.html)) is also a string representation of geometric coordinates. That grid code is utilized by [Japan's government](http://www.stat.go.jp/data/mesh/). NTT DoCoMo use [modified version](http://www.nttdocomo.co.jp/service/imode/make/content/iarea/domestic/index.html) of that grid code.

This project will maintain fast, accurate geohash, quadhash and grid code python library.

## Geohash API Quick Guide ##
Interface is almost compatible with Geohash (https://pypi.python.org/pypi/Geohash ).

Encoding.
```
>>> import geohash
>>> print 'Geohash for 42.6, -5.6:', geohash.encode(42.6, -5.6)
Geohash for 42.6, -5.6: ezs42e44yx96
```

Decoding. Returning values are float, which is incompatibile with Geohash.
```
>>> print 'Coordinate for Geohash ezs42:', geohash.decode('ezs42')
Coordinate for Geohash ezs42: (42.60498046875, -5.60302734375)
>>> print 'Exact coordinate for Geohash ezs42:\n', geohash.decode_exactly('ezs42')
Exact coordinate for Geohash ezs42:
(42.60498046875, -5.60302734375, 0.02197265625, 0.02197265625)
```


## Performance ##
Python-geohash is good for ecology. This library speeds up geohashing x3.5(decoding), x4.2(encoding) compared to [Geohash](http://pypi.python.org/pypi/Geohash/), and x1.5(decoding), x1.3(encoding) compared to [geohasher](http://pypi.python.org/pypi/geohasher/).
About x23 to [geodatastore](http://code.google.com/p/geodatastore/) in encoding, and geodatastore does not support decoding.

With C extension in this library, hashing will be extremely fast: x4.9 for encoding and x11.6 for decoding compared to pure-python mode.

![http://spreadsheets.google.com/oimg?key=0AgIdLTR1zWiEdHNCdnVSNmdHLVpkMnVZRzFjcWFTeGc&oid=3&v=1258158482160&ext=img.png](http://spreadsheets.google.com/oimg?key=0AgIdLTR1zWiEdHNCdnVSNmdHLVpkMnVZRzFjcWFTeGc&oid=3&v=1258158482160&ext=img.png)

## Installation ##
python-geohash works in pure python or with C extension. If you want to use this in pure python, just copy geohash.py to your script directory and it will work fine. If you want to enable C extension, build it in a normal way. You can also use the C geohasing routine in your C code, see src/geohash\_sample.c.

## License ##
Code is licensed under Apache License 2.0, MIT Licence and NEW BSD License.
You can choose one of those.
If you want to use the other license, please contact me.
