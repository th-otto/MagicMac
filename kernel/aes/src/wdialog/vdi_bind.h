typedef struct
{
	WORD	x1,
			y1,
			x2,
			y2;
}VRECT;

typedef struct
{
	LONG	size;					/* LÑnge der Struktur, muû vor vqt_xfntinfo() gesetzt werden */
	WORD	format;				/* Fontformat, z.B. 4 fÅr TrueType */
	WORD	id;					/* Font-ID, z.B. 6059 */
	WORD	index;				/* Index */
	BYTE	font_name[50];		/* vollstÑndiger Fontname, z.B. "Century 725 Italic BT" */
	BYTE	family_name[50];	/* Name der Fontfamilie, z.B. "Century725 BT" */
	BYTE	style_name[50];	/* Name des Fontstils, z.B. "Italic" */
	BYTE	file_name1[200];	/* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF" */
	BYTE	file_name2[200];	/* Name der optionalen 2. Fontdatei */
	BYTE	file_name3[200];	/* Name der optionalen 3. Fontdatei */
	WORD	pt_cnt;				/* Anzahl der Punkthîhen fÅr vst_point(), z.B. 10 */
	WORD	pt_sizes[64];		/* verfÅgbare Punkthîhen, z.B. { 8, 9, 10, 11, 12, 14, 18, 24, 36, 48 } */
} XFNT_INFO;

WORD	vqt_ext_name( WORD handle, WORD index, BYTE *name, UWORD *font_format, UWORD *flags );
WORD	vqt_xfntinfo( WORD handle, WORD flags, WORD id, WORD index, XFNT_INFO *info );

void	rect_sort( VRECT *rect );
WORD	rect_intersect( VRECT *rect1, VRECT *rect2, VRECT *dst );
