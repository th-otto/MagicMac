#include <tos.h>
#include <gemx.h>
#include "diallib.h"
#include "defs.h"



/*******************************************************/
/****** Events 											  ******/
/*******************************************************/
#if USE_GLOBAL_KEYBOARD == YES
#include <scancode.h>

int DoUserKeybd(int kstate, int scan, int ascii)
{
	(void)scan;
	if(kstate==K_CTRL)
	{
		switch(ascii)
		{
			case 'N':
				ChooseMenu( ME_FILE, ME_NEW );
				return(TRUE);
			case 'O':
				ChooseMenu( ME_FILE, ME_OPEN );
				return(TRUE);
			case 'S':
				ChooseMenu( ME_FILE, ME_SAVE );
				return(TRUE);
			case 'M':
				ChooseMenu( ME_FILE, ME_SAVE_AS );
				return(TRUE);
		}
	}
	return(FALSE);
}
#endif

void DoButton(EVNT *event)
{
#if USE_BUBBLEGEM==YES
	if(event->mbutton==2)
		Bubble(event->mx,event->my);
#endif
}

#if USE_USER_EVENTS == YES
void DoUserEvents(EVNT *event)
{
}
#endif



/*******************************************************/
/****** MenÅ-Auswahl 									  ******/
/*******************************************************/
#if USE_MENU == YES
void SelectMenu(int title, int entry)
{
	switch(title)
	{
		case ME_PROGRAM:
			switch(entry)
			{
				case ME_PROGRAM_INFO:
					OpenDialog(HandleAbout, tree_addr[PROGRAM_INFO], string_addr[WDLG_PRG],-1,-1);
					break;
				default:
					break;
			}
			break;
		case ME_FILE:
			switch(entry)
			{
				case ME_NEW :
					New();
					break;
				case ME_OPEN :
					Open(1);
					break;
				case ME_SAVE :
					Save();
					break;
				case ME_SAVE_AS :
					OpenFileselector(SaveFile,string_addr[FSEL_MAG_SAVE],tmp_path,
						std_paths,std_masks,0);
					ModalItem();
					break;
				case ME_QUIT:
					if((QuitClose())&&(!FastOut))
					{
					int back;
						doneFlag=TRUE;
						back=form_alert(1,string_addr[SYSTEM_RESTART]);
						if(back==1)
						{
						char *path=NULL;
							shel_envrn(&path,"SDMASTER=");
							if(path)
								shel_write(SHW_EXEC,1,SHW_PARALLEL,path,"");
							else
							{
							int msg[8]={AP_TERM,-1,0,0,0,AP_TERM,0,0};
								appl_write(0,16,msg);
							}
						}
						else if(back==3)
							doneFlag=FALSE;
					}
					else if(FastOut)
						doneFlag=TRUE;
					break;
			}
			break;
	}
}
#endif



/*******************************************************/
/****** Dialogobjekte mit Langen Editfeldern 	  ******/
/*******************************************************/
#if USE_LONGEDITFIELDS == YES
LONG_EDIT long_edit[]=
{
	{PATH,PA_SCRAP,MPATHMAX},
	{PATH,PA_ACC,MPATHMAX},
	{PATH,PA_START,MPATHMAX},
	{PATH,PA_SHELL,MPATHMAX},
	{PATH,PA_AUTO,MPATHMAX},
	{PATH,PA_TERMINAL,MPATHMAX},
	{VARIABLES,VA_VARIABLE,256},
	{VARIABLES,VA_NAME,128},
	{OTHER,OT_FSEL_MASK,256},
	{BOOT,BO_LOG,MPATHMAX},
	{BOOT,BO_IMAGE,MPATHMAX},
	{BOOT,BO_TILES,MPATHMAX}
};

int long_edit_count=(int)(sizeof(long_edit)/sizeof(LONG_EDIT));
#endif



/*******************************************************/
/****** Drag&Drop Protokoll							  ******/
/*******************************************************/
#if USE_DRAGDROP == YES
void DD_Object(DIALOG *dial,GRECT *rect,OBJECT *tree,int obj, char *data, unsigned long format)
/*
	Hier kînnen je nach Zielobjekt <obj> die D&D-Daten <data> anders
	ausgewertet werden. <data> hat eines der gewÅnschten Formate
	(<format>).
	Um <data> in seine EinzelbestÑnde zu zerlegen muss ParseData ver-
	wendet werden.
*/
{
char *next,*ptr=data;
	(void)format;
	if(tree==tree_addr[MAIN])
	{
		ParseData(data);
		strcpy(tmp_path,data);
		Open(0);
	}
	else if(tree==tree_addr[PATH])
	{
		switch(obj)
		{
		case PA_SCRAP:
		case PA_ACC:
		case PA_START:
			ParseData(data);
			ptr=strrchr(data,'\\');
			if(ptr!=NULL)
			{
				ptr[1]=0;
				wdlg_set_edit(dial,0);
				CopyMaximumChars(&tree[obj],data);
				wdlg_redraw(dial,rect,obj,MAX_DEPTH);
				wdlg_set_edit(dial,obj);
			}
			break;
		case PA_SHELL:
		case PA_AUTO:
		case PA_TERMINAL:
			ParseData(data);
			wdlg_set_edit(dial,0);
			CopyMaximumChars(&tree[obj],data);
			wdlg_redraw(dial,rect,obj,MAX_DEPTH);
			wdlg_set_edit(dial,obj);
			break;
		default:
			break;
		}
	}
	else if(tree==tree_addr[VFAT])
	{
		if(data[1]==':')
		{
			int drv = data[0] >= 'A' ? data[0] - 'A' : data[0] - '1' + 26;
			int button=VF_DRIVE_A+drv;
			if(tree[button].ob_state & OS_SELECTED)
				tree[button].ob_state&=~OS_SELECTED;
			else
				tree[button].ob_state|=OS_SELECTED;
			wdlg_redraw(dial,rect,button,0);
		}
	}
	else if(tree==tree_addr[BOOT])
	{
		switch(obj)
		{
		case BO_IMAGE:
		case BO_TILES:
		case BO_LOG:
			ParseData(data);
			wdlg_set_edit(dial,0);
			CopyMaximumChars(&tree[obj],data);
			wdlg_redraw(dial,rect,obj,1);
			wdlg_set_edit(dial,obj);
			break;
		default:
			break;
		}
	}
	else if((tree==tree_addr[VARIABLES])&&(obj==VA_VARIABLE))
	{
	int max_size=tree[obj].ob_spec.tedinfo->te_txtlen-1;
		ParseData(data);
		wdlg_set_edit(dial,0);
		strncat(tree[obj].ob_spec.tedinfo->te_ptext,data,
			max_size-strlen(tree[obj].ob_spec.tedinfo->te_ptext));
		tree[obj].ob_spec.tedinfo->te_ptext[max_size]=0;
		wdlg_redraw(dial,rect,obj,1);
		wdlg_set_edit(dial,obj);
	}
	else if((tree==tree_addr[LIBRARIES])&&(obj>=LI_01)&&(obj<=LI_10))
	{
extern void AddLibrarie(char *path);
extern LIST_BOX *lib_box;
	char *filename;
		do
		{
			next=ParseData(ptr);
			filename=strrchr(ptr,'\\');	/*	Falls eine Datei Åbergeben...	*/
			if((filename)&&(filename[1]))
				AddLibrarie(ptr);
			ptr=next;
		}while(*next);
		lbox_set_items(lib_box, (LBOX_ITEM *)mgx_SlbItems);
		lbox_set_asldr(lib_box,lbox_get_afirst(lib_box)+1,rect);
		lbox_update(lib_box,rect);
	}
}

void DD_DialogGetFormat(OBJECT *tree,int obj, unsigned long format[])
/*
	Hier kann an Hand des Objektbaumes und der Objektnummer
	Das gewÅnschte Daten-Format angegeben werden.
*/
{
int i;
	(void)tree;
	(void)obj;
	for(i=0;i<MAX_DDFORMAT;i++)
		format[i]=0L;

	format[0]=(unsigned long)'ARGS';
}
#endif



/*******************************************************/
/****** ST-Guide Kapitelauswahl						  ******/
/*******************************************************/
#if USE_STGUIDE == YES

#include <bgh.h>

char *GetTopic(void)
{
CHAIN_DATA *chain_ptr;
_WORD handle, dummy;
int typ=BGH_USER, gruppe=0, index=-1;
extern void *Help;
char *text_ptr=NULL;
	wind_get(0,WF_TOP,&handle, &dummy, &dummy, &dummy);

	chain_ptr=find_ptr_by_whandle(handle);
	if(!chain_ptr) 		/* Kein offenes Fenster?	*/
		index=0; 			/* user 000 */
	else if(chain_ptr->type==WIN_DIALOG)
	{
		typ=BGH_DIAL;		/* dial <nr. entsprechend dem Dialog>	*/
		for(gruppe=0;((DIALOG_DATA *)chain_ptr)->obj!=tree_addr[gruppe];gruppe++)
			;
/* 	Debug("Gruppe : %d",gruppe);
*/
		text_ptr=BGH_gethelpstring(Help,typ,gruppe,index);
		if(!text_ptr)
		{
			text_ptr=((DIALOG_DATA *)chain_ptr)->title;
		}
	}
	else
	{
		index=0; 			/* user 000 */
	}
	
	if(!text_ptr)
		BGH_gethelpstring(Help,typ,gruppe,index);

	return(text_ptr);
}
#endif



/*******************************************************/
/****** AV Protokoll 									  ******/
/*******************************************************/
#if USE_AV_PROTOCOL != NO
#include <av.h>

void DoVA_START(WORD msg[8])
/*
	Der Server aktiviert das Programm und Åbergibt eine Kommandozeile.
	Evtl. muss mittels ParseData() alles ausgewertet werden.
*/
{
int fromApp;
	if(modal_items<0) 			/* klappt nur, wenn kein modaler Dialog offen ist	*/
	{
	char	*data;
		data=*(char **)&msg[3];
		if(data!=NULL)
		{
			ParseData(data);
			strcpy(tmp_path,data);
			Open(0);
		}
	}

	fromApp=msg[1];
	msg[0]=AV_STARTED;
	msg[1]=ap_id;
	appl_write(fromApp,16,&msg[0]);
}

#if USE_AV_PROTOCOL == 3
void DoVA_Message(int msg[8])
{
	Debug("User Routine fÅr's AV Protokoll");
}
#endif
#endif



