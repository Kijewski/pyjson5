import os
import sys


sys.path.insert(0, os.path.abspath('..'))

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.autosectionlabel',
    'sphinx.ext.autosummary',
    'sphinx.ext.graphviz',
    'sphinx.ext.napoleon',
    'sphinx.ext.intersphinx',
    'sphinx.ext.inheritance_diagram',
    'sphinx_autodoc_typehints',
    'sphinx.ext.autosectionlabel',
    'myst_parser',
]

templates_path = ['_templates']
source_suffix = '.rst'
master_doc = 'index'

project = 'PyJSON5'
copyright = '2018-2025, René Kijewski'
author = 'René Kijewski'

with open('../src/VERSION.inc', 'rt') as f:
    version = eval(f.read().strip())
    release = version

language = 'en'
exclude_patterns = []
pygments_style = 'sphinx'
todo_include_todos = False

html_theme = 'furo'
htmlhelp_basename = 'PyJSON5doc'

display_toc = True
autodoc_default_flags = ['members']
autosummary_generate = True

intersphinx_mapping = {
    'python': ('https://docs.python.org/3.13', None),
}

graphviz_output_format = 'svg'

inheritance_graph_attrs = {
    'size': '"8.0, 10.0"',
    'fontsize': 32,
    'bgcolor': 'lightgrey',
}
inheritance_node_attrs = {
    'color': 'black',
    'fillcolor': 'white',
    'style': '"filled,solid"',
}
inheritance_edge_attrs = {
    'penwidth': 1.5,
    'arrowsize': 1.2,
}
