VARIANTS := $(basename $(notdir $(wildcard data/variants/*.yaml)))
LANGS    := en de
SOURCES  := cv.typ $(wildcard template/*.typ) $(wildcard data/*.yaml) $(wildcard data/variants/*.yaml)

PDFS := $(foreach v,$(VARIANTS),$(foreach l,$(LANGS),out/cv-$(v)-$(l).pdf))

.PHONY: all en de one watch clean

all: $(PDFS)

en: $(filter %-en.pdf,$(PDFS))
de: $(filter %-de.pdf,$(PDFS))

# make one VARIANT=short LANG_=de
VARIANT ?= default
LANG_   ?= en
one: out/cv-$(VARIANT)-$(LANG_).pdf

out/cv-%.pdf: $(SOURCES)
	@mkdir -p out
	typst compile --root . cv.typ $@ \
		--input variant=$(word 1,$(subst -, ,$*)) \
		--input lang=$(word 2,$(subst -, ,$*))

watch:
	@mkdir -p out
	typst watch --root . cv.typ out/cv-watch.pdf --input variant=$(VARIANT) --input lang=$(LANG_)

clean:
	rm -rf out
