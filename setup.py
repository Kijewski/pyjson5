#!/usr/bin/env python

from setuptools import setup, Extension
from os.path import dirname, join, abspath


def get_version():
    root = abspath(dirname(__file__))
    with open(join(root, 'src', 'VERSION'), 'rt') as f:
        return eval(f.read().strip())


extra_compile_args = [
    '-std=gnu++14', '-O2', '-fPIC', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

name = 'pyjson5'

setup(
    name=name,
    version=get_version(),
    description='JSON5 serializer and parser for Python 3 written in Cython.',
    author='René Kijewski',
    author_email='kijewski@library.vetmed.fu-berlin.de',
    maintainer='René Kijewski',
    maintainer_email='kijewski@library.vetmed.fu-berlin.de',
    url='https://bib.vetmed.fu-berlin.de/',
    python_requires='~= 3.4',
    zip_safe=False,
    ext_modules=[Extension(
        name,
        sources=[name + '.cpp'],
        include_dirs=['src'],
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_compile_args,
        language='c++',
    )],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: OS Independent',
        'Programming Language :: Cython',
        'Programming Language :: JavaScript',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: Implementation :: CPython',
        'Topic :: Text Processing :: General',
    ],
)
