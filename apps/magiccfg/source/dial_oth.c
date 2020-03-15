#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

void SetMTaskStatus(OBJECT *tree,int status)
{
	if(status)
	{
		tree[OT_MTASK].ob_state|=OS_SELECTED;
		tree[OT_TSL_TIME].ob_state&=~OS_DISABLED;
		tree[OT_TSL_PRIORITY].ob_state&=~OS_DISABLED;
		tree[OT_PRIOR_TXT].ob_state&=~OS_DISABLED;
		tree[OT_PROP_TXT].ob_state&=~OS_DISABLED;
	}
	else
	{
		tree[OT_MTASK].ob_state&=~OS_SELECTED;
		tree[OT_TSL_TIME].ob_state|=OS_DISABLED;
		tree[OT_TSL_PRIORITY].ob_state|=OS_DISABLED;
		tree[OT_PRIOR_TXT].ob_state|=OS_DISABLED;
		tree[OT_PROP_TXT].ob_state|=OS_DISABLED;
	}
}

WORD cdecl HandleOther( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_CLSD )				/* Closer bet„tigt? */
			return(0);
		if ( args.obj == HNDL_OPEN )
		{
			SetMTaskStatus(tree,(int)mgx_tsl_time);

			CopyMaximumChars(&tree[OT_FSEL_MASK],mgx_fsl_mask);

			if(mgx_tsl_time)
				sprintf(tree[OT_TSL_TIME].ob_spec.tedinfo->te_ptext,"%ld",mgx_tsl_time);
			else
				*tree[OT_TSL_TIME].ob_spec.tedinfo->te_ptext=0;
		
			if(mgx_tsl_prior)
				sprintf(tree[OT_TSL_PRIORITY].ob_spec.tedinfo->te_ptext,"%ld",mgx_tsl_prior);
			else
				*tree[OT_TSL_PRIORITY].ob_spec.tedinfo->te_ptext=0;
		
			if(mgx_shl_buf_size==0)
				*tree[OT_SHELL_BUFFER].ob_spec.tedinfo->te_ptext=0;
			else
				sprintf(tree[OT_SHELL_BUFFER].ob_spec.tedinfo->te_ptext,"%ld",mgx_shl_buf_size);

			wdlg_set_edit(args.dialog,OT_FSEL_MASK);
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case OT_MTASK:
				SetMTaskStatus(tree,tree[OT_TSL_TIME].ob_state & OS_DISABLED);
				wdlg_redraw(args.dialog,&rect,OT_SYSTEM,MAX_DEPTH);
				break;
			case OT_OK :
				changed=TRUE;
				mgx_shl_buf_size=atol(tree[OT_SHELL_BUFFER].ob_spec.tedinfo->te_ptext);
				if(tree[OT_MTASK].ob_state & OS_SELECTED)
				{
					mgx_tsl_time=atol(tree[OT_TSL_TIME].ob_spec.tedinfo->te_ptext);
					mgx_tsl_prior=atol(tree[OT_TSL_PRIORITY].ob_spec.tedinfo->te_ptext);
				}
				else
				{
					mgx_tsl_time=0;
					mgx_tsl_prior=0;
				}
				strcpy(mgx_fsl_mask,tree[OT_FSEL_MASK].ob_spec.tedinfo->te_ptext);
			case OT_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}



	
