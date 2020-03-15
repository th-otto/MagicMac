#include <tos.h>
#include <gemx.h>
#include <mint\cookie.h>
#include "DIALLIB.H"
#include "defs.h"


long MagiC_Version;
unsigned long MagiC_Date;

FONTSEL_DATA *fnt_dialog;

/*************************************************************/
int CheckSystem(void)
{
_WORD	funcs;
_WORD	dummy;
AESVARS *aesvars;
MAGX_COOKIE *cookie=NULL;

	if(Getcookie('MagX', (void *)&cookie))		/*	MagiC-Cookie suchen	*/
	{
		form_alert(1,string_addr[NO_MAGIC_FOUND]);	/*	Meldung	*/
		return(TRUE);									/*	nicht da ? -> tschss	*/
	}
	aesvars=cookie->aesvars;						/*	Aesvars holen	*/
	if(!aesvars)										/*	NULL ? -> tschss	*/
	{
		form_alert(1,string_addr[NO_MAGIC_VARS]);		/*	Meldung	*/
		return(TRUE);
	}
	
	MagiC_Date=aesvars->date << 16L;				/*	MagiC-Versionsdatum aufbauen	*/
	MagiC_Date|=aesvars->date >> 24L;
	MagiC_Date|=(aesvars->date >> 8L) & 0xff00L;

	MagiC_Version=aesvars->version;				/*	Versionsnummer	*/

	if(MagiC_Version<0x0500)						/*	Version < 5.00 ? */
	{
		form_alert(1,string_addr[NO_MAGIC_FOUND]);	/*	Meldung	*/
		return(TRUE);									/*	und tschss	*/
	}

	if(appl_find("?AGI")==0)						/*	appl_getinfo() vorhanden ?	*/
	{
		if(appl_getinfo(7,&funcs,&dummy,&dummy,&dummy ))	/* Unterfunktion 7 aufrufen */
		{
			if((funcs&0x07) == 0x07)				/* wdlg_xx()/lbox_xx()/fnts_xx() vorhanden? */
				return(FALSE);							/*	Alles OK	*/
		}	
	}
	form_alert(1,tree_addr[DIAL_LIBRARY][DI_WDIALOG_ERROR].ob_spec.free_string);
	return(TRUE);
}

int CreateFNTS(void)
{
	if(MagiC_Version>0x520)
		fnt_dialog=CreateFontselector(GetFont,FNTS_BTMP|FNTS_OUTL|FNTS_MONO|FNTS_PROP,string_addr[FNTS_SAMPLE],NULL);
	else
		fnt_dialog=CreateFontselector(GetFont,FNTS_BTMP|FNTS_MONO,string_addr[FNTS_SAMPLE],NULL);

	if(fnt_dialog==NULL)
	{
		form_alert(1,string_addr[NO_FNT_DIALOG]);
		return(TRUE);
	}
	return(FALSE);
}
/*************************************************************/
