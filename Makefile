targets = dist/tunebook.abc \
dist/tunebook2.abc \
dist/tunebook.pdf \
dist/tunebook2.pdf \
dist/tunebook-bflat.pdf \
dist/tunebook2-bflat.pdf \
dist/tunebook-eflat.pdf \
dist/tunebook2-eflat.pdf \
dist/tunebook-bassclef.pdf \
dist/tunebook2-bassclef.pdf \
dist/tunebook-guitar-dwhistle.pdf \
dist/tunebook2-guitar-dwhistle.pdf \
dist/tunebook-mandolin.pdf \
dist/tunebook2-mandolin.pdf \
dist/tunebook-dulcimer-chords-dad.pdf \
dist/tunebook-dulcimer-tabs-dxd.pdf \
dist/tunebook-dulcimer-tabs-a.pdf \
dist/tunebook-ukulele.pdf \
dist/tunebook2-ukulele.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet2.pdf \
dist/cheatsheet-dwhistle.pdf \
dist/cheatsheet2-dwhistle.pdf \
dist/cheatsheet-mandolin.pdf \
dist/cheatsheet2-mandolin.pdf \
dist/cheatsheet-dulcimer-d.pdf \
dist/cheatsheet-dulcimer-a.pdf

abc_source := $(wildcard abc/[0-9]*.abc)
abc2_source := $(wildcard abc2/[0-9]*.abc)

common_depends = inc/frontmatter.abc bin/sorter.py fmt/tunebook.fmt
common_depends2 = inc/frontmatter2.abc bin/sorter.py fmt/tunebook2.fmt
common_args = - -i -D fmt -F tunebook.fmt -O -
common_args2 = - -i -D fmt -F tunebook2.fmt -O -

.PHONY: default
default: $(targets)

# EasyABC writes files with <cr><lf> line endings - this target
# fixes them
.PHONY: fixup
fixup:
	dos2unix $(abc_source)

# Create a concatenation for distribution
dist/tunebook.abc: $(abc_source) inc/tunebook.abc inc/frontmatter.abc bin/sorter.py
	mkdir -p dist
	(echo '%abc-2.1'; \
     cat inc/tunebook.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "% Version $$(git describe --tags --always)"; echo; \
     bin/sorter.py --ref; \
	) > $@

dist/tunebook2.abc: $(abc2_source) bin/sorter.py
	mkdir -p dist
	(echo '%abc-2.1'; \
	 echo "% Version $$(git describe --tags --always)"; echo; \
     bin/sorter.py --ref abc2; \
	) > $@

# All the tunes as a printable score matching the published Tunebook
dist/tunebook.pdf : $(abc_source) inc/frontmatter.abc bin/sorter.py fmt/tunebook.fmt inc/tunebook.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/tunebook.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | abcm2ps $(common_args) | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC' -Author='Tunebook ABC' $@

dist/tunebook2.pdf : $(abc2_source) inc/frontmatter2.abc bin/sorter.py fmt/tunebook2.fmt inc/tunebook2.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/tunebook2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate abc2; \
	) | abcm2ps $(common_args2) | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed. Tunebook ABC' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in Bb
dist/tunebook-bflat.pdf : $(abc_source) $(common_depends) inc/bflat.abc fmt/bflat.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/bflat.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | bin/strip_chords.py | abcm2ps $(common_args) -F bflat.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in Bb' -Author='Tunebook ABC' $@

dist/tunebook2-bflat.pdf : $(abc2_source) $(common_depends2) inc/bflat2.abc fmt/bflat.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/bflat2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate abc2; \
	) | bin/strip_chords.py | abcm2ps $(common_args2) -F bflat.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC in Bb' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in Eb
dist/tunebook-eflat.pdf : $(abc_source) $(common_depends) inc/eflat.abc fmt/eflat.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/eflat.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | bin/strip_chords.py | abcm2ps $(common_args) -F eflat.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in Eb' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in Eb
dist/tunebook2-eflat.pdf : $(abc2_source) $(common_depends2) inc/eflat2.abc fmt/eflat.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/eflat2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate abc2; \
	) | bin/strip_chords.py | abcm2ps $(common_args2) -F eflat.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC in Eb' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in the bass clef
