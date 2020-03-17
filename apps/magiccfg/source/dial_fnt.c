#include <tos.h>
#include <gemx.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "DIALLIB.H"
#include "defs.h"

long	tmp_txs_id, tmp_txs_h,
		tmp_txb_id, tmp_txb_h;

int font_object;
DIALOG *font_dialog;

WORD aes_s;

int GetFont(FONTSEL_DATA *fnts)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(font_dialog,&tree,&rect);

	if(fnts->button==FNTS_OK)
	{
	long size;
		if(fnts->check_boxes & FNTS_SSIZE)	/*	Wenn Gr”sse bewusst ver„ndert wurde...	*/
		{
		_WORD att[10];
			vqt_attributes(vdi_handle,att);
			size=(long)att[7];
		}
		else
			size=0;
#if DEBUG
	{
	short dummy;
	
		vswr_mode(vdi_handle,MD_REPLACE);
		vst_alignment(vdi_handle,2,5,&dummy,&dummy);
		if(size==0)
			vst_height(vdi_handle,aes_s,&dummy,&dummy,&dummy,&dummy);
		else
			vst_height(vdi_handle,(int)size,&dummy,&dummy,&dummy,&dummy);
		vs_clip(vdi_handle,0,&dummy);
		v_gtext(vdi_handle,639,25,fnts_std_text);
	}
#endif
		wdlg_set_edit(font_dialog,0);
		if(tree==tree_addr[FONT])
		{
		_WORD mono,outl,index;
			if(font_object==FO_GNAME)
			{
				tmp_txb_h=size;
				tmp_txb_id=fnts->id;

				sprintf(tree[FO_GHEIGHT].ob_spec.tedinfo->te_ptext,"%ld",tmp_txb_h);

				index=fnts_get_info(fnt_dialog->dialog,tmp_txb_id,&mono,&outl);
				vqt_name(vdi_handle,index,tree[FO_GNAME].ob_spec.free_string);

				if(MagiC_Version<0x520)
				{
					strcpy(tree[FO_SNAME].ob_spec.free_string,tree[FO_GNAME].ob_spec.free_string);
					wdlg_redraw(font_dialog,&rect,FO_SNAME,1);
				}

				tree[FO_GNAME].ob_state&=(~OS_SELECTED);
				wdlg_redraw(font_dialog,&rect,FO_GNAME,1);
				wdlg_redraw(font_dialog,&rect,FO_GHEIGHT,1);
				wdlg_set_edit(font_dialog,FO_GHEIGHT);
			}
			if(font_object==FO_SNAME)
			{
				tmp_txs_h=size;
				tmp_txs_id=fnts->id;

				sprintf(tree[FO_SHEIGHT].ob_spec.tedinfo->te_ptext,"%ld",tmp_txs_h);

				index=fnts_get_info(fnt_dialog->dialog,tmp_txs_id,&mono,&outl);
				vqt_name(vdi_handle,index,tree[FO_SNAME].ob_spec.free_string);

				tree[FO_SNAME].ob_state&=(~OS_SELECTED);
				wdlg_redraw(font_dialog,&rect,FO_SNAME,1);
				wdlg_redraw(font_dialog,&rect,FO_SHEIGHT,1);
				wdlg_set_edit(font_dialog,FO_SHEIGHT);
			}
		}
		else if(tree==tree_addr[WINDOW])
		{
		_WORD mono,outl,index;
			if(font_object==WI_INF_FNAME)
			{
				tmp_inw_fonth=size;
				tmp_inw_fontid=fnts->id;

				sprintf(tree[WI_INF_FH].ob_spec.tedinfo->te_ptext,"%ld",tmp_inw_fonth);

				index=fnts_get_info(fnt_dialog->dialog,tmp_inw_fontid,&mono,&outl);
				vqt_name(vdi_handle,index,tree[WI_INF_FNAME].ob_spec.free_string);

				tree[WI_INF_FNAME].ob_state&=(~OS_SELECTED);
				wdlg_redraw(font_dialog,&rect,WI_INF_FNAME,1);
				wdlg_redraw(font_dialog,&rect,WI_INF_FH,1);
				wdlg_set_edit(font_dialog,WI_INF_FH);
			}
		}
		return(0);
	}
	else if(fnts->button==FNTS_CANCEL)
	{
		tree[font_object].ob_state&=(~OS_SELECTED);
		wdlg_redraw(font_dialog,&rect,font_object,1);
		return(0);
	}
	
	return(1);
}

