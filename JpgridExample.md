Encoding.
```
>>> import jpgrid
>>> jpgrid.encode(35.65486522, 156.42456722)
'53563383622'
```

Shortcut encoding methods.
```
>>> # 第１次地域区画
... jpgrid.encodeLv1(35.65486522, 156.42456722)
'5356'
>>> # 第２次地域区画
... jpgrid.encodeLv2(35.65486522, 156.42456722)
'535633'
>>> # 第３次地域区画
... jpgrid.encodeLv3(35.65486522, 156.42456722)
'53563383'
>>> # 基準地域メッシュ
... jpgrid.encodeBase(35.65486522, 156.42456722)
'53563383'
>>> # ２分の１地域メッシュ
... jpgrid.encodeHalf(35.65486522, 156.42456722)
'535633834'
>>> # ４分の１地域メッシュ
... jpgrid.encodeQuarter(35.65486522, 156.42456722)
'5356338342'
>>> # ８分の１地域メッシュ
... jpgrid.encodeEighth(35.65486522, 156.42456722)
'53563383422'
>>> # ２倍地域メッシュ（統合地域メッシュ）
... jpgrid.encodeUni2(35.65486522, 156.42456722)
'535633825'
>>> # ５倍地域メッシュ（統合地域メッシュ）
... jpgrid.encodeUni5(35.65486522, 156.42456722)
'5356333'
>>> # 10倍地域メッシュ（統合地域メッシュ）
... jpgrid.encodeUni10(35.65486522, 156.42456722)
'535633'
```

Decoding. decode() returns a tuple of (latitude, longitude), which is a center coordinate of the grid code. decode\_sw returns south-west coordinates and grid size like geohash.decode\_exactly(). bbox() returns a bounding box information.
```
>>> jpgrid.decode('53563383622')
(35.658854166666664, 156.42421874999999)
>>> jpgrid.decode_sw('53563383622', True)
(35.658333333333331, 156.42343750000001, 0.0010416666666666667, 0.0015625000000000001)
>>> jpgrid.bbox('53563383622')
{'s': 156.42343750000001, 'e': 35.659374999999997, 'w': 35.658333333333331, 'n': 156.42500000000001}
```

When you want to get neighbor codes of a specific code, use neighbors(). expand() includes the center code together with neighbors().
```
>>> jpgrid.neighbors('53394525')
['53394524', '53394526', '53394534', '53394535', '53394536', '53394514', '53394515', '53394516']
>>> jpgrid.expand('53394525')
['53394524', '53394526', '53394534', '53394535', '53394536', '53394514', '53394515', '53394516', '53394525']
```