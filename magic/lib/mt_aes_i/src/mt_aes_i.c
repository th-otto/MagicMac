/****************************************************************
*
*	Tabulatorweite: 5
*
* Mit der Projektdatei mt_aes_i.prj wird eine Bibliothek
* mt_aes_i.lib erzeugt, die der Åblichen mt_aes.lib
* entspricht, aber zusÑtzlich die sys_set-Aufrufe enthÑlt sowie
* die Mîglichkeit, den AES-Aufruf auf den internen
* MagiC-AES-Dispatchers umzuleiten.
*
*
* Anwendung:
* ----------
*
* #include <mt_aes_i.h>
*
* WORD main( ... )
* {
*	... (alle AES-Aufrufe gehen Åber den Trap) ...
*	init_mt_aesi();
*	... (alle AES-Aufrufe gehen jetzt intern ohne Trap) ...
* }
*
****************************************************************/

#include	"mt_aes_i.h"

#ifndef NULL
#define NULL        ((void *)0L)
#endif

/****************************************************************
*
* (0,0)	sys_set_getdisp
*
****************************************************************/

void sys_set_getdisp( void **disp_adr, void **disp_err )
{
	PARMDATA d;
	static WORD c[] = {0,1,0,0};

	d.intin[0] = 0;	/* Subcode 0: AES-Dispatcher ermitteln */
	_mt_aes( &d, c, 0L );
	*disp_adr = d.addrout[0];
	if	(disp_err)
		*disp_err = d.addrout[1];
}


/****************************************************************
*
* (0,1)	sys_set_getfn
*
****************************************************************/

AES_FUNCTION *sys_set_getfn( WORD fn )
{
	PARMDATA d;
	static int16	c[] = {0,2,0,0,1};

	d.intin[0] = 1;	/* Subcode 1: AES-Funktion ermitteln */
	d.intin[1] = fn;	/* Funktionsnummer */
	_mt_aes( &d, c, 0L );
	return((AES_FUNCTION *) d.addrout[0] );
}


/****************************************************************
*
* (0,2)	sys_set_setfn
*
****************************************************************/

WORD sys_set_setfn( WORD fn, AES_FUNCTION *f )
{
	PARMDATA d;
	static int16	c[] = {0,2,1,1};							/* Funktion 0 */

	d.intin[0] = 2;	/* Subcode 2: AES-Funktion Ñndern */
	d.intin[1] = fn;	/* Funktionsnummer */
	d.addrin[0] = (void *) f;
	_mt_aes( &d, c, 0L );
	return( d.intout[0] );
}


/****************************************************************
*
* (0,3)	sys_set_appl_getinfo
*
****************************************************************/

void *sys_set_appl_getinfo( AES_FUNCTION *f )
{
	PARMDATA d;
	static WORD c[] = {0,1,0,1};

	d.intin[0] = 3;	/* Subcode 3: appl_getinfo einklinken */
	d.addrin[0] = (void *) f;
	_mt_aes( &d, c, NULL );
	return(d.addrout[0]);
}


/****************************************************************
*
* (0,5)	sys_set_colourtab
*
****************************************************************/

void sys_set_colourtab( WORD *colourtab )
{
	PARMDATA d;
	static WORD c[] = {0,1,0,1};

	d.intin[0] = 5;	/* Subcode 5: Farbtabelle Åbergeben */
	d.addrin[0] = colourtab;
	_mt_aes( &d, c, NULL );
}
