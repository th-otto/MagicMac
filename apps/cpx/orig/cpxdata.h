/*  CPX DATA STRUCTURES
 *==========================================================================
 *  XCPB structure is passed TO the CPX
 *  CPXINFO structure pointer is returned FROM the CPX
 *
 *  xcpb structure is initialized in XCONTROL.C
 */

typedef struct {
	WORD x;
	WORD y;
	WORD buttons;
	WORD kstate;
} MRETS;

#ifndef NUM_TREE
struct foobar { _WORD dummy; _WORD *image; };
#endif

typedef struct {
/*   0 */     short handle;
/*   2 */     short booting;
/*   4 */     short reserved;  
/*   6 */     short SkipRshFix;

/*   8 */     void    *cdecl (*Get_Head_Node)( void );	    /* ON distribution disk...         */
/*  12 */     BOOLEAN cdecl (*Save_Header)( void *ptr );  /* These 2 would be void *reserved */
     
/*  16 */     void  cdecl (*rsh_fix)( int num_obs, int num_frstr, int num_frimg,
      		       int num_tree, OBJECT *rs_object, 
                       TEDINFO *rs_tedinfo, BYTE *rs_strings[],
                       ICONBLK *rs_iconblk, BITBLK *rs_bitblk,
                       long *rs_frstr, long *rs_frimg, long *rs_trindex,
                       struct foobar *rs_imdope );
                       
/*  20 */     void  cdecl (*rsh_obfix)( OBJECT *tree, int curob );

/*  24 */     short cdecl (*Popup)( char *items[], int num_items, int default_item,
                     int font_size, GRECT *button, GRECT *world );

/*  28 */     void  cdecl (*Sl_size)( OBJECT *tree, int base, int slider, int num_items,
                             int visible, int direction, int min_size );
     
/*  32 */     void  cdecl (*Sl_x)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void cdecl (*foo)(void) );
                    
/*  36 */     void  cdecl (*Sl_y)( OBJECT *tree, int base, int slider, int value,
                          int num_min, int num_max, void cdecl (*foo)(void) );
                    
/*  40 */     void  cdecl (*Sl_arrow)( OBJECT *tree, int base, int slider, int obj,
                              int inc, int min, int max, int *numvar,
                              int direction, void cdecl (*foo)(void) );
                        
/*  44 */     void  cdecl (*Sl_dragx)( OBJECT *tree, int base, int slider, int min,
     			      int max, int *numvar, void cdecl (*foo)(void) );
                        
/*  48 */     void  cdecl (*Sl_dragy)( OBJECT *tree, int base, int slider, int min,
                              int max, int *numvar, void cdecl (*foo)(void) );
     
/*  52 */     WORD    cdecl (*Xform_do)( OBJECT *tree, WORD start_field, WORD puntmsg[] );
/*  56 */     GRECT   *cdecl (*GetFirstRect)( GRECT *prect );
/*  60 */     GRECT   *cdecl (*GetNextRect)( void );
     
/*  64 */     void    cdecl (*Set_Evnt_Mask)( int mask, MOBLK *m1, MOBLK *m2, long time );
/*  68 */     BOOLEAN cdecl (*XGen_Alert)( int id );
/*  72 */     BOOLEAN cdecl (*CPX_Save)( void *ptr, long num );
/*  76 */     void    *cdecl (*Get_Buffer)( void );

/*  80 */     int     cdecl (*getcookie)( long cookie, long *p_value );
  
/*  84 */     int     Country_Code;        
     
/*  86 */     void    cdecl (*MFsave)( BOOLEAN saveit, MFORM *mf );
} XCPB;


/*
 * codes for XGen_Alert
 */
