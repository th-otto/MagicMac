/*
*
* Dieses Programm erzeugt eine Tastaturtabelle "KEYTABLS.SYS".
* Die Datei muû in gemsys/magic/xtension liegen.
*
* FÅr die US-Tastatur
*
*/

#include <tos.h>

char tab_unshift[128] = {
 0,		/*   0: nicht belegt */
 0x1b,	/*   1: Esc */
 '1',	/*   2: '1' */
 '2',	/*   3: '2' */
 '3',	/*   4: '3' */
 '4',
 '5',
 '6',
 '7',
 '8',
 '9',
 '0',	/*  11: '0' */
 '-',	/*  12: 'û' */
 '=',	/*  13: ''' */
 0x08,	/*  14: Backspace */
 0x09,	/*  15: Tabulator */
 'q',	/*  16: 'Q' */
 'w',
 'e',
 'r',
 't',
 'y',
 'u',
 'i',
 'o',
 'p',
 '[',	/*  26: 'ö' */
 ']',	/*  27: '+' */
 0x0d,	/*  28: Return */
 0,		/*  29: Control */
 'a',
 's',
 'd',
 'f',
 'g',
 'h',
 'j',
 'k',
 'l',	/*  38: 'L' */
 ';',	/*  39: 'ô' */
 0x27,	/*  40: 'é' */
 '`',	/*  41: '#' */
 0,		/*  42: ShiftLinks */
 '\\',	/*  43: '~' 			MF-2: '^' */
 'z',	/*  44: 'Y' */
 'x',	/*  45: 'X' */
 'c',
 'v',
 'b',
 'n',
 'm',
 ',',	/*  51: ',' */
 '.',	/*  52: '.' */
 '/',	/*  53: '-' */
 0,		/*  54: ShiftRechts */
 0,		/*  55: <unbelegt> */
 0,		/*  56: Alternate */
 ' ',	/*  57: SPACE */
 0,		/*  58: CapsLock */
 0,		/*  59: F1 */
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,		/*  68: F10 */
 0,		/*  69: 				MF-2: F11 */
 0,		/*  70:				MF-2: F12 */
 0,		/*  71: Home */
 0,		/*  72: CursorHoch */
 0,		/*  73:				MF-2: BildHoch */
 '-',	/*  74: Num-'-' */
 0,		/*  75: CursorLinks */
 0,		/*  76:				MF-2: AltGr */
 0,		/*  77: CursorRechts */
 '+',	/*  78: Num-'+' */
 0,		/*  79:				MF-2: Ende */
 0,		/*  80: CursorRunter */
 0,		/*  81:				MF-2: BildRunter */
 0,		/*  82: Insert			MF-2: Einfg */
 0x7f,	/*  83: Delete			MF-2: Entf */
 0,		/*  84: Shift-F1 */
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,
 0,		/*  93: Shift-F10 */
 0,		/*  94:				MF-2: Shift-F11 */
 0,		/*  95:				MF-2: Shift-F12 */
 0,		/*  96: '<' */
 0,		/*  97: Undo */
 0,		/*  98: Help */
 '(',	/*  99: Num-'(' */
 ')',	/* 100: Num-')' */
 '/',	/* 101: Num-'/' */
 '*',	/* 102: Num-'*' */
 '7',	/* 103: Num-'7' */
 '8',	/* 104: Num-'8' */
 '9',	/* 105: Num-'9' */
 '4',	/* 106: Num-'4' */
 '5',	/* 107: Num-'5' */
 '6',	/* 108: Num-'6' */
 '1',	/* 109: Num-'1' */
 '2',	/* 110: Num-'2' */
 '3',	/* 111: Num-'3' */
 '0',	/* 112: Num-'0' */
 '.',	/* 113: Num-'.'		MF-2: Num-',' */
 0x0d,	/* 114: Num-Enter */
 0,		/* 115: Ctrl-CursorLinks */
 0,		/* 116: Ctrl-CursorRechts */
 0,		/* 117: <unbelegt> */
 0,		/* 118: <unbelegt> */
 0,		/* 119: Ctrl-Home */
 0,		/* 120: Alt-1 */
 0,		/* 121: Alt-2 */
 0,		/* 122: Alt-3 */
 0,		/* 123: Alt-4 */
 0,		/* 124: Alt-5 */
 0,		/* 125: Alt-6 */
 0,		/* 126: Alt-7 */
 0		/* 127: Alt-8 */
};

