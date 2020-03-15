#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

WORD cdecl HandleAbout( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )										/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_CLSD )						/* Closer bet„tigt? */
			return( 0 );								/* beenden */ 
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case PR_OK : 
			{
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
			}
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}


