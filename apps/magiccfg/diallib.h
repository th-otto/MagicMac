#ifndef __DIALOG__
#define __DIALOG__

#define	ON							1
#define	OFF						0
#define	YES						ON
#define	NO							OFF

#define	GERMAN					1
#define	ENGLISH					2
#define	FRENCH					3

#include "SOURCE\DL_USER.H"			/*	Applikationsspezifische Daten	*/

#include RESOURCE_HEADER_FILE			/*	Resource-Header einbinden	*/

#include "SOURCE\DL_MISS.H"			/*	fehlende Definitionen erg„nzen	*/

#define	USE_ITEM				(USE_DIALOG|USE_WINDOW|USE_FILESELECTOR|USE_FONTSELECTOR)

/*	Window-Typen	*/
#define	WIN_WINDOW	1
#define	WIN_DIALOG	2
#define	WIN_FILESEL	3
#define	WIN_FONTSEL	4
#define	WIN_PRINTER	5

/*	USER_DATA status-flags	*/
#define	WIS_OPEN			0x01
#define	WIS_ICONIFY		0x02
#define	WIS_ALLICONIFY	0x04
#define	WIS_FULL			0x10


/*	Window-Messages	*/
#define	WIND_INIT					-1
#define	WIND_OPEN					-2
#define	WIND_EXIT					-4
#define	WIND_CLOSE					-5

#define	WIND_KEYPRESS				-10
#define	WIND_CLICK					-15

#define	WIND_REDRAW					-20
#define	WIND_SIZED					-21
#define	WIND_MOVED					-22
#define	WIND_TOPPED					-23
#define	WIND_NEWTOP					-24
#define	WIND_UNTOPPED				-25
#define	WIND_ONTOP					-26
#define	WIND_BOTTOM					-27

#define	WIND_DRAGDROPFORMAT		-30
#define	WIND_DRAGDROP				-31

#define	WIND_ICONIFY				-40
#define	WIND_UNICONIFY				-41
#define	WIND_ALLICONIFY			-42

#define	WIND_BUBBLE					-50

/*	File Maximum	*/
#define	DL_PATHMAX					256
#define	DL_NAMEMAX					64

/*	AV-Protokoll Flags	*/
#define	AV_P_VA_SETSTATUS		0x01
#define	AV_P_VA_START			0x02
#define	AV_P_AV_STARTED		0x04
#define	AV_P_VA_FONTCHANGED	0x08
#define	AV_P_QUOTING			0x10
#define	AV_P_VA_PATH_UPDATE	0x20

typedef struct _chain_data_
{
	struct _chain_data_	*next;
	struct _chain_data_	*previous;
	int	type;
	int	whandle;
	int	status;
	GRECT last;
}CHAIN_DATA;

typedef struct _dialog_data_
{
	struct _dialog_data_	*next;
	struct _dialog_data_	*previous;
	int	type;
	int	whandle;
	int	status;
	GRECT last;
	DIALOG *dial;
	OBJECT *obj;
	char	*title;
}DIALOG_DATA;

struct _window_data_;
typedef	int (*HNDL_WIN)(struct _window_data_ *wptr, int obj, void *data);

typedef struct _window_data_
{
	struct _window_data_	*next;
	struct _window_data_	*previous;
	int	type;
	int	whandle;
	int	status;
	GRECT full;
	GRECT last;
	HNDL_WIN proc;
	char	*title;
	int	kind;
	int	vdi_handle;
	int	workout[57];
	int	ext_workout[57];
	int	h_max;
	int	v_max;
	int	h_pos;
	int	v_pos;
	int	h_speed;
	int	v_speed;
	void *data;
}WINDOW_DATA;

struct _filesel_data_;
typedef	void (*HNDL_FSL)(struct _filesel_data_ *fslx,int nfiles);

typedef struct _filesel_data_
{
	struct _filesel_data_	*next;
	struct _filesel_data_	*previous;
	int	type;
	int	whandle;
	int	status;
	GRECT last;
	HNDL_FSL proc;
	void *dialog;
	char path[DL_PATHMAX];
	char name[DL_NAMEMAX];
	int	button;
	int	sort_mode;
	int	nfiles;
	void *data;
}FILESEL_DATA;

struct _fontsel_data_;
typedef	int (*HNDL_FONT)(struct _fontsel_data_ *fnts_data);

