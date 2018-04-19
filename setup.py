#!/usr/bin/env python

from os import environ
from Cython.Distutils import Extension, build_ext
from distutils.core import setup
from os.path import dirname, join, abspath


extra_compile_args = [
    '-std=gnu++14', '-O2', '-fPIC', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

root = abspath(dirname(__file__))


def get_version():
    with open(join(root, 'src', 'VERSION'), 'rt') as f:
        return eval(f.read().strip())


setup(
    name='pyjson5',
    version='0.3.1',
    description='JSON5 serializer and parser written in Cython.',
    author='René Kijewski',
    author_email='kijewski@library.vetmed.fu-berlin.de',
    url='https://bib.vetmed.fu-berlin.de/',
    python_requires='>= 3.3',
    ext_modules=[
        Extension(
            'pyjson5',
            sources=['pyjson5.pyx'],
            extra_compile_args=extra_compile_args,
            extra_link_args=extra_compile_args,
            language='c++',
        ),
    ],
    cmdclass={
        'build_ext': build_ext,
    },
)
