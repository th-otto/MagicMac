; pc_xfs.s vom 23.06.1996
;
; Autor:
; Thomas Binder
; (binder@rbg.informatik.th-darmstadt.de)
;
; Zweck:
; Assembler-Teil der Pure-C-Schnittstelle fÅr MagiC-3-Filesysteme.
; Alle Elemente der MX_XFS- und der MX_DEV-Struktur werden als Pure-
; C-kompatible Funktionsaufrufe realisiert. Bei den Funktionen der
; Schnittstellen, die mehr als ein Funktionsergebnis liefern, werden
; entsprechend temporÑre Long-Arrays zur Ablage der weiteren
; Ergebnisse bereitgestellt. Eine genau Beschreibung, wie diese
; Schnittstelle zu benutzen ist, findet sich in der Begleit-
; dokumentation.
;
; History:
; 04.11.-
; 05.11.1995: Erstellung
; 06.11.1995: "Frontends" fÅr die Kernel-Funktionen eingebaut, da
;             diese leider nicht alle fÅr Pure C nîtigen Register
;             retten (genauer: A2 kann verÑndert werden).
; 11.11.1995: my_sprintf korrigiert: Die Parameter werden jetzt
;             richtig auf dem Stack Åbergeben.
;             SÑmtliche Frontends der Kernelfunktionen waren falsch,
;             ein Wunder, daû das erst jetzt aufgefallen ist.
; 12.11.1995: fopen, xattr und attrib mÅssen wie sfirst bei Bedarf 
;             in a0 einen Zeiger auf einen symbolischen Link liefern,
;             daher wurden die entsprechenden Frontends angepaût.
; 23.11.1995: Fehler im Frontend fÅr sfirst beseitigt.
; 11.12.1995: Frontends fÅr die neuen Kernelfunktionen DMD_rdevinit
;             und proc_info geschrieben.
; 27.12.1995: Fehler entfernt, der zur Folge hatte, daû der Zeiger
;             auf my_int_malloc teilweise Åberschrieben wurde.
;             my_int_malloc hatte auûerdem bisher den RÅckgabewert
;             im falschen Register geliefert.
; 28.12.1995: chmod, chown und dcntl liefern bei Bedarf ebenfalls in
;             a0 einen Zeiger auf einen symbolischen Link, also
;             wurden die Frontends der beiden Funktionen erweitert.
; 31.12.1995: Der Frontend von path2DD wurde an das neue Parameter-
;             layout angepaût (siehe pc_xfs.h)
; 13.02.1996: Sourcecode aufgerÑumt und fertig kommentiert.
; 16.06.1996: Kein selbstmodifizierender Code mehr fÅr die Aufrufe
;             C-Funktionen als Subroutinen
; 23.06.1996: Wrapper fÅr neue Kernelfunktionen von MagiC 5
;             eingebaut: my_mxalloc, my_mfree und my_mshrink.

	include	"mgx_xfs.inc"

	export	install_xfs
	export	my_xfs

; Makro zum Retten von Registern. Als Parameter erhÑlt es eine Nummer
; und die zu rettenden Register im movem-Format; wird es nur mit
; Nummer benutzt, werden automatisch d1-d2/a0-a1 gerettet. a6 wird
; immer gerettet. Die Nummer hat dabei nur dann eine Bedeutung, wenn
; die erste Zeile des Makros aktiv ist (die standardmaessig durch
; if 0 ausgeklammert ist): Dann wird die Nummer als Long in 0x6f0
; abgelegt, was einem helfen kann, wenn es AbstÅrze gibt und man
; nicht weiû, welche XFS-Funktion nun betroffen ist.
macro pushr number,which
if 0
	move.l	#number,$6f0.w
endif
ifnb which
	movem.l	which/a6,-(sp)
else
	movem.l	d1-d2/a0-a1/a6,-(sp)
endif
endm

; Wie oben, nur ohne Nummer und zum ZurÅckholen der geretteten
; Register
macro popr which
ifnb which
	movem.l	(sp)+,which/a6
else
	movem.l	(sp)+,d1-d2/a0-a1/a6
endif
endm

	text

