#!/usr/bin/env python3

'''
Given the name of a mp3 file in dist/mp3, read title and track
number information from the corresponding file in abc/ and
print the information as `lame` command `lame` arguements
'''

import argparse
import glob
import os
import re
import sys

assert len(sys.argv) > 1, "Usage get_tags.py <mp3 filename>"
mp3_pathname = sys.argv[1]
file_root = os.path.splitext(os.path.basename(mp3_pathname))[0]
assert file_root, "Can't find file root"
abc_pathname = os.path.join('abc', file_root + '.abc')
assert os.path.isfile(abc_pathname), abc_pathname + ' not found'

with open(abc_pathname) as file:
    abc_text = file.read()

    title = ''
    match = re.search(r'^T:\s*(.*?)$', abc_text, re.MULTILINE)
    if match:
        title = match.group(1)
        match = re.search(r'^(.*),\s+(the)$', title, re.IGNORECASE)
        if match:
            title = match.group(2) + ' ' + match.group(1)
        title = re.sub(r'"', r'\\"', title)

all_filenames = sorted(glob.glob('abc/[0-9]*.abc'))

track_no = all_filenames.index(abc_pathname) + 1
n_tracks = len(all_filenames)

print(f'--tt "{title}" --tn "{track_no}/{n_tracks}"')

'''


parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('--ref', action='store_true')
group.add_argument('--title', action='store_true')
parser.add_argument('--paginate', action='store_true')
args = parser.parse_args()

X_match = re.compile(r'^X:\s*(.*?)$', flags=re.MULTILINE)
T_match = re.compile(r'^T:\s*(.*?)$', flags=re.MULTILINE)

songs = []
current_page = None

for filename in glob.glob('abc/[0-9]*.abc'):
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
    if args.ref and args.paginate:
        this_page = song['key'][:3]
        if current_page and current_page != this_page:
            print('%%newpage')
            print()
        current_page = this_page
    print(song['data'])
    print()
'''