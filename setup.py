#!/usr/bin/env python

from setuptools import setup, Extension
from os.path import dirname, join, abspath


def get_text(name):
    root = abspath(dirname(__file__))
    with open(join(root, 'src', name), 'rt') as f:
        return eval(f.read().strip())


extra_compile_args = [
    '-std=c++11', '-O3', '-fPIC', '-ggdb1', '-pipe',
    '-fomit-frame-pointer', '-fstack-protector-strong',
]

name = 'pyjson5'

setup(
    name=name,
    version=get_text('VERSION.inc'),
    long_description=get_text('DESCRIPTION.inc'),
    description='JSON5 serializer and parser for Python 3 written in Cython.',
    author='René Kijewski',
    author_email='pypi.org@k6i.de',
    maintainer='René Kijewski',
    maintainer_email='pypi.org@k6i.de',
    url='https://github.com/Kijewski/pyjson5',
    python_requires='~= 3.5',
    zip_safe=False,
    ext_modules=[Extension(
        name + '.' + name,
        sources=[name + '.pyx'],
        include_dirs=['src'],
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_compile_args,
        language='c++',
    )],
    platforms=['any'],
    license='Apache 2.0',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: OS Independent',
        'Programming Language :: Cython',
        'Programming Language :: JavaScript',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: Implementation :: CPython',
        'Topic :: Text Processing :: General',
    ],
    packages=[name],
    package_dir={
        '': 'src',
    },
    package_data = {
        name: [
            '__init__.pyi',
            'py.typed',
        ],
    },
)
