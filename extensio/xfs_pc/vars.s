	.bss

	.globl _strbuf
_strbuf: ds.b 162
	.globl _cont_parse
_cont_parse: ds.w 1
	.globl _vt52_err
_vt52_err: ds.w 1
	.globl _args
_args: ds.l 1
	.globl _strstart
_strstart: ds.l 1
	.globl _strend
_strend: ds.l 1
	.globl _tmpbuf
_tmpbuf: ds.b 82
