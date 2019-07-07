default: dist/tunebook.pdf

dist/tunebook.abc : abc/*.abc
	cp abc/*.abc work/abc/
	mac2unix work/abc/*.abc
	-rm dist/tunebook_a.abc
	for f in `ls work/abc/*.abc`; do (cat "$${f}"; echo; echo) >> dist/tunebook_a.abc; done
	grep -v '%abc-2.1' dist/tunebook_a.abc > $@


dist/tunebook.pdf : dist/tunebook.abc
	abcm2ps $< -i -F flute.fmt -T1 -O - | ps2pdf - $@
