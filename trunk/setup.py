from distutils.core import setup, Extension

c1=Extension('_geohash',
	define_macros = [('PYTHON_MODULE',1),],
	sources=['geohash.c'])

setup(name='geohash',
	version='0.3',
	py_modules=['geohash','quadtree','jpgrid','jpiarea'],
	ext_modules = [c1]
)
