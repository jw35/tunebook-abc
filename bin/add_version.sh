#!/bin/bash

build_version=$(git describe --tags --always)

sed -E "/^%abc-/a\\
% build version ${build_version}\\
"
