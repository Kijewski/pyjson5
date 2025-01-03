#!/usr/bin/env python3

from setuptools import setup, Extension

extra_compile_args = [
    "-std=c++11",
    "-O3",
    "-fPIC",
    "-g0",
    "-pipe",
    "-fomit-frame-pointer",
]

setup(
    ext_modules=[
        Extension(
            "pyjson5.pyjson5",
            sources=["pyjson5.pyx"],
            include_dirs=["src"],
            extra_compile_args=extra_compile_args,
            extra_link_args=extra_compile_args,
            language="c++",
        )
    ],
)
