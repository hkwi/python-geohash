Encoding.
```
>>> import quadtree
>>> quadtree.encode(35.65486522, 156.42456722)
'313211312033'
```

Decoding. decode() returns a tuple of (latitude, longitude), which is a center coordinate of the grid code. decode\_sw returns south-west coordinates and grid size like geohash.decode\_exactly(). bbox() returns a bounding box information.
```
>>> quadtree.decode('313211312033')
(35.66162109375, 156.4013671875)
>>> quadtree.decode('313211312033',delta=True)
(35.66162109375, 156.4013671875, 0.02197265625, 0.0439453125)
>>> quadtree.bbox('313211312033')
{'s': 35.6396484375, 'e': 156.4453125, 'w': 156.357421875, 'n': 35.68359375}
```

When you want to get neighbor codes of a specific code, use neighbors(). expand() includes the center code together with neighbors().
```
>>> quadtree.neighbors('313211312033')
['313211312032', '313211312122', '313211312210', '313211312211', '313211312300', '313211312030', '313211312031', '313211312120']
>>> quadtree.expand('313211312033')
['313211312032', '313211312122', '313211312210', '313211312211', '313211312300', '313211312030', '313211312031', '313211312120', '313211312033']
```