WORD cdecl HandleFont( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
_WORD index,mono,outl;
_WORD dummy;

	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if ( args.obj < 0 )								/* Ereignis oder Objektnummer? */
	{
		if ( args.obj == HNDL_OPEN )					
		{
			appl_getinfo(0,&aes_s,&dummy,&dummy,&dummy);

			index=fnts_get_info(fnt_dialog->dialog,mgx_txb_id,&mono,&outl);
			tmp_txb_id=mgx_txb_id;
			tmp_txb_h=mgx_txb_h;
			vqt_name(vdi_handle,index,tree[FO_GNAME].ob_spec.free_string);

			index=fnts_get_info(fnt_dialog->dialog,mgx_txs_id,&mono,&outl);
			tmp_txs_id=mgx_txs_id;
			tmp_txs_h=mgx_txs_h;
			vqt_name(vdi_handle,index,tree[FO_SNAME].ob_spec.free_string);
			
			sprintf(tree[FO_GHEIGHT].ob_spec.tedinfo->te_ptext,"%ld",tmp_txb_h);
			sprintf(tree[FO_SHEIGHT].ob_spec.tedinfo->te_ptext,"%ld",tmp_txs_h);
			
			sprintf(tree[FO_AES_OW].ob_spec.tedinfo->te_ptext,"%ld",mgx_obs_ow);
			sprintf(tree[FO_AES_OH].ob_spec.tedinfo->te_ptext,"%ld",mgx_obs_oh);
			
			if(MagiC_Version<0x520)
				tree[FO_SNAME].ob_state|=OS_DISABLED;
			if(MagiC_Version<=0x520)
			{
				tree[FO_AES_OW].ob_state|=OS_DISABLED;
				tree[FO_AES_OH].ob_state|=OS_DISABLED;
			}

			wdlg_set_edit(args.dialog,0);
			wdlg_set_edit(args.dialog,FO_GHEIGHT);
		}
		if ( args.obj == HNDL_CLSD )					/* Closer bet„tigt? = OK*/
			return( 0 );								/* beenden */ 
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case FO_GNAME : 
			{
			_WORD char_h,dummy,i,mode,pt_int=1,set_pt_int;
			long pt=0L;
				font_dialog=args.dialog;
				font_object=args.obj;

				mode=FNTS_CHSIZE;

				tmp_txb_h=atol(tree[FO_GHEIGHT].ob_spec.tedinfo->te_ptext);
				if(!tmp_txb_h)
					tmp_txb_h=(long)aes_s;
				else
					mode|=FNTS_SSIZE;
				
				vst_font(vdi_handle,(int)tmp_txb_id);
/*				printf("\33H\n%ld Pixel \n",tmp_txb_h);
*/				for(i=0;(i<30)&&(!pt);i++)
				{
					set_pt_int=vst_point(vdi_handle,pt_int,&dummy,&char_h,&dummy,&dummy);
/*					printf("%d Points --> %d Pixel \n",set_pt_int,char_h);
*/
					if(char_h==tmp_txb_h)
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
					pt=(((tmp_txb_h)*workout[4])/353)<<16;
				
				if(OpenFontselector(fnt_dialog,mode,tmp_txb_id,pt,0x10000L))
					ModalItem();
				break;
			}
			case FO_SNAME : 
			{
			_WORD char_h,dummy,i,mode,pt_int=1,set_pt_int;
			long pt=0L;

				font_dialog=args.dialog;
				font_object=args.obj;

				mode=FNTS_CHSIZE;

				tmp_txs_h=atol(tree[FO_SHEIGHT].ob_spec.tedinfo->te_ptext);
				if(!tmp_txs_h)
					tmp_txs_h=(long)aes_s;
				else
					mode|=FNTS_SSIZE;
				
				vst_font(vdi_handle,(int)tmp_txs_id);
/*				printf("\33H\n%ld Pixel \n",tmp_txs_h);
*/				for(i=0;(i<10)&&(!pt);i++)
				{
					set_pt_int=vst_point(vdi_handle,pt_int,&dummy,&char_h,&dummy,&dummy);
/*					printf("%d Points --> %d Pixel \n",set_pt_int,char_h);
*/
					if(char_h==tmp_txs_h)
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
					pt=(((tmp_txs_h)*workout[4])/353)<<16;
				
				if(OpenFontselector(fnt_dialog,mode,tmp_txs_id,pt,0x10000L))
					ModalItem();
				break;
			}
			case FO_OK :
				changed = 1;
				mgx_txb_h=atol(tree[FO_GHEIGHT].ob_spec.tedinfo->te_ptext);
				mgx_txs_h=atol(tree[FO_SHEIGHT].ob_spec.tedinfo->te_ptext);
				mgx_txb_id=tmp_txb_id;
				mgx_txs_id=tmp_txs_id;
				fnts_get_info(fnt_dialog->dialog,mgx_txb_id,&mono,&outl);
				if(mono)
					mgx_txb_aqui=1L;
				else
					mgx_txb_aqui=0L;
				fnts_get_info(fnt_dialog->dialog,mgx_txs_id,&mono,&outl);
				if(mono)
					mgx_txs_aqui=1L;
				else
					mgx_txb_aqui=0L;

				mgx_obs_ow=atol(tree[FO_AES_OW].ob_spec.tedinfo->te_ptext);
				mgx_obs_oh=atol(tree[FO_AES_OH].ob_spec.tedinfo->te_ptext);
			
			case FO_CANCEL :
				tree[args.obj].ob_state&=(~OS_SELECTED);
				return(0);
		}
	}
	return( 1 );					/* alles in Ordnung - weiter so */
}
