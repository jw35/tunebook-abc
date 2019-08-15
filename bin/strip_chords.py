#!/usr/bin/env python3

'''
Generate a copy of the supplied ABC tune or tunebook with
guitar chords removed
'''

import fileinput
import re

for line in fileinput.input():

    # Blank lines
    if re.fullmatch(r'\s*', line):
        print(line, end='')
    # Headers and comments
    elif re.match('([A-Za-z]:)|%', line):
        print(line, end='')
    # Notes
    else:
        # Remove guitar chords
        line = re.sub(r'".*?"', r'', line)
        print(line, end='')
