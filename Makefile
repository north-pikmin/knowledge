# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

install:
	@pip install -r requirements.txt

livehtml:
	sphinx-autobuild "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

setup:
	sudo apt-get install texlive-xetex texlive-latex-base texlive-extra-utils
	sudo apt-get install texlive-fonts-extra

setup_venv_with_pyenv:
	@echo == to have a 'doc' virtualenv to fit the commited .python-version file
	@echo 0. pyenv virtualenv doc
	@echo 1. restart a terminal
	@echo 2. check "doc" virtualenv is activated
	@echo 3. run "$$ pip install -r requirements.txt"

ldc_pdf:
	sed -i "s/root_doc = 'index'/root_doc = 'ldc_index'/" conf.py
	make latexpdf
	sed -i "s/root_doc = 'ldc_index'/root_doc = 'index'/" conf.py

ldc_html:
	sed -i "s/root_doc = 'index'/root_doc = 'ldc_index'/" conf.py
	make html
	sed -i "s/root_doc = 'ldc_index'/root_doc = 'index'/" conf.py

clean:
	@echo "Delete _build directory"
	rm -r "$(BUILDDIR)"



