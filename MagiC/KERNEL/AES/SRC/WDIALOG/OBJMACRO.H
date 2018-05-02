/*----------------------------------------------------------------------------------------*/ 
/* Objektmanipulation																							*/
/*----------------------------------------------------------------------------------------*/ 
#define	obj_NORMAL( tree, obj )				tree[obj].ob_state &= 0xff00

#define	obj_SELECTED( tree, obj )			tree[obj].ob_state |= SELECTED
#define	obj_DESELECTED( tree, obj )		tree[obj].ob_state &= ~SELECTED

#define	obj_DISABLED( tree, obj )			tree[obj].ob_state |= DISABLED
#define	obj_ENABLED( tree, obj )			tree[obj].ob_state &= ~DISABLED

#define	obj_SELECTABLE( tree, obj )		tree[obj].ob_flags |= SELECTABLE
#define	obj_NOT_SELECTABLE( tree, obj )	tree[obj].ob_flags &= ~SELECTABLE

#define	obj_DEFAULT( tree, obj )			tree[obj].ob_flags |= DEFAULT
#define	obj_NOT_DEFAULT( tree, obj )		tree[obj].ob_flags &= ~DEFAULT

#define	obj_EXIT( tree, obj )				tree[obj].ob_flags |= EXIT
#define	obj_NOT_EXIT( tree, obj )			tree[obj].ob_flags &= ~EXIT

#define	obj_EDITABLE( tree, obj )			tree[obj].ob_flags |= EDITABLE
#define	obj_NOT_EDITABLE( tree, obj )		tree[obj].ob_flags &= ~EDITABLE

#define	obj_TOUCHEXIT( tree, obj )			tree[obj].ob_flags |= TOUCHEXIT
#define	obj_NOT_TOUCHEXIT( tree, obj )	tree[obj].ob_flags &= ~TOUCHEXIT

#define	obj_HIDDEN( tree, obj )				tree[obj].ob_flags |= HIDETREE
#define	obj_VISIBLE( tree, obj )			tree[obj].ob_flags &= ~HIDETREE


/*----------------------------------------------------------------------------------------*/ 
/* Objektstatus																									*/
/*----------------------------------------------------------------------------------------*/ 
#define	is_obj_NORMAL( tree, obj )			( tree[obj].ob_state & 0xff )

#define	is_obj_SELECTED( tree, obj )		( tree[obj].ob_state & SELECTED )
#define	is_obj_DESELECTED( tree, obj )	!( tree[obj].ob_state & SELECTED )

#define	is_obj_DISABLED( tree, obj )		( tree[obj].ob_state & DISABLED )
#define	is_obj_ENABLED( tree, obj )		!( tree[obj].ob_state & DISABLED )

#define	is_obj_SELECTABLE( tree, obj )	( tree[obj].ob_flags & SELECTABLE )
#define	is_obj_NOT_SELECTABLE( tree, obj )	!( tree[obj].ob_flags & SELECTABLE )

#define	is_obj_DEFAULT( tree, obj )		( tree[obj].ob_flags & DEFAULT )
#define	is_obj_NOT_DEFAULT( tree, obj )	!( tree[obj].ob_flags & DEFAULT )

#define	is_obj_EXIT( tree, obj )			( tree[obj].ob_flags & EXIT )
#define	is_obj_NOT_EXIT( tree, obj )		!( tree[obj].ob_flags & EXIT )

#define	is_obj_EDITABLE( tree, obj )		( tree[obj].ob_flags & EDITABLE )
#define	is_obj_NOT_EDITABLE( tree, obj )	!( tree[obj].ob_flags & EDITABLE )

#define	is_obj_TOUCHEXIT( tree, obj )		( tree[obj].ob_flags & TOUCHEXIT )
#define	is_obj_NOT_TOUCHEXIT( tree, obj )	!( tree[obj].ob_flags & TOUCHEXIT )

#define	is_obj_HIDDEN( tree, obj )			( tree[obj].ob_flags & HIDETREE )
#define	is_obj_VISIBLE( tree, obj )		!( tree[obj].ob_flags & HIDETREE )