dist/tunebook-bassclef.pdf : $(abc_source) $(common_depends) inc/bassclef.abc fmt/bassclef.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/bassclef.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | bin/strip_chords.py | abcm2ps $(common_args) -F bassclef.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in the bass clef' -Author='Tunebook ABC' $@

dist/tunebook2-bassclef.pdf : $(abc2_source) $(common_depends2) inc/bassclef2.abc fmt/bassclef.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/bassclef2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate abc2; \
	) | bin/strip_chords.py | abcm2ps $(common_args2) -F bassclef.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC in the bass clef' -Author='Tunebook ABC' $@

## Tablatures and chords

# All the tunes as a printable score, one tune per page with guitar
# chord diagrams and D whistle tabs
dist/tunebook-guitar-dwhistle.pdf : $(abc_source) $(common_depends) inc/guitar-dwhistle.abc bin/add_chords.py fmt/guitar-dwhistle.fmt fmt/flute.fmt fmt/guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/guitar-dwhistle.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps $(common_args) -1 -T1 -F guitar-dwhistle.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - Guitar and D Whistle' -Author='Tunebook ABC' $@

dist/tunebook2-guitar-dwhistle.pdf : $(abc2_source) $(common_depends2) inc/guitar-dwhistle2.abc bin/add_chords.py fmt/guitar-dwhistle.fmt fmt/flute.fmt fmt/guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/guitar-dwhistle2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref abc2; \
	) | bin/add_chords.py | abcm2ps $(common_args2) -1 -T1 -F guitar-dwhistle.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - Guitar and D Whistle' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with mandolin tabs
dist/tunebook-mandolin.pdf : $(abc_source) $(common_depends) inc/mandolin.abc fmt/mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/mandolin.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | abcm2ps $(common_args) -1 -T7 -F mandolin.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - Mandolin' -Author='Tunebook ABC' $@

dist/tunebook2-mandolin.pdf : $(abc2_source) $(common_depends2) inc/mandolin2.abc fmt/mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/mandolin2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref abc2; \
	) | abcm2ps $(common_args2) -1 -T7 -F mandolin.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - Mandolin' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with dulcimer
# chord diagrams for a DAD-tuned instrument
dist/tunebook-dulcimer-chords-dad.pdf : $(abc_source) $(common_depends) inc/dulcimer-chords-dad.abc bin/add_chords.py fmt/dulcimer-chords-dad.fmt fmt/dulcimerchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-chords-dad.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps $(common_args) -1 -F dulcimer-chords-dad.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - DAD Dulcimer Chords' -Author='Tunebook ABC' $@

dist/tunebook2-dulcimer-chords-dad.pdf : $(abc2_source) $(common_depends2) inc/dulcimer-chords-dad2.abc bin/add_chords.py fmt/dulcimer-chords-dad.fmt fmt/dulcimerchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-chords-dad2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref abc2; \
	) | bin/add_chords.py | abcm2ps $(common_args2) -1 -F dulcimer-chords-dad.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - DAD Dulcimer Chords' -Author='Tunebook ABC' $@

# Dulcimer melody TABs for tunes in 'D' (with D-A-D tuning) and 'G' (with DGD tuning)
dist/tunebook-dulcimer-tabs-dxd.pdf : $(abc_source) $(common_depends) inc/dulcimer-tabs-dxd.abc inc/dulcimer-tabs-dxd-1.abc inc/dulcimer-tabs-dxd-2.abc fmt/dulcimer-tabs-dad.fmt fmt/dulcimer-tabs-dgd.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-tabs-dxd.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 cat inc/dulcimer-tabs-dxd-1.abc; echo; echo; \
	 echo '%%format dulcimer-tabs-dad.fmt'; \
	 bin/sorter.py --ref --key-filter=D --key-filter=Bm --key-filter=AMix --key-filter=EDor; \
	 echo '%%newpage'; \
	 cat inc/dulcimer-tabs-dxd-2.abc; echo; echo; \
	 echo '%%format dulcimer-tabs-dgd.fmt'; \
	 bin/sorter.py --ref --key-filter=G --key-filter=Em --key-filter=DMix --key-filter=ADor; \
	) | abcm2ps $(common_args) -1 -T8 | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - DAD/DGD Dulcimer' -Author='Tunebook ABC' $@

