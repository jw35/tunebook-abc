#!/usr/bin/env python3

'''
Process the command line as a list of files and process each one
in turn. In each file:

  * Replace the sequence !!VERSION!! with the current output of
    `git describe`
  * Replace any line starting '#INCLUDE <filename>' or
    '#INLCUDE: <filename>' while applying these substitutions to that
    file too
'''

import re
import subprocess
import sys

include = re.compile(r'#INCLUDE:?\s*(.*)')
version = re.compile(r'!!VERSION!!')


def get_version():

    result = subprocess.run(['git', 'describe', '--always', '--tags'],
                            text=True, check=True, capture_output=True)
    return result.stdout.rstrip()


def process_file(filename, ver):

    try:
        with open(filename) as file:
            for line in file:
                line = line.rstrip('\n')
                if version.search(line):
                    line = version.sub(ver, line)
                match = include.match(line)
                if match:
                    process_file(match.group(1), ver)
                else:
                    print(line)
    except IOError as e:
        print(e, file=sys.stderr)


def main():

    ver = get_version()

    for filename in sys.argv[1:]:
        process_file(filename, ver)


if __name__ == '__main__':
    main()
