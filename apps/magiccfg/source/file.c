#include <tos.h>
#include <atarierr.h>
#include <gemx.h>
#include <string.h>
#include "diallib.h"
#include "defs.h"

/* Fxattr modes */
#define FXATTR_RESOLVE  0
#define FXATTR_NRESOLVE 1


char	mgx_path[MPATHMAX]="",
		mgx_filename[MPATHMAX]="";
char	tmp_path[MPATHMAX]="*:\\MAGX.INF";

char	mgx_Pfade[6][MPATHMAX];

ENV_VAR	*mgx_EnvVar=NULL;
LIB_ITEM *mgx_SlbItems=NULL;

char	mgx_fsl_mask[256];

long	mgx_version,
		mgx_shl_buf_size,
		mgx_res_dev, mgx_res_mode,
		mgx_txt_gsize, mgx_txt_ksize, mgx_txt_font,
		mgx_flags,
		mgx_win_cnt,
		mgx_tsl_time, mgx_tsl_prior,
		mgx_fsl_mode,
		mgx_desk_back,
		mgx_txs_id, mgx_txs_aqui, mgx_txs_h,
		mgx_txb_id, mgx_txb_aqui, mgx_txb_h,
		mgx_obs_ow, mgx_obs_oh, mgx_obs_bw, mgx_obs_bh,
		mgx_inw_objh, mgx_inw_fontid, mgx_inw_mflag, mgx_inw_fonth;

long	mgx_vfat_drives;

char	mgx_bootlog[MPATHMAX],
		mgx_image[MPATHMAX],
		mgx_tiles[MPATHMAX];
long	mgx_cookies;

int	open_file=FALSE,
		changed=FALSE;

char	*QuellMAGX=NULL;

void Mgx_ClearVars(void)
{
int i;
LBOX_ITEM *ptr, *ptr2;
	*mgx_path=0;
	strcpy(mgx_filename,string_addr[NEW_FILE]);

	for(i=0;i<6;i++)
		mgx_Pfade[i][0]=0;
	
	ptr=(LBOX_ITEM *)mgx_EnvVar;

	while(ptr!=NULL)
	{
		ptr2=(LBOX_ITEM *)ptr->next;
		Mfree(ptr);
		ptr=ptr2;
	};
	mgx_EnvVar=NULL;

	ptr=(LBOX_ITEM *)mgx_SlbItems;
	while(ptr!=NULL)
	{
		ptr2=(LBOX_ITEM *)ptr->next;
		Mfree(ptr);
		ptr=ptr2;
	};
	mgx_SlbItems=NULL;

	mgx_version=MagiC_Version;
	mgx_shl_buf_size=0;
	mgx_res_dev=0;
	mgx_res_mode=0;
	mgx_txt_gsize=0;
	mgx_txt_ksize=0;
	mgx_txt_font=0;
	mgx_flags=0;
	mgx_win_cnt=0;
	mgx_tsl_time=0;
	mgx_tsl_prior=0;
	*mgx_fsl_mask=0;
	mgx_fsl_mode=0;
	mgx_desk_back=0;
	mgx_vfat_drives=0;
	mgx_txs_id=0;
	mgx_txs_aqui=0;
	mgx_txs_h=0;
	mgx_txb_id=0;
	mgx_txb_aqui=0;
	mgx_txb_h=0;
	mgx_obs_ow=0;
	mgx_obs_oh=0;
	mgx_obs_bw=0;
	mgx_obs_bh=0;
	mgx_inw_objh=0;
	mgx_inw_fontid=0;
	mgx_inw_mflag=0;
	mgx_inw_fonth=0;

	*mgx_bootlog=0;
	*mgx_image=0;
	*mgx_tiles=0;
	mgx_cookies=0;
}

void Mgx_SetDefaultValues(void)
{
extern char *asc_nullstr;
	QuellMAGX=asc_nullstr;

	mgx_version=MagiC_Version;

	mgx_shl_buf_size=4192;
	mgx_res_dev=1;
	mgx_flags=RECHTS|LOOK3D|SHOW_BD|TITEL_LINES|TITEL_3D|REAL_SCROLL|REAL_MOVE;
	mgx_win_cnt=16;
	mgx_desk_back=0x73;
	mgx_txs_id=1;
	mgx_txs_aqui=1;
	mgx_txs_h=0;
	mgx_txb_id=1;
	mgx_txb_aqui=1;
	mgx_txb_h=0;
}

