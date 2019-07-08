default: dist/tunebook.abc dist/tunebook.pdf dist/tunebook-whistle.pdf

dist/tunebook.abc : header.abc abc/*.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
		cat header.abc; \
		echo; \
		for f in `ls abc/*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done) > $@
	mac2unix $@

dist/tunebook.pdf : dist/tunebook.abc
	abcm2ps $< -i -O - | ps2pdf - $@

dist/tunebook-whistle.pdf : dist/tunebook.abc
	abcm2ps $< -i -F flute.fmt -T1 -O - | ps2pdf - $@
