
						EXPORT	hndl_exit
						EXPORT	slct_item
						EXPORT	set_item

						INCLUDE	"WDIALOG.I"
						INCLUDE	"LISTBOX.I"
						INCLUDE	"FNTS.I"
						
						TEXT

;WORD handle_exit( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;d0.w obj
;d1.w clicks
;a0.l dialog
;a1.l events
;4(sp).l data
;Ausgaben:
;d0.w
hndl_exit:			move.l	a2,-(sp)									;Register a2 sichern

						move.l	8(sp),-(sp)								;data
						move.w	d1,-(sp)									;clicks
						move.w	d0,-(sp)									;obj
						move.l	a1,-(sp)									;events
						move.l	a0,-(sp)									;dialog
						
						move.l	DIALOG_handle_exit(a0),a0			;Zeiger auf die Service-Routine
						jsr		(a0)										;WORD (cdecl *)( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
						lea		16(sp),sp								;Stack korrigieren
						
						movea.l	(sp)+,a2
						rts

;void	slct_item( LIST_BOX *box, LBOX_ITEM *item, WORD index, WORD last_state );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;d0.w	index
;d1.w	last_state
;a0.l box
;a1.l item
;Ausgaben:
;-
slct_item:			move.l	a2,-(sp)									;Register a2 sichern


						move.w	d1,-(sp)									;last_state
						move.w	d0,-(sp)									;index
						move.l	LBOX_user_data(a0),-(sp)			;user_data
						move.l	a1,-(sp)									;item
						move.l	LBOX_tree(a0),-(sp)					;tree
						move.l	a0,-(sp)									;box
						
						movea.l	LBOX_slct(a0),a0
						jsr		(a0)										;void	(cdecl *)( void *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD index, WORD last_state );
						lea		20(sp),sp								;Stack korrigieren
						
						movea.l	(sp)+,a2
						rts
						
;WORD	set_item( LIST_BOX *box, LBOX_ITEM *item, WORD index, GRECT *rect );
;Vorgaben:
;Register d0-d2/a0-a1 kînnen verÑndert werden
;Eingaben:
;d0.w	index
;a0.l box
;a1.l item
;4(sp) rect
;Ausgaben:
;d0.w	index fÅr Redraw
set_item:			move.l	a2,-(sp)									;Register a2 sichern

						move.w	LBOX_first_b(a0),-(sp)				;first
						move.l	10(sp),-(sp)							;rect
						move.l	LBOX_user_data(a0),-(sp)			;user_data
						move.w	d0,-(sp)									;index
						move.l	a1,-(sp)									;item
						move.l	LBOX_tree(a0),-(sp)					;tree
						move.l	a0,-(sp)									;box
						
						movea.l	LBOX_set_item(a0),a0
						jsr		(a0)										;WORD	(cdecl *)( void *box, OBJECT *tree, struct _lbox_item *item, WORD index, void *user_data, GRECT *rect, WORD first  );
						lea		24(sp),sp								;Stack korrigieren
						
						movea.l	(sp)+,a2
						rts

						END