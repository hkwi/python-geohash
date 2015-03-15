Encoding.
```
>>> import jpiarea
>>> jpiarea.encode(35.65486522, 156.42456722)
'53563332312'
```

Decoding. decode() returns a tuple of (latitude, longitude), which is a center coordinate of the grid code. decode\_sw returns south-west coordinates and grid size like geohash.decode\_exactly(). bbox() returns a bounding box information.
```
>>> jpiarea.decode('53563332312')
(35.66015625, 156.462890625)
>>> jpiarea.decode_sw('53563332312',delta=True)
(35.658854166666664, 156.4609375, 0.0026041666666666665, 0.00390625)
>>> jpiarea.bbox('53563332312')
{'s': 156.4609375, 'e': 35.661458333333329, 'w': 35.658854166666664, 'n': 156.46484375}
```

When you want to get neighbor codes of a specific code, use neighbors(). expand() includes the center code together with neighbors().
```
>>> jpiarea.neighbors('53563332312')
['53563332303', '53563332313', '53563332321', '53563332330', '53563332331', '53563332301', '53563332310', '53563332311']
>>> jpiarea.expand('53563332312')
['53563332303', '53563332313', '53563332321', '53563332330', '53563332331', '53563332301', '53563332310', '53563332311', '53563332312']
```