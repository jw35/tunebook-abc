#!/bin/sh

for f in dist/midi/*.midi; do
    echo -n "${f}, ";
    midicsv ${f} | egrep '^2' | grep Note_on_c | wc -l;
done > note-counts.csv