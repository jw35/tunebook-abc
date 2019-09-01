targets = dist/tunebook.abc \
dist/tunebook.pdf \
dist/tunebook-bflat.pdf \
dist/tunebook-eflat.pdf \
dist/tunebook-baseclef.pdf \
dist/tunebook-guitar-dwhistle.pdf \
dist/tunebook-mandolin.pdf \
dist/tunebook-dulcimer-chords-dad.pdf \
dist/tunebook-dulcimer-tabs-dad.pdf \
dist/tunebook-ukulele.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet-dwhistle.pdf \
dist/cheatsheet-mandolin.pdf \
dist/cheatsheet-dulcimer-dad.pdf

abc_source := $(wildcard abc/[0-9]*.abc)

common_depends = inc/frontmatter.abc bin/sorter.py fmt/tunebook.fmt
common_args = - -i -D fmt -F tunebook.fmt -O -

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

# All the tunes as a printable score matching the published Tunebook
dist/tunebook.pdf : $(abc_source) $(common_depends) inc/tunebook.abc
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

# All the tunes as a printable score matching the published Tunebook in the base clef
dist/tunebook-baseclef.pdf : $(abc_source) $(common_depends) inc/baseclef.abc fmt/baseclef.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/baseclef.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | bin/strip_chords.py | abcm2ps $(common_args) -F baseclef.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in the base clef' -Author='Tunebook ABC' $@

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

# Just the tunes in 'D' as a printable score, one tune per page with dulcimer
# chord diagrams and dulcimer tabs for a DAD-tuned instrument
dist/tunebook-dulcimer-tabs-dad.pdf : $(abc_source) $(common_depends) inc/dulcimer-tabs-dad.abc bin/add_chords.py fmt/dulcimer-tabs-dad.fmt fmt/dulcimer.fmt fmt/dulcimerchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/dulcimer-tabs-dad.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --key-filter D; \
	) | bin/add_chords.py | abcm2ps $(common_args) -1 -T8 -F dulcimer-tabs-dad.fmt | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC - DAD Dulcimer' -Author='Tunebook ABC' $@

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
	) | bin/make_cheatsheet.py --rows 13 | abcm2ps $(common_args) -F  cheatsheet.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-dwhistle.pdf : $(abc_source) $(common_depends) inc/cheatsheet-dwhistle.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dwhistle.fmt fmt/flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-dwhistle.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 7 | abcm2ps $(common_args) -T1 -F cheatsheet.fmt -F cheatsheet-dwhistle.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet D Whistle' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with mandolin fingering
dist/cheatsheet-mandolin.pdf : $(abc_source) $(common_depends) inc/cheatsheet-mandolin.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-mandolin.fmt fmt/mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-mandolin.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 8 | abcm2ps $(common_args) -T7 -F cheatsheet.fmt -F cheatsheet-mandolin.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Mandolin' -Author='Tunebook ABC' $@

# The first few bars of all the tunes in 'D' with dulcimer fingering for a
# DAD-tuned instrument
dist/cheatsheet-dulcimer-dad.pdf : $(abc_source) $(common_depends) inc/cheatsheet-dulcimer-dad.abc bin/make_cheatsheet.py fmt/cheatsheet.fmt fmt/cheatsheet-dulcimer-dad.fmt fmt/dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat inc/cheatsheet-dulcimer-dad.abc; echo; echo; \
	 cat inc/frontmatter.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title --key-filter D; \
	) |  bin/make_cheatsheet.py --rows 8 | abcm2ps $(common_args) -T8 -F cheatsheet.fmt -F cheatsheet-dulcimer-dad.fmt | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet DAD Dulcimer' -Author='Tunebook ABC' $@

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

midi_targets := $(patsubst %.abc,%.midi,$(patsubst abc/%,dist/midi/%,$(abc_source)))
midi: $(midi_targets)
$(midi_targets) : dist/midi/%.midi : abc/%.abc
	mkdir -p dist/midi
	abc2midi "$<" -o "$@"

dist/tunebook-midi.zip: $(midi_targets)
	( cd dist/midi; zip ../tunebook-midi.zip *.midi )

mp3_targets := $(patsubst %.abc,%.mp3,$(patsubst abc/%,dist/mp3/%,$(abc_source)))
mp3: $(mp3_targets)
tmp_file := $(shell mktemp)
$(mp3_targets) : dist/mp3/%.mp3 : dist/midi/%.midi
	mkdir -p dist/mp3
	fluidsynth -F "$(tmp_file)" -T wav GeneralUser_GS_v1.471.sf2 "$<"
	lame $(shell bin/get_tags.py $@) --tl "Tunebook ABC" --ta "Tunebook ABC" --tg Folk "$(tmp_file)" "$@"
	rm "$(tmp_file)"

dist/tunebook-mp3.zip: $(mp3_targets)
	( cd dist/mp3; zip ../tunebook-mp3.zip *.mp3 )


# Copy the generated files to a web site
target_filenames := $(patsubst dist/%,%,$(targets))
.PHONY: website
website: $(targets) index.html .htaccess abc midi mp3 dist/tunebook-abc.zip dist/tunebook-midi.zip dist/tunebook-mp3.zip
	( \
		cd dist; \
		rsync -av ../index.html ../.htaccess $(target_filenames) abc midi mp3 tunebook-abc.zip tunebook-midi.zip tunebook-mp3.zip jonw@sphinx.mythic-beasts.com:brsn.org.uk_html/tunebook-abc/; \
	)
