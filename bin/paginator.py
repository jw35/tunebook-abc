#!/usr/bin/env python3

'''
Read a collection of ABC-formatted tunes. Before each new tune,
print '%%newpage' if the first three characters of the 'X:' header
have changed. In this collection of tunes, the first three characters
encode the number of the page that the tune appears on in the printed
tunebook so this process duplicates the layout.
'''

import fileinput
import re

current_page = None

for line in fileinput.input():

    match = re.match(r'X:(\d\d\d)', line)
    if match:
        this_page = match.group(1)
        if current_page and current_page != this_page:
            print('%%newpage')
        current_page = this_page
    print(line, end='')
