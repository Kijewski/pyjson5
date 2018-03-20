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
    '-Os', '-flto', '-fPIC',
    '-march=native', '-mtune=native', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

setup(
    name='my_json_encoder',
    version='0.4.2',
    description='JSON ...',
    author='René Kijewski',
    author_email='kijewski@library.vetmed.fu-berlin.de',
    url='https://bib.vetmed.fu-berlin.de/',
    ext_modules=[
        Extension(
            'my_json_encoder',
            sources=['my_json_encoder.pyx'],
            extra_compile_args=extra_compile_args,
            extra_link_args=extra_compile_args,
            language='c++',
        ),
    ],
    cmdclass={
        'build_ext': build_ext,
    },
)