; install_xfs
;
; Diese Funktion Åbernimmt die Umsetzung der vom C-Programm
; gelieferten XFS-Struktur in das MagiC-Format, meldet das XFS dann
; an und bildet die C-Version der Kernelstruktur.
;
; Eingabe:
; a0: Zeiger auf die THE_MGX_XFS-Struktur, die angemeldet werden soll
;
; RÅckgabe:
; a0: Zeiger auf THE_MX_KERNEL-Struktur, wenn die Anmeldung geklappt
;     hat, sonst 0
install_xfs:

	movem.l	a2-a3,-(sp)
	moveq	#0,d0
; Ist ein Nullzeiger Åbergeben worden, gleich abbrechen
	tst.l	a0
	beq.w	failure

; Ansonsten die einzelnen Funktionspointer und den Namen des XFS
; in die jeweiligen Zielstrukturen eintragen.
	move.l	a0,a2
	lea		my_xfs,a1
	move.l  (a0),(a1)
	move.l  4(a0),4(a1)
	lea		my_cxfs,a3
	lea		xfs_sizeof(a3),a1
copy_xfs:
	move.l	(a2)+,(a3)+
	cmp.l	a3,a1
	bne.s	copy_xfs

; Jetzt das XFS mit der "echten" Struktur per Dcntl anmelden, bei
; Fehler abbrechen
	pea		my_xfs
	clr.l	-(sp)
	move.w	#KER_INSTXFS,-(sp)
	move.w	#$130,-(sp)		; Dcntl
	trap	#1
	lea		12(sp),sp
failure:
	move.l	d0,a0
	movem.l	(sp)+,a2-a3
	rts

; Es folgen jetzt die Routinen, die fÅr die einzelnen XFS-Funktionen
; tatsÑchlich angemeldet sind. Sie rufen die zugehîrigen C-Funktionen
; mit dem richtigen Parameterformat auf und wandeln ggf. die
; RÅckgabewerte in das vom Kernel erwartete Format um. Jede einzelne
; Funktion zu beschreiben schenke ich mir...
my_sync:
	pushr	1
	move.l	my_cxfs+xfs_sync(pc),a6
	jsr		(a6)
	popr
	rts

my_pterm:
	pushr	2
	move.l	my_cxfs+xfs_pterm,a6
	jsr		(a6)
	popr
	rts

my_garbcoll:
	pushr	3
	move.l	my_cxfs+xfs_garbcoll,a6
	jsr		(a6)
	popr
	rts

my_freeDD:
	pushr	4
	move.l	my_cxfs+xfs_freeDD,a6
	jsr		(a6)
	popr
	rts

my_drv_open:
	pushr	5
	move.l	my_cxfs+xfs_drv_open,a6
	jsr		(a6)
	popr
	rts

my_drv_close:
	pushr	6
	move.l	my_cxfs+xfs_drv_close,a6
	jsr		(a6)
	popr
	rts

my_path2DD:
	pushr	7,d2
	lea		-12(sp),sp
	pea		8(sp)
	pea		8(sp)
	pea		8(sp)
	move.l	my_cxfs+xfs_path2DD,a6
	jsr		(a6)
	lea		12(sp),sp
	move.l	(sp)+,d1
	move.l	(sp)+,a0
	move.l	(sp)+,a1
	popr	d2
	rts

my_sfirst:
	pushr	8,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	my_cxfs+xfs_sfirst,a6
	jsr		(a6)
	addq.l	#8,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_snext:
	pushr	9,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_snext,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_fopen:
	pushr	10,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_fopen,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_fdelete:
	pushr	11
	move.l	my_cxfs+xfs_fdelete,a6
	jsr		(a6)
	popr
	rts

my_link:
	pushr	12
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	move.w	d2,d0
	move.l	my_cxfs+xfs_link,a6
	jsr		(a6)
	addq.l	#8,sp
	popr
	rts

my_xattr:
	pushr	13,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	my_cxfs+xfs_xattr,a6
	jsr		(a6)
	addq.l	#8,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_attrib:
	pushr	14,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_attrib,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_chown:
	pushr	15,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_chown,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_chmod:
	pushr	16,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_chmod,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

my_dcreate:
	pushr	17
	move.l	my_cxfs+xfs_dcreate,a6
	jsr		(a6)
	popr
	rts

my_ddelete:
	pushr	18
	move.l	my_cxfs+xfs_ddelete,a6
	jsr		(a6)
	popr
	rts

