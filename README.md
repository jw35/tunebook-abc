Tunebook ABC
============

This is a transcription of all the tunes in the
[Tuneworks](https://www.tuneworks.co.uk/)
[Tunebook](https://docs.wixstatic.com/ugd/d6448b_974724120ad6465fbf8f417ff89daf0b.pdf)
into [ABC notation](http://abcnotation.com/) and a set of tools to process that into various
useful formats.

See https://www.brsn.org.uk/tunebook-abc/ for the processed result.

Processing
----------

All the tunes are represented by ABC file fragments in at `abc/` directory. Their file names,
and the `X:` field reference numbers inside them, are based on the two-digit page
number on which the tune appears in the Tunebook and a two-digit sequence number
within that page.

There is a Makefile which processes these fragments into various formats
(a multi-tune 'ABC tunebook', PDF in various formats, etc.). This was written
to work on MacOS but should be compatible with most Unix-ish environments. The
Makefile assumes that reasonably recent copies of the following programs are available somewhere on
`$PATH` (all of which can be installed with Homebrew):

* `abcm2ps` (https://github.com/leesavide/abcm2ps/, http://abcplus.sourceforge.net/#abcm2ps)
* `abc2midi` (from the abcmidi package)
* `dos2unix`
* `ps2pdf` (from the Ghostscript package)
* `python3`
* `git`
* `tclsh` (from the tcl cask)
* `exiftool`
* `fluidsynth`
* `lame`

This work was lagely inspired by [Paul Hardy's Tunebooks](http://www.pghardy.net/concertina/tunebooks/)
and his [tunebook processs page](http://www.pghardy.net/concertina/tunebooks/tunebook_process.html) heavily
informed the processing pipeline.

Licensing
---------

The contents of this repository is licenced under the terms of the GNU General Public License.
In addition, the transcribed ABC files and the results of processing them
into various other formats distributed from https://brsn.org.uk/tunebook-abc/
are also licensed under the Creative Commons
'[Attribution ShareAlike (CC BY-SA)](https://creativecommons.org/licenses/by-sa/4.0/)'
licence.

See the file [LICENCE.txt](LICENCE.txt) for more details.
