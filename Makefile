LANGS    := en de
DATA     := $(if $(wildcard data/cv.yaml),data/cv.yaml,data/cv.example.yaml)
# variant names = keys under the top-level `variants:` block
VARIANTS := $(shell awk '/^variants:/{f=1;next} /^[^ \#]/{f=0} f && /^  [A-Za-z0-9_]+:/{sub(/^  /,"");sub(/:.*/,"");print}' $(DATA))
SOURCES  := cv.typ $(wildcard template/themes/*.typ) $(wildcard template/*.typ) $(wildcard data/*.yaml)

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
		--input data=$(DATA) \
		--input variant=$(word 1,$(subst -, ,$*)) \
		--input lang=$(word 2,$(subst -, ,$*))

watch:
	@mkdir -p out
	typst watch --root . cv.typ out/cv-watch.pdf --input data=$(DATA) --input variant=$(VARIANT) --input lang=$(LANG_)

clean:
	rm -rf out
