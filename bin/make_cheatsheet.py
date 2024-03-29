#!/usr/bin/env python3

'''
Generate a 'cheatsheet' (or 'Incipit') containing just the first few bars of each
tune. This script is good enough to extract information from the tunes
in this repository, but doesn't include a complete ABC parser and is likely
to choke on entirely legal ABC files that happen to include features not
used here.
'''

import argparse
import fileinput
import re

from fractions import Fraction

# "borrowed' from EasyABC (https://sourceforge.net/projects/easyabc/)"
note_pattern = re.compile(r"(?P<note>([_=^]?[A-Ga-gxz](,+|'+)?))(?P<length>\d{0,3}(?:/\d{0,3})*)(?P<dot>\.*)(?P<broken>[><]?)")
bar_pattern = re.compile(r'(?P<bar>.*?\|)')

parser = argparse.ArgumentParser()
parser.add_argument('--cols', default=2, type=float,
                    help='number of colums (default %(default)s)')
parser.add_argument('--pagewidth', default=21, type=float,
                    help='width of the page (cm, default %(default)s)')
parser.add_argument('--margin', default=1.5, type=float,
                    help='width of left & right page margin (cm, default %(default)s)')
parser.add_argument('--gutter', default=1, type=float,
                    help='width of the gutter between columns (cm, default %(default)s)')
parser.add_argument('files', nargs='*',
                    help='files to process (default stdin)')
args = parser.parse_args()

col_width = (args.pagewidth-(2 * args.margin)-((args.cols-1) * args.gutter)) / 2
# print(f'rows {args.rows} cols {args.cols} pagewidth {args.pagewidth}')
# print(f'margin {args.margin} gutter {args.gutter} col_width {col_width}')


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

        # print(match.group('note'), match.group('length'), match.group('dot'))

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

        # print(multiplier * default_length)

        total_length += multiplier * default_length

    return total_length


length_so_far = 0
metre = Fraction(4, 4)
default_length = Fraction(1, 16)

tune = -1
in_tune = False

for line in fileinput.input(args.files):

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
        in_tune = False
        print(line, end='')
    # Start of tune
    elif re.match('X:', line):
        in_tune = False
        tune += 1
        # print(f'row {row}, col {col}, page {page}')
        col = tune % args.cols
        left_margin = args.margin+(col * (col_width+args.gutter))
        right_margin = args.margin+((args.cols-col-1) * (col_width+args.gutter))
        if col == 0:
            if tune == 0:
                print('%%newpage')
            elif tune > 0:
                print('%%multicol end')
                print()
            print('%%multicol start')
            print(f'%%rightmargin {right_margin}cm')
            print(f'%%staffwidth {col_width}cm')
        elif col == args.cols-1:
            print('%%multicol new')
            print(f'%%leftmargin {left_margin}cm')
            print(f'%%staffwidth {col_width}cm')
        else:
            print('%%multicol new')
            print(f'%%leftmargin {left_margin}cm')
            print(f'%%rightmargin {right_margin}cm')
            print(f'%%staffwidth {col_width}cm')
        print()
        print(line, end='')
    # Other headers if not in the notes section
    elif re.match('[A-Za-z]:', line) and not in_tune:
        print(line, end='')
    # Comments
    elif re.match('%', line):
        print(line, end='')
    # Notes, and not enough of them
    elif length_so_far < 2*metre:

        in_tune = True

        # print('Metre', metre, 'Default length', default_length, file=sys.stderr)

        # Dump leading bar marker
        line = re.sub(r'\s*\|:?\s*', '', line, count=1)

        for match in bar_pattern.finditer(line):
            bar = match.group('bar')
            # print('Got bar', bar, file=sys.stderr)
            length = bar_length(bar, default_length)
            # print('Length', length, file=sys.stderr)

            print(bar, end='')
            length_so_far += length
            if length_so_far >= 2 * metre:
                break

        print()

print('%%multicol end')
