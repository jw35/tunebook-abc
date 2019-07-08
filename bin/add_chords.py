#!/usr/bin/env python3

'''
Generate a copy of the supplied ABC tune or tunebook with the
guitar chords replicated as decorations for the benefit of
'guitarchords.fmt'
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
        # Replace guitar chord with the cord, any existing decorations,
        # and then the chord expressed as a decoration
        line = re.sub(r'"(.*?)"((?:!.*?!)*)', r'"\1"\2!\1!', line)
        print(line, end='')
