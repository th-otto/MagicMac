#ifndef NULL
#define NULL        ( ( void * ) 0L )
#endif

extern int vdi_handle;
extern WORD rc_intersect(GRECT *p1, GRECT *p2);
extern WORD xy_in_grect( WORD x, WORD y, GRECT *g );