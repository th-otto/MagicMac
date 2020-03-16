#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

WORD cdecl HandleVFat( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
int i;
long bitset;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if (args.obj == HNDL_OPEN )
		{
		long drives;
			drives=Dsetdrv((int)Dgetdrv());
			bitset=1L;
			for(i=0;i<26;i++)
			{
				if(mgx_vfat_drives&bitset)
					tree[VF_DRIVE_A+i].ob_state|=OS_SELECTED;
				else
					tree[VF_DRIVE_A+i].ob_state&=~OS_SELECTED;
				if(drives&bitset)
					tree[VF_DRIVE_A+i].ob_state&=~OS_DISABLED;
				else
					tree[VF_DRIVE_A+i].ob_state|=OS_DISABLED;
				bitset=bitset<<1;
			}
		}
		if ( args.obj == HNDL_CLSD )				/* Closer bet„tigt? */
			return( 0 );							/* beenden */ 
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case VF_OK :
				bitset=1L;
				for(i=0;i<26;i++)
				{
					if(tree[VF_DRIVE_A+i].ob_state&OS_SELECTED)
						mgx_vfat_drives|=bitset;
					else
						mgx_vfat_drives&=~bitset;
					bitset=bitset<<1;
				}
				changed=TRUE;
			case VF_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}


