#include <tos.h>
#include <gemx.h>
#include "diallib.h"

#ifndef _AESrshdr
#define _AESrshdr *(RSHDR **)&aes_global[7]
#endif

#if DEBUG_LOG == YES
int debug_handle=0, old_stderr;
#endif

int	ap_id;
WORD aes_handle,pwchar,phchar,pwbox,phbox;
WORD has_agi=0, has_wlffp=0, has_iconify=0;
#if USE_VDI==YES
WORD vdi_handle;
WORD workin[11];
WORD workout[57];
WORD ext_workout[57];
#if SAVE_COLORS==YES
RGB1000 save_palette[256];
#endif
#endif
#if USE_LONGFILENAMES==YES
int	old_domain;
#endif

#if LANGUAGE==GERMAN
char	*err_loading_rsc="[1][Fehler beim Laden von |'"RESOURCE_FILE"'.][Abbruch]";
#elif LANGUAGE==FRENCH
char	*err_loading_rsc="[1][Impossible de trouver '"RESOURCE_FILE"'.][Annuler]";
#else
char	*err_loading_rsc="[1][Error while loading |'"RESOURCE_FILE"'.][Cancel]";
#endif
char	*resource_file=RESOURCE_FILE;
RSHDR	*rsh;
OBJECT	**tree_addr;
int	tree_count;
char	**string_addr;
#if USE_MENU==YES
OBJECT	*menu_tree;
#endif

KEYTAB *key_table;

int DoAesInit(void);
int DoInitSystem(void);
void DoExitSystem(void);

int DoAesInit(void)
{
	_WORD dummy;
#if DEBUG_LOG==ON
long ret;
	ret=Fopen(PROGRAM_NAME ".log",O_WRONLY|O_CREAT|O_APPEND);
	if(ret>=0)
	{
		debug_handle=(int)ret;
		old_stderr=(int)Fdup(STDERR_FILENO);
		ret=Fforce(STDERR_FILENO,debug_handle);
		if(ret<0L)
			puts("Error in Fforce()");
		else
			Debug(PROGRAM_NAME" startet");
	}
	else
		puts("Unable to create LOG file");
#endif

	ap_id=appl_init();
	if(ap_id<0)
		return(TRUE);

	if(rsrc_load(resource_file)==0)
	{
		form_alert(1,err_loading_rsc);
		appl_exit();
		return(TRUE);
	}


	rsh=_AESrshdr;

	tree_addr=(OBJECT **)(((char *)rsh)+rsh->rsh_trindex);
	tree_count = rsh->rsh_ntree;
	string_addr=(char **)((char *)rsh+rsh->rsh_frstr);

	has_agi = (_AESversion == 0x399) || (_AESversion >= 0x400) || (appl_find("?AGI") >= 0);

#if USE_ITEM == YES
	if( !has_agi )
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_WDIALOG_ERROR].ob_spec.free_string);
		rsrc_free();
		appl_exit();
		return(TRUE);
	}
/*
Bit 0:           wdlg_xx()-Funktionen sind vorhanden (1)
Bit 1:           lbox_xx()-Funktionen sind vorhanden (1)
Bit 2:           fnts_xx()-Funktionen sind vorhanden (1)
Bit 3:           fslx_xx()-Funktionen sind vorhanden (1)
Bit 4:           pdlg_xx()-Funktionen sind vorhanden (1)
*/

	if((appl_getinfo(7,&has_wlffp,&dummy,&dummy,&dummy)==0)||
		((has_wlffp & 0x01) != 0x01))
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_WDIALOG_ERROR].ob_spec.free_string);
		return(TRUE);
	}
	if(appl_getinfo(11,&has_iconify,&dummy,&dummy,&dummy))
		has_iconify=has_iconify & 0x80;

	iconified_tree=tree_addr[DIAL_LIBRARY];
	iconified_name=tree_addr[DIAL_LIBRARY][DI_ICONIFY_NAME].ob_spec.free_string;
/*
	if(has_iconify)
	{
	GRECT icon={0,0,72,72};
	short w,h,dummy;
		if(wind_get(0,WF_ICONIFY,&dummy,&w,&h,&dummy))
		{
			icon.g_w=w;
			icon.g_h=h;
		}
		wind_calc(WC_WORK,NAME,&icon,&icon);
		tree_addr[DIAL_LIBRARY][DI_ICON].ob_x=(icon.g_w-tree_addr[DIAL_LIBRARY][DI_ICON].ob_width)>>1;
		tree_addr[DIAL_LIBRARY][DI_ICON].ob_y=(icon.g_h-tree_addr[DIAL_LIBRARY][DI_ICON].ob_height)>>1;
	}
*/
#endif

	aes_handle=graf_handle(&pwchar,&phchar,&pwbox,&phbox);

#if USE_MENU==YES
	menu_tree=tree_addr[MENU];
#endif

	return(FALSE);
}

int DoInitSystem(void)
{
#if USE_VDI==YES
	{
	int i;
		for(i=0;i<10;workin[i++]=1);
		workin[10]=2;
		vdi_handle=aes_handle;
		v_opnvwk(workin,&vdi_handle,workout);
		if(!vdi_handle)
		{
			form_alert(1,tree_addr[DIAL_LIBRARY][DI_VDI_WKS_ERROR].ob_spec.free_string);
			rsrc_free();
			appl_exit();
			return(TRUE);
		}
		vq_extnd(vdi_handle,1,ext_workout);

#if SAVE_COLORS==YES
		for(i=0;i<256;i++)
			vq_color(vdi_handle,i,1,&save_palette[i]);
#endif
	}
#endif
#if USE_LONGFILENAMES==YES
	old_domain=(int)Pdomain(1);
#endif
#if USE_LONGEDITFIELDS==YES
	DoInitLongEdit();
#endif
#if USE_BUBBLEGEM==YES
	DoInitBubble();
#endif
#if USE_AV_PROTOCOL>=2
	DoAV_PROTOKOLL(AV_P_QUOTING|AV_P_VA_START|AV_P_AV_STARTED);
#endif

	key_table=Keytbl((void *)NIL,(void *)NIL,(void *)NIL);		/*	Key-Table ermitteln	*/

	return(FALSE);
}

void DoExitSystem(void)
{
#if USE_AV_PROTOCOL>=2
	DoAV_EXIT();
#endif
#if USE_BUBBLEGEM==YES
	DoExitBubble();
#endif
#if USE_LONGEDITFIELDS==YES
	DoExitLongEdit();
#endif
#if USE_LONGFILENAMES==YES
	Pdomain(old_domain);
#endif
#if USE_VDI==YES
	if(vdi_handle)
	{
#if SAVE_COLORS==YES
	int i;
		for(i=0;i<256;i++)
			vs_color(vdi_handle,i,&save_palette[i]);
#endif
		v_clsvwk(vdi_handle);
	}
#endif

	rsrc_free();
	appl_exit();

#if DEBUG_LOG == ON
	Fclose(debug_handle);
	Fforce(STDERR_FILENO,old_stderr);
#endif
}