#define CPX_SAVE_DEFAULTS	0
#define CPX_MEM_ERR			1
#define CPX_FILE_ERR		2
#define CPX_FILE_NOT_FOUND  3
#define CPX_NO_NODES_ERR	4
#define CPX_RELOAD_CPXS		5
#define CPX_UNLOAD_CPX		6
#define CPX_NO_RELOAD		7
#define CPX_SAVE_HEADER		8
#define CPX_FILE_NOT_CPX	9
#define CPX_NO_SOUND_DMA	10
#define CPX_SHUTDOWN		11


typedef struct {
     BOOLEAN	cdecl (*cpx_call)( GRECT *work );
     
     void	cdecl (*cpx_draw)( GRECT *clip );
     void	cdecl (*cpx_wmove)( GRECT *work );
     
     void	cdecl (*cpx_timer)( int *event );
     void	cdecl (*cpx_key)( int kstate, int key, int *event );
     void	cdecl (*cpx_button)( MRETS *mrets, int nclicks, int *event );
     void	cdecl (*cpx_m1)( MRETS *mrets, int *event );
     void	cdecl (*cpx_m2)( MRETS *mrets, int *event );
     BOOLEAN	cdecl (*cpx_hook)( int event, int *msg, MRETS *mrets,
                	 	   int *key, int *nclicks );

     void  	cdecl (*cpx_close)( BOOLEAN flag );
} CPXINFO;





/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `tree' must be an OBJECT *
 */
#define SPECIAL		0x40 /* user defined object state */

#define ObNext(obj)	( tree[(obj)].ob_next )
#define ObHead(obj)	( tree[(obj)].ob_head )
#define ObTail(obj)	( tree[(obj)].ob_tail )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj)	( tree[(obj)].ob_spec )
#define TedText(obj)	( tree[(obj)].ob_spec->te_ptext )
#define TedTemp(obj)	( tree[(obj)].ob_spec->te_ptmplt )
#define TedLen(obj)	( tree[(obj)].ob_spec->te_txtlen )
#define TedTempLen(obj)	( tree[(obj)].ob_spec->te_tmplen )

#define TedJust( obj )  ( tree[(obj)].ob_spec->te_just )
#define TedFont( obj )  ( tree[(obj)].ob_spec->te_font )
#define TedColor( obj ) ( tree[(obj)].ob_spec->te_color )

#define ObString(obj)	( tree[(obj)].ob_spec.free_string )
#define ObX(obj) 	( tree[(obj)].ob_x )
#define ObY(obj) 	( tree[(obj)].ob_y )
#define ObW(obj) 	( tree[(obj)].ob_width )
#define ObH(obj) 	( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(tree[(obj)].ob_x)) )


#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&tree) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define IsSelected(obj)		( ObState(obj) & SELECTED )
#define IsEditable(obj)		( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)		( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( tree = newtree )
#define IsDisabled(obj)		( ObState(obj) & DISABLED )
#define IsActiveTree( newtree ) ( tree == newtree )

/* macros ok when object is not on screen
 */
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define NoEdit(obj)		( ObFlags(obj) &= ~EDITABLE )
#define Select(obj)		( ObState(obj) |= SELECTED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )
#define Enable(obj)		( ObState(obj) &= ~DISABLED )
#define MarkObj(obj)		( ObState(obj) |= SPECIAL  )
#define UnmarkObj(obj)		( ObState(obj) &= ~SPECIAL  )
#define SetNormal(obj)		( ObState(obj) = NORMAL	   )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )
#define MakeExit( obj )		( ObFlags(obj) |= EXIT )
#define NoExit( obj )		( ObFlags(obj) &= ~EXIT )


/* Shorthand macro to pass parameters for objc_draw() */
#define PTRS(r) r->g_x, r->g_y, r->g_w, r->g_h
#define ELTS(r) r.g_x, r.g_y, r.g_w, r.g_h



#define VERTICAL	0
#define HORIZONTAL	1
#define NULLFUNC	((void cdecl(*)(void))0)

#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND	3

#define MFSAVE 1
#define MFRESTORE 0


/* Additional define from XFORM_DO() */
#define CT_KEY		53
