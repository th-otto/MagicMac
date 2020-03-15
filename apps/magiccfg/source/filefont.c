#include <tos.h>
#include <gemx.h>
#include <atarierr.h>
#include "DIALLIB.H"
#include "defs.h"

/* Fxattr modes */
#define FXATTR_RESOLVE  0

char	*std_paths="C:\\\0",
		*std_masks="*.INF\0*\0";

void LoadFile(FILESEL_DATA *ptr, int nfiles)
{
	if(ptr->button)
	{
		strcpy(tmp_path,ptr->path);
		strcat(tmp_path,ptr->name);
		Open(0);
	}
}

void SaveFile(FILESEL_DATA *ptr, int nfiles)
{
	if(ptr->button)
	{
	long ret;
	XATTR xattr;
	char *chptr;
	DIALOG_DATA *dial_ptr;
		strcpy(tmp_path,ptr->path);
		strcat(tmp_path,ptr->name);

		ret=Fxattr(FXATTR_RESOLVE,tmp_path,&xattr);
		if(ret==0)
		{
			if(form_alert(1,string_addr[F_EXISTS])==2)
				return;
		}
		else if(ret!=EFILNF)
		{
			form_xerr(ret,ptr->name);
			return;
		}
		
		chptr=strrchr(tmp_path,'\\');			/*	Pfadangabe enthalten ?	*/
		if(chptr==NULL)							/*	Wenn nicht, dann....	*/
			chptr=tmp_path;						/*	das Ganze ist der Filename	*/
		else											/*	sonst....	*/
			chptr+=1;								/*	Pointer auf den Filename setzen	*/
		
		strcpy(mgx_path,tmp_path);				/*	kompletter Pfad merken	*/
		strcpy(mgx_filename,chptr);			/*	Name eintragen	*/

		dial_ptr=find_dialog_by_obj(tree_addr[MAIN]);
		if(dial_ptr)
			wind_set_str(dial_ptr->whandle,WF_NAME,dial_ptr->title);

		Save();
	}
}

void QuitCloseFile(FILESEL_DATA *ptr, int nfiles)
{
	if(ptr->button)
	{
	int msg[8]={MN_SELECTED,0,0,ME_FILE,ME_QUIT};
		SaveFile(ptr,nfiles);
		msg[1]=ap_id;
		if(!changed)
			appl_write(ap_id,16,msg);
	}
}

void NewCloseFile(FILESEL_DATA *ptr, int nfiles)
{
	if(ptr->button)
	{
	int msg[8]={MN_SELECTED,0,0,ME_FILE,ME_NEW};
		SaveFile(ptr,nfiles);
		msg[1]=ap_id;
		if(!changed)
			appl_write(ap_id,16,msg);
	}
}

void OpenCloseFile(FILESEL_DATA *ptr, int nfiles)
{
	if(ptr->button)
	{
	int msg[8]={MN_SELECTED,0,0,ME_FILE,ME_OPEN};
		SaveFile(ptr,nfiles);
		msg[1]=ap_id;
		if(!changed)
			appl_write(ap_id,16,msg);
	}
}


char *file_mask="*\0";

int file_object=0;
DIALOG *file_dialog;

void GetFile(FILESEL_DATA *ptr, int nfiles)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(file_dialog,&tree,&rect);
	if(ptr->button && nfiles)	/*	mit OK beendet ?	*/
	{
		strcat(ptr->path,ptr->name);
		CopyMaximumChars(&tree[file_object],ptr->path);
		wdlg_redraw(file_dialog,&rect,file_object,1);
	}
}

void GetFolder(FILESEL_DATA *ptr, int nfiles)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(file_dialog,&tree,&rect);
	if(ptr->button)	/*	mit OK beendet ?	*/
	{
		CopyMaximumChars(&tree[file_object],ptr->path);
		wdlg_redraw(file_dialog,&rect,file_object,1);
	}
}

void GetAnything(FILESEL_DATA *ptr, int nfiles)
{
OBJECT *tree;
GRECT rect;
	wdlg_get_tree(file_dialog,&tree,&rect);
	if(ptr->button)	/*	mit OK beendet ?	*/
	{
		strcat(ptr->path,ptr->name);
		CopyMaximumChars(&tree[file_object],ptr->path);
		wdlg_redraw(file_dialog,&rect,file_object,1);
	}
}
/*
int LoadFont(void *ptr)
{
char full[80],style[80],family[80];
FONTSEL_DATA *fnts=ptr;
	puts("\33H\nFontselector:");
	if(fnts->button==FNTS_OK)
		puts("OK    ");
	if(fnts->button==FNTS_CANCEL)
		puts("CANCEL");
	if(fnts->button==FNTS_SET)
		puts("SET   ");
	if(fnts->button==FNTS_MARK)
		puts("MARK  ");
	if(fnts->button==FNTS_OPT)
		puts("OPTION");

	fnts_get_name(fnts->dialog,fnts->id,full,family,style);
	printf("%s : %s : %s\n",full, family,style);

	if((fnts->button==FNTS_OK)||(fnts->button==FNTS_CANCEL))
	{
		return(0);
	}
	
	return(1);
}
*/


/*
	OpenFileselector(LoadFile,string_addr[FSEL_MAG_OPEN],tmp_path,
		std_paths,std_masks,0);
	OpenFontselector(LoadFont,FNTS_OUTL|FNTS_BTMP|FNTS_MONO|FNTS_PROP,
		FNTS_SNAME|FNTS_SSIZE|
		FNTS_CHNAME|FNTS_CHSTYLE|FNTS_CHSIZE|FNTS_CHRATIO|FNTS_RATIO|
		FNTS_BSET|FNTS_BMARK,
		0L,0xA0000L,0x10000L,"Darstellung");
	ModalItem();

*/

