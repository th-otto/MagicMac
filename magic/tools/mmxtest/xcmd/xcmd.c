/*********************************************************************
*
* Beispielprogramm zum Aufruf einer nativen MacOS-Funktion von
* MagicMacX aus.
*
*********************************************************************/


#include <mgx_dos.h>
#include <stdio.h>
#include <string.h>

typedef unsigned long UINT32;
typedef long INT32;
typedef unsigned char UINT8;

#include "mmx_xcmd.h"

XCMD_CMD *pXCMD_CMD;
XCMD_EXEC *pXCMD_EXEC;

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
* Initialisieren der beiden Funktionszeiger.
* Der erste verwaltet die Bibliothek, der zweite ruft
* Bibliotheksfunktionen auf.
*
*********************************************************************/

long init(void)
{
	COOKIE *pMMXCookie;
	struct MgMxCookieData *pMMXCookieData;

	pMMXCookie = getcookie('MgMx');
	if	(!pMMXCookie)
	{
		printf("MgMx-Cookie nicht gefunden");
		return(-1);
	}

	pMMXCookieData = (struct MgMxCookieData *) pMMXCookie->value;
	if	(pMMXCookieData->mgmx_magic != 'MgMx')
		return(-2);

	pXCMD_CMD = pMMXCookieData->mgmx_xcmd;
	pXCMD_EXEC = pMMXCookieData->mgmx_xcmd_exec;

	return(0);
}


/*********************************************************************
*
* Hauptprogramm
*
*********************************************************************/

struct structAtariData{	char input[256];	char output[256];};
int main(void)
{
	struct strXCMD cmd;
	long ret;
	struct structAtariData Data;
	UINT32 SymPtr;


	ret = init();
	if	(ret)
		return((int) ret);

	cmd.m_cmd = eXCMDVersion;
	ret = pXCMD_CMD(&cmd);
	printf("XCMD-Version = %ld\n", ret);

	cmd.m_cmd = eXCMDMaxCmd;
	ret = pXCMD_CMD(&cmd);
	printf("XCMD-MaxFn = %ld\n", ret);

/*
 Die Funktion liegt in einer "shared library"
 mit Namen "SampleSharedLibraryDEBUG".
 Das ist nicht der Dateiname, sondern der beim Linken
 der Bibliothek angegebene Bibliothekname
*/
	cmd.m_cmd = eXCMDLoadByLibName;
	strcpy(cmd.u.m_10_11.m_PathOrName, "SampleSharedLibraryDEBUG");
	ret = pXCMD_CMD(&cmd);
	printf("XCMD-LoadByLibName => %ld\n", ret);
	if	(ret < 0)
		return((int) ret);
	printf("XCMD-nSymbols = %ld\n", cmd.u.m_10_11.m_nSymbols);
	printf("XCMD-LibHandle = %ld\n", cmd.m_LibHandle);

	cmd.m_cmd = eXCMDGetSymbolByName;
	strcpy(cmd.u.m_12_13.m_Name, "MyFunctionTakesStruct");
	ret = pXCMD_CMD(&cmd);
	printf("XCMD-GetSymbolByName => %ld\n", ret);
	if	(ret < 0)
	{
		printf("Symbol nicht gefunden");
		return((int) ret);
	}

	SymPtr = cmd.u.m_12_13.m_SymPtr;

	printf("XCMD-SymPtr = %08lxlx\n", SymPtr);
	printf("XCMD-SymClass = %ld\n", (UINT32) cmd.u.m_12_13.m_SymClass);

	strcpy(Data.input, "Helau");
	ret = pXCMD_EXEC(SymPtr, &Data);
	printf("EXEC => %08lx\n", ret);
	printf("output = %s\n", Data.output);

	strcpy(Data.input, "Hallo, hier spricht der Atari");
	ret = pXCMD_EXEC(SymPtr, &Data);
	printf("EXEC => %08lx\n", ret);
	printf("output = %s\n", Data.output);

	return(0);
}