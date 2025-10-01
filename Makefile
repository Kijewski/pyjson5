all: sdist wheel docs

.DELETE_ON_ERROR:

.PHONY: all sdist wheel clean docs prepare test install

export PYTHONUTF8 := 1
export PYTHONIOENCODING := UTF-8

INCLUDES := \
    src/VERSION.inc src/DESCRIPTION.inc \
    src/_decoder_recursive_select.hpp src/_unicode_cat_of.hpp \
    src/_escape_dct.hpp src/_stack_heap_string.hpp src/native.hpp \
    src/dragonbox.cc

FILES := Makefile MANIFEST.in pyjson5.pyx README.rst pyproject.toml ${INCLUDES}

DerivedGeneralCategory.txt: DerivedGeneralCategory.txt.sha
	curl -s -o $@ https://www.unicode.org/Public/17.0.0/ucd/extracted/DerivedGeneralCategory.txt
	python scripts/sha512sum.py -c $@.sha

src/_unicode_cat_of.hpp: DerivedGeneralCategory.txt scripts/make_unicode_categories.py
	python scripts/make_unicode_categories.py $< $@

src/_decoder_recursive_select.py.hpp: scripts/make_decoder_recursive_select.py
	python $< $@

src/_escape_dct.hpp: scripts/make_escape_dct.py
	python $< $@

pyjson5.cpp: pyjson5.pyx $(wildcard src/*.pyx) $(wildcard src/*.hpp)
	python -m cython --line-directives --cplus --force --output-file $@ $<

prepare: pyjson5.cpp ${FILES}

sdist: prepare
	-rm -- dist/pyjson5-*.tar.gz
	python -m build --sdist

wheel: prepare
	-rm -- dist/pyjson5-*.whl
	python -m build --wheel

install: wheel
	pip install --force dist/pyjson5-*.whl

docs: install $(wildcard docs/* docs/*/*)
	python -m sphinx -M html docs/ dist/

clean:
	[ ! -d build/ ] || rm -r -- build/
	[ ! -d dist/ ] || rm -r -- dist/
	[ ! -d pyjson5.egg-info/ ] || rm -r -- pyjson5.egg-info/
	-rm -- pyjson5.*.so python5.cpp

test: wheel
	pip install --force dist/pyjson5-*.whl
	python scripts/run-minefield-test.py
	python scripts/run-tests.py
