#!/usr/bin/env python3

'''
Generate a 'cheatsheet' (or 'Incipit') containing just the first few bars of each
tune. This script is good enough to extract information from the tunes
in this repository, but doesn't include a complete ABC parser and is likely
to choke on entirely legal ABC files that happen to include features not
used here.
'''

import fileinput
import re
import sys

from fractions import Fraction

# "borrowed' from EasyABC (https://sourceforge.net/projects/easyabc/)"
note_pattern = re.compile(r"(?P<note>([_=^]?[A-Ga-gxz](,+|'+)?))(?P<length>\d{0,3}(?:/\d{0,3})*)(?P<dot>\.*)(?P<broken>[><]?)")
bar_pattern = re.compile(r'(?P<bar>.*?\|)')


def get_default_len(abc):
    m = re.search(r'(?m)^L: *(\d+)/(\d+)', abc)
    if m:
        return Fraction(int(m.group(1)), int(m.group(2)))
    else:
        return Fraction(1, 8)


def get_metre(abc):
    m = re.search(r'(?m)^M: *(\d+)/(\d+)', abc)
    if m:
        return Fraction(int(m.group(1)), int(m.group(2)))
    else:
        return Fraction(4, 4)


def bar_length(notes, default_length):

    total_length = 0

    for match in note_pattern.finditer(re.sub(r'".*?"', '', notes)):

        #print(match.group('note'), match.group('length'), match.group('dot'))

        length = match.group('length')
        multiplier = Fraction(1)
        dividend = length.split('/')[0]
        if dividend:
            multiplier = multiplier * Fraction(int(dividend))
        for divmatch in re.finditer(r'/(\d*)', length):
            divisor = divmatch.group(1)
            if divisor:
                divisor = int(divisor)
            else:
                divisor = 2
            multiplier = multiplier / Fraction(divisor)
        for dot in match.group('dot'):
            multiplier = multiplier * Fraction(3, 2)

        #print(multiplier * default_length)

        total_length += multiplier * default_length

    return total_length


length_so_far = 0
metre = Fraction(4, 4)
default_length = Fraction(1, 16)


for line in fileinput.input():

    if re.match('X:', line):
        length_so_far = 0
        metre = Fraction(4, 4)
        default_length = Fraction(1, 16)
    elif re.match('L:', line):
        default_length = get_default_len(line)
    elif re.match('M:', line):
        metre = get_metre(line)

    # Blank lines
    if re.fullmatch(r'\s*', line):
        print(line, end='')
    # Headers and comments
    elif re.match('([A-Za-z]:)|%', line):
        print(line, end='')
    # Notes
    elif length_so_far < 2*metre:

        #print('Metre', metre, 'Default length', default_length, file=sys.stderr)

        # Dump leading bar marker
        line = re.sub(r'\s*\|:?\s*', '', line, count=1)

        for match in bar_pattern.finditer(line):
            bar = match.group('bar')
            #print('Got bar', bar, file=sys.stderr)
            length = bar_length(bar, default_length)
            #print('Length', length, file=sys.stderr)

            print(bar, end='')
            length_so_far += length
            if length_so_far >= 2 * metre:
                break

        print()
