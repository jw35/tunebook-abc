Tunebook ABC
============

This is an attempt to transcribe all the tunes in the
[Tuneworks](https://www.tuneworks.co.uk/)
[Tunebook](https://docs.wixstatic.com/ugd/d6448b_974724120ad6465fbf8f417ff89daf0b.pdf)
into [ABC notation](http://abcnotation.com/) and then process that into various
useful formats.

Processing
----------

All the tunes are represented by ABC file fragments in at `abc/` directory. Their file names,
and the `X:` field reference numbers inside them, are based on the two-digit page
number on which the tune appears in the Tunebook and a two-digit sequence number
within that page.

There is a simple Makefile which processes these fragments into various formats
(a multi-tune 'ABC tunebook', PDF in various formats, etc.). This was written
to work on MacOS but should be compatible with most Unix-ish environments. The
Makefile assumes that reasonably recent copies of the following programs are available somewhere on
`$PATH` (all of which can be installed with Homebrew):

* `abcm2ps` (https://github.com/leesavide/abcm2ps/, http://abcplus.sourceforge.net/#abcm2ps)
* `dos2unix` (from the dos2unix package)
* `ps2pdf` (from the Ghostscript package)

Licensing
---------

This work is licensed under the Creative Commons
'[Attribution ShareAlike (CC BY-SA)](https://creativecommons.org/licenses/by-sa/4.0/)'
licence, which means you can
"remix, tweak, and build upon" this work even for commercial purposes,
as long as you credit the original authors and license your new creations under the identical terms. The licensing of the Tuneworks Tunebook on which
this work is based is unclear, other than it saying:

>"The book is downloadable from http://www.tuneworks.co.uk/.
>Please feel free to use it as widely as you like".

