#!/bin/sh
for var in "$@"
do
	dst="$var.utf8"
#	echo "$dst"
    cp -p "$var" "$dst"
	recode AtariST..UTF-8 "$dst"
done
