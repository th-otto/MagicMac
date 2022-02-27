	XDEF	strgcat
	XDEF	strgcmp
	XDEF	strgcpy
	XDEF	strglen
	XDEF	strgint
	XDEF	copy_mem
	XDEF	strgupr
	XDEF	clear_mem
	XDEF	intstrg
	XDEF	fill_mem
	XDEF	copy_mem_aln

	TEXT

;void	clear_mem( LONG len, void *s );
;Bytes loeschen
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l	Anzahl der Bytes
;a0.l	Adresse
;Ausgaben:
;-
clear_mem:
	move.l	d0,d1
	moveq	#0,d0

;void  *fill_mem( void *s, WORD val, LONG len );
;Speicher mit Bytes fuellen
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.w Wert
;d1.l Anzahl der Bytes
;a0.l Startadresse
;Ausgaben:
;a0.l Startadresse
memset: ; not exported!
fill_mem:
	movea.l	a0,a1
	move.l	a0,d2
	and.w	#1,d2
	beq.s	memset_aln
	move.b	d0,(a1)+
	subq.l	#1,d1
	bmi.s	memset_exit
memset_aln:
	move.b	d0,d2
	lsl.w	#8,d2
	move.b	d0,d2
	move.w	d2,d0
	swap	d0
	move.w	d2,d0
	moveq	#3,d2
	and.w	d1,d2
	lsr.l	#2,d1
	bra.s	memset_sub
memset_loop:
	move.l	d0,(a1)+
memset_sub:
	subq.l	#1,d1
	bpl.s	memset_loop
	subq.w	#1,d2
	bmi.s	memset_exit
memset_byte:
	move.b	d0,(a1)+
	subq.w	#1,d2
	bpl.s	memset_byte
memset_exit:
	rts

;void	copy_mem( LONG len, void *s, void *d );
;Bytes kopieren
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l	Anzahl der Bytes
;a0.l	Quelle
;a1.l Ziel
;Ausgaben:
;-
copy_mem:
	moveq	#1,d1
	move.w	a0,d2
	and.w	d1,d2
	bne.s	copy_so
	move.w	a1,d2
	and.w	d1,d2
	beq.s	copy_cnt
	bra.s	copy_sb_sub

copy_pre_byte:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0

copy_cnt:
	moveq	#3,d1
	and.l	d0,d1
	asr.l	#2,d0
	bra.s	copy_a_sub

copy_a_loop:
	move.l	(a0)+,(a1)+
copy_a_sub:
	subq.l	#1,d0
	bpl.s	copy_a_loop
	bra.s	copy_b_sub

copy_b_loop:
	move.b	(a0)+,(a1)+
copy_b_sub:
	subq.w	#1,d1
	bpl.s	copy_b_loop
	rts

copy_so:
	move.w	a1,d2
	and.w	d1,d2
	bne.s	copy_pre_byte
	bra.s	copy_sb_sub

copy_sb_loop:
	move.b	(a0)+,(a1)+
copy_sb_sub:
	subq.l	#1,d0
	bpl.s	copy_sb_loop
	rts

    IFNE 1 /* unused */
;void	copy_mem_aln( LONG len, void *s, void *d );
;Bytes kopieren, Adressen sind gerade und die Anzahl ist eine Vielfache von zwei
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l	Anzahl der Bytes
;a0.l	Quelle
;a1.l Ziel
;Ausgaben:
;-
copy_mem_aln:
	move.l	d0,d1
	asr.l		#2,d1
	bcc.s		copy_ma_sub
	move.w	(a0)+,(a1)+
	bra.s		copy_ma_sub						
copy_ma_loop:
	move.l	(a0)+,(a1)+
	subq.l	#1,d1
copy_ma_sub:
	bpl.s		copy_ma_loop
	rts			
	ENDC

;void	strgcat( void *d, void *s );
;an einen C-String anhaengen
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	Quelle
;a1.l Ziel
;Ausgaben:
;-
strgcat:
strcat: ; not exported!
	tst.b	(a0)+
	bne.s	strgcat
	subq.l	#1,a0

