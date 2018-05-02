"0.3.6"

#if 0 /*

from os import environ
from setuptools import setup, Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    build_ext = None


name = 'pyjson5'

with open(__file__, 'rt') as f:
    version = eval(next(iter(f)))

extra_compile_args = [
    '-std=gnu++14', '-O2', '-fPIC', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

kw = dict(
    name=name,
    version=version,
    description='JSON5 serializer and parser written in Cython.',
    author='René Kijewski',
    author_email='kijewski@library.vetmed.fu-berlin.de',
    url='https://bib.vetmed.fu-berlin.de/',
    python_requires='>= 3.3',
    setup_requires=['cython == 0.*, >= 0.28'],
    ext_modules=[Extension(
        name,
        sources=[name + '.' + ('cpp' if build_ext is None else 'pyx')],
        language='c++',
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_compile_args,
    )],
    cmdclass={},
)

if build_ext is not None:
    kw['cmdclass']['build_ext'] = build_ext

setup(**kw)

#*/
#endif
