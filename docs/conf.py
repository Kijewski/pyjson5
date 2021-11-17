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

templates_path = ['_templates']
source_suffix = '.rst'
master_doc = 'index'

project = u'PyJSON5'
copyright = u'2018-2021, René Kijewski'
author = u'René Kijewski'

with open('../src/VERSION.inc', 'rt') as f:
    version = eval(f.read().strip())
    release = version

language = None
exclude_patterns = []
pygments_style = 'sphinx'
todo_include_todos = False

html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    'navigation_depth': -1,
}
html_sidebars = {
    '**': [
        'localtoc.html',
        'searchbox.html',
    ]
}
htmlhelp_basename = 'PyJSON5doc'

latex_elements = {}
latex_documents = [
    (master_doc, 'PyJSON5.tex', u'PyJSON5 Documentation',
     u'René Kijewski', 'manual'),
]

man_pages = [
    (master_doc, 'pyjson5', u'PyJSON5 Documentation',
     [author], 1)
]

texinfo_documents = [
    (master_doc, 'PyJSON5', u'PyJSON5 Documentation',
     author, 'PyJSON5', 'One line description of project.',
     'Miscellaneous'),
]

display_toc = True
autodoc_default_flags = ['members']
autosummary_generate = True

intersphinx_mapping = {
    'python': ('https://docs.python.org/3.10', None),
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