typedef struct _fontsel_data_
{
	struct _fontsel_data_	*next;
	struct _fontsel_data_	*previous;
	int	type;
	int	whandle;
	int	status;
	GRECT last;
	HNDL_FONT proc;
	FNT_DIALOG *dialog;
	int	font_flag;
	char 	*opt_button;
	int	button,check_boxes;
	long	id,pt,ratio;
	int	vdi_handle;
	void *data;
}FONTSEL_DATA;

/*
 *		DL_INIT.C
 */
extern	int	ap_id;
extern	WORD aes_handle,pwchar,phchar,pwbox,phbox;
extern	WORD has_wlffp,has_iconify;
#if USE_VDI==YES
extern	WORD vdi_handle;
extern	WORD workin[11];
extern	WORD workout[57];
extern	WORD ext_workout[57];
#if SAVE_COLORS==YES
extern	RGB1000 save_palette[256];
#endif
#endif
extern	char	*resource_file,*err_loading_rsc;
extern	RSHDR	*rsh;
extern	OBJECT	**tree_addr;
extern	int	tree_count;
extern	char	**string_addr;
#if USE_MENU==YES
extern	OBJECT	*menu_tree;
#endif
extern	KEYTAB *key_table;

int DoAesInit(void);
int DoInitSystem(void);
void DoExitSystem(void);

/*
 *		DL_EVENT.C
 */
extern	int	doneFlag;
extern	int	FastOut;
void DoEventDispatch(EVNT *event);
void DoEvent(void);

/*
 *		DL_ITEMS.C
 */
extern	char	*iconified_name;
extern	OBJECT	*iconified_tree;
extern	int	iconified_icon;
extern	CHAIN_DATA	*iconified_list[MAX_ICONIFY_PLACE];
extern	int	iconified_count;
extern	CHAIN_DATA	*all_list;
extern	int	modal_items;
extern	_WORD modal_stack[MAX_MODALRECURSION];

void add_item(CHAIN_DATA *item);
void remove_item(CHAIN_DATA *item);
void FlipIconify(void);
void AllIconify(int handle, GRECT *r);
void CycleItems(void);
void RemoveItems(void);
void ModalItem(void);
void ItemEvent(EVNT *event);
CHAIN_DATA *find_ptr_by_whandle(int handle);


/*
 *		DL_MENU.C
 */
void ChooseMenu(int title, int entry);

/*
 *		DL_DIAL.C
 */
DIALOG *OpenDialog(HNDL_OBJ proc,OBJECT *tree,char *title,int x, int y);
void SendCloseDialog(DIALOG *dial);
void CloseDialog(DIALOG_DATA *ptr);
void CloseAllDialogs(void);
void RemoveDialog(DIALOG_DATA *ptr);

void DialogEvents(DIALOG_DATA *ptr,EVNT *event);
void SpecialMessageEvents(DIALOG *dialog,EVNT *event);

void dialog_iconify(DIALOG *dialog, GRECT *r);
void dialog_uniconify(DIALOG *dialog, GRECT *r);

DIALOG_DATA *find_dialog_by_obj(OBJECT *tree);
DIALOG_DATA *find_dialog_by_whandle(int handle);

/*
 *		DL_WIN.C
 */
WINDOW_DATA *OpenWindow(HNDL_WIN proc, int kind, char *title, int max_w, int max_h, GRECT *open_data,void *user_data);
void CloseWindow(WINDOW_DATA *ptr);
void CloseAllWindows(void);
void RemoveWindow(WINDOW_DATA *ptr);
void ScrollWindow(WINDOW_DATA *ptr, int rel_x, int rel_y);
void WindowEvents(WINDOW_DATA *ptr, EVNT *event);
void SetWindowSlider(WINDOW_DATA *ptr);
void ResizeWindow(WINDOW_DATA *ptr, int max_h, int max_v);
void IconifyWindow(WINDOW_DATA *ptr,GRECT *r);
void UniconifyWindow(WINDOW_DATA *ptr,GRECT *r);
void ClickWindow(EVNT *event);
WINDOW_DATA *find_openwindow_by_whandle(int handle);
WINDOW_DATA *find_window_by_whandle(int handle);
WINDOW_DATA *find_window_by_proc(HNDL_WIN proc);

/*
 *		DL_FILSL.C
 */
void *OpenFileselector(HNDL_FSL proc,char *comment,char *filepath,char *path,char *pattern,short mode);
void FileselectorEvents(FILESEL_DATA *ptr,EVNT *event);
void RemoveFileselector(FILESEL_DATA *ptr);