int CheckMAGX(char *ptr, long size)
{
extern char *asc_mag;
char *start=ptr;
	do
	{
		if((*(unsigned char *)ptr<' ')&&(*ptr!='\r')&&(*ptr!='\n')&&(*ptr!='\t'))
			return(FALSE);
		ptr++;
	}while(--size>0);
	
	if(strstr(start,asc_mag)==NULL)
		return(FALSE);
	
	return(TRUE);
}


int QuitClose(void)
{
	if(changed)
	{
	char temp[256];
	int ret;
		sprintf(temp,string_addr[F_CHANGED],mgx_filename);
		ret=form_alert(1,temp);
		if(ret==3)
			return(FALSE);
		else if(ret==1)
		{
			if(!open_file)					/*	Dateiname bestimmt ?	*/
			{
				if (OpenFileselector(QuitCloseFile,string_addr[FSEL_MAG_SAVE],tmp_path,
					std_paths,std_masks,0))
					ModalItem();
				return(FALSE);
			}
			Save();
		}
	}

	if(QuellMAGX)
	{
		Mfree(QuellMAGX);
		QuellMAGX=NULL;
	}

	CloseAllDialogs();
	Mgx_ClearVars();							/*	Variablen l”schen	*/
	menu_ienable(menu_tree,ME_SAVE,0);
	menu_ienable(menu_tree,ME_SAVE_AS,0);
	changed=FALSE;
	open_file=FALSE;
	return(TRUE);
}

void Close(void)
{
	if(QuellMAGX)
	{
		Mfree(QuellMAGX);
		QuellMAGX=NULL;
	}

	CloseAllDialogs();
	Mgx_ClearVars();							/*	Variablen l”schen	*/
	menu_ienable(menu_tree,ME_SAVE,0);
	menu_ienable(menu_tree,ME_SAVE_AS,0);
	changed=FALSE;
	open_file=FALSE;
}

void New(void)
{
	if(changed)
	{
	char temp[256];
	int ret;
		sprintf(temp,string_addr[F_CHANGED],mgx_filename);
		ret=form_alert(1,temp);
		if(ret==3)
			return;
		else if(ret==1)
		{
			if(!open_file)					/*	Dateiname bestimmt ?	*/
			{
				if (OpenFileselector(NewCloseFile,string_addr[FSEL_MAG_SAVE],tmp_path,
					std_paths,std_masks,0))
					ModalItem();
				return;
			}
			Save();
		}
	}
	Close();
	Mgx_SetDefaultValues();
	open_file=FALSE,
	changed=FALSE;
	menu_ienable(menu_tree,ME_SAVE_AS,1);
	OpenDialog(HandleMain,tree_addr[MAIN],mgx_filename,-1,-1);
}

