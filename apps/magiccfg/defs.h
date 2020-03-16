#define	MPATHMAX	256

#define	RECHTS			0
#define	LINKS				1
#define	LOOK3D			0
#define	LOOK2D			2
#define	SHOW_BD			0
#define	HIDE_BD			4
#define	TITEL_LINES		0
#define	TITEL_PATTERN	8
#define	TITEL_3D			0
#define	TITEL_NORMAL	16
#define	REAL_SCROLL		0
#define	NORM_SCROLL		32
#define	REAL_MOVE		0
#define	NORM_MOVE		64
#define	MENU_2D			0
#define  MENU_3D			128



typedef struct _env_var
{
	struct _env_var *next;
	int	selected;
	int	active;
	char	var;
}ENV_VAR;

typedef struct _lib_item
{
	struct _lib_item *next;
	int	selected;
	int	version;
	char	str;
}LIB_ITEM;



/*
 *		addi.c
 */
extern	FONTSEL_DATA *fnt_dialog;
extern	long MagiC_Version;
extern	unsigned long MagiC_Date;

int CheckSystem(void);
int CreateFNTS(void);

/*
 *		file.c
 */
extern char	mgx_path[], mgx_filename[];
extern char	tmp_path[];
extern char	mgx_Pfade[][MPATHMAX];
extern char	mgx_fsl_mask[256];
extern long	mgx_version,mgx_shl_buf_size,mgx_res_dev, mgx_res_mode,
		mgx_flags,mgx_win_cnt,mgx_tsl_time, mgx_tsl_prior,	mgx_fsl_mode,
		mgx_desk_back,	mgx_vfat_drives,mgx_txs_id, mgx_txs_aqui, mgx_txs_h,
		mgx_txb_id, mgx_txb_aqui, mgx_txb_h,mgx_obs_ow, mgx_obs_oh, 
		mgx_obs_bw, mgx_obs_bh,	mgx_inw_objh, mgx_inw_fontid, 
		mgx_inw_mflag, mgx_inw_fonth;
extern char	mgx_bootlog[],mgx_image[], mgx_tiles[];
extern long	mgx_cookies;
extern int	open_file,changed;
extern char	*QuellMAGX;
extern ENV_VAR	*mgx_EnvVar;
extern LIB_ITEM *mgx_SlbItems;

void New(void);
void Open(int mode);
int QuitClose(void);
void Close(void);
void Save(void);

/*
 *		fileproc.c
 */
char *BCD_To_ASCII(char *ptr, long num);
void LoadMAGX(char *buf);
int SaveMAGX(char *dst,char *src);

/*
 *		getinfo.c
 */
/*int GetFont(long *FontId, long *PtSize);*/

/*
 *		dial_xxx.c
 */
WORD cdecl HandleAbout( struct HNDL_OBJ_args args);
WORD cdecl HandleMain( struct HNDL_OBJ_args args );
void GetMainDialogItems(void);

extern	int	font_object;
extern	DIALOG	*font_dialog;
int GetFont(FONTSEL_DATA *fnts);
WORD cdecl HandleFont( struct HNDL_OBJ_args args );
WORD cdecl HandlePath( struct HNDL_OBJ_args args );
WORD cdecl HandleVariables( struct HNDL_OBJ_args args );
WORD cdecl HandleResolution( struct HNDL_OBJ_args args );
WORD cdecl HandleVFat( struct HNDL_OBJ_args args );
WORD cdecl HandleOther( struct HNDL_OBJ_args args );
WORD cdecl HandleBackground( struct HNDL_OBJ_args args );
WORD cdecl HandleBoot( struct HNDL_OBJ_args args );
extern	long	tmp_inw_fontid, tmp_inw_fonth;
WORD cdecl HandleWindow( struct HNDL_OBJ_args args );
WORD cdecl HandleLibraries( struct HNDL_OBJ_args args );

/*
 *		filefont.c
 */
extern	char	*std_paths,*std_masks;
void LoadFile(FILESEL_DATA *ptr, int nfiles);
void SaveFile(FILESEL_DATA *ptr, int nfiles);
void QuitCloseFile(FILESEL_DATA *ptr, int nfiles);
void NewCloseFile(FILESEL_DATA *ptr, int nfiles);
void OpenCloseFile(FILESEL_DATA *ptr, int nfiles);
int LoadFont(void *ptr);

extern	char *file_mask;
extern	int file_object;
extern	DIALOG *file_dialog;
void GetFile(FILESEL_DATA *ptr, int nfiles);
void GetFolder(FILESEL_DATA *ptr, int nfiles);
void GetAnything(FILESEL_DATA *ptr, int nfiles);
