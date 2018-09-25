Andreas Kromke
2018-04-29


Text coding conversion helpers.

atari-utf8.c
				Converts all input files between AtariST coding and UTF-8.
				It does not work "inplace", i.e. does not overwrite the source file,
				but creates new ones with name suffix ".utf8" or ".ataritext".
				Command line switch "-v" tells about each replacement.
				Normally converts from UTF-8 to AtariST.
				Command line switch "-r" converts back from AtariST to UTF-8.
				Do not write "-vr", but "-v -r".

atari-to-utf8.sh
utf8-to-atari.sh

				Shell scripts doing more or less the same, using the "recode" command.