/*
 *		DL_FONSL.C
 */
extern char fnts_std_text[80];
FONTSEL_DATA *CreateFontselector(HNDL_FONT proc,int font_flag,char *sample_text,char *opt_button);
int OpenFontselector(FONTSEL_DATA *ptr,int button_flag,long id,long pt,long ratio);
void CloseFontselector(FONTSEL_DATA *ptr);
void RemoveFontselector(FONTSEL_DATA *ptr);
void FontselectorEvents(FONTSEL_DATA *ptr,EVNT *event);

/*
 *		DL_AV.C
 */
#if USE_AV_PROTOCOL != NO
void DoVA_START(WORD msg[8]);			/*	minimales AV-Protokoll	*/

#if USE_AV_PROTOCOL >= 2				/*	normales/maximales AV-Protokoll	*/
void DoVA_PROTOSTATUS(int msg[8]);
void DoAV_PROTOKOLL(int flags);
void DoAV_EXIT(void);
#endif

#endif

/*
 *		DL_AVCMD.C
 */
void DoAV_GETSTATUS(void);
void DoAV_STATUS(char *string);
void DoAV_SENDKEY(int kbd_state, int code);
void DoAV_ASKFILEFONT(void);
void DoAV_ASKCONFONT(void);
void DoAV_ASKOBJECT(void);
void DoAV_OPENCONSOLE(void);
void DoAV_OPENWIND(char *path, char *wildcard);
void DoAV_STARTPROG(char *path, char *commandline, int id);
void DoAV_ACCWINDOPEN(int handle);
void DoAV_ACCWINDCLOSED(int handle);
void DoAV_COPY_DRAGGED(int kbd_state, char *path);
void DoAV_PATH_UPDATE(char *path);
void DoAV_WHAT_IZIT(int x,int y);
void DoAV_DRAG_ON_WINDOW(int x,int y, int kbd_state, char *path);
void DoAV_STARTED(char *ptr);
void DoAV_XWIND(char *path, char *wild_card, int bits);
void DoAV_VIEW(char *path);
void DoAV_FILEINFO(char *path);
void DoAV_COPYFILE(char *file_list, char *dest_path,int bits);
void DoAV_DELFILE(char *file_list);
void DoAV_SETWINDPOS(int x,int y,int w,int h);
void DoAV_SENDCLICK(EVNTDATA *mouse, int ev_return);

/*
 *		DL_DRAG.C
 */
void DragDrop(WORD msg[]);

/*
 *		DL_BUBBL.C
 */
void DoInitBubble(void);
void DoExitBubble(void);
void Bubble(int mx,int my);

/*
 *		DL_HELP.C
 */
void STGuideHelp(void);

/*
 *		DL_LEDIT.C
 */
void DoInitLongEdit(void);
void DoExitLongEdit(void);

/*
 *		DL_CFGRD.C
 */
int CfgOpenFile(char *path);
void CfgCloseFile(void);
void CfgWriteFile(char *path);
char *CfgGetLine(char *src);
char *CfgGetVariable(char *variable);
char *CfgExtractVarPart(char *start,char separator,int num);
int CfgSaveMemory(long len);
int CfgSetLine(char *line);
int CfgSetVariable(char *name,char *value);

/*
 *		DL_DHST.C
 */
void DhstAddFile(char *path);
void DhstFree(WORD msg[]);

/*
 *		DL_ROUTS.C
 */
void ConvertKeypress(int *key,int *kstate);
void CopyMaximumChars(OBJECT *obj,char *str);
char *ParseData(char *start);
void Debug(char *str,...);

/*
 *		DL_USER.C
 */
typedef struct
{
	int	tree;
	int	obj;
	int	len;
	XTED	xted;
}LONG_EDIT;

extern LONG_EDIT long_edit[];
extern int long_edit_count;

int DoUserKeybd(int kstate, int scan, int ascii);
void DoButton(EVNT *event);
void DoUserEvents(EVNT *event);
void SelectMenu(int title, int entry);
void DD_Object(DIALOG *dial,GRECT *rect,OBJECT *tree,int obj, char *data, unsigned long format);
void DD_DialogGetFormat(OBJECT *tree,int obj, unsigned long format[]);
char *GetTopic(void);
void DoVA_START(WORD msg[8]);
void DoVA_Message(int msg[8]);


#endif