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
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Tabs' $@

# The first few bars of all the tunes
dist/cheatsheet.pdf : abc/*.abc header.abc cheatsheet.abc copying.abc bin/sorter.py  bin/make_cheatsheet.py tunebook.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%staffwidth 10cm'; \
	 echo '%%titleformat T-1'; \
	 bin/sorter.py --title; \
	) | bin/make_cheatsheet.py | abcm2ps - -i -F tunebook.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-whistle.pdf : abc/*.abc header.abc cheatsheet-whistle.abc copying.abc bin/sorter.py bin/make_cheatsheet.py tunebook.fmt flute.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-whistle.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
 	 echo '%%staffwidth 10cm'; \
 	 echo '%%titleformat T-1'; \
	 bin/sorter.py --title; \
	) |  bin/make_cheatsheet.py | abcm2ps - -i -F tunebook.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Whistle' $@

# Copy the generated files to a web site
.PHONY: website
website: default
	scp $(targets) HEADER.html jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc
