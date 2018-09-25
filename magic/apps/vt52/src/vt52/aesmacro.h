/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `rs_object' must be an OBJECT *
 */
#define SPECIAL		0x40 /* user defined object state */

#define ObNext(obj)	( rs_object[(obj)].ob_next )
#define ObHead(obj)	( rs_object[(obj)].ob_head )
#define ObTail(obj)	( rs_object[(obj)].ob_tail )
#define ObFlags(obj)	( rs_object[(obj)].ob_flags )
#define ObState(obj)	( rs_object[(obj)].ob_state )
#define ObSpec(obj)	( rs_object[(obj)].ob_spec )
#define TedText(obj)	( rs_object[(obj)].ob_spec->te_ptext )
#define TedTemp(obj)	( rs_object[(obj)].ob_spec->te_ptmplt )
#define TedLen(obj)	( rs_object[(obj)].ob_spec->te_txtlen )
#define TedTempLen(obj)	( rs_object[(obj)].ob_spec->te_tmplen )

#define TedJust( obj )  ( rs_object[(obj)].ob_spec->te_just )
#define TedFont( obj )  ( rs_object[(obj)].ob_spec->te_font )
#define TedColor( obj ) ( rs_object[(obj)].ob_spec->te_color )

#define ObString(obj)	( rs_object[(obj)].ob_spec.free_string )
#define ObX(obj) 	( rs_object[(obj)].ob_x )
#define ObY(obj) 	( rs_object[(obj)].ob_y )
#define ObW(obj) 	( rs_object[(obj)].ob_width )
#define ObH(obj) 	( rs_object[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(rs_object[(obj)].ob_x)) )


#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&rs_object) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define IsSelected(obj)		( ObState(obj) & SELECTED )
#define IsEditable(obj)		( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)		( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( rs_object = newtree )
#define IsDisabled(obj)		( ObState(obj) & DISABLED )
#define IsActiveTree( newtree ) ( rs_object == newtree )

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
