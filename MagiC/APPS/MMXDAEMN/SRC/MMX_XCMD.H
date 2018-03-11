/*********************************************************************
*
* Diese Daten enth„lt die Schnittstelle, um von einem Atari-Programm
* aus unter MagicMacX PPC-native Funktionen aufzurufen.
*
*********************************************************************/

typedef INT32(XCMD_CMD)(struct strXCMD *pCmd);
typedef INT32(XCMD_EXEC)(UINT32 SymPtr, void *pParams);
typedef INT32(MMX_DAEMN)(UINT16 cmd, void *pParams);

struct MgMxCookieData
{
	UINT32	mgmx_magic;		/* ist "MgMx" */
	UINT32	mgmx_version;		/* Versionsnummer */
	UINT32	mgmx_len;			/* Strukturl¥nge */
	XCMD_CMD	*mgmx_xcmd;		/* PPC-Bibliotheken laden und verwalten */
	XCMD_EXEC	*mgmx_xcmd_exec;	/* PPC-Aufruf aus PPC-Bibliothek */
	UINT32	mgmx_internal;
	MMX_DAEMN *mgmx_daemon;
};

/* Befehlsformat fr XCmd-Kommandos: */struct strXCMD{	UINT32	m_cmd;		/* ->	Kommando */	UINT32	m_LibHandle;	/* <->	Connection-ID (je nach Kommando IN oder OUT) */	UINT32	m_MacError;	/* ->	Mac-Fehlercode */	union	{		struct		{			char m_PathOrName[256];	/* ->	Pfad (Kommando 10) oder Name */			INT32 m_nSymbols;		/* <-	Anzahl Symbole beim ™ffnen */		} m_10_11;		struct		{			UINT32 m_Index;		/* ->	Index (Kommando 13) */			char m_Name[256];		/* ->	Symbolname (Kommando 12) */								/* <-	Symbolname (Kommando 13) */			UINT32 m_SymPtr;		/* <-	Zeiger auf Symbol */			UINT8 m_SymClass;		/* <-	Symboltyp */		} m_12_13;	}u;};
enum eXCMD{	eXCMDVersion = 0,	eXCMDMaxCmd = 1,	eXCMDLoadByPath = 10,	eXCMDLoadByLibName = 11,	eXCMDGetSymbolByName = 12,	eXCMDGetSymbolByIndex = 13,	eUnLoad = 14};