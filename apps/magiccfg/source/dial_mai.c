#include <tos.h>
#include <gemx.h>
#include "DIALLIB.H"
#include "defs.h"

WORD cdecl HandleMain( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree(args.dialog, &tree, &rect);

	if(args.obj<0)
	{
		if(args.obj==HNDL_CLSD)
		{
			ChooseMenu(ME_FILE,ME_QUIT);
			return(0);
		}
		else if(args.obj==HNDL_OPEN)
		{
			BCD_To_ASCII(tree[MA_VERSION].ob_spec.free_string+15,mgx_version);

			if(mgx_flags & LINKS)
			{
				tree[MA_LOGO_RIGHT].ob_state&=~(OS_SELECTED);
				tree[MA_LOGO_LEFT].ob_state|=OS_SELECTED;
			}
			else
			{
				tree[MA_LOGO_LEFT].ob_state&=~(OS_SELECTED);
				tree[MA_LOGO_RIGHT].ob_state|=OS_SELECTED;
			}

			if(mgx_flags & LOOK2D)
				tree[MA_3D_EFFECT].ob_state&=~(OS_SELECTED);
			else
				tree[MA_3D_EFFECT].ob_state|=OS_SELECTED;

			if(mgx_flags & HIDE_BD)
				tree[MA_BACKDROP].ob_state&=~(OS_SELECTED);
			else
				tree[MA_BACKDROP].ob_state|=OS_SELECTED;

			if(mgx_flags & TITEL_PATTERN)
				tree[MA_TITLE_LINES].ob_state&=~(OS_SELECTED);
			else
				tree[MA_TITLE_LINES].ob_state|=OS_SELECTED;

			if(mgx_flags & TITEL_NORMAL)
				tree[MA_TITLE_3D].ob_state&=~(OS_SELECTED);
			else
				tree[MA_TITLE_3D].ob_state|=OS_SELECTED;

			if(mgx_flags & NORM_SCROLL)
				tree[MA_REAL_SCROLL].ob_state&=~(OS_SELECTED);
			else
				tree[MA_REAL_SCROLL].ob_state|=OS_SELECTED;

			if(mgx_flags & NORM_MOVE)
				tree[MA_REAL_MOVE].ob_state&=~(OS_SELECTED);
			else
				tree[MA_REAL_MOVE].ob_state|=OS_SELECTED;

			if(mgx_flags & MENU_3D)
				tree[MA_3D_MENU].ob_state|=OS_SELECTED;
			else
				tree[MA_3D_MENU].ob_state&=~(OS_SELECTED);
			

			if(MagiC_Version<0x510)
				tree[MA_REAL_MOVE].ob_state|=OS_DISABLED;

			if(MagiC_Version<0x520)
				tree[MA_BACKGROUND].ob_state|=OS_DISABLED;

			if(MagiC_Version<=0x520)
			{
				tree[MA_3D_MENU].ob_state|=OS_DISABLED;
				tree[MA_BOOT].ob_state|=OS_DISABLED;
				tree[MA_LIBS].ob_state|=OS_DISABLED;
			}
		}
		else if(args.obj==HNDL_MESG)
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		switch(args.obj)
		{
			case MA_PATH :
				OpenDialog(HandlePath,tree_addr[PATH], string_addr[WDLG_PATH],-1,-1);
				tree[args.obj].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_RESOLUTION :
				OpenDialog(HandleResolution,tree_addr[RESOLUTION], string_addr[WDLG_RES],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_VARIABLES :
				OpenDialog(HandleVariables,tree_addr[VARIABLES], string_addr[WDLG_ENV],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_FONT :
				OpenDialog(HandleFont,tree_addr[FONT], string_addr[WDLG_FONT],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_VFAT :
				OpenDialog(HandleVFat,tree_addr[VFAT], string_addr[WDLG_VFAT],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_OTHER :
				OpenDialog(HandleOther,tree_addr[OTHER], string_addr[WDLG_OTHER],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_BACKGROUND :
				OpenDialog(HandleBackground,tree_addr[BACKGROUND], string_addr[WDLG_BACKGROUND],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_BOOT :
				OpenDialog(HandleBoot,tree_addr[BOOT], string_addr[WDLG_BOOT],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_WINDOW :
				OpenDialog(HandleWindow,tree_addr[WINDOW], string_addr[WDLG_WINDOW],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
			case MA_LIBS :
				OpenDialog(HandleLibraries,tree_addr[LIBRARIES], string_addr[WDLG_LIBRARIES],-1,-1);
				tree[args.dialog].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,args.obj,0);
				break;
		}
	}
	return(1);
}

void GetMainDialogItems(void)
{
	mgx_flags=0;
	if(tree_addr[MAIN][MA_LOGO_LEFT].ob_state&OS_SELECTED)
		mgx_flags|=LINKS;
	if((tree_addr[MAIN][MA_3D_EFFECT].ob_state&OS_SELECTED)==0)
		mgx_flags|=LOOK2D;
	if((tree_addr[MAIN][MA_BACKDROP].ob_state&OS_SELECTED)==0)
		mgx_flags|=HIDE_BD;
	if((tree_addr[MAIN][MA_TITLE_LINES].ob_state&OS_SELECTED)==0)
		mgx_flags|=TITEL_PATTERN;
	if((tree_addr[MAIN][MA_TITLE_3D].ob_state&OS_SELECTED)==0)
		mgx_flags|=TITEL_NORMAL;
	if((tree_addr[MAIN][MA_REAL_SCROLL].ob_state&OS_SELECTED)==0)
		mgx_flags|=NORM_SCROLL;
	if((tree_addr[MAIN][MA_REAL_MOVE].ob_state&OS_SELECTED)==0)
		mgx_flags|=NORM_MOVE;
	if(tree_addr[MAIN][MA_3D_MENU].ob_state&OS_SELECTED)
		mgx_flags|=MENU_3D;
}

