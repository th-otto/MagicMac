/*********************************************************************
*
* Diese Daten enth�lt die Schnittstelle, um von einem Atari-Programm
* aus unter MagicMacX PPC-native Funktionen aufzurufen.
*
*********************************************************************/

typedef INT32(XCMD_CMD)(struct strXCMD *pCmd);
typedef INT32(XCMD_EXEC)(UINT32 SymPtr, void *pParams);

struct MgMxCookieData
/* Befehlsformat f�r XCmd-Kommandos: */
enum eXCMD