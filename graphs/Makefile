TARGETS = fig1.svg fig2.svg

%.svg:	%.dot
	dot -Tsvg $< > $@

%.pdf:	%.dot
	dot -Tpdf $< > $@

all:	$(TARGETS)
