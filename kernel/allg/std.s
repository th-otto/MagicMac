/*
*
* Dieses Modul enthaelt allgemeine Routinen von MagiC, die von
* von mehreren anderen Modulen verwendet werden.
*
* Die Routinen, die der Aufrufkonvention von PureC entsprechen,
* sind mit "PUREC" gekennzeichnet.
*
*/


	XDEF vmemcpy
	XDEF memmove
	XDEF	fast_clrmem
	XDEF	toupper
	XDEF stricmp
	XDEF	strlen
	XDEF strchr
	XDEF	strrchr
	XDEF	strcmp
	XDEF	vstrcpy
	XDEF strcat
	XDEF strncpy
	XDEF	_ltoa
	XDEF	_sprintf

	XDEF	ext_8_3,int_8_3
	XDEF	fn_name
	XDEF	ffind

	XDEF mmalloc
	XDEF mfree
	XDEF mshrink
	XDEF	smalloc,smfree,smshrink
	XDEF dgetdrv
	XDEF dpathconf
	XDEF dopendir
	XDEF	dclosedir
	XDEF dxreaddir
	XDEF fxattr
	XDEF dgetpath
	XDEF drvmap

	XDEF	putch
	XDEF putstr
	XDEF crlf
	XDEF hexl
	XDEF getch

	XDEF	date2str

* aus MATH

	XREF	_lmul,_ldiv

* aus MALLOC

	XREF	Mxalloc,Mxfree,Mxshrink

* aus MAGIDOS

	XREF	datemode			; fuer date2str


	INCLUDE	"dos.inc"
	INCLUDE	"errno.inc"
	INCLUDE	"kernel.inc"
	INCLUDE	"..\dos\magicdos.inc"

dev_vecs		EQU $51e		/* long dev_vecs[8*4]		*/

	TEXT

**********************************************************************
*
* PUREC void putstr( a0 = char *s )
*

putstr:
 move.b	(a0)+,d0
 beq.b	puts_ende
 bsr.b 	putch
 bra.b	putstr
puts_ende:
 rts


**********************************************************************
*
* PUREC void putch( d0 = char c)
*

putch:
 move.l	a2,-(sp)				; wg. PureC
 andi.w   #$00ff,d0
 move.l   a0,-(sp)
 move.w   d0,-(sp)
 move.w   #2,-(sp)                 ; CON
 move.l   dev_vecs+$68,a0          ; Bconout CON
 jsr      (a0)
 addq.l   #4,sp
 move.l   (sp)+,a0
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* void crlf( void )
*

crlf:
 moveq	#$d,d0
 bsr.b	putch
 moveq	#$a,d0
 bra.b	putch


**********************************************************************
*
* void hexl( d0 = long i )
*

hexl:
 move.l	d0,-(sp)
 swap	d0					; Hiword
 bsr.b	hexw
 move.l	(sp)+,d0				; Loword
;bra 	hexw


**********************************************************************
*
* void hexw( d0 = int i )
*

hexw:
 movem.l	d6/d7,-(sp)
 move.w	d0,d7
 moveq	#4-1,d6				; 4 Hex- Stellen
hexw_loop:
 rol.w	#4,d7				; hoechstes Nibble in die unteren 4 Bit
 move.w	d7,d0
 bsr.b	_hex
 dbra	d6,hexw_loop
 movem.l	(sp)+,d6/d7
 rts

_hex:
 andi.w	#$f,d0
 addi.b	#'0',d0
 cmpi.b	#'9',d0
 ble.b	_hex_1
 addi.b	#'A'-'0'-10,d0
_hex_1:
 bra 	putch


**********************************************************************
*
* LONG getch( void )
*

getch:
 move.w	#2,-(sp)				; CON
 move.w	#2,-(sp)
 trap	#$d
 addq.w	#4,sp
 rts


**********************************************************************
*
* PUREC void fast_clrmem(a0 = void *von, a1 = void *bis )
*
* Wird vom DOS aufgerufen
*

fast_clrmem:
 movem.l  d3/d4/d5/d6/d7/a2/a3,-(sp)
 moveq    #0,d1
 moveq    #0,d2
 moveq    #0,d3
 moveq    #0,d4
 moveq    #0,d5
 moveq    #0,d6
 moveq    #0,d7
 movea.w  d7,a3
 move.l   a0,d0
 btst     #0,d0
 beq.b    fclr_even
 move.b   d1,(a0)+
