#!/bin/bash

infile=${1}
outfile=${2}

abcm2ps - -q -i -F flute.fmt -T1 -O - | ps2pdf - -