dist/tunebook2-dulcimer-tabs-dxd.pdf : $(abc2_source) $(common_depends2) inc/dulcimer-tabs-dxd2.abc inc/dulcimer-tabs-dxd-1.abc inc/dulcimer-tabs-dxd-2.abc fmt/dulcimer-tabs-dad.fmt fmt/dulcimer-tabs-dgd.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-tabs-dxd2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 cat inc/dulcimer-tabs-dxd-1.abc; echo; echo; \
	 echo '%%format dulcimer-tabs-dad.fmt'; \
	 bin/sorter.py --ref --key-filter=D --key-filter=Bm --key-filter=AMix --key-filter=EDor abc2; \
	 echo '%%newpage'; \
	 cat inc/dulcimer-tabs-dxd-2.abc; echo; echo; \
	 echo '%%format dulcimer-tabs-dgd.fmt'; \
	 bin/sorter.py --ref --key-filter=G --key-filter=Em --key-filter=DMix --key-filter=ADor abc2; \
	) | abcm2ps $(common_args2) -1 -T8 | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - DAD/DGD Dulcimer' -Author='Tunebook ABC' $@


# Dulcimer melody TABs for a 'A' melody string
dist/tunebook-dulcimer-tabs-a.pdf : $(abc_source) $(common_depends) inc/dulcimer-tabs-a.abc fmt/dulcimer-tabs-a.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-tabs-a.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | abcm2ps $(common_args) -1 -T8 -F dulcimer-tabs-a.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - Dulcimer melody D' -Author='Tunebook ABC' $@

dist/tunebook2-dulcimer-tabs-a.pdf : $(abc2_source) $(common_depends2) inc/dulcimer-tabs-a2.abc fmt/dulcimer-tabs-a.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-tabs-a2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref abc2; \
	) | abcm2ps $(common_args2) -1 -T8 -F dulcimer-tabs-a.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - Dulcimer melody D' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with ukulele chords
dist/tunebook-ukulele.pdf : $(abc_source) $(common_depends) inc/ukulele.abc bin/add_chords.py fmt/ukulele.fmt fmt/ukulelechords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/ukulele.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps $(common_args) -1 -F ukulele.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - Ukulele' -Author='Tunebook ABC' $@

dist/tunebook2-ukulele.pdf : $(abc2_source) $(common_depends2) inc/ukulele2.abc bin/add_chords.py fmt/ukulele.fmt fmt/ukulelechords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/ukulele2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref abc2; \
	) | bin/add_chords.py | abcm2ps $(common_args2) -1 -F ukulele.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - Ukulele' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with 'C' accordian fingering
dist/tunebook-accordion.pdf : $(abc_source) $(common_depends) inc/accordion1.abc fmt/d-to-c.fmt fmt/g-to-c.fmt fmt/accordion1.fmt fmt/accordion1buttons.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/accordion1.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 echo '%%format d-to-c.fmt'; \
	 bin/sorter.py --ref --key-filter=D --key-filter=Bm --key-filter=AMix --key-filter=EDor; \
	 echo '%%newpage'; \
	 echo '%%format g-to-c.fmt'; \
	 bin/sorter.py --ref --key-filter=G --key-filter=Em --key-filter=DMix --key-filter=ADor; \
	) | abcm2ps $(common_args) -1 -T6 -F accordion1.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - C Accordion' -Author='Tunebook ABC' $@

dist/tunebook2-accordion.pdf : $(abc2_source) $(common_depends2) inc/accordion12.abc fmt/d-to-c.fmt fmt/g-to-c.fmt fmt/accordion1.fmt fmt/accordion1buttons.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/accordion12.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 echo '%%format d-to-c.fmt'; \
	 bin/sorter.py --ref --key-filter=D --key-filter=Bm --key-filter=AMix --key-filter=EDor abc2; \
	 echo '%%newpage'; \
	 echo '%%format g-to-c.fmt'; \
	 bin/sorter.py --ref --key-filter=G --key-filter=Em --key-filter=DMix --key-filter=ADor abc2; \
	) | abcm2ps $(common_args2) -1 -T6 -F accordion1.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='2nd ed Tunebook ABC - C Accordion' -Author='Tunebook ABC' $@

## Cheatsheets

