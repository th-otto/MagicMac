#!/bin/sh
for var in "$@"
do
	dst="$var.ataritext"
#	echo "$dst"
    cp -p "$var" "$dst"
	recode UTF-8..AtariST "$dst"
done
