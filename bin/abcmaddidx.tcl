#!/usr/bin/env tclsh

# Create a tune index from the abcm2ps PostScript output
#	
# Copyright (C) 2007-2017 Jean-François Moine
#
# version 2017-07-23
#	- wrong computation of the number of indexes per page (reported by Paul Hardy)
# version 2017-01-06
#	- add '-nx' (asked by Paul Sherwood)
# version 2016-08-05
#	- fix page overflow when landscape
#	- handle '-m' for old version of abcm2ps
# version 2016-08-04
#	- fix loop when landscape
# version 2016-04-27
#	- add option '-m' for main titles only
#	- the subtitles were at a wrong place
# version 2015-10-14
#	- handle abcm2ps >= 8.9.0
# version 2015/09/10
#	- fix bad output when '[' and ']' in a title
# version 2015/09/08
#	- fix crash when '"' (double quote) and non blank char in a title
# version 2014/07/01
#	- add utf-8 support with abcm2ps >= 7.8.5 or 8.1.3
# version 2013/03/16
#	- fix crash when %%header with 2 lines (reported by Chuck Boody)
# version 2011/04/18
#	- handle the secondary titles
# version 2010/06/11
#	- bad vertical space in index
#	- add option in usage
# version 2010/06/03
#	- more settable variables
#	- add option to set the index at the first pages
#	- do it work with abcm2ps-6.x.x
# version 2007/12/01
#	- loop when 1st title ends with ", The' and abcm2ps version < 5

# -- set your preferences here --
# below, you may force the fontname, fontsize and xmid (X middle)
# which are normally found in the input PostScript file
    set fontname {}
# example:
#    set fontname {/Helvetica exch selectfont}
    set fontsize 0
    set xmid 0
# title of the index page
    set index {index}
# the following values are used when fontname, fontsize or
# xmid cannot be found in the input PostScript file
    set fontname_d {F0}		;# default encoded font name
    set fontsize_d {20}		;# default encoded font size
    set xmid_d 300		;# default x middle of the page
# -- end preferences --