# The first few bars of all the tunes
dist/cheatsheet.pdf : $(abc_source) $(common_depends) inc/cheatsheet.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) | bin/make_cheatsheet.py | abcm2ps $(common_args) -F  cheatsheet.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' -Author='Tunebook ABC' $@

dist/cheatsheet2.pdf : $(abc2_source) $(common_depends2) inc/cheatsheet2.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet2.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title abc2; \
	) | bin/make_cheatsheet.py | abcm2ps $(common_args2) -F  cheatsheet.fmt | ps2pdf - $@
	exiftool -Title='2nd ed Tunebook ABC - Cheatsheet' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-dwhistle.pdf : $(abc_source) $(common_depends) inc/cheatsheet-dwhistle.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dwhistle.fmt fmt/flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-dwhistle.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args) -T1 -F cheatsheet.fmt -F cheatsheet-dwhistle.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet D Whistle' -Author='Tunebook ABC' $@

dist/cheatsheet2-dwhistle.pdf : $(abc2_source) $(common_depends2) inc/cheatsheet2-dwhistle.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dwhistle.fmt fmt/flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet2-dwhistle.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title abc2; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args2) -T1 -F cheatsheet.fmt -F cheatsheet-dwhistle.fmt | ps2pdf - $@
	exiftool -Title='2nd ed Tunebook ABC - Cheatsheet D Whistle' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with mandolin fingering
dist/cheatsheet-mandolin.pdf : $(abc_source) $(common_depends) inc/cheatsheet-mandolin.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-mandolin.fmt fmt/mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-mandolin.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args) -T7 -F cheatsheet.fmt -F cheatsheet-mandolin.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Mandolin' -Author='Tunebook ABC' $@

dist/cheatsheet2-mandolin.pdf : $(abc2_source) $(common_depends2) inc/cheatsheet2-mandolin.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-mandolin.fmt fmt/mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet2-mandolin.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title abc2; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args2) -T7 -F cheatsheet.fmt -F cheatsheet-mandolin.fmt | ps2pdf - $@
	exiftool -Title='2nd ed Tunebook ABC - Cheatsheet Mandolin' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with dulcimer fingering for an
# instrument with a 'D' melody string
dist/cheatsheet-dulcimer-d.pdf : $(abc_source) $(common_depends) inc/cheatsheet-dulcimer-d.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dulcimer-d.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-dulcimer-d.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args) -T8 -F cheatsheet.fmt -F cheatsheet-dulcimer-d.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet DAD Dulcimer' -Author='Tunebook ABC' $@

dist/cheatsheet2-dulcimer-d.pdf : $(abc2_source) $(common_depends2) inc/cheatsheet2-dulcimer-d.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dulcimer-d.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet2-dulcimer-d.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title abc2; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args2) -T8 -F cheatsheet.fmt -F cheatsheet-dulcimer-d.fmt | ps2pdf - $@
	exiftool -Title='2nd ed Tunebook ABC - Cheatsheet DAD Dulcimer' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with dulcimer fingering for an
# instrument with a 'A' melody string
dist/cheatsheet-dulcimer-a.pdf : $(abc_source) $(common_depends) inc/cheatsheet-dulcimer-a.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dulcimer-a.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-dulcimer-a.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args) -T8 -F cheatsheet.fmt -F cheatsheet-dulcimer-a.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet DAD Dulcimer' -Author='Tunebook ABC' $@

dist/cheatsheet2-dulcimer-a.pdf : $(abc2_source) $(common_depends2) inc/cheatsheet2-dulcimer-a.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dulcimer-a.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet2-dulcimer-a.abc; echo; echo; \
	 cat inc/frontmatter2.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title abc2; \
	) |  bin/make_cheatsheet.py | abcm2ps $(common_args2) -T8 -F cheatsheet.fmt -F cheatsheet-dulcimer-a.fmt | ps2pdf - $@
	exiftool -Title='2nd ed Tunebook ABC - Cheatsheet DAD Dulcimer' -Author='Tunebook ABC' $@

# Assorted files

abc_targets := $(patsubst abc/%,dist/abc/%,$(abc_source))
abc: $(abc_targets)
$(abc_targets) : dist/abc/%.abc : abc/%.abc
	mkdir -p dist/abc
	( 	\
		echo '%abc-2.1'; \
		cat "$<"; \
	) > $@

