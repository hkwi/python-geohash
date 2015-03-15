Japan's government utilize [grid square mesh code](http://www.stat.go.jp/data/mesh/) for census and other purposes. The specificateion is documented as JIS C 6304, and revised to JIS X 0410. NTT DoCoMo use modified version of that grid code for [Open i-Area in Japan](http://www.nttdocomo.co.jp/service/imode/make/content/iarea/domestic/index.html).a

The code is intended to use in Japan, and the expression supports only between latitude between 0--66 degree and longitude between 100--180 degree.

Base grid size is about 1km. Below shows various grid sizes.
![http://spreadsheets.google.com/pub?key=ty87iDFT6tDA4EVTbGo42AQ&oid=2&output=image&ext=img.png](http://spreadsheets.google.com/pub?key=ty87iDFT6tDA4EVTbGo42AQ&oid=2&output=image&ext=img.png)

You can scan a database with grid code PREFIX to find a record that belongs to that grid. For example you want to find a record that is in '535633', you scan for the grid code that starts with '535633'. '53563332312' has the same prefix, and it is in the grid of course.

Grid code encoding, decoding examples are shown below.
  * JpgridExample
  * JpiareaExample