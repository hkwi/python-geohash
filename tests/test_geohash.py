import unittest
import math
import warnings
import geohash

class TestEncode(unittest.TestCase):
	def test_cycle(self):
		for code in ["000000000000","zzzzzzzzzzzz","bgr96qxvpd46",]:
			self.assertEqual(code, geohash.encode(*geohash.decode(code)))

	def test_north_pole_boundary_warns_and_uses_adjacent_cell(self):
		latitude = math.nextafter(90.0, -math.inf)
		expected = geohash.encode(latitude, 0.0)
		with warnings.catch_warnings(record=True) as captured:
			warnings.simplefilter("always")
			self.assertEqual(expected, geohash.encode(90.0, 0.0))
		self.assertEqual(1, len(captured))
		self.assertIn("nextafter(90.0, -inf)", str(captured[0].message))

	def test_north_pole_boundary_preserves_longitude_cell(self):
		latitude = math.nextafter(90.0, -math.inf)
		with warnings.catch_warnings():
			warnings.simplefilter("ignore")
			self.assertEqual(geohash.encode(latitude, 0.0), geohash.encode(90.0, 0.0))
			self.assertEqual(geohash.encode(latitude, 135.0), geohash.encode(90.0, 135.0))
			self.assertNotEqual(geohash.encode(90.0, 0.0), geohash.encode(90.0, 135.0))

class TestDecode(unittest.TestCase):
	def test_empty(self):
		self.assertEqual(
			geohash.bbox(''),
			{'s':-90.0, 'n':90.0, 'w':-180.0, 'e':180.0})
	
	def test_one(self):
		seq = '0123456789bcdefghjkmnpqrstuvwxyz'
		sws = [
			(-90.0, -180.0),
			(-90.0, -135.0),
			(-45.0, -180.0),
			(-45.0, -135.0),
			(-90.0, -90.0),
			(-90.0, -45.0),
			(-45.0, -90.0),
			(-45.0, -45.0),
			(0.0, -180.0),
			(0.0, -135.0),
			(45.0, -180.0),
			(45.0, -135.0),
			(0.0, -90.0),
			(0.0, -45.0),
			(45.0, -90.0),
			(45.0, -45.0),
			(-90.0, 0.0),
			(-90.0, 45.0),
			(-45.0, 0.0),
			(-45.0, 45.0),
			(-90.0, 90.0),
			(-90.0, 135.0),
			(-45.0, 90.0),
			(-45.0, 135.0),
			(0.0, 0.0),
			(0.0, 45.0),
			(45.0, 0.0),
			(45.0, 45.0),
			(0.0, 90.0),
			(0.0, 135.0),
			(45.0, 90.0),
			(45.0, 135.0)
			]
		for i in zip(seq, sws):
			x = geohash.bbox(i[0])
			self.assertEqual((x['s'], x['w']), i[1])
			self.assertEqual(x['n']-x['s'], 45)
			self.assertEqual(x['e']-x['w'], 45)
	
	def test_ezs42(self):
		x=geohash.bbox('ezs42')
		self.assertEqual(round(x['s'],3), 42.583)
		self.assertEqual(round(x['n'],3), 42.627)
	
	def test_issue12(self):
		ll=geohash.decode(geohash.encode(51.566141,-0.009434,24))
		self.assertAlmostEqual(ll[0], 51.566141)
		self.assertAlmostEqual(ll[1], -0.009434)

class TestNeighbors(unittest.TestCase):
	def test_empty(self):
		self.assertEqual([], geohash.neighbors(""))
	
	def test_one(self):
		self.assertEqual(set(['1', '2', '3', 'p', 'r']), set(geohash.neighbors("0")))
		self.assertEqual(set(['w', 'x', 'y', '8', 'b']), set(geohash.neighbors("z")))
		self.assertEqual(set(['2', '6', '1', '0', '4', '9', '8', 'd']), set(geohash.neighbors("3")))

class TestUpperCase(unittest.TestCase):
	# The _geohash extension accepts upper-case base32 letters, so the
	# pure-Python fallback (used whenever the extension is not built, e.g. the
	# README's "copy geohash.py" path and every non-x86_64-Linux install) must
	# decode the same codes to the same result.
	codes = ['ezs42', 'u4pruydqqvj', 'dr5regw3pg', 'sunny', 'bgr96qxvpd46']

	def test_decode_upper_equals_lower(self):
		for code in self.codes:
			self.assertEqual(geohash.decode(code.upper()), geohash.decode(code))

	def test_decode_exactly_upper_equals_lower(self):
		for code in self.codes:
			self.assertEqual(geohash.decode_exactly(code.upper()), geohash.decode_exactly(code))

	def test_bbox_upper_equals_lower(self):
		for code in self.codes:
			self.assertEqual(geohash.bbox(code.upper()), geohash.bbox(code))

	def test_neighbors_upper_equals_lower(self):
		for code in self.codes:
			self.assertEqual(set(geohash.neighbors(code.upper())), set(geohash.neighbors(code)))

	def test_expand_upper_equals_lower(self):
		for code in self.codes:
			expanded = geohash.expand(code.upper())
			self.assertIn(code.upper(), expanded)
			self.assertEqual(set(expanded) - {code.upper()}, set(geohash.neighbors(code)))

	def test_mixed_case(self):
		self.assertEqual(geohash.decode('Ezs42'), geohash.decode('ezs42'))
		self.assertEqual(geohash.decode('eZS42'), geohash.decode('ezs42'))

	def test_every_base32_letter_uppercases(self):
		for c in '0123456789bcdefghjkmnpqrstuvwxyz':
			code = 'e' + c + 's'
			self.assertEqual(geohash.decode(code.upper()), geohash.decode(code))

class TestInvalidCode(unittest.TestCase):
	# Letters a, i, l, o (and their upper-case forms) are not in the geohash
	# base32 alphabet; the extension raises ValueError for them, so the
	# fallback must too rather than leaking a bare KeyError.
	invalid = ['abc', 'io', 'ezs42a', 'ezs42L', 'EZS42O', 'ezs 42', 'ezs42!', 'A', 'I', 'l', 'o']

	def test_invalid_char_raises_value_error(self):
		for code in self.invalid:
			for fn in (geohash.decode, geohash.decode_exactly, geohash.bbox,
			           geohash.neighbors, geohash.expand):
				with self.assertRaises(ValueError):
					fn(code)


if __name__=='__main__':
	unittest.main()