dist/tunebook-abc.zip: $(abc_targets)
	( cd dist/abc; zip ../tunebook-abc.zip *.abc )

abc2_targets := $(patsubst abc2/%,dist/abc2/%,$(abc2_source))
abc2: $(abc2_targets)
$(abc2_targets) : dist/abc2/%.abc : abc2/%.abc
	mkdir -p dist/abc2
	( 	\
		echo '%abc-2.1'; \
		echo "%Version $$(git describe --tags --always)"; \
		cat "$<"; \
	) > $@

dist/tunebook2-abc.zip: $(abc2_targets)
	( cd dist/abc2; zip ../tunebook2-abc.zip *.abc )

midi_targets := $(patsubst %.abc,%.midi,$(patsubst abc/%,dist/midi/%,$(abc_source)))
midi: $(midi_targets)
$(midi_targets) : dist/midi/%.midi : abc/%.abc
	mkdir -p dist/midi
	abc2midi "$<" -o "$@"

dist/tunebook-midi.zip: $(midi_targets)
	( cd dist/midi; zip ../tunebook-midi.zip *.midi )

midi2_targets := $(patsubst %.abc,%.midi,$(patsubst abc2/%,dist/midi2/%,$(abc2_source)))
midi2: $(midi2_targets)
$(midi2_targets) : dist/midi2/%.midi : abc2/%.abc
	mkdir -p dist/midi2
	abc2midi "$<" -o "$@"

dist/tunebook2-midi.zip: $(midi2_targets)
	( cd dist/midi2; zip ../tunebook2-midi.zip *.midi )

mp3_targets := $(patsubst %.abc,%.mp3,$(patsubst abc/%,dist/mp3/%,$(abc_source)))
mp3: $(mp3_targets)
tmp_file := $(shell mktemp)
$(mp3_targets) : dist/mp3/%.mp3 : dist/midi/%.midi
	mkdir -p dist/mp3
	fluidsynth -F "$(tmp_file)" -T wav GeneralUser_GS_v1.471.sf2 "$<"
	lame $(shell bin/get_tags.py $@ "abc") --tl "Tunebook ABC" --ta "Tunebook ABC" --tg Folk "$(tmp_file)" "$@"
	rm "$(tmp_file)"

dist/tunebook-mp3.zip: $(mp3_targets)
	( cd dist/mp3; zip ../tunebook-mp3.zip *.mp3 )

mp3_2_targets := $(patsubst %.abc,%.mp3,$(patsubst abc2/%,dist/mp3-2/%,$(abc2_source)))
mp3_2: $(mp3_2_targets)
tmp_file := $(shell mktemp)
$(mp3_2_targets) : dist/mp3-2/%.mp3 : dist/midi2/%.midi
	mkdir -p dist/mp3-2
	fluidsynth -F "$(tmp_file)" -T wav GeneralUser_GS_v1.471.sf2 "$<"
	lame $(shell bin/get_tags.py $@ "abc2") --tl "2nd ed Tunebook ABC" --ta "2nd ed Tunebook ABC" --tg Folk "$(tmp_file)" "$@"
	rm "$(tmp_file)"

dist/tunebook2-mp3.zip: $(mp3_2_targets)
	( cd dist/mp3-2; zip ../tunebook2-mp3.zip *.mp3 )


# Copy the generated files to a web site
target_filenames := $(patsubst dist/%,%,$(targets))
.PHONY: website
website: $(targets) index.html index2.html errata.txt .htaccess abc abc2 midi midi2 mp3 mp3_2 dist/tunebook-abc.zip dist/tunebook2-abc.zip dist/tunebook-midi.zip dist/tunebook2-midi.zip dist/tunebook-mp3.zip dist/tunebook2-mp3.zip
	( \
		cd dist; \
		rsync -av ../index.html ../index2.html ../errata.txt ../.htaccess $(target_filenames) abc abc2 midi midi2 mp3 mp3-2 tunebook-abc.zip tunebook2-abc.zip tunebook-midi.zip tunebook2-midi.zip tunebook-mp3.zip tunebook2-mp3.zip jonw@caracal.mythic-beasts.com:www/brsn.org.uk/tunebook-abc/; \
	)
