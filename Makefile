.PHONY: default
default: dist/tunebook.abc \
dist/tunebook.pdf \
dist/tunebook-tabs.pdf \
dist/cheatsheet.pdf \
dist/cheatsheet-whistle.pdf

# EasyABC writes files with <cr><lf> line endings - this target
# fixes them
.PHONY: fixup
fixup:
	dos2unix abc/*.abc

.PHONY: dist/version.abc
dist/version.abc:
	echo "%%header \"$$(git describe --always --tags)		\"" > dist/version.abc

# All the tunes in one big tunebook
dist/tunebook.abc : header.abc dist/version.abc copying.abc abc/*.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat dist/version.abc; echo; echo; \
	 cat header.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo '%%newpage'; \
	 for f in `ls abc/[0-9]*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) > $@

# All the tunes as a printable score
dist/tunebook.pdf : dist/tunebook.abc tunebook.fmt
	abcm2ps $< -i -F tunebook.fmt -O - | ps2pdf - $@

# All the tunes as a printable score with guitar chord diagrams
# and whistle tabs
dist/tunebook-tabs.pdf : dist/tunebook.abc header.abc dist/version.abc tabs.abc copying.abc tunebook.fmt flute.fmt guitarchords.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat dist/version.abc; echo; echo; \
	 cat header.abc; echo; echo; \
	 cat tabs.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo '%%newpage'; \
	 for f in `ls abc/[0-9]*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) | bin/add_chords.py | abcm2ps - -i -F tunebook.fmt -T1 -O - | ps2pdf - $@

# The first few bars of all the tunes
dist/cheatsheet.pdf : abc/*.abc header.abc dist/version.abc cheatsheet.abc copying.abc bin/make_cheatsheet.py cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat dist/version.abc; echo; echo; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
	 echo '%%staffwidth 10cm'; \
	 for f in `ls abc/[0-9]*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) | bin/make_cheatsheet.py | abcm2ps - -i -F cheatsheet.fmt -O - | ps2pdf - $@

# The first few bars of all the tunes with whistle fingering
dist/cheatsheet-whistle.pdf : abc/*.abc header.abc dist/version.abc cheatsheet-whistle.abc copying.abc bin/make_cheatsheet.py cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat dist/version.abc; echo; echo; \
	 cat header.abc; echo; echo; \
	 cat cheatsheet-whistle.abc; echo; echo; \
	 cat copying.abc; echo; echo; \
 	 echo '%%staffwidth 10cm'; \
	 for f in `ls abc/[0-9]*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) |  bin/make_cheatsheet.py | abcm2ps - -i -F cheatsheet.fmt -T1 -O - | ps2pdf - $@

# Copy the generated files to a web site
.PHONY: website
website: default
	scp dist/* HEADER.html jonw@sphinx.mythic-beasts.com:www.brsn.org.uk_html/tunebook-abc
