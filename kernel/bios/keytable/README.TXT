To enable the keyboard translation you should copy the appropriate 
*.sys file to the directory \GEMSYS\MAGIC\XTENSION,
rename it there to KEYTABLS.SYS and reboot.

The source(s) for the table(s) can be taken directly from this
directory (the *.inc files) and compiled using the mktbl.ttp
program.

Currently, only the german table has extra tables for AltGr,
and only the german and french tables have a dead-key table.