;void	strgcpy( void *d, void *s );
;C-String kopieren
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	Quelle
;a1.l Ziel
;Ausgaben:
;-
strgcpy:
strcpy: ; not exported!
	move.b	(a1)+,(a0)+
	bne.s	strgcpy
	rts

;LONG	strglen( BYTE *s );
;Laenge eines C-Strings ermitteln
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	Adresse
;Ausgaben:
;d0.l Laenge des Strings
strglen:
strlen: ; not exported!
	movea.l	a0,a1
strlen_loop:
	tst.b	(a1)+
	bne.s	strlen_loop
	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
	rts

;WORD strgcmp( BYTE *s1, BYTE *s2 );
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	String 1
;a1.l	String 2
;Ausgaben:
;d0.w Ergebnis
strgcmp:
strcmp: ; not exported!
	moveq	#0,d0
	moveq	#0,d1
strcmp_loop:
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	cmp.w	d1,d0
	blt.s	strcmp_lt	;s1 < s2
	bgt.s	strcmp_gt	;s1 > s2
	or.b	d0,d1
	bne.s	strcmp_loop
strcmp_eq:
	moveq	#0,d0		;s1 == s2
	rts
strcmp_lt:
	moveq	#-1,d0		;s1 < s2
	rts
strcmp_gt:
	moveq	#1,d0		;s1 > s2
	rts

;BYTE	*strgupr( BYTE *s );
;C-String in Grossbuchstaben umwandeln
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	String
;Ausgaben:
;a0.l String
    IFNE 1 /* unused */
strgupr:
strupr: ; not exported!
	movea.l	a0,a1
strupr_loop:
	move.b	(a1),d0
	cmp.b	#97,d0		; lower case
	blt.s	strupr_save
	cmp.b	#122,d0		;a-z ?
	bgt.s	strupr_ae
	sub.b	#32,d0			;A-Z
	bra.s	strupr_save
strupr_ae:
	cmp.b	#132,d0 ; lowercase ae
	bne.s	strupr_oe
	move.b	#142,d0
	bra.s	strupr_save
strupr_oe:
	cmp.b	#148,d0 ; lowercase ue
	bne.s	strupr_ue
	move.b	#153,d0
	bra.s	strupr_save
strupr_ue:
	cmp.b	#129,d0 ; lowercase oe
	bne.s	strupr_save
	move.b	#154,d0
strupr_save:
	move.b	d0,(a1)+
	bne.s	strupr_loop
	rts
	ENDC


;BYTE	*intstrg( ULONG i, BYTE *s );
;Zahl in einen C-String umwandeln
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;d0.l Zahl
;a0.l	String
;Ausgaben:
;a0.l String
; NOTE: actually works with shorts only
    IFNE 1 /* ... but is acually unused */
intstrg:
	clr.l	-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	lea		10(sp),a1
intstrg_loop:
	divu	#10,d0
	swap	d0
	add.b	#48,d0
	move.b	d0,-(a1)
	clr.w	d0
	swap	d0
	tst.w	d0
	bne.s	intstrg_loop
	move.l	a0,d0
intstrg_copy:
	move.b	(a1)+,(a0)+
	bne.s	intstrg_copy
	movea.l	d0,a0
	lea		12(sp),sp
	rts
	ENDC


;LONG	strgint( BYTE *s );
;C-String in eine Zahl umwandeln
;Vorgaben:
;Register d0-d2/a0-a1 koennen veraendert werden
;Eingaben:
;a0.l	String
;Ausgaben:
;d0.l Zahl
    IFNE 1 /* unused */
strgint:
	moveq	#0,d0
	moveq	#0,d1
	bra.s	strgint_next
strgint_loop:
	sub.b	#48,d1
	cmp.w	#9,d1				/* Zahl zwischen 0 und 9? */
	bhi.s	strgint_exit
	mulu.w	#10,d0
	add.l	d1,d0
strgint_next:
	move.b	(a0)+,d1
	bne.s	strgint_loop
strgint_exit:
	rts
	ENDC
