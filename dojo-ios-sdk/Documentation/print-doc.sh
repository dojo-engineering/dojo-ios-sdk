#!/bin/sh

# how to use: navigate to this file's folder in terminal and execute ./print-doc.sh

# if script is not working, exectute <chmod u+x {this-file}> in teminal and try again
# remove --no-filename to get filenames printed
grep -rni "^\s*///" ../Classes/* --no-filename