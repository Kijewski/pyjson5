#!/usr/bin/env python3

from Cython.Build import cythonize
from setuptools import Extension, setup

extra_compile_args = [
    "-std=c++11",
    "-O3",
    "-fPIC",
    "-g0",
    "-pipe",
    "-fomit-frame-pointer",
]

extensions = [
    Extension(
        "pyjson5.pyjson5",
        sources=["pyjson5.pyx"],
        include_dirs=["src"],
        extra_compile_args=extra_compile_args,
        extra_link_args=extra_compile_args,
        language="c++",
    ),
]

setup(
    ext_modules=cythonize(
        extensions,
        compiler_directives={"language_level": 3},
        annotate=True,
    ),
)
