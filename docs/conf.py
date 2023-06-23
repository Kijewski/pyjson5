import os
import sys


sys.path.insert(0, os.path.abspath('..'))

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.autosectionlabel',
    'sphinx.ext.autosummary',
    'sphinx.ext.napoleon',
    'sphinx.ext.intersphinx',
    'sphinx.ext.inheritance_diagram',
    'sphinx_autodoc_typehints',
    'sphinx.ext.autosectionlabel',
    'myst_parser',
]

language = "en"

templates_path = ['_templates']
source_suffix = '.rst'
master_doc = 'index'

project = 'PyJSON5'
copyright = '2018-2023, René Kijewski'
author = 'René Kijewski'

with open('../src/VERSION.inc', 'rt') as f:
    version = eval(f.read().strip())
    release = version

language = None
exclude_patterns = []
pygments_style = 'sphinx'
todo_include_todos = False

html_theme = 'furo'
htmlhelp_basename = 'PyJSON5doc'

display_toc = True
autodoc_default_flags = ['members']
autosummary_generate = True

intersphinx_mapping = {
    'python': ('https://docs.python.org/3.11', None),
}

inheritance_graph_attrs = {
    'size': '"6.0, 8.0"',
    'fontsize': 32,
    'bgcolor': 'transparent',
}
inheritance_node_attrs = {
    'color': 'black',
    'fillcolor': 'white',
    'style': '"filled,solid"',
}
inheritance_edge_attrs = {
    'penwidth': 1.2,
    'arrowsize': 0.8,
}
