default: dist/tunebook.abc dist/tunebook.pdf dist/tunebook-whistle.pdf dist/cheatsheet.pdf

dist/tunebook.abc : header.abc abc/*.abc
	mkdir -p dist
	(echo '%abc-2.1'; \
	 cat header.abc; \
	 echo; echo; \
	 for f in `ls abc/*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
	) > $@
	mac2unix $@

dist/tunebook.pdf : dist/tunebook.abc
	mkdir -p dist
	abcm2ps $< -i -O - | ps2pdf - $@

dist/tunebook-whistle.pdf : dist/tunebook.abc
	mkdir -p dist
	abcm2ps $< -i -F flute.fmt -T1 -O - | ps2pdf - $@

dist/cheatsheet.pdf : abc/*.abc bin/make_cheatsheet.py
	(echo '%abc-2.1'; \
  	 for f in `ls abc/*.abc`; do (grep -v '%abc-2.1' "$${f}"; echo;) done \
  	) | bin/make_cheatsheet.py | abcm2ps - -i -O - | ps2pdf - $@