void Open(int mode)
{
long ret;
char *ptr;

	if(changed)
	{
	char temp[256];
	int ret;
		sprintf(temp,string_addr[F_CHANGED],mgx_filename);
		ret=form_alert(1,temp);
		if(ret==3)
			return;
		else if(ret==1)
		{
			if(!open_file)					/*	Dateiname bestimmt ?	*/
			{
				OpenFileselector(OpenCloseFile,string_addr[FSEL_MAG_SAVE],tmp_path,
					std_paths,std_masks,0);
				ModalItem();
				return;
			}
			Save();
		}
	}
	Close();

	if(mode)
	{
		OpenFileselector(LoadFile,string_addr[FSEL_MAG_OPEN],tmp_path,
			std_paths,std_masks,0);
		return;
	}

	ptr=strrchr(tmp_path,'\\');			/*	Pfadangabe enthalten ?	*/
	if(ptr==NULL)								/*	Wenn nicht, dann....	*/
		ptr=tmp_path;							/*	das Ganze ist der Filename	*/
	else											/*	sonst....	*/
		ptr+=1;									/*	Pointer auf den Filename setzen	*/
	
	if(*ptr==0)									/*	wurde kein Filename angegeben ?	*/
		return;

	strcpy(mgx_path,tmp_path);				/*	kompletter Pfad merken	*/
	strcpy(mgx_filename,ptr);				/*	Name eintragen	*/

	ret=Fopen(mgx_path,O_RDONLY);			/*	Datei ”ffnen	*/
	if(ret==EFILNF)
	{
		if(form_alert(1,string_addr[F_NOT_EXIST])==2)
			return;
		Mgx_SetDefaultValues();
	}
	else if(ret<0L)
	{
		form_xerr(ret,mgx_filename);
		return;
	}
	else
	{
	int handle;
	XATTR xattr;
		handle=(int)ret;
	
		Fxattr(FXATTR_RESOLVE,mgx_path,&xattr);
		ret=(long)Mxalloc(xattr.st_size+1,3);
		if(ret==0L)
		{
			form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
			Mgx_SetDefaultValues();
		}
		else
		{
			QuellMAGX=(char *)ret;
			Fread(handle,xattr.st_size,QuellMAGX);
			QuellMAGX[xattr.st_size]=0;				/*	Zeilenende markieren	*/
	
			if(!CheckMAGX(QuellMAGX, xattr.st_size))
			{
				if(form_alert(2,string_addr[F_NOT_MAGXINF])==2)
				{
					Fclose(handle);
					Mfree(QuellMAGX);
					QuellMAGX=NULL;
					return;
				}
			}
			LoadMAGX(QuellMAGX);
			DhstAddFile(mgx_path);

		}
		Fclose(handle);
	}

	open_file=TRUE,
	changed=FALSE;

	menu_ienable(menu_tree,ME_SAVE,1);
	menu_ienable(menu_tree,ME_SAVE_AS,1);
	OpenDialog(HandleMain,tree_addr[MAIN],mgx_filename,-1,-1);
}

void Save(void)
{
char *savebuffer,bakpath[MPATHMAX], *ptr;
long ret;
int handle;
XATTR xattr;
	ret=(long)Mxalloc(strlen(QuellMAGX)+5000L,3);
	if(ret==0L)
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
		return;
	}
	savebuffer=(char *)ret;

	
	GetMainDialogItems();
	if(SaveMAGX(savebuffer,QuellMAGX))
	{
		Mfree(savebuffer);
		return;
	}
	

	ret=Fxattr(FXATTR_RESOLVE,mgx_path,&xattr);		/*	existiert Datei ?	*/
	if(ret==0)
	{

		strcpy(bakpath,mgx_path);						/*	BAK-Name aufbauen	*/
		ptr=strrchr(bakpath,'.');
		if(ptr)
		{
		char *ptr2;
			ptr2=strrchr(bakpath,'\\');
			if(ptr2==NULL)
				ptr2=bakpath;
			
			if(ptr>ptr2)
				*ptr=0;
		}
		strcat(bakpath,".bak");
		
		ret=Fxattr(FXATTR_RESOLVE,bakpath,&xattr);	/*	existiert BAK-Datei ?	*/
		if(ret==0)
		{
			ret=Fdelete(bakpath);							/*	BAK-Datei l”schen	*/
			if(ret<0L)
			{
				Mfree(savebuffer);
				form_xerr(ret,bakpath);
				return;
			}
		}
	
		ret=Frename(0,mgx_path,bakpath);					/*	Datei in BAK umbenennen	*/
		if(ret!=0)
		{
			Mfree(savebuffer);
			form_xerr(ret,mgx_path);
			return;
		}
	}
	
	ret=Fopen(mgx_path,O_WRONLY|O_CREAT|O_TRUNC);
	if(ret<0L)
	{
		Mfree(savebuffer);
		form_xerr(ret,mgx_filename);
		return;
	}

	handle=(int)ret;
	
	Fwrite(handle,strlen(savebuffer),savebuffer);
	
	Fclose(handle);
	Mfree(savebuffer);

	changed=FALSE;
	return;
}
