#!/bin/bash

cd abc

for file in *.abc
do
    echo ${file}...
    ../mkpdf.sh <${file} >../pdf/${file%.abc}.pdf
done
