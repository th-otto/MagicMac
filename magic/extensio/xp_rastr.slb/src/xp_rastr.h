/*
*
* Binding zum Aufruf von XP_RASTR.SLB
*
*/

/* ermittle Funktionszeiger zur Wandlung */
#define XPRASTER_GETFNS(a,b) (*slb_xpraster_exec)(slb_xpraster, 0L, 4, a, b)
/* neue Farbtabelle Åbergeben */
#define XPRASTER_NEWCOLTAB(a) (*slb_xpraster_exec)(slb_xpraster, 1L, 2, a)
