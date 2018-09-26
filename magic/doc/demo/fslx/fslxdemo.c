/*******************************************************************
*
*             FSLXDEMO                    	         5.11.95
*             ========
*
* geschrieben mit Pure C V1.1
* Projektdatei: FSLXDEMO.PRJ
*
* Demonstrationsprogramm fÅr die erweiterten Dateiauswahl-
* Funktionen von MagiC 4.
* Der Test (appl_getinfo), ob die Funktionen vorhanden sind,
* ist in fslx_txt beschrieben.
*
* Andreas Kromke
*  20.11.95
*
****************************************************************/

#include <tos.h>
#include <aes.h>
#include <string.h>
#include <stdlib.h>

#ifndef NULL
#define NULL ((void *) 0)
#endif


int main( void )
{
	char pathbuf[128];
	char fname[33];
	int	result;
	int button,sortmode;
	int nfiles;
	char *pattern;
	void *fsel_dialog;
	int whdl;
	EVNT evnt;


	if   ((appl_init()) < 0)
		Pterm(-1);

	/* Aufruf */
	/* ------ */

	strcpy(fname, "initname");
	strcpy(pathbuf, "E:\\BIN\\");


	if	(1 == form_alert(1, "[2][Modus ?][Fenster|Dialog]"))
		{
		fsel_dialog = fslx_open(
					" Titel ",
					-1,-1,
					&whdl,
					pathbuf, 128,
					fname, 33,
					"*.PRG,*.APP\0"
					"*.TOS,*.TTP\0"
					"*\0",
					0L,			/* kein Filter */
					"C:\\\0"
					"D:\\01234567890\\ABCDE\\3434343434343434\\FGHIJKLMN\\abcdefghijklmn\\\0"
					"E:\\BIN\\01234567890\\ABCDE\\3434343434343434\\FGHIJKLMN\\abcdefghijklmn\\\0"
					"U:\\BIN\\ABCDEF\\ftt\\dfdfdfdfdf\\GHIJKLMN\\01234567890\\abcdefghijklmn\\\0"
					"C:\\BIN\\01234567890\\abcdefghijklmn\\\0"
					"C:\\GEMSYS\\MAGIC\\XTENSION\\\0"
					"U:\\DEV\\\0",
					SORTBYNAME,
					GETMULTI
				);
		if	(fsel_dialog)
			{
			do	{
				evnt.mwhich = evnt_multi(
						MU_KEYBD+MU_BUTTON+MU_MESAG,
						2,1,1,
						0,NULL,
						0,NULL,
						evnt.msg,
						0L,
						(EVNTDATA*) &(evnt.mx),
						&evnt.key,
						&evnt.mclicks);
				result = fslx_evnt(
						fsel_dialog,
						&evnt,
						pathbuf,
						fname,
						&button,
						&nfiles,
						&sortmode,
						&pattern);
				}
			while(result);
			form_alert(1, (button) ? "[0][OK betÑtigt.][OK]" :
								"[0][Abbruch betÑtigt.][OK]");
			}
		}
	else	{

		sortmode = SORTBYNAME;
		fsel_dialog = fslx_do(
				"mein Titel",
				pathbuf, 128,
				fname, 33,
/*
				"*.PRG,*.APP\0"
				"*.TOS,*.TTP\0"
*/
				"*\0",
				0L,				/* kein Filter */
				"C:\\\0"
				"U:\\BIN\\\0"
				"U:\\DEV\\\0",
				&sortmode,
				0,
				&button,
				&nfiles,
				&pattern
				);
		}

	if	(fsel_dialog)
		fslx_close(fsel_dialog);

	appl_exit();
	return(0);
}