proc usage {} {
    puts {Add a tune index to a abcm2ps output.
Usage: ./abcmaddidx.tcl [options] <input abcm2ps file> <output file with index>
  <input abcm2ps file> may be '-' for stdin
  -b     set the index before the music
  -m     set an index for main titles only (not for subtitles)
  -nx    don't include the tune number in the titles}
#'
	exit 1
}

proc main {} {
    global argv
    global fontname_d fontsize_d xmid_d fontname fontsize xmid index
    set fnin {}
    set fnout {}
    set before 0
    set main_title 0
    set no_x 0
    foreach p $argv {
	switch -- $p {
	    -b {
		set before 1
	    }
	    -m {
		set main_title 1
	    }
	    -nx {
		set no_x 1
	    }
	    default {
		if {[string length $fnin] == 0} {
		    set fnin $p
		} elseif {[string length $fnout] == 0} {
		    set fnout $p
		} else {
			usage
		}
	    }
	}
    }
    if {$fnin == "-"} {
	set in stdin
    } else {
	set in [open $fnin r]
    }
    set out [open $fnout w]
    set page 1
    set titlelist {}
    set gsave {}
    set scale {1 dup scale}
    set margin {}
    set new_version 0
    set w 595

    # copy the header
    while {[gets $in line] >= 0} {
	if {[string compare $line {%%EndSetup}] == 0} {
	    puts $out "% -- Tune index
/mkidx{	x 0 M showr
	40 0 M show 20 0 RM
	{(  .  )show currentpoint pop xmax ge{exit}if}loop
	0 fh T
}!
/mkidx2{	x 0 M showr
	40 0 M arrayshow 20 0 RM
	{(  .  )show currentpoint pop xmax ge{exit}if}loop
	0 fh T
}!"
	    puts $out $line
	    break
	}
	if {[string compare [string range $line 0 14] {%%BoundingBox:}] == 0} {
		set w [lindex [split $line] 3]
	}
	puts $out $line
    }
    if {$before} {
	set before [tell $in]
    }
    while {[gets $in line] >= 0} {
	if {[string compare [string range $line 0 7] {%%Page: }] == 0} {
	    set page [lindex [split $line] 1]
	    if {[string length $gsave] == 0} {
		if {!$before} {
		    puts $out $line
		}
		gets $in line
		if {[string index $line 0] == "%"} {
		    if {!$before} {
			puts $out $line
		    }
		    gets $in line
		}
		set gsave $line
		while {1} {
		    if {!$before} {
			puts $out $line
		    }
		    if {[gets $in line] < 0} break
		    set tmp [split $line]
		    if {[string compare [string range $line 0 11] {% --- width }] == 0} {
			if {$xmid == 0} {
			    set xmid [expr {[lindex $line 3] * 0.5}]
			}
		    }
		    switch [lindex $tmp end] {
			scale {set scale $line}
			T {
			    if {[lindex $line 0] == 0} continue
			    set margin $line
			    break
			}
		    }
		}
	    }
	} elseif {[string compare [string range $line 0 10] {% --- title}] == 0} {

	    # new versions (utf-8)
	    if {!$before} {
		puts $out $line
	    }
	    if {[string compare [string range $line 11 13] {sub}] == 0} {
		if {$main_title} {
		    puts $out $line
		    continue
		}
		set atitle [string range $line 15 end]
	    } else {
		set atitle [string range $line 12 end]
	    }

	    gets $in line

	    set j [string first "\]arrayshow" $line]
	    if {$j > 0} {
		set i [string first "\[" $line]
		incr i
		incr j -1
		set title [string trim [string range $line $i $j]]
		if {$no_x} {
			set title [regsub {^\([0-9. ]+} $title {(}]
		}
		lappend titlelist [list $atitle "\[$title\]($page)mkidx2"]
		set new_version 1
#		if {[string length $fontname] == 0
#		  || $fontsize == 0 || $xmid == 0} {
#			set tmp [split $line]
#			set xmid [lindex $tmp 0]
#			set fontsize [lindex $tmp 4]
#			set fontname [lindex $tmp 5]
#		}
#puts $out "% xmid $xmid fontsize $fontsize fontname $fontname\n"
#flush $out
	    } else {
		set i [string first "(" $line]
		set j [string last ")" $line]
		if {$i > 0 && $j > 0} {
			incr i
			incr j -1
			set title [string trim [string range $line $i $j]]
			if {$no_x} {
				set title [regsub {^[0-9. ]+} $title {}]
			}
			lappend titlelist [list $atitle "($title)($page)mkidx"]
#			if {[string length $fontname] == 0
#			  || $fontsize == 0 || $xmid == 0} {
#				set tmp [split $line]
#				set xmid [lindex $tmp 0]
#				set fontsize [lindex $tmp 3]
#				set fontname [lindex $tmp 4]
#			}
		}
	    }
	} elseif {[string compare [string range $line 0 10] {% --- font }] == 0} {
		set tmp [split $line]
		if {$fontsize == 0} {
		    set fontsize [lindex $tmp 3]
		}
		if {[string length $fontname] == 0} {
		    set fontname [lindex $tmp 4]
		}
	} elseif {[string compare [string range $line 0 5] {% --- }] == 0 &&
	  !$new_version} {

	    # old versions (no utf-8)
	    set i [string first "(" $line]
	    set j [string last ")" $line]
	    if {$i > 0 && $j > 0} {
	      incr i
	      incr j -1
	      if {$main_title && [string index $line 6] == "+"} {
		puts $out $line
		continue
	      }
	      set title [string trim [string range $line $i $j]]
	      lappend titlelist [list $title "($title)($page)mkidx"]
	      if {[string length $fontname] == 0
		|| $fontsize == 0 || $xmid == 0} {
		set i [string last ", " $title]
		if {$i > 0} {
		    incr i -1
		    set title [string range $title 0 $i]
		}
		while {1} {
		    if {!$before} {
			puts $out $line
		    }
		    if {[gets $in line] < 0} break
		    if {[string compare [string range $line 0 10] {% --- font }] == 0} {
			set tmp [split $line]
			if {$fontsize == 0} {
			    set fontsize [lindex $tmp 3]
			}
			if {[string length $fontname] == 0} {
			    set fontname [lindex $tmp 4]
			}
			break
		    }
		    if {[string first $title $line] >= 0} {
			set tmp [split $line]
			if {[string index [lindex $tmp 4] 0] == "M"} {
			    if {$fontsize == 0} {
				set fontsize [lindex $tmp 0]
			    }
			    if {[string length $fontname] == 0} {
				set fontname [lindex $tmp 1]
			    }
			    if {$xmid == 0} {
				set xmid [lindex $tmp 2]
			    }
			} else {
			    if {$fontsize == 0} {
				set fontsize [lindex $tmp 3]
			    }
			    if {[string length $fontname] == 0} {
				set fontname [lindex $tmp 4]
			    }
			    if {[string last "showc" $line] > 0
				&& [string index [lindex $tmp 2] 0] == "M"} {
				if {$xmid == 0} {
				    set xmid [lindex $tmp 0]
				}
			    } elseif {$xmid == 0} {
#				puts stderr "line: $line"
				puts stderr "xmid forced to $xmid_d"
				set xmid $xmid_d
			    }
			}
			if {[string index $fontname 0] != "F"} {
#			    puts stderr "line: $line"
#			    puts stderr "font: $fontname"
			    puts stderr "font forced to $fontsize_d $fontname_d"
			    set fontname $fontname_d
			    set fontsize $fontsize_d
			}
			break
		    }
		}
	      }
	    }
	} elseif {[string compare [string range $line 0 8] {%%Trailer}] == 0} {
	    break
	}
	if {!$before} {
	    puts $out $line
	}
    }
    # output the index
    set x [expr {$xmid * 2}]
    set ph [lindex $gsave end-1]		; # page height
    if {$ph < 0} {
	# landscape - compute the page height from %%BoundingBox and scale
	if {[string compare [string range $scale 0 2] {1 }] == 0} {
	    if {[lindex [split $gsave] 3] == scale} {
		set sc [lindex [split $gsave] 1]
	    } else {
		set sc 1
	    }
	} else {
	    set sc [lindex [split $scale] 0]
	}
	set ph [expr {$w / $sc}]
    }
#    set fh [expr {($fontsize / 0.8)}]
    set fh [expr {$fontsize * 1.1}]
#    set lh [expr {($fontsize / 0.8) * [lindex $scale 0]}]
    set lh [expr {$fh * [lindex $scale 0]}]
    set n [expr {int(($ph - 6 * $lh) / $lh)}]
    set titlelist [lsort -dictionary -index 0 $titlelist]
#puts "titlelist: $titlelist"
    set first 1
    if {$before} {
	set page 0
    }
    puts $out "% -- Tune index"
    while {[llength $titlelist] > 0} {
	set sublist [lrange $titlelist 0 [expr {$n - 1}]]
	set titlelist [lrange $titlelist $n end]
	incr page 1
	puts $out "%%Page: $page $page
$gsave
$scale
$margin
$fontsize $fontname
$x 40 sub /x 1 index def
/xmax exch 40 sub def
/fh -$fh def
0 fh 1.6 mul T"
	if {$first} {
	    puts $out "x 2 div 0 M($index)showc
0 fh 1.6 mul T"
	    set first 0
	    incr n 2
	}
	foreach t $sublist {
	    puts $out [lindex $t 1]
	}
	puts $out "%%PageTrailer
grestore
showpage"
    }
    # if index at the beginning, copy the tunes
    if {$before} {
	seek $in $before
	while {[gets $in line] >= 0} {
	    if {[string compare [string range $line 0 7] {%%Page: }] == 0} {
		incr page
		puts $out "%%Page: $page $page"
	    } elseif {[string compare [string range $line 0 8] {%%Trailer}] == 0} {
		break
	    } else {
		puts $out $line
	    }
	}
    }
    # update the trailer
    puts $out "%%Trailer
%%Pages: $page
%EOF"
}

# -- main
if {$argc < 2} {
    usage
}

main
