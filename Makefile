# Makefile for euenc

NAME = euenc
DOC = $(NAME).pdf
DTX = $(NAME).dtx

# Files grouped by generation mode
COMPILED = $(DOC)
FDFILES = eu1lmdh.fd eu1lmr.fd eu1lmss.fd eu1lmssq.fd eu1lmtt.fd eu1lmvtt.fd\
eu2lmdh.fd eu2lmr.fd eu2lmss.fd eu2lmssq.fd eu2lmtt.fd eu2lmvtt.fd
UNPACKED = sed-eu1lmr.sed sed-eu2lmr.sed test-euxlm.ltx convert-lmfd.sh
GENERATED = $(COMPILED) $(UNPACKED) $(FDFILES)
SOURCE = $(DTX) README Makefile

# Files grouped by installation location
RUNFILES = $(UNPACKED) $(FDFILES)
DOCFILES = $(DOC) README
SRCFILES = $(DTX) Makefile

# The following definitions should be equivalent
# ALL_FILES = $(RUNFILES) $(DOCFILES) $(SRCFILES)
ALL_FILES = $(GENERATED) $(SOURCE)

# Installation locations
FORMAT = latex
RUNDIR = $(TEXMFROOT)/tex/$(FORMAT)/$(NAME)
DOCDIR = $(TEXMFROOT)/doc/$(FORMAT)/$(NAME)
SRCDIR = $(TEXMFROOT)/source/$(FORMAT)/$(NAME)
TEXMFROOT = ./texmf

CTAN_ZIP = $(NAME).zip
TDS_ZIP = $(NAME).tds.zip
ZIPS = $(CTAN_ZIP) $(TDS_ZIP)

DO_PDFLATEX = pdflatex --interaction=batchmode $< >/dev/null
DO_MAKEINDEX = makeindex -s gind.ist $(subst .dtx,,$<) >/dev/null 2>&1
DO_SED = sh convert-lmfd.sh

all: $(GENERATED)
doc: $(COMPILED)
unpack: $(UNPACKED)
ctan: $(CTAN_ZIP)
tds: $(TDS_ZIP)
world: all ctan

$(FDFILES): $(UNPACKED)
	$(DO_SED)

$(COMPILED): $(DTX)
	$(DO_PDFLATEX)
	$(DO_MAKEINDEX)
	$(DO_PDFLATEX)
	$(DO_PDFLATEX)

$(UNPACKED): $(COMPILED)

$(CTAN_ZIP): $(SOURCE) $(COMPILED) $(TDS_ZIP)
	@echo "Making $@ for CTAN upload."
	@$(RM) -- $@
	@zip -9 $@ $^ >/dev/null

define run-install
@mkdir -p $(RUNDIR) && cp $(RUNFILES) $(RUNDIR)
@mkdir -p $(DOCDIR) && cp $(DOCFILES) $(DOCDIR)
@mkdir -p $(SRCDIR) && cp $(SRCFILES) $(SRCDIR)
endef

$(TDS_ZIP): TEXMFROOT=./tmp-texmf
$(TDS_ZIP): $(ALL_FILES)
	@echo "Making TDS-ready archive $@."
	@$(RM) -- $@
	$(run-install)
	@cd $(TEXMFROOT) && zip -9 ../$@ -r . >/dev/null
	@$(RM) -r -- $(TEXMFROOT)

.PHONY: install manifest clean mrproper

install: $(ALL_FILES)
	@echo "Installing in '$(TEXMFROOT)'."
	$(run-install)

manifest: 
	@echo "Source files:"
	@for f in $(SOURCE); do echo $$f; done
	@echo ""
	@echo "Derived files:"
	@for f in $(GENERATED); do echo $$f; done

clean: 
	@$(RM) -- *.log *.aux *.toc *.idx *.ind *.ilg

mrproper: clean
	@$(RM) -- $(GENERATED) $(ZIPS)
