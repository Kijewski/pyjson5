all: sdist bdist_wheel docs

.DELETE_ON_ERROR:

.PHONY: all sdist bdist_wheel clean docs

FILES := Makefile MANIFEST.in pyjson5.pyx README.rst setup.py \
         src/native.hpp src/VERSION src/_unicode_cat_of.hpp

DerivedGeneralCategory.txt:
	wget -O $@ https://www.unicode.org/Public/12.1.0/ucd/extracted/DerivedGeneralCategory.txt
	sha512sum -c $@.sha

src/_unicode_cat_of.hpp: DerivedGeneralCategory.txt make_unicode_categories.py
	python make_unicode_categories.py $< $@

pyjson5.cpp: pyjson5.pyx $(wildcard src/*.pyx)
	python -m cython -o $@ $<

sdist: pyjson5.cpp ${FILES}
	rm -f -- dist/pyjson5-*.tar.gz
	python setup.py sdist

bdist_wheel: pyjson5.cpp ${FILES} | sdist
	rm -f -- dist/pyjson5-*.whl
	python setup.py bdist_wheel

docs: bdist_wheel $(wildcard docs/* docs/*/*)
	pip install --force dist/pyjson5-*.whl
	python -m sphinx -M html docs/ dist/

clean:
	[ ! -d build/ ] || rm -r -- build/
	[ ! -d dist/ ] || rm -r -- dist/
	[ ! -d pyjson5.egg-info/ ] || rm -r -- pyjson5.egg-info/
	rm -f -- pyjson5.*.so python5.cpp
