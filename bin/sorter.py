#!/usr/bin/env python3

'''
Read all files in abc/[0-9]*.abc and spit out their content
sorted by X: or T: field,. If sorted by X, the output can be
optionally paginated.
'''

import argparse
import glob
import os
import re

parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group(required=True)
parser.add_argument('source', nargs='?', default='abc', help='source directory')
group.add_argument('--ref', action='store_true', help='sort by reference (X) header')
group.add_argument('--title', action='store_true', help='sort by title (T) header')
parser.add_argument('--paginate', action='store_true', help='paginate based on page number encoded in referece')
parser.add_argument('--key-filter', action='append', help='filter out tunes not in indicated key(s)')
args = parser.parse_args()

X_match = re.compile(r'^X:\s*(.*?)$', flags=re.MULTILINE)
T_match = re.compile(r'^T:\s*(.*?)$', flags=re.MULTILINE)
K_match = re.compile(r'^K:\s*(.*?)$', flags=re.MULTILINE)

songs = []
current_page = None

for filename in glob.glob(os.path.join(args.source, '[0-9]*.abc')):
    with open(filename) as file:
        data = file.read()

        if args.ref:
            match = X_match.search(data)
            key = match.group(1)
        elif args.title:
            match = T_match.search(data)
            key = match.group(1).lower()

        songs.append({'key': key, 'data': data})

for song in sorted(songs, key=lambda song: song['key']):

    if args.key_filter:
        match = K_match.search(song['data'])
        if match.group(1) not in args.key_filter:
            continue

    if args.ref and args.paginate:
        this_page = song['key'][:3]
        if current_page and current_page != this_page:
            print('%%newpage')
            print()
        current_page = this_page

    print(song['data'])
    print()
