#!/usr/bin/env python

from distutils.core import setup
from distutils.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    from pip import pip

    pip.main(['install', 'cython'])

    from Cython.Distutils import build_ext


extra_compile_args = [
    '-std=gnu++14',
    '-O2', '-flto', '-fPIC',
    '-march=native', '-mtune=native', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

setup(
    name='json5',
    version='0.1.0',
    description='JSON5 ...',
    author='René Kijewski',
    author_email='kijewski@library.vetmed.fu-berlin.de',
    url='https://bib.vetmed.fu-berlin.de/',
    ext_modules=[
        Extension(
            'json5',
            sources=['json5.pyx'],
            extra_compile_args=extra_compile_args,
            extra_link_args=extra_compile_args,
            language='c++',
        ),
    ],
    cmdclass={
        'build_ext': build_ext,
    },
)
