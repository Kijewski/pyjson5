all: sdist bdist_wheel docs

.DELETE_ON_ERROR:

.PHONY: all sdist bdist_wheel clean docs

export PYTHONUTF8 := 1
export PYTHONIOENCODING := UTF-8

INCLUDES := \
    src/VERSION src/DESCRIPTION \
    src/_decoder_recursive_select.hpp src/_unicode_cat_of.hpp \
    src/_escape_dct.hpp src/_stack_heap_string.hpp src/native.hpp

FILES := Makefile MANIFEST.in pyjson5.pyx README.rst setup.py ${INCLUDES}

DerivedGeneralCategory.txt: DerivedGeneralCategory.txt.sha
	curl -s -o $@ https://www.unicode.org/Public/13.0.0/ucd/extracted/DerivedGeneralCategory.txt
	python sha512sum.py -c $@.sha

src/_unicode_cat_of.hpp: DerivedGeneralCategory.txt make_unicode_categories.py
	python make_unicode_categories.py $< $@

src/_decoder_recursive_select.py.hpp: make_decoder_recursive_select.py
	python $< $@

src/_escape_dct.hpp: make_escape_dct.py
	python $< $@

pyjson5.cpp: pyjson5.pyx $(wildcard src/*.pyx) $(wildcard src/*.hpp)
	python -m cython -f -o $@ $<

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
