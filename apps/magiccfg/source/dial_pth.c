#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include "defs.h"


WORD cdecl HandlePath( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
int i;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_OPEN )
		{
			for(i=0;i<6;i++)
				CopyMaximumChars(&tree[PA_SCRAP+i],&mgx_Pfade[i][0]);

			wdlg_set_edit(args.dialog,0);
			wdlg_set_edit(args.dialog,PA_SCRAP);
		}
		if ( args.obj == HNDL_CLSD )					/* Closer bet„tigt? */
			return( 0 );								/* beenden */ 
		if (args.obj == HNDL_EDCH )
		{
			if((args.events->mclicks==2)&&(args.events->mbutton==1))
			{
				args.obj=*(int *)args.data;
				file_dialog=args.dialog;
				file_object=args.obj;
				switch(args.obj)
				{
					case PA_SCRAP :
					case PA_ACC :
					case PA_START :
						if(OpenFileselector(GetFolder,string_addr[FSEL_GETFOLDER],
								tree_addr[PATH][args.obj].ob_spec.tedinfo->te_ptext,
								std_paths,file_mask,0))
							ModalItem();
						break;
					case PA_SHELL :
					case PA_AUTO :
					case PA_TERMINAL :
						if(OpenFileselector(GetFile,string_addr[FSEL_GETAPPL],
								tree_addr[PATH][args.obj].ob_spec.tedinfo->te_ptext,
								std_paths,file_mask,0))
							ModalItem();
						break;
				}
			}
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case PA_OK : 
				for(i=0;i<6;i++)
					strcpy(&mgx_Pfade[i][0],tree[i+PA_SCRAP].ob_spec.tedinfo->te_ptext);
				changed=TRUE;
			case PA_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}

