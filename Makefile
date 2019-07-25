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

# Concatenate all the tunes
dist/raw_tunebook.abc : abc/*.abc
	mkdir -p dist
	(echo "% Version $$(git describe --tags --always)"; echo; \
     for f in `ls abc/[0-9]*.abc`; do (cat "$${f}"; echo; echo;) done \
	) | bin/add_version.sh > $@

# Create a concatenation that includes pagenation
dist/paged_tunebook.abc: dist/raw_tunebook.abc bin/paginator.py
	bin/paginator.py dist/raw_tunebook.abc > $@

# Create a concatenation for distribution
dist/tunebook.abc: header.abc copying.abc dist/raw_tunebook.abc
	(echo '%abc-2.1'; \
     cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 cat dist/raw_tunebook.abc; \
	) > $@

# All the tunes as a printable score matching the published Tunebook
dist/tunebook.pdf : header.abc copying.abc dist/paged_tunebook.abc tunebook.fmt
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 cat dist/paged_tunebook.abc; \
	) | abcm2ps - -i -F tunebook.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC' $@

# All the tunes as a printable score, one tune per page with guitar
# chord diagrams and whistle tabs
dist/tunebook-tabs.pdf : dist/raw_tunebook.abc header.abc tabs.abc copying.abc tunebook.fmt flute.fmt guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat tabs.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%newpage'; \
	 cat dist/raw_tunebook.abc; \
	) | bin/add_chords.py | abcm2ps - -1 -i -F tunebook.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Tabs' $@

# The first few bars of all the tunes
dist/cheatsheet.pdf : dist/raw_tunebook.abc header.abc cheatsheet.abc copying.abc bin/make_cheatsheet.py tunebook.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
	 echo '%%staffwidth 10cm'; \
	 cat dist/raw_tunebook.abc; \
	) | bin/make_cheatsheet.py | abcm2ps - -i -F tunebook.fmt -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet' $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-whistle.pdf : abc/*.abc header.abc cheatsheet-whistle.abc copying.abc bin/make_cheatsheet.py tunebook.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-whistle.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo "%%header \"-$$(git describe --tags --always)		\$$P\""; echo; \
 	 echo '%%staffwidth 10cm'; \
	 cat dist/raw_tunebook.abc; \
	) |  bin/make_cheatsheet.py | abcm2ps - -i -F tunebook.fmt -T1 -O - | ps2pdf - $@
	exiftool -Title='Tunebook ABC - Cheatsheet Whistle' $@

# Copy the generated files to a web site
.PHONY: website
website: default
	scp $(targets) HEADER.html jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc
