default: dist/tunebook.abc dist/tunebook.pdf dist/tunebook-tabs.pdf dist/cheatsheet.pdf

# All the tunes in one big tunebook
dist/tunebook.abc : header.abc abc/*.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; \
	 echo; echo; \
	 for f in `ls abc/*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) > $@
	mac2unix $@

# All the tunes as a printable score
dist/tunebook.pdf : dist/tunebook.abc tunebook.fmt
	abcm2ps $< -i -F tunebook.fmt -O - | ps2pdf - $@

# All the tunes as a printable score with guitar chord diagrams
# and whistle tabs
dist/tunebook-tabs.pdf : dist/tunebook.abc tunebook.fmt flute.fmt guitarchords.fmt
	bin/add_chords.py $< | abcm2ps - -i -F tunebook.fmt -T1 -O - | ps2pdf - $@

# The first few bars of all the tunes
dist/cheatsheet.pdf : abc/*.abc bin/make_cheatsheet.py cheatsheet.fmt
	mkdir -p dist
	(echo '%abc-2.1'; \
  	 for f in `ls abc/*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
  	) | bin/make_cheatsheet.py | abcm2ps - -i -F cheatsheet.fmt -O - | ps2pdf - $@
