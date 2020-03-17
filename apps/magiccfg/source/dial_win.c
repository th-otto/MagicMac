#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

long tmp_inw_fontid, tmp_inw_fonth;

WORD cdecl HandleWindow( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
WORD index,mono,outl;
	wdlg_get_tree( args.dialog, &tree, &rect );	/* Adresse des Baums erfragen */

	if ( args.obj < 0 )							/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_CLSD )			/* Closer bet„tigt? */
			return(0);
		if ( args.obj == HNDL_OPEN )
		{
			tmp_inw_fontid=mgx_inw_fontid;
			tmp_inw_fonth=mgx_inw_fonth;
			index=fnts_get_info(fnt_dialog->dialog,tmp_inw_fontid,&mono,&outl);
			vqt_name(vdi_handle,index,tree[WI_INF_FNAME].ob_spec.free_string);
			
			sprintf(tree[WI_INF_FH].ob_spec.tedinfo->te_ptext,"%ld",tmp_inw_fonth);
			sprintf(tree[WI_INF_HEIGHT].ob_spec.tedinfo->te_ptext,"%ld",mgx_inw_objh);
			sprintf(tree[WI_WIN_CNT].ob_spec.tedinfo->te_ptext,"%ld",mgx_win_cnt);
			
			if(mgx_win_cnt==0)
				*tree[WI_WIN_CNT].ob_spec.tedinfo->te_ptext=0;

			if(MagiC_Version<=0x520)
			{
				tree[WI_INF_HEIGHT].ob_state|=OS_DISABLED;
				tree[WI_INF_FNAME].ob_state|=OS_DISABLED;
				tree[WI_INF_FH].ob_state|=OS_DISABLED;
			}

			wdlg_set_edit(args.dialog,0);
			wdlg_set_edit(args.dialog,WI_WIN_CNT);
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case WI_INF_FNAME :
			{
			WORD char_h,dummy,i,mode,pt_int=1,set_pt_int;
			long pt=0L;
			WORD aes_s;
				appl_getinfo(0,&aes_s,&dummy,&dummy,&dummy);
				font_dialog=args.dialog;
				font_object=args.obj;

				mode=FNTS_CHSIZE;

				tmp_inw_fonth=atol(tree[WI_INF_FH].ob_spec.tedinfo->te_ptext);
				if(!tmp_inw_fonth)
					tmp_inw_fonth=(long)aes_s;
				else
					mode|=FNTS_SSIZE;
				
				vst_font(vdi_handle,(int)tmp_inw_fontid);
/*				printf("\33H\n%ld Pixel \n",tmp_inw_fonth);
*/				for(i=0;(i<30)&&(!pt);i++)
				{
					set_pt_int=vst_point(vdi_handle,pt_int,&dummy,&char_h,&dummy,&dummy);
/*					printf("%d Points --> %d Pixel \n",set_pt_int,char_h);
*/
					if(char_h==tmp_inw_fonth)
						pt=((long)(set_pt_int)<<16);
					else
					{
					int j=0;
						while((vst_point(vdi_handle,++pt_int,&dummy,&char_h,&dummy,&dummy)==set_pt_int)&&
								(j++<10))
							;
					}
				}
				if(!pt)
					pt=(((tmp_inw_fonth)*workout[4])/353)<<16;
				
				if(OpenFontselector(fnt_dialog,mode,tmp_inw_fontid,pt,0x10000L))
					ModalItem();
				break;
			}
			case WI_OK :
				changed=TRUE;
				mgx_win_cnt=atol(tree[WI_WIN_CNT].ob_spec.tedinfo->te_ptext);

				mgx_inw_objh=atol(tree[WI_INF_HEIGHT].ob_spec.tedinfo->te_ptext);
				mgx_inw_fonth=atol(tree[WI_INF_FH].ob_spec.tedinfo->te_ptext);
				mgx_inw_fontid=tmp_inw_fontid;

				fnts_get_info(fnt_dialog->dialog,mgx_inw_fontid,&mono,&outl);
				if(mono)
					mgx_inw_mflag=1L;
				else
					mgx_inw_mflag=0L;

			case WI_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );										/* alles in Ordnung - weiter so */
}



	
