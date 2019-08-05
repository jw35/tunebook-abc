targets = dist/tunebook.abc \
dist/tunebook.pdf \
dist/tunebook-tabs.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet-whistle.pdf

.PHONY: default
default: $(targets)

# EasyABC writes files with <cr><lf> line endings - this target
# fixes them
.PHONY: fixup
fixup:
	dos2unix abc/*.abc

# Create a concatenation for distribution
dist/tunebook.abc: abc/*.abc header.abc copying.abc bin/sorter.py
	(echo '%abc-2.1'; \
     cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "% Version $$(git describe --tags --always)"; echo; \
     bin/sorter.py --ref; \
	) > $@

# All the tunes as a printable score matching the published Tunebook
dist/tunebook.pdf : abc/*.abc header.abc copying.abc bin/sorter.py tunebook.fmt
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

# All the tunes as a printable score, one tune per page with guitar
# chord diagrams and whistle tabs
dist/tunebook-tabs.pdf : abc/*.abc header.abc tabs.abc copying.abc bin/sorter.py tunebook.fmt flute.fmt guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat tabs.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 bin/sorter.py --ref; \
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -T7 -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Tabs' $@

# The first few bars of all the tunes
dist/cheatsheet.pdf : abc/*.abc header.abc cheatsheet.abc copying.abc bin/sorter.py  bin/make_cheatsheet.py tunebook.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%topspace 0.3cm'; \
     echo '%%staffsep 0.7cm'; \
     echo '%%titleformat T-1'; \
     echo '%%maxshrink 0.9'; \
     echo '%%musiconly 1'; \
     echo '%%printtempo 0'; \
     echo '%%titlefont * 16'; \
     echo '%%subtitlefont * 13'; \
     echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) | bin/make_cheatsheet.py --rows 13 | abcm2ps - -i -F tunebook.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-whistle.pdf : abc/*.abc header.abc cheatsheet-whistle.abc copying.abc bin/sorter.py bin/make_cheatsheet.py tunebook.fmt flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-whistle.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%topspace 0.3cm'; \
     echo '%%staffsep 0.7cm'; \
     echo '%%titleformat T-1'; \
     echo '%%maxshrink 0.9'; \
     echo '%%musiconly 1'; \
     echo '%%printtempo 0'; \
     echo '%%titlefont * 16'; \
     echo '%%subtitlefont * 13'; \
     echo '%%scale 0.6'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py --rows 7 | abcm2ps - -i -F tunebook.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Whistle' $@


dist/.abcfiles: abc/*.abc header.abc copying.abc
	mkdir -p dist/abc
	(cd abc; \
	 for f in `ls [0-9]*.abc`; do ( \
	 	echo '%abc-2.1'; \
	 	cat "$${f}"; \
	 	) > ../dist/abc/$${f}; done; \
	)
	touch dist/.abcfiles

dist/.midifiles: abc/*.abc
	mkdir -p dist/midi
	(cd abc; \
	 for f in `ls [0-9]*.abc`; do abc2midi "$${f}" -o ../dist/midi/$$(basename "$${f}" .abc).midi; done; \
	)
	touch dist/.midifiles

# Copy the generated files to a web site
.PHONY: website
website: default dist/.abcfiles dist/.midifiles
	scp -r $(targets) index.html dist/abc dist/midi jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc
