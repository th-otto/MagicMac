#include <tos.h>
#include <falcon.h>
#include <gemx.h>
#include <mint/cookie.h>
#include "diallib.h"
#include "defs.h"


/*
	Listbox-Verwaltungs-Prozeduren
*/
WORD cdecl res_set_item( struct SET_ITEM_args );
void	cdecl	res_select_item( struct SLCT_ITEM_args );


#define	CD_NA		0
#define	CD_2		1
#define	CD_4		2
#define	CD_16		3
#define	CD_256	4
#define	CD_32K	5
#define	CD_65K	6
#define	CD_16M	7
#define	CD_MAX	CD_16M

char *Colordepth[]=
	{
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	};

int tmp_col;

static char *st_high;
static char *tt_high;
static char *st_med;
static char *st_low;
static char *tt_med;
static char *tt_low;
static char *f64_48="640x480";
static char *f64_24="640x240";
static char *f64_40="640x400";
static char *f64_20="640x200";
static char *f32_48="320x480";
static char *f32_24="320x240";
static char *f32_40="320x400";
static char *f32_20="320x200";

static char *f76_48="768x480";
static char *f76_24="768x240";
static char *f38_48="384x480";
static char *f38_24="384x240";
		
static char *fnull="";
		

typedef struct
{
	char **name;
	int mode;
}A_RESO;

static A_RESO vga_tab[]=
{
	{&st_high,BPS1|VGA|STMODES|COL80},
	{&st_med,BPS2|VGA|STMODES|COL80|VERTFLAG},
	{&st_low,BPS4|VGA|STMODES|COL40},

	{&f64_48,BPS1|VGA|COL80},
	{&f64_24,BPS1|VGA|COL80|VERTFLAG},

	{&f64_48,BPS2|VGA|COL80},
	{&f64_24,BPS2|VGA|COL80|VERTFLAG},
	{&f32_48,BPS2|VGA|COL40},
	{&f32_24,BPS2|VGA|COL40|VERTFLAG},

	{&tt_med,BPS4|VGA|COL80},
	{&f64_24,BPS4|VGA|COL80|VERTFLAG},
	{&f32_48,BPS4|VGA|COL40},
	{&f32_24,BPS4|VGA|COL40|VERTFLAG},

	{&f64_48,BPS8|VGA|COL80},
	{&f64_24,BPS8|VGA|COL80|VERTFLAG},
	{&tt_low,BPS8|VGA|COL40},
	{&f32_24,BPS8|VGA|COL40|VERTFLAG},

	{&f32_48,BPS16|VGA|COL40|VERTFLAG},
	{&f32_24,BPS16|VGA|COL40},
	{&fnull,-1}
};

A_RESO rgb_tab[]=
{
	{&f76_48,BPS1|TV|PAL|COL80|VERTFLAG|OVERSCAN},
	{&st_high,BPS1|TV|PAL|COL80|VERTFLAG|STMODES},
	{&f76_24,BPS1|TV|PAL|COL80|OVERSCAN},
	{&f64_20,BPS1|TV|PAL|COL80},

	{&f76_48,BPS2|TV|PAL|COL80|VERTFLAG|OVERSCAN},
	{&f64_40,BPS2|TV|PAL|COL80|VERTFLAG},
	{&f76_24,BPS2|TV|PAL|COL80|OVERSCAN},
	{&st_med,BPS2|TV|PAL|COL80|STMODES},
	{&f38_48,BPS2|TV|PAL|COL40|VERTFLAG|OVERSCAN},
	{&f32_40,BPS2|TV|PAL|COL40|VERTFLAG},
	{&f38_24,BPS2|TV|PAL|COL40|OVERSCAN},
	{&f32_20,BPS2|TV|PAL|COL40},

	{&f76_48,BPS4|TV|PAL|COL80|VERTFLAG|OVERSCAN},
	{&f64_40,BPS4|TV|PAL|COL80|VERTFLAG},
	{&f76_24,BPS4|TV|PAL|COL80|OVERSCAN},
	{&f64_20,BPS4|TV|PAL|COL80},
	{&f38_48,BPS4|TV|PAL|COL40|VERTFLAG|OVERSCAN},
	{&f32_40,BPS4|TV|PAL|COL40|VERTFLAG},
	{&f38_24,BPS4|TV|PAL|COL40|OVERSCAN},
	{&st_low,BPS4|TV|PAL|COL40|STMODES},

	{&f76_48,BPS8|TV|PAL|COL80|VERTFLAG|OVERSCAN},
	{&f64_40,BPS8|TV|PAL|COL80|VERTFLAG},
	{&f76_24,BPS8|TV|PAL|COL80|OVERSCAN},
	{&f64_20,BPS8|TV|PAL|COL80},
	{&f38_48,BPS8|TV|PAL|COL40|VERTFLAG|OVERSCAN},
	{&f32_40,BPS8|TV|PAL|COL40|VERTFLAG},
	{&f38_24,BPS8|TV|PAL|COL40|OVERSCAN},
	{&f32_20,BPS8|TV|PAL|COL40},

	{&f76_48,BPS16|TV|PAL|COL80|VERTFLAG|OVERSCAN},
	{&f64_40,BPS16|TV|PAL|COL80|VERTFLAG},
	{&f76_24,BPS16|TV|PAL|COL80|OVERSCAN},
	{&f64_20,BPS16|TV|PAL|COL80},
	{&f38_48,BPS16|TV|PAL|COL40|VERTFLAG|OVERSCAN},
	{&f32_40,BPS16|TV|PAL|COL40|VERTFLAG},
	{&f38_24,BPS16|TV|PAL|COL40|OVERSCAN},
	{&f32_20,BPS16|TV|PAL|COL40},
	{&fnull,-1}
};

#define	NO_VIS_RES	10
int res_ctrl[5] = { RE_BOX, RE_UP, RE_DOWN, RE_BACK, RE_WHITE };
int res_objs[NO_VIS_RES] = { RE_00, RE_01, RE_02, RE_03, RE_04, RE_05, RE_06, RE_07, RE_08, RE_09 };

LIST_BOX	*res_box;

typedef struct _res_var
{
	struct _res_var *next;
	int	selected;
	char	str[30];
	int	dev, mode;
}RES_VAR;

RES_VAR	*ResVar=NULL;

void NewEntry(char *txt, int device, int mode)
{
RES_VAR *ptr=ResVar;
long ret;
	ret=(long)Mxalloc(sizeof(RES_VAR),3);
	if(ret==0)
		return;
	
	if(ptr==NULL)
	{
		ptr=(RES_VAR *)ret;
		ResVar=ptr;
	}
	else
	{
		while(ptr->next)
			ptr=ptr->next;
		ptr->next=(RES_VAR *)ret;
		ptr=ptr->next;
	}
	ptr->next=NULL;
	ptr->selected=0;
	ptr->dev=device;
	ptr->mode=mode;
	strcpy(ptr->str,txt);
}


RES_VAR *Largest(RES_VAR *Selected)
{
RES_VAR *This;

	if(!Selected)
		return(NULL);

	This=Selected->next;
	while(This)
	{
		if(strcmp(Selected->str,This->str)<0)
			Selected=This;
		This=This->next;
	}
	return(Selected);
}

void Remove(RES_VAR *This)
{
RES_VAR *ptr=ResVar;
	if(This==NULL)
		return;
	if(ResVar==This)
		ResVar=ResVar->next;
	else
	{
		while(ptr)
		{
			if(ptr->next==This)
				ptr->next=ptr->next->next;
			ptr=ptr->next;
		}
	}
}

RES_VAR *Sort(void)
{
RES_VAR *First=NULL, *Next=NULL;

	First=Largest(ResVar);

	Remove(First);

	Next=First;

	while(Next)
	{
		Next->next=Largest(ResVar);
		Next=Next->next;
		Remove(Next);
	};

	return(First);
}


void CreateColors(int colors)
{
long value;
int vdo;
	if(Getcookie('_VDO',&value))
	{
		NewEntry(string_addr[NO_RESOLUTION], -1, -1);
		return;
	}

	st_high = string_addr[FS_ST_HIGH];
	tt_high = string_addr[FS_TT_HIGH];
	st_med = string_addr[FS_ST_MED];
	st_low = string_addr[FS_ST_LOW];
	tt_med = string_addr[FS_TT_MED];
	tt_low = string_addr[FS_TT_LOW];

	vdo=*(int *)&value;

	if(vdo<2)								/*	ST oder STE	*/
	{
		switch(colors)
		{
			case CD_2 :
				NewEntry(st_high, 4, 0);
				break;
			case CD_4 :
				NewEntry(st_med, 3, 0);
				break;
			case CD_16 :
				NewEntry(st_low, 2, 0);
				break;
		}
	}
	if(vdo==2)								/*	TT	*/
	{
		switch(colors)
		{
			case CD_2 :
				NewEntry(st_high, 4, 0);
				NewEntry(tt_high, 8, 0);
				break;
			case CD_4 :
				NewEntry(st_med, 3, 0);
				break;
			case CD_16 :
				NewEntry(st_low, 2, 0);
				NewEntry(tt_med, 6, 0);
				break;
			case CD_256 :
				NewEntry(tt_low, 9, 0);
				break;
		}
	}
	if(vdo==3)								/*	Falcon	*/
	{
	int mtype, fcolor;
		mtype=VgetMonitor();
		
		switch(colors)
		{
			case CD_2:
				fcolor=BPS1;
				break;
			case CD_4:
				fcolor=BPS2;
				break;
			case CD_16:
				fcolor=BPS4;
				break;
			case CD_256:
				fcolor=BPS8;
				break;
			case CD_32K:
				fcolor=BPS16;
				break;
		}

		if(mtype==0)
		{
			if(colors==CD_2)
				NewEntry(st_high, 5, STMODES|COL80|BPS1);
		}
		else if(mtype==2)
		{
		int i;
			for(i=0;vga_tab[i].mode!=-1;i++)
			{
				if((vga_tab[i].mode & NUMCOLS)==fcolor)
					NewEntry(*vga_tab[i].name, 5, vga_tab[i].mode);
			}
		}
		else if((mtype==1)||(mtype==3))
		{
		int i;
			for(i=0;rgb_tab[i].mode!=-1;i++)
			{
				if((rgb_tab[i].mode &NUMCOLS)==fcolor)
					NewEntry(*rgb_tab[i].name, 5, rgb_tab[i].mode);
			}
		}
	}

	if(ResVar==NULL)
		NewEntry(string_addr[NO_RESOLUTION], -1, -1);
	
	ResVar=Sort();
}

int SelectItem(int dev, int mode)
{
RES_VAR *ptr=ResVar;
	while(ptr)
	{
		if((ptr->mode==mode)&&(ptr->dev==dev))
		{
			ptr->selected=1;
			return(TRUE);
		}
		ptr=ptr->next;
	}
	return(FALSE);
}

void CreateColorPopup(void)
{
OBJECT *tree=tree_addr[COLOR_POPUP];
long value;
int vdo, i;

	if(Colordepth[0]==NULL)
	{
		for(i=0;i<CD_MAX;i++)
			Colordepth[i]=tree[CO_BPS+i].ob_spec.tedinfo->te_ptext;
	}

	for(i=0;i<CD_MAX;i++)
	{
		tree[CO_BPS+i].ob_state&=~OS_CHECKED;
		tree[CO_BPS+i].ob_flags|=OF_HIDETREE;
		tree[CO_BPS+i].ob_spec.tedinfo->te_ptext=Colordepth[CD_NA];
	}

	if(Getcookie('_VDO',&value))
	{
		tree[0].ob_height=tree[CO_BPS].ob_height;
		tree[CO_BPS].ob_flags&=~OF_HIDETREE;
		return;
	}
	
	vdo=*(int *)&value;

	if(vdo<2)								/*	ST oder STE	*/
	{
		tree[CO_BPS].ob_spec.tedinfo->te_ptext=Colordepth[CD_2];
		tree[CO_BPS+1].ob_spec.tedinfo->te_ptext=Colordepth[CD_4];
		tree[CO_BPS+2].ob_spec.tedinfo->te_ptext=Colordepth[CD_16];
	}
	if(vdo==2)								/*	TT	*/
	{
		tree[CO_BPS].ob_spec.tedinfo->te_ptext=Colordepth[CD_2];
		tree[CO_BPS+1].ob_spec.tedinfo->te_ptext=Colordepth[CD_4];
		tree[CO_BPS+2].ob_spec.tedinfo->te_ptext=Colordepth[CD_16];
		tree[CO_BPS+3].ob_spec.tedinfo->te_ptext=Colordepth[CD_256];
	}
	if(vdo==3)								/*	Falcon	*/
	{
		tree[CO_BPS].ob_spec.tedinfo->te_ptext=Colordepth[CD_2];
		tree[CO_BPS+1].ob_spec.tedinfo->te_ptext=Colordepth[CD_4];
		tree[CO_BPS+2].ob_spec.tedinfo->te_ptext=Colordepth[CD_16];
		tree[CO_BPS+3].ob_spec.tedinfo->te_ptext=Colordepth[CD_256];
		tree[CO_BPS+4].ob_spec.tedinfo->te_ptext=Colordepth[CD_32K];
	}

	tree[0].ob_height=0;
	
	for(i=0;i<CD_MAX;i++)
	{
		if(tree[CO_BPS+i].ob_spec.tedinfo->te_ptext!=Colordepth[CD_NA])
		{
			tree[CO_BPS+i].ob_flags&=~OF_HIDETREE;
			tree[0].ob_height+=tree[CO_BPS].ob_height;
		}
	}
}

int CreateResBox(DIALOG *dialog)
{
int i,crcol;

	if((mgx_res_dev==5)&&((mgx_res_mode&NUMCOLS)==BPS16))
		crcol=CD_32K;
	else if((mgx_res_dev==9)||
		((mgx_res_dev==5)&&((mgx_res_mode&NUMCOLS)==BPS8)))
		crcol=CD_256;
	else if((mgx_res_dev==2)||(mgx_res_dev==6)||
		((mgx_res_dev==5)&&((mgx_res_mode&NUMCOLS)==BPS4)))
		crcol=CD_16;
	else if((mgx_res_dev==3)||
		((mgx_res_dev==5)&&((mgx_res_mode&NUMCOLS)==BPS2)))
		crcol=CD_4;
	else if((mgx_res_dev==4)||(mgx_res_dev==8)||
		((mgx_res_dev==5)&&((mgx_res_mode&NUMCOLS)==BPS1)))
		crcol=CD_2;
	else
		crcol=CD_NA;
	
	CreateColorPopup();

	tmp_col=0;
	for(i=0;i<CD_MAX;i++)
	{
		if(tree_addr[COLOR_POPUP][CO_BPS+i].ob_spec.tedinfo->te_ptext==
				Colordepth[crcol])
			tmp_col=CO_BPS+i;
	}
	tree_addr[COLOR_POPUP][tmp_col].ob_state|=OS_CHECKED;

	CreateColors(crcol);

	SelectItem((int)mgx_res_dev, (int)mgx_res_mode);

	/* vertikale Listbox mit Auto-Scrolling und Real-Time-Slider anlegen */
	res_box = lbox_create( tree_addr[RESOLUTION], res_select_item,
							res_set_item, (LBOX_ITEM *)ResVar,
							NO_VIS_RES, 0, res_ctrl, res_objs, 
							LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT +
							LBOX_REAL + LBOX_SNGL, 
							40, dialog, dialog, 0, 0, 0, 0 );
	if(res_box)
		return(TRUE);
	else
		return(FALSE);
}

int SetOwnsettings(int state, long device, long mode)
{
	if(state)
	{
		ltoa(device,tree_addr[RESOLUTION][RE_DRIVER].ob_spec.tedinfo->te_ptext,10);
		ltoa(mode,tree_addr[RESOLUTION][RE_MODE].ob_spec.tedinfo->te_ptext,10);
		tree_addr[RESOLUTION][RE_DRIVER_TXT].ob_state&=~OS_DISABLED;
		tree_addr[RESOLUTION][RE_DRIVER].ob_state&=~OS_DISABLED;
		tree_addr[RESOLUTION][RE_DRIVER].ob_flags|=OF_EDITABLE;
		tree_addr[RESOLUTION][RE_MODE_TXT].ob_state&=~OS_DISABLED;
		tree_addr[RESOLUTION][RE_MODE].ob_state&=~OS_DISABLED;
		tree_addr[RESOLUTION][RE_MODE].ob_flags|=OF_EDITABLE;
		return(RE_DRIVER);
	}
	
	*tree_addr[RESOLUTION][RE_DRIVER].ob_spec.tedinfo->te_ptext=0;
	*tree_addr[RESOLUTION][RE_MODE].ob_spec.tedinfo->te_ptext=0;
	tree_addr[RESOLUTION][RE_DRIVER_TXT].ob_state|=OS_DISABLED;
	tree_addr[RESOLUTION][RE_DRIVER].ob_state|=OS_DISABLED;
	tree_addr[RESOLUTION][RE_DRIVER].ob_flags&=~OF_EDITABLE;
	tree_addr[RESOLUTION][RE_MODE_TXT].ob_state|=OS_DISABLED;
	tree_addr[RESOLUTION][RE_MODE].ob_state|=OS_DISABLED;
	tree_addr[RESOLUTION][RE_MODE].ob_flags&=~OF_EDITABLE;
	return(0);
}

WORD cdecl HandleResolution( struct HNDL_OBJ_args args )
{
OBJECT	*tree;
GRECT		rect;
	wdlg_get_tree( args.dialog, &tree, &rect );		/* Adresse des Baums erfragen */

	if(args.obj<0)									/* Ereignis oder Objektnummer? */
	{
		if(args.obj==HNDL_CLSD)						/* Closer bet„tigt? */
		{
			lbox_free_items(res_box);
			ResVar=NULL;
			lbox_delete(res_box);
			return(0);									/* beenden */ 
		}
		if(args.obj==HNDL_OPEN)
		{
		int new_obj;
		char *textptr;
			new_obj=SetOwnsettings(0,mgx_res_dev,mgx_res_mode);
			tree[RE_OWNSETTING].ob_state&=~OS_SELECTED;
			tree[RE_NOCHANGE].ob_state&=~OS_SELECTED;

			if(!CreateResBox(args.dialog))
				return(0);

			if(!lbox_get_slct_item(res_box))
			{
				if(mgx_res_dev==1)
					tree[RE_NOCHANGE].ob_state|=OS_SELECTED;
				else
				{
					tree[RE_OWNSETTING].ob_state|=OS_SELECTED;
					new_obj=SetOwnsettings(1,mgx_res_dev,mgx_res_mode);
				}
			}
			wdlg_set_edit(args.dialog,new_obj);

			strcpy(tree[RE_COLOR].ob_spec.free_string,tree_addr[COLOR_POPUP][tmp_col].ob_spec.tedinfo->te_ptext);
			textptr=strchr(tree[RE_COLOR].ob_spec.free_string,' ');
			if(textptr)
				*textptr=0;
		}
		if (args.obj == HNDL_MESG )
			SpecialMessageEvents(args.dialog, args.events);
	}
	else
	{
		lbox_do(res_box, args.obj);
		switch(args.obj)
		{
			case RE_NOCHANGE :
			case RE_OWNSETTING :
			{
			int new_obj,old_state;
			RES_VAR *item=(RES_VAR *)(lbox_get_slct_item(res_box));
				wdlg_set_edit(args.dialog,0);
				if(item)
				{
					item->selected=0;
					lbox_update(res_box, &rect);
				}
				old_state=tree[RE_MODE_TXT].ob_state;
				if(args.obj==RE_OWNSETTING)
					new_obj=SetOwnsettings(1,mgx_res_dev,mgx_res_mode);
				else
					new_obj=SetOwnsettings(0,0L,0L);

				if(old_state!=tree[RE_MODE_TXT].ob_state)
					wdlg_redraw(args.dialog,&rect,RE_OWNSETTING,MAX_DEPTH);
				wdlg_set_edit(args.dialog,new_obj);
				break;
			}
			case RE_COLOR :
			{
			_WORD new_col,x,y;
				objc_offset(tree,RE_COLOR,&x,&y);
				new_col=form_popup(tree_addr[COLOR_POPUP],x+(tree[RE_COLOR].ob_width>>1),y);
				if((new_col!=-1)&&(new_col!=tmp_col))
				{
				char *textptr;
					tree_addr[COLOR_POPUP][tmp_col].ob_state&=~OS_CHECKED;
					tree_addr[COLOR_POPUP][new_col].ob_state|=OS_CHECKED;
					tmp_col=new_col;
					strcpy(tree[RE_COLOR].ob_spec.free_string,tree_addr[COLOR_POPUP][tmp_col].ob_spec.tedinfo->te_ptext);
					textptr=strchr(tree[RE_COLOR].ob_spec.free_string,' ');
					if(textptr)
						*textptr=0;

					for(x=0;x<CD_MAX;x++)
					{
						if(Colordepth[x]==tree_addr[COLOR_POPUP][tmp_col].ob_spec.tedinfo->te_ptext)
							new_col=x;
					}

					lbox_free_items(res_box);

					ResVar=NULL;

					CreateColors(new_col);
					if(!(tree[RE_NOCHANGE].ob_state&OS_SELECTED)&&
						!(tree[RE_OWNSETTING].ob_state&OS_SELECTED))
						SelectItem((int)mgx_res_dev, (int)mgx_res_mode);

					lbox_set_items(res_box,(LBOX_ITEM*)ResVar);
					lbox_update(res_box, &rect);
				}
				tree[RE_COLOR].ob_state&=(~OS_SELECTED);
				wdlg_redraw(args.dialog,&rect,RE_COLOR,0);
				break;
			}
			case RE_OK :
			{
				if(tree[RE_NOCHANGE].ob_state & OS_SELECTED)
				{
					mgx_res_dev=1;
					mgx_res_mode=0;
				}
				else if(tree[RE_OWNSETTING].ob_state & OS_SELECTED)
				{
					mgx_res_dev=atol(tree[RE_DRIVER].ob_spec.tedinfo->te_ptext);
					mgx_res_mode=atol(tree[RE_MODE].ob_spec.tedinfo->te_ptext);
				}
				else
				{
				RES_VAR *item=(RES_VAR *)(lbox_get_slct_item(res_box));
					if(item)
					{
						mgx_res_dev=item->dev;
						mgx_res_mode=item->mode;
					}
				}
				changed=TRUE;
			}
			case RE_CANCEL : 
				tree[args.obj].ob_state&=(~OS_SELECTED);
				tree_addr[COLOR_POPUP][tmp_col].ob_state&=~OS_CHECKED;
				lbox_free_items(res_box);
				ResVar=NULL;
				lbox_delete(res_box);
				SendCloseDialog(args.dialog);
		}
	}
	return( 1 );								/* alles in Ordnung - weiter so */
}




WORD cdecl res_set_item(struct SET_ITEM_args args)
{
char *ptext, *str;
	ptext=args.tree[args.obj_index].ob_spec.tedinfo->te_ptext;

	if(args.item)								/* LBOX_ITEM vorhanden? */
	{
		if(args.item->selected)
			args.tree[args.obj_index].ob_state|=OS_SELECTED;
		else
			args.tree[args.obj_index].ob_state&=~OS_SELECTED;

		str=((RES_VAR *)args.item)->str;		/* Zeiger auf den String */

		if(args.first==0)
		{
			if(*ptext)
			{
				*ptext++=' ';					/* vorangestelltes Leerzeichen */
				*ptext++=' ';					/* vorangestelltes Leerzeichen */
			}
		}
		else
			args.first-=2;
		
		if(args.first<=strlen(str))
		{
			str+=args.first;

			while(*ptext && *str)
				*ptext++ = *str++;
		}
		
		if(((RES_VAR *)args.item)->dev==-1)
		{
			args.tree[args.obj_index].ob_state&=~OS_SELECTED;
			args.tree[args.obj_index].ob_state|=OS_DISABLED;
		}
		else
			args.tree[args.obj_index].ob_state&=~OS_DISABLED;
	}
	else										/* nicht benutzter Eintrag */
	{
		args.tree[args.obj_index].ob_state&=~OS_CHECKED;
		args.tree[args.obj_index].ob_state&=~OS_SELECTED;
	}

	while(*ptext)
		*ptext++=' ';						/* Stringende mit Leerzeichen auffllen */	

	return(args.obj_index);						/* Objektnummer des Startobjekts */
}

void cdecl	res_select_item( struct SLCT_ITEM_args args )
{
DIALOG_DATA *dial = NULL;
OBJECT *dummy;
GRECT r;
	dial=find_dialog_by_obj(args.tree);
	wdlg_get_tree( dial->dial, &dummy, &r );
	if(args.tree[RE_NOCHANGE].ob_state & OS_SELECTED)
		objc_change(args.tree, RE_NOCHANGE, 0, r.g_x, r.g_y, r.g_w, r.g_h, args.tree[RE_NOCHANGE].ob_state & (~OS_SELECTED), 1);
	if(args.tree[RE_OWNSETTING].ob_state & OS_SELECTED)
	{
		args.tree[RE_OWNSETTING].ob_state&=~OS_SELECTED;
		SetOwnsettings(0,0L,0L);
		wdlg_set_edit(dial->dial,0);
		wdlg_redraw(dial->dial,&r,RE_OWNSETTING,MAX_DEPTH);
	}
}


