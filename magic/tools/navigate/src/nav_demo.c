/* * Demo-Programm zum Gebrauch der "Nav XCMD" * */#include <stddef.h>#include <stdlib.h>#include <string.h>#include <mgx_dos.h>#include "MGMC_API.H"#include "NAV_XCMD.H"
/*********************************************************************
*
* Ermittelt einen Cookie
*
*********************************************************************/

COOKIE *getcookie(long key)
{
	return((COOKIE *) xbios(39, 'AnKr', 4, key));
}


/*********************************************************************
*
* Zeigt einen Navigation-Dialog
*
*********************************************************************/
int main (void){
	COOKIE *cookie;	MgMcCookie *gMgMcCookie;	XCMDMgrRec *xcmd;	XCMDHdl hdl;
	NGetFileParm gparm;
	NPutFileParm pparm;
	char buf[256];
	long ret;


	cookie = getcookie('MgMc');	if	(!cookie)
		return(-1);
	gMgMcCookie = (MgMcCookie *) cookie->value; 		/* find and open the XCMD */
	xcmd = gMgMcCookie->xcmdMgrPtr;	if	(!xcmd)
		return(-1);
	/* NAV XCMD */
	Cconws("Navigation Services laden...\r\n");
	hdl = xcmd->open("Nav XCMD");
	if	((long)hdl < 0)
		return(-1);		/* Nav XCMD ist nicht installiert */
	gparm.buflen = 256;
	gparm.buf = buf;	Cconws("Bestehende Datei ausw„hlen...\r\n");
	ret = xcmd->call (hdl, xcmdGetFile, &gparm);

	if	(!ret)
		{
		Cconws("Pfad = \"");
		Cconws(buf);
		Cconws("\"");
		}
	else	{
		if	(ret == 1)
			Cconws("Es wurde kein Objekt ausgew„hlt.");
		else	{
			ltoa(ret, buf, 10);
			Cconws("Fehlercode ");
			Cconws(buf);
			}
		}
	Cconws("\r\n");
	Cconin();
	pparm.buflen = 256;
	pparm.buf = buf;	Cconws("Sichern: Neue Datei anw„hlen...\r\n");
	ret = xcmd->call (hdl, xcmdPutFile, &pparm);

	if	(!ret)
		{
		Cconws("Pfad = \"");
		Cconws(buf);
		Cconws("\"");
		}
	else	{
		if	(ret == 1)
			Cconws("Es wurde kein Objekt ausgew„hlt.");
		else	{
			ltoa(ret, buf, 10);
			Cconws("Fehlercode ");
			Cconws(buf);
			}
		}
	Cconws("\r\n");
	Cconin();
	Cconws("Navigation Services freigeben...\r\n");
	xcmd->close (hdl);
	return(0);}