char tab_shift[128] = {
 0,
 0x1b,
 '!','@','#','0x','%','^','&','*','(',')','_',
 '+',0x08,0x09,
 'Q','W','E','R','T',
 'Y','U','I','O','P',
 '{','}',0x0d,0,'A','S',
 'D','F','G','H','J','K',
 'L',':','"','~',0,'|','Z','X','C','V',
 'B','N','M','<','>','?',0,0,0,0x20,0,0,0,0,0,0,
 0,0,0,0,0,0,0,'7','8',0,'-','4',0,'6','+',0,
 '2',0,'0',0x7f,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3',
 '0','.',0x0d,0,0,0,0,0,0,0,0,0,0,0,0,0
};

char tab_caps[128] = {
 0,0x1b,'1','2','3','4','5','6','7','8','9','0','-','=',0x08,0x09,
 'Q','W','E','R','T','Y','U','I','O','P','[',']',0x0d,0,'A','S',
 'D','F','G','H','J','K','L',';',0x27,'`',0,'\\','Z','X','C','V',
 'B','N','M',',','.','/',0,0,0,0x20,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0,
 0,0,0,0x7f,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,'(',')','/','*','7','8','9','4','5','6','1','2','3',
 '0','.',0x0d,0,0,0,0,0,0,0,0,0,0,0,0,0
};

#define	XXX	0x20		/* darf nicht belegt werden */
#define	YYY	XXX		/* ist nicht belegt */

char tab_altgr[128] = {
  0,YYY,0xfc,0xfd,0xfe,0xfb,0xae,0xee,0x7b,'[',']',0x7d,'\\',0xf4,YYY,YYY,
  '@',0x8a,0x82,0,0,0x97,0xa3,0xa1,0xa2,0x95,0xb1,0x7e,YYY,XXX,0xa0,0x85,
  0xb0,0x86,0xa6,0,0xc0,0x8d,0xb3,0xb4,0x91,0xf0,XXX,0xf3,0x98,0,0x87,0,
  0,0xa4,0xe6,0xa9,0xfa,0xff,XXX,0,XXX,YYY,XXX,0xc2,0xc3,0xc4,0xc5,0xc6,
  0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,YYY,YYY,0,0xbf,YYY,0,YYY,0xf1,0,
  YYY,0,YYY,YYY,0,0,0,0,0,0,0,0,0,0,0,0,
  0x7c,0xdb,0xda,0,0,0xf6,0xf8,0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,
  0,0xbd,YYY,0,0,0,0,0,0,0,0,0,0,0,0,0
};

char tab_shaltgr[128] = {
  0,YYY,0xad,0xab,0xbb,0xac,0xaf,0xef,0x9b,0x9c,0x9d,0xdf,0xa8,0xf5,0,0,
  0x89,0x88,0x90,0,0,0x96,0,0x8b,0xa7,0x93,0xb8,0xb9,YYY,XXX,0x83,0xb6,
  0xb7,0x8f,0,0,0xc1,0x8c,0xb2,0xb5,0x92,0xf7,XXX,0xf2,0,0,0x80,0,
  0,0xa5,0,0xaa,0x7f,0x9f,XXX,0,XXX,YYY,XXX,0xce,0xcf,0xd0,0xd1,0xd2,
  0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,YYY,YYY,0xbc,0,YYY,0,YYY,0,0,
  YYY,0,YYY,YYY,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0xdc,0,0,0,0xf9,0xe9,0xea,0xeb,0xec,0xed,0,0,0,0,
  0,0xbe,YYY,0,0,0,0,0,0,0,0,0,0,0,0,0
};

char tab_alt[128] = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

char tab_shalt[128] = {
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};


int main( void )
{
	long ret;
	int hdl;

	ret = Fcreate("KEYTABLS.SYS", 0);
	hdl = (int) ret;
	if	(ret < 0)
		return(hdl);

	ret = Fwrite(hdl, 128L, tab_unshift);
	if	(ret != 128L)
		{
		 wr_err:
		Fclose(hdl);
		Fdelete("KEYTABLS.SYS");
		return(-1);
		}
	ret = Fwrite(hdl, 128L, tab_shift);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_caps);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_altgr);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_shaltgr);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_altgr);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_alt);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_shalt);
	if	(ret != 128L)
		goto wr_err;
	ret = Fwrite(hdl, 128L, tab_alt);
	if	(ret != 128L)
		goto wr_err;

	Fclose(hdl);
	return(0);
}
