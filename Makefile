targets = dist/tunebook.abc \
dist/tunebook.pdf \
dist/tunebook-bflat.pdf \
dist/tunebook-eflat.pdf \
dist/tunebook-base.pdf \
dist/tunebook-tabs.pdf \
dist/tunebook-mandolin.pdf \
dist/tunebook-dulcimer.pdf \
dist/tunebook-ukulele.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet-whistle.pdf \
dist/cheatsheet-mandolin.pdf \
dist/cheatsheet-dulcimer.pdf

abc_source := $(wildcard abc/[0-9]*.abc)

.PHONY: default
default: $(targets)

# EasyABC writes files with <cr><lf> line endings - this target
# fixes them
.PHONY: fixup
fixup:
	dos2unix $(abc_source)

# Create a concatenation for distribution
dist/tunebook.abc: $(abc_source) header.abc copying.abc bin/sorter.py
	mkdir -p dist
	(echo '%abc-2.1'; \
     cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "% Version $$(git describe --tags --always)"; echo; \
     bin/sorter.py --ref; \
	) > $@

# All the tunes as a printable score matching the published Tunebook
dist/tunebook.pdf : $(abc_source) header.abc copying.abc bin/sorter.py tunebook.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | abcm2ps - -i -F tunebook.fmt -O - | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in Bb
dist/tunebook-bflat.pdf : $(abc_source) header.abc copying.abc bflat.abc bin/sorter.py tunebook.fmt bflat.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat bflat.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | abcm2ps - -i -F tunebook.fmt -F bflat.fmt -O - | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in Bb' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in Eb
dist/tunebook-eflat.pdf : $(abc_source) header.abc copying.abc eflat.abc bin/sorter.py tunebook.fmt eflat.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat eflat.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | abcm2ps - -i -F tunebook.fmt -F eflat.fmt -O - | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in Eb' -Author='Tunebook ABC' $@

# All the tunes as a printable score matching the published Tunebook in the base clef
dist/tunebook-base.pdf : $(abc_source) header.abc copying.abc base.abc bin/sorter.py tunebook.fmt base.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat base.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref --paginate; \
	) | abcm2ps - -i -F tunebook.fmt -F base.fmt -O - | bin/abcmaddidx.tcl - $@.ps
	ps2pdf $@.ps $@
	rm $@.ps
	exiftool -Title='Tunebook ABC in the base clef' -Author='Tunebook ABC' $@

## Tablatures and chords

# All the tunes as a printable score, one tune per page with guitar
# chord diagrams and D whistle tabs
dist/tunebook-tabs.pdf : $(abc_source) header.abc tabs.abc copying.abc bin/sorter.py bin/add_chords.py tunebook.fmt flute.fmt guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat tabs.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -F guitarchords.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - D Wistle' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with mandolin tabs
dist/tunebook-mandolin.pdf : $(abc_source) header.abc mandolin.abc copying.abc bin/sorter.py bin/add_chords.py tunebook.fmt mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat mandolin.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | abcm2ps - -1 -i -F tunebook.fmt -T7 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Mandolin' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with dulcimer
# chord diagrams and dulcimer tabs
dist/tunebook-dulcimer.pdf : $(abc_source) header.abc dulcimer.abc copying.abc bin/sorter.py bin/add_chords.py tunebook.fmt dulcimer.fmt dulcimerchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat dulcimer.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -F dulcimerchords.fmt -T8 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Dulcimer' -Author='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with ukulele chords
dist/tunebook-ukulele.pdf : $(abc_source) header.abc ukulele.abc copying.abc bin/sorter.py bin/add_chords.py tunebook.fmt ukulelechords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat ukulele.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -F ukulelechords.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Dulcimer' -Author='Tunebook ABC' $@

## Cheatsheets

# The first few bars of all the tunes
dist/cheatsheet.pdf : $(abc_source) header.abc cheatsheet.abc copying.abc bin/sorter.py  bin/make_cheatsheet.py tunebook.fmt cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) | bin/make_cheatsheet.py --rows 13 | abcm2ps - -i -F tunebook.fmt -F  cheatsheet.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-whistle.pdf : $(abc_source) header.abc cheatsheet-whistle.abc copying.abc bin/sorter.py bin/make_cheatsheet.py tunebook.fmt cheatsheet.fmt flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-whistle.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 7 | abcm2ps - -i -F tunebook.fmt -F cheatsheet.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Whistle' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with mandolin fingering
dist/cheatsheet-mandolin.pdf : $(abc_source) header.abc cheatsheet-mandolin.abc copying.abc bin/sorter.py bin/make_cheatsheet.py tunebook.fmt cheatsheet.fmt cheatsheet-mandolin.fmt mandolin.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-mandolin.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 8 | abcm2ps - -i -F tunebook.fmt -F cheatsheet.fmt -F cheatsheet-mandolin.fmt -T7 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Mandolin' -Author='Tunebook ABC' $@

# The first few bars of all the tunes with dulcimer fingering
dist/cheatsheet-dulcimer.pdf : $(abc_source) header.abc cheatsheet-dulcimer.abc copying.abc bin/sorter.py bin/make_cheatsheet.py tunebook.fmt cheatsheet.fmt cheatsheet-dulcimer.fmt dulcimer.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-dulcimer.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\""; echo; \
	 echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 8 | abcm2ps - -i -F tunebook.fmt -F cheatsheet.fmt -F cheatsheet-dulcimer.fmt -T8 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Dulcimer' -Author='Tunebook ABC' $@

# Assorted files

abc_targets := $(patsubst abc/%,dist/abc/%,$(abc_source))
abc: $(abc_targets)
$(abc_targets) : dist/abc/%.abc : abc/%.abc
	mkdir -p dist/abc
	( 	\
		echo '%abc-2.1'; \
		cat "$<"; \
	) > $@

dist/tunebook-abc.zip: dist/abc/*.abc
	( cd dist/abc; zip ../tunebook-abc.zip *.abc )

midi_targets := $(patsubst %.abc,%.midi,$(patsubst abc/%,dist/midi/%,$(abc_source)))
midi: $(midi_targets)
$(midi_targets) : dist/midi/%.midi : abc/%.abc
	mkdir -p dist/midi
	abc2midi "$<" -o "$@"

dist/tunebook-midi.zip: dist/midi/*.midi
	( cd dist/midi; zip ../tunebook-midi.zip *.midi )

mp3_targets := $(patsubst %.abc,%.mp3,$(patsubst abc/%,dist/mp3/%,$(abc_source)))
mp3: $(mp3_targets)
tmp_file := $(shell mktemp)
$(mp3_targets) : dist/mp3/%.mp3 : dist/midi/%.midi
	mkdir -p dist/mp3
	fluidsynth -F "$(tmp_file)" -T wav GeneralUser_GS_v1.471.sf2 "$<"
	lame $(shell bin/get_tags.py $@) --tl "Tunebook ABC" --ta "Tunebook ABC" --tg Folk "$(tmp_file)" "$@"
	rm "$(tmp_file)"

dist/tunebook-mp3.zip: dist/mp3/*.mp3
	( cd dist/mp3; zip ../tunebook-mp3.zip *.mp3 )


# Copy the generated files to a web site
target_filenames := $(patsubst dist/%,%,$(targets))
.PHONY: website
website: $(targets) index.html .htaccess abc midi mp3 dist/tunebook-abc.zip dist/tunebook-midi.zip dist/tunebook-mp3.zip
	( \
		cd dist; \
		rsync -av ../index.html ../.htaccess $(target_filenames) abc midi mp3 tunebook-abc.zip tunebook-midi.zip tunebook-mp3.zip jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc/; \
	)