fclr_even:
 move.l   a1,d0
 sub.l    a0,d0
 and.l    #$ffffff00,d0
 beq.b    fclr_loop2
 lea      0(a0,d0.l),a0
 movea.l  a0,a2
 lsr.l    #8,d0
fclr_loop:
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 movem.l  d1/d2/d3/d4/d5/d6/d7/a3,-(a2)
 subq.l   #1,d0
 bne.b    fclr_loop
fclr_loop2:
 cmpa.l   a0,a1
 beq.b    fclr_ende
 move.b   d1,(a0)+
 bra.b    fclr_loop2
fclr_ende:
 movem.l  (sp)+,a3/a2/d7/d6/d5/d4/d3
 rts


**********************************************************************
*
* PUREC void vmemcpy(void *dst, void *src, size_t len)
*
* void vmemcpy(a0 = void *dst, a1 = void *src, d0 = unsigned long len
*
* aendert nur d1/a0/a1
*

vmemcpy:
 move.l d0,d1
 beq.b	mcp_end
 cmpa.l	a0,a1
 bcs.b	mcp_dir2
mcp_loop1:
 move.b	(a1)+,(a0)+
 subq.l	#1,d1
 bne.b	mcp_loop1
mcp_end:
 rts
mcp_dir2:
 adda.l	d1,a0
 adda.l	d1,a1
mcp_loop2:
 move.b	-(a1),-(a0)
 subq.l	#1,d1
 bne.b	mcp_loop2
 rts


**********************************************************************
*
* PUREC void memmove(void *dst, void *src, size_t len)
*
* void memmove(a0 = void *dst, a1 = void *src, d0 = unsigned long len
*

memmove:
 tst.l    d0
 beq      mmov_2BE
 move.l   a0,-(sp)
 cmpa.l   a0,a1
 bhi      mmov_1DA
 beq      mmov_2BC
 adda.l   d0,a1
 adda.l   d0,a0
 move.w   a1,d1
 move.w   a0,d2
 btst     #0,d1
 beq.b    mmov_106
 btst     #0,d2
 bne.b    mmov_10E
mmov_FC:
 move.b   -(a1),-(a0)
 subq.l   #1,d0
 bne.b    mmov_FC
 bra      mmov_2BC
mmov_106:
 btst     #0,d2
 bne.b    mmov_FC
 bra.b    mmov_116
mmov_10E:
 move.b   -(a1),-(a0)
 subq.l   #1,d0
 beq      mmov_2BC
mmov_116:
 move.l   d0,d1
 lsr.l    #5,d1
 lsr.l    #4,d1
 beq      mmov_1B4
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
mmov_124:
 movem.l  -$28(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$50(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$78(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$a0(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$c8(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$f0(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$118(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$140(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$168(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$190(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$1b8(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$1e0(a1),a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(a0)
 movem.l  -$200(a1),a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4,-(a0)
 suba.w   #$200,a1
 subq.l   #1,d1
 bne      mmov_124
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
mmov_1B4:
 move.w   d0,d1
 and.w    #$1ff,d0
 lsr.w    #2,d0
 beq.b    mmov_1C6
 subq.w   #1,d0
mmov_1C0:
 move.l   -(a1),-(a0)
 dbf      d0,mmov_1C0
mmov_1C6:
 and.w    #3,d1
 beq      mmov_2BC
 subq.w   #1,d1
mmov_1D0:
 move.b   -(a1),-(a0)
 dbf      d1,mmov_1D0
 bra      mmov_2BC
mmov_1DA:
 move.w   a1,d1
 move.w   a0,d2
 btst     #0,d1
 beq.b    mmov_1F4
 btst     #0,d2
 bne.b    mmov_1FC
mmov_1EA:
 move.b   (a1)+,(a0)+
 subq.l   #1,d0
 bne.b    mmov_1EA
 bra      mmov_2BC
mmov_1F4:
 btst     #0,d2
 bne.b    mmov_1EA
 bra.b    mmov_200
mmov_1FC:
 move.b   (a1)+,(a0)+
 subq.l   #1,d0
mmov_200:
 move.l   d0,d1
 lsr.l    #5,d1
 lsr.l    #4,d1
 beq      mmov_29C
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,-(sp)
mmov_20E:
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$28(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$50(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$78(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$a0(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$c8(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$f0(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$118(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$140(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$168(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$190(a0)
 movem.l  (a1)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4/a5/a6,$1b8(a0)
 movem.l  (a1)+,a4/a3/d7/d6/d5/d4/d3/d2
 movem.l  d2/d3/d4/d5/d6/d7/a3/a4,$1e0(a0)
 adda.w   #$200,a0
 subq.l   #1,d1
 bne      mmov_20E
 movem.l  (sp)+,a6/a5/a4/a3/d7/d6/d5/d4/d3/d2
mmov_29C:
 move.w   d0,d1
 and.w    #$1ff,d0
 lsr.w    #2,d0
 beq.b    mmov_2AE
 subq.w   #1,d0
mmov_2A8:
 move.l   (a1)+,(a0)+
 dbf      d0,mmov_2A8
mmov_2AE:
 and.w    #3,d1
 beq.b    mmov_2BC
 subq.w   #1,d1
mmov_2B6:
 move.b   (a1)+,(a0)+
 dbf      d1,mmov_2B6
mmov_2BC:
 movea.l  (sp)+,a0
mmov_2BE:
 rts


**********************************************************************
*
* char toupper(d0 = char c)
*
*  veraendert nur d0!
*

toupper:
 cmp.b	#'a',d0
 bcs.b	toup_nix
 cmp.b	#'z',d0
 bhi.b	toup_sonder
 bclr	#5,d0
toup_nix:
 rts
toup_sonder:
 move.l	a0,-(sp)
 lea 	sonder_s(pc),a0
toup_loop:
 tst.b	(a0)
 beq.b	toup_ende 			; nicht gefunden, nicht konvertieren
 cmp.b	(a0)+,d0
 bne.b	toup_loop 			; weitersuchen
 move.b	14(a0),d0 			; gefunden, konvertieren
toup_ende:
 move.l	(sp)+,a0
 rts

sonder_s:
 DC.B	'',$84,'',$94,'',$81,'',$82,'',$85,'',$86,'',$87,'',$91,'',$a4,'',$b0,'',$b1,'',$b3,'',$b4,'',$c0,'',0
 DC.B	'',$8e,'',$99,'',$9a,'',$90,'',$b6,'',$8f,'',$80,'',$92,'',$a5,'',$b7,'',$b8,'',$b2,'',$b5,'',$c1,'',0


**********************************************************************
*
* PUREC WORD vstrcpy(char *dst, char *src)
*

vstrcpy:
 move.b	(a1)+,(a0)+
 bne.b	vstrcpy
 rts


**********************************************************************
*
* PUREC WORD strcmp(char *s1, char *s2)
*
* int strcmp(a0 = char *s1, a1 = char *s2)
*
* aendert nur a0/a1
*

strcmp:
 clr.w	d0
smp_loop:
 move.b	(a0),d1
 cmp.b	(a1)+,d1
 bne.b	smp_endloop
 tst.b	(a0)+
 beq.b	smp_ende
 bra.b	smp_loop
smp_endloop:
 move.b	(a0),d0
 ext.w	d0
 move.b	-1(a1),d1
 ext.w	d1
 sub.w	d1,d0
smp_ende:
 rts


**********************************************************************
*
* PUREC WORD stricmp(const char *s1, const char *s2 )
*

stricmp:
 moveq	#0,d0
stricmp_loop:
 move.b	(a0),d0
 bsr.s	toupper
 move.b	d0,d1
 move.b	(a1)+,d0
 bsr.s	toupper
 cmp.b	d0,d1
 bne.b	stricmp_endloop
 tst.b	(a0)+
 beq.b	stricmp_ende
 bra.b	stricmp_loop
stricmp_endloop:
 ext.w	d1
 ext.w	d0
 sub.w	d0,d1
 move.w	d1,d0
stricmp_ende:
 rts


**********************************************************************
*
* PUREC LONG strlen(const char *string)
*
* long strlen(a0 = char *string)
*
* aendert a1/a0/d0
*

strlen:
 move.l	a0,a1
str1:
 tst.b	(a0)+
 bne.b	str1
 suba.l	a1,a0
 move.l	a0,d0
 subq.l	#1,d0
 rts


**********************************************************************
*
* PUREC char * strchr(const char *string, int c)
*
* a0 = char * strchr(a0 = char *string, d0 = char c)
*
* aendert nur a0
*

strchr:
 cmp.b	(a0),d0
 beq.b	strchr_ende
 tst.b	(a0)+			; Ende ?
 bne.b	strchr
 suba.l	a0,a0
strchr_ende:
 rts


**********************************************************************
*
* PUREC char * strrchr(const char *string, char c)
*
* a0 = char * strrchr(a0 = char *string, d0 = char c)
*
* aendert a1/a0
*

strrchr:
 suba.l	a1,a1			; noch nix gefunden
strr_loop:
 cmp.b	(a0),d0
 bne.b	strr_not
 move.l	a0,a1			; gefunden
strr_not:
 tst.b	(a0)+			; Ende ?
 bne.b	strr_loop
 move.l	a1,a0
 rts


**********************************************************************
*
* PUREC void strcat( char *dst, char *src )
*
* aendert nur a0/a1
*

strcat:
 tst.b	(a0)+
 bne.b	strcat
 subq.l	#1,a0
strcat_loop:
 move.b	(a1)+,(a0)+
 bne.b	strcat_loop
 rts


**********************************************************************
*
* PUREC void strncpy( char *dest, const char *src, UWORD maxlen );
*

strncpy:
 subq.w	#1,d0
 bcs.b	strncpy_ende
strncpy_loop:
 move.b	(a1)+,(a0)+
 dbeq	d0,strncpy_loop
strncpy_ende:
 rts


**********************************************************************
*
* a0 =  char *_ltoa( d0 = long l, a0 = char *s)
*
* PUREC char *_ltoa( LONG l, char *s )
*
* Wandelt eine Zahl in eine Zeichenkette um und gibt den Zeiger
* auf EOS zurueck.
*

_ltoa:
 movem.l	d4/d5/d6/a6,-(sp)
 move.l	a0,a6
 move.l	d0,d4
 bpl.b	lta_plus
 move.b	#'-',(a6)+
 neg.l	d4
lta_plus:
 moveq	#0,d5
 suba.w	#$10,sp
lta_loop1:
 tst.l	d4
 beq.b	lta_endloop1
 moveq	#10,d1
 move.l	d4,d0
 jsr 	_ldiv
 move.l	d0,d6			; d6 = zahl / 10
 moveq	#10,d1
 jsr 	_lmul
 move.l	d4,d2
 sub.l	d0,d2			; d2 = zahl % 10
 add.w	#'0',d2
 move.b	d2,0(sp,d5.w)
 addq.w	#1,d5
 move.l	d6,d4
 bra.b	lta_loop1
lta_endloop1:
 subq.w	#1,d5			; Zahl war 0 ?
 bge.b	lta_loop2			; nein, 
 move.b	#'0',(a6)+		; nur Null uebergeben
 bra.b	lta_ende
lta_loop2:
 move.b	0(sp,d5.w),(a6)+
 dbf 	d5,lta_loop2
lta_ende:
 adda.w	#$10,sp
 clr.b	(a6)
 move.l	a6,a0
 movem.l	(sp)+,d4/d5/d6/a6
 rts


**********************************************************************
*
* PUREC void date2str(  a0 = char *s, d0 = WORD date )
*
* Das DOS-Datum wird umgewandelt in
*	tt.mm.jj
*	 .. (usw.) ..
*
* datemode[0] enthaelt den Code 0=MTJ 1=TMJ 2=JMT 3=JTM
* datemode[1] enthaelt das Trennzeichen
*

date2str:
 moveq	#'0',d1
 move.b	datemode.w,d2
 subq.b	#1,d2
 beq.b	d2s_1
 move.l	a0,a1			; Zeiger s merken
 bsr.b	d2s_1			; erstmal TMJ
 move.b	datemode.w,d2
 beq.b	d2s_0
 subq.b	#2,d2
 beq.b	d2s_2

* Modus JTM

 move.b	(a1),d2			; T retten
 move.b	6(a1),(a1)		; J->T
 move.b	3(a1),6(a1)		; M->J
 move.b	d2,3(a1)			; T->M
 addq.l	#1,a1
 move.b	(a1),d2			; T retten
 move.b	6(a1),(a1)		; J->T
 move.b	3(a1),6(a1)		; M->J
 move.b	d2,3(a1)			; T->M
 rts

* Modus MTJ

d2s_0:
 move.b	(a1),d2			; TM tauschen
 move.b	3(a1),(a1)
 move.b	d2,3(a1)
 addq.l	#1,a1
 move.b	(a1),d2
 move.b	3(a1),(a1)
 move.b	d2,3(a1)
 rts

* Modus JMT

d2s_2:
 move.b	(a1),d2			; TJ tauschen
 move.b	6(a1),(a1)
 move.b	d2,6(a1)
 addq.l	#1,a1
 move.b	(a1),d2
 move.b	6(a1),(a1)
 move.b	d2,6(a1)
 rts

* Modus TMJ

d2s_1:
 moveq	#0,d2			; Hiword loeschen
 move.w	d0,d2
 andi.w	#31,d2			; d2 = Tag
 lsr.w	#5,d0
 divu	#10,d2
 add.b	d1,d2
 move.b	d2,(a0)+			; Tag*10
 swap	d2
 add.b	d1,d2
 move.b	d2,(a0)+			; Tag
 move.b	(datemode+1).w,(a0)+	; Trennzeichen
 moveq	#0,d2			; Hiword loeschen
 move.w	d0,d2
 andi.w	#15,d2			; d2 = Monat
 lsr.w	#4,d0
 divu	#10,d2
 add.b	d1,d2
 move.b	d2,(a0)+			; Monat*10
 swap	d2
 add.b	d1,d2
 move.b	d2,(a0)+			; Monat
 move.b	(datemode+1).w,(a0)+	; Trennzeichen
 addi.w	#80,d0
 andi.l	#$0000ffff,d0		; Hiword loeschen
 divu	#100,d0
 clr.w	d0
 swap	d0				; Jahrhunderte loeschen, nur 0..99
 divu	#10,d0
 add.b	d1,d0
 move.b	d0,(a0)+			; Jahr*10
 swap	d0
 add.b	d1,d0
 move.b	d0,(a0)+			; Jahr
 clr.b	(a0)
 rts


**********************************************************************
*
* void _sprintf(char *dest, char *source, long p[])
*
* Schreibt einen String <source> nach <dest> und setzt dabei Werte
* wie "%W" und "%L" ein. p zeigt auf "long"s, die jeweils als
* signed (!!) long oder unsigned int bzw. Zeichenketten interpretiert
* werden.
*

_sprintf:
 movem.l	a3/a4/a5,-(sp)
 movem.l	$10(sp),a5/a4/a3		; a3 = dst
							; a4 = src
							; a5 = p[]
_spr_loop:
 tst.b	(a4)
 beq 	_spr_ende 			; Zeichenketten- Ende
 cmpi.b	#'%',(a4)
 beq.b	_spr_perc
_spr_cpy:
 move.b	(a4)+,(a3)+			; einfach kopieren
 bra.b	_spr_loop
* % gefunden
_spr_perc:
 addq.l	#1,a4
 cmpi.b	#'%',(a4) 			; zweites %
 beq.b	_spr_cpy
 move.b	(a4)+,d0				; naechstes Zeichen nach %
 cmp.b	#'L',d0
 bne.b	_spr_w1
* %L einsetzen
 move.l	(a5)+,d0				; "long" holen
 bra.b	_spr_long
_spr_w1:
 cmp.b	#'W',d0
 bne.b	_spr_w2
* %W einsetzen
 moveq	#0,d0
 move.w	(a5)+,d0				; "unsigned int" holen
 addq.l	#2,a5
 bra.b	_spr_long
_spr_w2:
 cmp.b	#'S',d0
 bne.b	_spr_loop
* %S einsetzen
 movea.l	(a5)+,a0
_spr_sloop:
 tst.b	(a0) 				; ohne EOS kopieren
 beq.b	_spr_loop
 move.b	(a0)+,(a3)+
 bra.b	_spr_sloop
_spr_long:
 move.l	a3,a0
;move.l	d0,d0
 bsr		_ltoa
 move.l	a0,a3
 bra 	_spr_loop

_spr_ende:
 clr.b	(a3)
 movem.l	(sp)+,a5/a4/a3
 rts


**********************************************************************
*
* void ext_8_3(a0 = char *dst_name, a1 = char *src_int_name)
*
* Wandelt einen Dateinamen der Form 8+3 aus einem 8+3 Eingabefeld
* um in die "normale" Darstellung mit '.'
*

ext_8_3:
 moveq	#7,d0
e83_namloop:
 move.b	(a1)+,d1
 beq.b	e83_ende
 cmpi.b	#' ',d1
 beq.b	e83_space
 move.b	d1,(a0)+
e83_space:
 dbf 	d0,e83_namloop
 move.b	(a1)+,d1
 beq.b	e83_ende
 cmpi.b	#' ',d1
 beq.b	e83_ende
 move.b	#'.',(a0)+
 moveq	#2,d0
 bra.b	e83_put2
e83_extloop:
 move.b	(a1)+,d1
 beq.b	e83_ende
 cmpi.b	#' ',d1
 beq.b	e83_ende
e83_put2:
 move.b	d1,(a0)+
 dbf		d0,e83_extloop
e83_ende:
 clr.b	(a0)
 rts


**********************************************************************
*
* void int_8_3(a0 = char *dst_int_name, a1 = char *src_name)
*
* Wandelt einen "normalen" Dateinamen mit '.' in die interne
* Form 8+3 fuer ein 8+3 Eingabefeld um.
*

int_8_3:
 moveq	#7,d0
i83_namloop:
 tst.b	(a1)
 beq.b	i83_endnamloop
 cmpi.b	#'.',(a1)
 beq.b	i83_endnamloop
 move.b	(a1)+,(a0)+
 dbf 	d0,i83_namloop
 bra.b	i83_ext
i83_endnamloop:
 tst.b	(a1)
 beq.b	nti_eos
i83_sp_loop:
 move.b	#' ',(a0)+
 dbf 	d0,i83_sp_loop
i83_ext:
 tst.b	(a1)+
 beq.b	nti_eos
i83_ext_loop:
 tst.b	(a1)
 beq.b	nti_eos
 move.b	(a1)+,(a0)+
 bra.b	i83_ext_loop
nti_eos:
 clr.b	(a0)
 rts


**********************************************************************
*
* a1 = char* mk_fname(a0 = char *buf, a1 = char *path, a2 = char *name)
*
* Setzt einen kompletten Pfadnamen aus Pfad und Dateinamen
* zusammen. Der Pfad ist mit EOS oder ';' abgeschlossen.
* Pfad leer => alles leer.
*

mk_fname:
 move.l	a0,d1				; Pfadanfang merken
mkf_loop1:
 move.b	(a1)+,d0
 cmpi.b	#';',d0
 bne.b	mkf_cp
 moveq	#0,d0				; ';' wie EOS	
mkf_cp:
 move.b	d0,(a0)+				; Pfad kopieren
 bne.b	mkf_loop1
 subq.l	#1,a0				; a0 auf EOS
 subq.l	#1,a1				; a1 auf EOS oder ';'
 cmp.l	a0,d1				; Pfad leer?
 beq.b	mkf_err				; ja, nichts liefern
 cmpi.b	#$5c,-1(a0)
 beq.b	mkf_cat
 cmpi.b	#':',-1(a0)
 beq.b	mkf_cat
 move.b	#$5c,(a0)+
mkf_cat:
 move.b	(a2)+,(a0)+
 bne.b	mkf_cat
 rts
mkf_err:
 clr.b	(a0)
 rts


**********************************************************************
*
* ULONG ffind(a0 = char *path, d0 = WORD mode, d1 = XATTR *xa,
*			a1 = char **srchpaths, a2 = char **srchpathlists)
*
* Sucht eine Datei.
*
* Bit 0:	suche die Datei woertlich, wenn ein Pfad	angegeben wurde.
* Bit 1:	suche in den angegebenen Suchpfaden, deren Liste durch NULL
*		abgeschlossen wurde.
* Bit 2:	suche im aktuellen Verzeichnis
* Bit 3:	suche in den angegebenen Pfadlisten (jeweils Pfade durch ';'
*		getrennt), die durch NULL abgeschlossen wurde.
*
* Wenn die Datei gefunden wurde, wird in a0 der gefundene Pfad
* eingetragen und <xa> initialisiert.
* <xa> wird in jedem Fall zerstoert.
* Rueckgabe: EFILNF oder E_OK.
*

ffind:
 movem.l	d5/d6/d7/a3/a4/a5/a6,-(sp)
 suba.w	#130,sp
 move.l	a0,a6			; a6 = path
 move.l	d1,d5			; d5 = xa
 move.l	a1,a4			; a4 = srchpaths
 move.l	a2,d6			; d6 = srchpathlists
 move.w	d0,d7			; d7 = mode

;move.l	a0,a0
 bsr		fn_name
 move.l	a0,a3			; a3 = reiner Dateiname
 tst.b	(a3)
 beq		ffi_efilnf		; leerer Name wird nie gefunden

* Datei woertlich suchen, wenn ein Pfad angegeben wurde

 btst	#0,d7
 beq.b	ffi_2			; weiter
 cmp.l	a6,a3
 bls.b	ffi_2			; kein Pfad angegeben

 move.l	d5,-(sp)			; xa
 move.l	a6,-(sp)			; path
 clr.w	-(sp)
 gemdos	Fxattr
 adda.w	#12,sp
 tst.l	d0
 beq 	ffi_ok			; gefunden

* Suche in den angegebenen Suchpfaden

ffi_2:
 btst	#1,d7
 beq.b	ffi_3
ffi_2loop:
 move.l	(a4)+,d0			; Suchpfad
 beq.b	ffi_3			; Ende der Liste
 move.l	a3,a2			; name
 move.l	d0,a1			; pfad
 lea		(sp),a0			; buf
 bsr		mk_fname			; Name zusammenbauen

 move.l	d5,-(sp)			; xa
 pea		4(sp)			; path
 clr.w	-(sp)
 gemdos	Fxattr
 adda.w	#12,sp
 tst.l	d0
 beq 	ffi_ok_cp			; gefunden

 bra.b	ffi_2loop			; naechster Suchpfad

* Suche im aktuellen Verzeichnis

ffi_3:
 btst	#2,d7
 beq.b	ffi_4
 move.l	d5,-(sp)			; xa
 move.l	a3,-(sp)			; nur name
 clr.w	-(sp)
 gemdos	Fxattr
 adda.w	#12,sp
 tst.l	d0
 move.l	a3,a0
 beq 	ffi_okloop		; gefunden

* Suche in den angegebenen Suchpfadlisten

ffi_4:
 btst	#1,d7
 beq.b	ffi_efilnf
 move.l	d6,a4
ffi_4loop:
 move.l	(a4)+,d0			; Suchpfad
 beq.b	ffi_efilnf		; Ende der Liste
 move.l	d0,a5			; a5 = suchpfad
ffi_4_loop2:
 move.l	a3,a2			; name
 move.l	a5,a1			; pfad
 lea		(sp),a0			; buf
 bsr		mk_fname			; Name zusammenbauen
 move.l	a1,a5			; Zeiger auf ';' oder EOS

 tst.b	(sp)				; leerer Name?
 beq.b	ffi_4_nxt			; ja, ueberspringen

 move.l	d5,-(sp)			; xa
 pea		4(sp)			; path
 clr.w	-(sp)
 gemdos	Fxattr
 adda.w	#12,sp
 tst.l	d0
 beq 	ffi_ok_cp			; gefunden

ffi_4_nxt:
 tst.b	(a5)+
 bne.b	ffi_4_loop2		; naechster Pfad in Liste
 bra.b	ffi_4loop			; naechster Suchpfad

* ENDE

ffi_efilnf:
 moveq	#EFILNF,d0
 bra.b	ffi_ende
ffi_ok_cp:
 move.l	sp,a0
ffi_okloop:
 move.b	(a0)+,(a6)+		; lokalen Pfadpuffer zurueckgeben
 bne.b	ffi_okloop
ffi_ok:
 moveq	#E_OK,d0
ffi_ende:
 adda.w	#130,sp
 movem.l	(sp)+,d5/d6/d7/a3/a4/a5/a6
 rts


**********************************************************************
*
* PUREC char *fn_name( char *path )
*
* a0/d0 = char *fn_name(a0 = char *path)
*
* ermittelt zu einem kompletten Pfadnamen den reinen Dateinamen
* und gibt ihn in a0 und d0 zurueck.
*
* veraendert nicht a2
*

fn_name:
 movea.l	a0,a1
fnn_loop1:
 tst.b	(a0)+
 bne.b	fnn_loop1
fnn_loop2:
 move.b	-(a0),d0
 cmpa.l	a1,a0
 bcs.b	fnn_ende
 cmp.b	#$5c,d0
 beq.b	fnn_ende
 cmp.b	#':',d0
 bne.b	fnn_loop2
fnn_ende:
 addq.l	#1,a0
 move.l	a0,d0
 rts


**********************************************************************
*
* PUREC LONG smalloc( ULONG size)
*
* EQ/NE void *smalloc(d0 = unsigned long size)
*
* Wie <malloc>, aber ohne Limit und ohne Taskwechsel.
* Immer: TT-RAM preferred.
*

smalloc:
 move.l	a2,-(sp)
 move.l	act_pd.l,a1
 move.w	#$2003,d1			; Bit 13: nolimit
 jsr		Mxalloc			; ->MALLOC
 move.l	d0,a0			; wg. PureC
 tst.l	d0
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* long smshrink(a0 = void *memblk, d0 = long size )
*
* PUREC LONG smshrink( void *memblk, LONG size )
*
* Wie mshrink, aber ohne Limit und ohne Taskwechsel
*

smshrink:
 move.l	a2,-(sp)
 suba.l	a1,a1			; kein Limit
;move.l	a0,a0
;move.l	d0,d0
 jsr		Mxshrink
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* PUREC void smfree( a0 = void *memblk )
*
* Wie <mfree>, aber ohne Limit und ohne Taskwechsel.
*

smfree:
 move.l	a2,-(sp)
 suba.l	a1,a1			; kein Limit
 jsr		Mxfree			; ->MALLOC
 move.l	(sp)+,a2
 rts


**********************************************************************
*
* PUREC LONG mmalloc( ULONG size)
*
* EQ/NE void *mmalloc(d0 = unsigned long size)
*
* Die Rueckgabeadresse und Groesse ist immer gerade, weil GEMDOS
* darauf achtet.
* Setzt das Z- Flag, falls zuwenig Speicher
*

mmalloc:
;move.l	a2,-(sp)
 move.l	d0,-(sp)
 move.w	#$48,-(sp)
 trap	#1				; gemdos Malloc
 addq.w	#6,sp
;move.l	(sp)+,a2
 move.l d0,a0
 tst.l	d0
 rts


**********************************************************************
*
* long mfree(a0 = void *memblk)
*
* PUREC LONG mfree( void *memblk )
*

mfree:
 move.l	a0,-(sp)
 move.w	#$49,-(sp)
 trap	#1
 addq.l	#6,sp
 rts


**********************************************************************
*
* long mshrink(a0 = void *memblk, d0 = long size )
*
* PUREC LONG mshrink( void *memblk, LONG size )
*

mshrink:
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 clr.w	-(sp)
 move.w	#$4a,-(sp)
 trap	#1
 lea		12(sp),sp
 rts


**********************************************************************
*
* PUREC WORD dgetdrv( void )
*

dgetdrv:
 move.w	#$19,-(sp)
 trap	#1
 addq.l	#2,sp
 rts


**********************************************************************
*
* LONG dpathconf(char *path, WORD which)
*

dpathconf:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.w	#$124,-(sp)
 trap	#1
 addq.l	#8,sp
 rts


**********************************************************************
*
* PUREC LONG dopendir( char *path, WORD tosflag )
*

dopendir:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.w	#$128,-(sp)
 trap	#1
 addq.l	#8,sp
 rts


**********************************************************************
*
* PUREC LONG dxreaddir( WORD len, LONG dirhandle, char *buf,
*					XATTR *xattr, LONG *xr )
*

dxreaddir:
 move.l	4(sp),-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	d1,-(sp)
 move.w	d0,-(sp)
 move.w	#$142,-(sp)
 trap	#1
 lea		20(sp),sp
 rts


**********************************************************************
*
* PUREC LONG dclosedir( LONG dirhandle )
*

dclosedir:
 move.l	d0,-(sp)
 move.w	#$12b,-(sp)
 trap	#1
 addq.l	#6,sp
 rts


**********************************************************************
*
* PUREC LONG fxattr( WORD mode, char *path, XATTR *xattr )
*

fxattr:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.w	d0,-(sp)
 move.w	#$12c,-(sp)
 trap	#1
 lea		12(sp),sp
 rts


**********************************************************************
*
* PUREC LONG dgetpath( char *buf, WORD drv )
*

dgetpath:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.w	#$47,-(sp)
 trap	#1
 addq.l	#8,sp
 rts


**********************************************************************
*
* PUREC LONG drvmap( void )
*

drvmap:
 move.w	#10,-(sp)
 trap	#13
 addq.l	#2,sp
 rts

	END
