targets = dist/tunebook.abc \
dist/tunebook.pdf \
dist/tunebook-tabs.pdf \
dist/tunebook-mandolin.pdf \
dist/tunebook-dulcimer.pdf \
dist/tunebook-ukulele.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet-whistle.pdf \
dist/cheatsheet-mandolin.pdf \
dist/cheatsheet-dulcimer.pdf

abc_source := $(wildcard abc/[0-9]*.abc)
abc_targets := $(patsubst abc/%,dist/abc/%,$(abc_source))
midi_targets := $(patsubst %.abc,%.midi,$(patsubst abc/%,dist/midi/%,$(abc_source)))
mp3_targets := $(patsubst %.abc,%.mp3,$(patsubst abc/%,dist/mp3/%,$(abc_source)))

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
	exiftool -Title='Tunebook ABC' $@

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
	exiftool -Title='Tunebook ABC - D Wistle' $@

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
	exiftool -Title='Tunebook ABC - Mandolin' $@

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
	exiftool -Title='Tunebook ABC - Dulcimer' $@

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
	exiftool -Title='Tunebook ABC - Dulcimer' $@

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
	exiftool -Title='Tunebook ABC - Cheatsheet' $@

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
	exiftool -Title='Tunebook ABC - Cheatsheet Whistle' $@

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
	exiftool -Title='Tunebook ABC - Cheatsheet Mandolin' $@

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
	exiftool -Title='Tunebook ABC - Cheatsheet Dulcimer' $@


dist/.abcfiles: $(abc_source) header.abc copying.abc
	mkdir -p dist/abc
	(cd abc; \
	 for f in `ls [0-9]*.abc`; do ( \
	 	echo '%abc-2.1'; \
	 	cat "$${f}"; \
	 	) > ../dist/abc/$${f}; done; \
	)
	touch dist/.abcfiles

dist/.midifiles: $(abc_source)
	mkdir -p dist/midi
	(cd abc; \
	 for f in `ls [0-9]*.abc`; do abc2midi "$${f}" -o ../dist/midi/$$(basename "$${f}" .abc).midi; done; \
	)
	touch dist/.midifiles

dist/.mp3files: dist/.midifiles
	mkdir -p dist/mp3
	(cd dist/midi; \
	 for f in `ls [0-9]*.midi`; do fluidsynth -F tmp.wav ../../GeneralUser_GS_v1.471.sf2 "$${f}"; lame tmp.wav ../../dist/mp3/$$(basename "$${f}" .midi).mp3; rm tmp.wav; done; \
	)
	touch dist/.mp3files

# Copy the generated files to a web site
.PHONY: website
website: default dist/.abcfiles dist/.midifiles dist/.mp3files
	scp -r $(targets) index.html .htaccess jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc
	(cd dist; \
		rsync -av abc/ jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc/abc; \
		rsync -av midi/ jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc/midi; \
		rsync -av mp3/ jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc/mp3; \
	)