my_DD2name:
	pushr	19
	move.l	my_cxfs+xfs_DD2name,a6
	jsr		(a6)
	popr
	rts

my_dopendir:
	pushr	20
	move.l	my_cxfs+xfs_dopendir,a6
	jsr		(a6)
	popr
	rts

my_dreaddir:
	pushr	21
	move.l	d2,-(sp)
	move.l	d1,-(sp)
	move.l	my_cxfs+xfs_dreaddir,a6
	jsr		(a6)
	addq.l	#8,sp
	popr
	rts

my_drewinddir:
	pushr	22
	move.l	my_cxfs+xfs_drewinddir,a6
	jsr		(a6)
	popr
	rts

my_dclosedir:
	pushr	23
	move.l	my_cxfs+xfs_dclosedir,a6
	jsr		(a6)
	popr
	rts

my_dpathconf:
	pushr	24
	move.l	my_cxfs+xfs_dpathconf,a6
	jsr		(a6)
	popr
	rts

my_dfree:
	pushr	25
	move.l	my_cxfs+xfs_dfree,a6
	jsr		(a6)
	popr
	rts

my_wlabel:
	pushr	26
	move.l	my_cxfs+xfs_wlabel,a6
	jsr		(a6)
	popr
	rts

my_rlabel:
	pushr	27
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	my_cxfs+xfs_rlabel,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_symlink:
	pushr	28
	move.l	d0,-(sp)
	move.l	my_cxfs+xfs_symlink,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_readlink:
	pushr	29
	move.l	d0,-(sp)
	move.w	d1,d0
	move.l	my_cxfs+xfs_readlink,a6
	jsr		(a6)
	addq.l	#4,sp
	popr
	rts

my_dcntl:
	pushr	30,a1/d1-d2
	clr.l	-(sp)
	pea		(sp)
	move.l	my_cxfs+xfs_dcntl,a6
	jsr		(a6)
	addq.l	#4,sp
	move.l	(sp)+,a0
	popr	a1/d1-d2
	rts

	data

; Diese Struktur wird tatsÑchlich beim Kernel angemeldet und enthÑlt
; Zeiger auf die weiter oben zu findenen Aufrufroutinen
my_xfs:
	dc.b	0,0,0,0,0,0,0,0	; xfs_name
	dc.l	0				; xfs_next
	dc.l	0				; xfs_flags
	dc.l	0				; xfs_init
	dc.l	my_sync			; xfs_sync
	dc.l	my_pterm		; xfs_pterm
	dc.l	my_garbcoll		; xfs_garbcoll
	dc.l	my_freeDD		; xfs_freeDD
	dc.l	my_drv_open		; xfs_drv_open
	dc.l	my_drv_close	; xfs_drv_close
	dc.l	my_path2DD		; xfs_path2DD
	dc.l	my_sfirst		; xfs_sfirst
	dc.l	my_snext		; xfs_snext
	dc.l	my_fopen		; xfs_fopen
	dc.l	my_fdelete		; xfs_fdelete
	dc.l	my_link			; xfs_link
	dc.l	my_xattr		; xfs_xattr
	dc.l	my_attrib		; xfs_attrib
	dc.l	my_chown		; xfs_chown
	dc.l	my_chmod		; xfs_chmod
	dc.l	my_dcreate		; xfs_dcreate
	dc.l	my_ddelete		; xfs_ddelete
	dc.l	my_DD2name		; xfs_DD2name
	dc.l	my_dopendir		; xfs_dopendir
	dc.l	my_dreaddir		; xfs_dreaddir
	dc.l	my_drewinddir	; xfs_drewinddir
	dc.l	my_dclosedir	; xfs_dclosedir
	dc.l	my_dpathconf	; xfs_dpathconf
	dc.l	my_dfree		; xfs_dfree
	dc.l	my_wlabel		; xfs_wlabel
	dc.l	my_rlabel		; xfs_rlabel
	dc.l	my_symlink		; xfs_symlink
	dc.l	my_readlink		; xfs_readlink
	dc.l	my_dcntl		; xfs_dcntl

	BSS

; In diese Tabelle werden spÑter von install_xfs die Adressen der
; XFS-C-Funktionen eingetragen, um sie in den vorgeschalteten
; Assemblerroutinen ohne Offsetberechnungen anspringen zu kînnen.
my_cxfs:
	ds.b xfs_sizeof
