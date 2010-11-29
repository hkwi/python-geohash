import unittest
import geohash

class TestEncode(unittest.TestCase):
	def test_empty(self):
		self.assertEqual([], geohash.neighbors(""))
	
	def test_one(self):
		self.assertEqual(set(['1', '2', '3', 'p', 'r']), set(geohash.neighbors("0")))
		self.assertEqual(set(['w', 'x', 'y', '8', 'b']), set(geohash.neighbors("z")))
		self.assertEqual(set(['2', '6', '1', '0', '4', '9', '8', 'd']), set(geohash.neighbors("3")))

# if __name__=='__main__':
# 	unittest.main()
