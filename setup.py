from distutils.core import setup, Extension

c1=Extension('_geohash',
	sources=['src/geohash.c'],
	define_macros = [('PYTHON_MODULE',1),])

setup(name='geohash',
	version='0.3',
	py_modules=['geohash','quadtree','jpgrid','jpiarea'],
	ext_modules = [c1]
)
