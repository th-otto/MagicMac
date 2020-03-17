#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include "defs.h"

WORD cdecl HandleBackground( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_CLSD )				/* Closer bet„tigt? */
			return( 0 );								/* beenden */ 
		if (args.obj == HNDL_OPEN )
		{
			tree[BA_PREVIEW].ob_spec.obspec.fillpattern=(int)(mgx_desk_back>>4);
			tree[BA_PATTERN].ob_spec.obspec.fillpattern=(int)(mgx_desk_back>>4);
			tree[BA_PREVIEW].ob_spec.obspec.interiorcol=(int)(mgx_desk_back&15);
			tree[BA_COLOR].ob_spec.obspec.interiorcol=(int)(mgx_desk_back&15);
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case BA_PATTERN :
			{
			WORD pat,x,y;
				objc_offset(tree,BA_PATTERN,&x,&y);
				pat=form_popup(tree_addr[BACKPAT_POPUP],x+(tree[BA_PATTERN].ob_width>>1),y);
				if(pat!=-1)
				{
					tree[BA_PREVIEW].ob_spec.obspec.fillpattern=pat-BA_P1;
					tree[BA_PATTERN].ob_spec.obspec.fillpattern=pat-BA_P1;
				}
				wdlg_redraw(args.dialog,&rect,BA_PREVIEW,0);
				wdlg_redraw(args.dialog,&rect,BA_PATTERN,0);
				break;
			}
			case BA_COLOR :
			{
			WORD col,x,y;
				objc_offset(tree,BA_COLOR,&x,&y);
				col=form_popup(tree_addr[BACKCOL_POPUP],x+(tree[BA_COLOR].ob_width>>1),y);
				if(col!=-1)
				{
					tree[BA_PREVIEW].ob_spec.obspec.interiorcol=col-BA_COL1;
					tree[BA_COLOR].ob_spec.obspec.interiorcol=col-BA_COL1;
				}
				wdlg_redraw(args.dialog,&rect,BA_PREVIEW,0);
				wdlg_redraw(args.dialog,&rect,BA_COLOR,0);
				break;
			}
			case BA_OK :
				mgx_desk_back=tree[BA_PREVIEW].ob_spec.obspec.fillpattern<<4;
				mgx_desk_back+=tree[BA_PREVIEW].ob_spec.obspec.interiorcol;
				changed=TRUE;
			case BA_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}


