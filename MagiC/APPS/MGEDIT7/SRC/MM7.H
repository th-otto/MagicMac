/* * Schnittstelle zur Spezialversion von MagiCMac
 * (Åber "Men XCMD" und "Nav XCMD". *
 * bietet:
 *	- MenÅs
 *	- Hintergrund
 *	- Dateiauswahl
 *	- Programmbeendigung */
/* Command-Taste */
#define K_CMD           0x0020

extern LONG MgMc7Init (void);extern LONG MgMc7Exit (void);extern LONG MgMc7InitMenuBar( char *fname, short rscno, OBJECT *tree );extern LONG MgMc7DrawMenuBar( void );extern LONG MgMc7NavGetFile( char *buf, int buflen );
extern LONG MgMc7NavPutFile( char *buf, int buflen );
extern LONG MgMc7DoMouseClick(int mx, int my, int *menu, int *entry);
extern LONG MgMc7MenuHilite(int menu);
extern LONG MgMc7EnableItem(int menu, int item);
extern LONG MgMc7DisableItem(int menu, int item);
extern void MgMc7Shutdown( void );