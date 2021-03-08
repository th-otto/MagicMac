;Import aus READ_INF

     IMPORT    read_inf            ; char *read_inf( void );
     IMPORT    rinf_vfat           ; void rinf_vfa( a0 = char *inf );
     IMPORT    rinf_img            ; void rinf_img( a0 = char *inf );
     IMPORT    rinf_log            ; long rinf_log( a0 = char *inf );
     IMPORT    rinf_coo            ; long rinf_coo( a0 = char *inf );
     IMPORT    rinf_idt            /* long rinf_idt( a0 = char *inf ) */
     IMPORT    rinf_bdev           /* long rinf_bdev( a0 = char *inf ) */
     IMPORT    rinf_dvh            /* long rinf_dvh( a0 = char *inf ) */

	DEB	'Bootlaufwerk setzen'
 bsr 	set_bootdrive			; Bootlaufwerk als aktuelles
;move.l	$bffff,-(sp)			; TOS 3.06
;trap	#$d					; bios Kbshift
;addq.l	#4,sp
;btst	#2,d0				; CTRL ?
;bne.b	no_autop				; ja, AUTO nicht ausfuehren

* Jetzt (ab MagiC 5.01) die magx.inf laden und auswerten

	DEB	'MAGX.INF lesen und auswerten'
 jsr		read_inf
 move.l	d0,p_mgxinf
	DEB	'VFAT konfigurieren'
 move.l	d0,a0
 jsr		rinf_vfat				; lange Dateinamen aktivieren

* Jetzt (ab MagiC 5.13 vom 1.6.97) Tastaturtabellen laden

	DEB	'Tastaturtabellen einlesen'
 bsr		read_keytbl

* Jetzt (ab MagiC 6) Cookie-Tabelle anlegen

	DEB	'neue Cookies anlegen ?'
 move.l	p_mgxinf,a0
 jsr		rinf_coo
 tst.l	d0
 beq.s 	bot_no_coo
 cmpi.l	#NCOOKIES,d0
 bcs.s	bot_no_coo			; Mindestgroesse
	DEB	'ja, neue Cookies anlegen!'
 move.l	d0,-(sp)				; Anzahl merken
 lsl.l	#3,d0				; * 8 wg. 2 LONGs pro Eintrag
 move.l	d0,-(sp)
 gemdos	Malloc
 addq.l	#6,sp
 move.l	(sp)+,d1				; Anzahl zurueck
 tst.l	d0
 beq.b 	bot_no_coo			; nicht genuegend Speicher
 move.l	_p_cookies,a0
 move.l	d0,a1
bot_coo_cp_loop:
 move.l	(a0)+,(a1)+			; Cookie-Schluessel kopieren
 beq.b	bot_coo_cp_ende		; Ende-Zeichen
 move.l	(a0)+,(a1)+
 bra.b	bot_coo_cp_loop
bot_coo_cp_ende:
 move.l	d1,(a1)+				; neue Laenge eintragen
 move.l	d0,a0				; Anfang
 lsl.l	#3,d1				; Anzahl * 8
 add.l	d1,a0				; Block-Ende
bot_coo_clr_loop:
 cmpa.l	a0,a1
 bcc.b	bot_coo_ende
 clr.l	(a1)+
 bra.b	bot_coo_clr_loop
bot_coo_ende:
 move.l	d0,_p_cookies			; Zeiger umsetzen
bot_no_coo:

/* override idt cookie */
 move.l	p_mgxinf,a0
 jsr		rinf_idt
 beq.s      no_idt_val
 move.l     d0,a1            /* save value */
 move.l     #0x5f494454,d0   /* '_IDT' */
 bsr        getcookie
 beq.s      no_idt_val
 move.l     a1,4(a0)         /* overwrite _IDT cookie value */
no_idt_val:

* Jetzt (ab MagiC 6) log-Datei oeffnen

	DEB	'BOOT.LOG ',$94,'ffnen?'
 move.l	p_mgxinf,a0
 jsr		rinf_log				; Log-Datei oeffnen
 move.l	d0,log_fd
 bmi.b	bot_nolog
 move.l	dev_vecs+$68,log_oldconout	; alten Bconout-Vektor merken
 move.l	#bconout_log,dev_vecs+$68; Vektor umsetzen
 move.l	act_pd.l,log_fd_pd			; PD fuer Handle merken
bot_nolog:

* Jetzt (ab MagiC 6) Startbild laden

	DEB	'Startbild laden und anzeigen'
	IFEQ	MACINTOSH
 move.l	#'EdDI',d0			; Behne-Routinen versagen auf dem Milan
 bsr		getcookie
 beq.b	no_eddi
	ENDIF
 move.l	p_mgxinf,a0
 jsr		rinf_img				; Startbild anzeigen
no_eddi:

* Jetzt alle Geraete wieder loeschen (waren nur fuer Hddriver)

 jsr		deleddev

* Jetzt XTENSION-Ordner, dann AUTO-Ordner

	DEB	'Ger',$84,'tetreiber (DEV) laden'
 lea 	devdir_s(pc),a5
 lea 	devpgm_s(pc),a6
 bsr 	auto_programs			; \GEMSYS\MAGIC\XTENSION\*.DEV
	DEB	'Dateisysteme (XFS) laden'
 lea 	xfsdir_s(pc),a5
 lea 	xfspgm_s(pc),a6
 bsr 	auto_programs			; \GEMSYS\MAGIC\XTENSION\*.XFS
	DEB	'BIOS-Ger',$84,'tedateien aus MAGX.INF konfigurieren'
 move.l	p_mgxinf,a0
 jsr		rinf_bdev
	DEB	'Restliche Ger',$84,'tedateien initialisieren'
 jsr		iniddev1
	DEB	'Ger',$84,'te-Handles aus MAGX.INF zuweisen'
 move.l	p_mgxinf,a0
 jsr		rinf_dvh
	DEB	'Restliche Handles des DOS initialisieren'
 jsr		iniddev2
	DEB	'AUTOEXEC.BAT ausf',$81,'hren'
 lea 	autoexec_s(pc),a6
 bsr 	autoexec				; \AUTO\AUTOEXEC.BAT
 tst.w	d0					; ausgefuehrt ?
 beq.b	no_autop				; ja, OK
	DEB	'kein AUTOEXEC.BAT => AUTO-Ordner ausf',$81,'hren'
 lea 	autodir_s(pc),a5
 lea 	autopgm_s(pc),a6
 bsr 	auto_programs			; \AUTO\*.PRG
no_autop:

* Boot-Log schliessen

	DEB	'BOOT.LOG schlie',$9e,'en'
 move.l	log_fd,d0
 bmi.b	bot_nolog2
 move.l	dev_vecs+$68,a1
 cmpa.l	#bconout_log,a1
 bne.b	bot_logchg			; Achtung: Vektor geaendert!
 move.l	log_oldconout,dev_vecs+$68	; Vektor restaurieren
bot_logchg:
 move.w	d0,-(sp)
 gemdos	Fclose
 addq.l	#4,sp
bot_nolog2:

* dann setzen wir den Stack auf den korrekten Wert (TT-RAM!)

 move.l	pgm_superst,sp
 move.l	#syshdr,_sysbase
 tst.w	_cmdload
 beq.b	bot_nocmd 			; kein Kommandoprozessor

* Kommandoprozessor laden

	DEB	'Kommandoprozessor starten'
 pea 	nullstring(pc)
 pea 	nullstring(pc)
 pea 	cmdname(pc)
 move.l	$4b0000,-(sp)			; Pexec : Laden und Starten
 bra		bot_cmd				; statt AES starten

* kein Kommandoprozessor: Environment selbst erzeugen und AES starten

bot_nocmd:
 lea 	environment_pattern(pc),a0
 lea 	deflt_env,a1
bot_envloop:
 cmpi.b	#'#',(a0)
 bne.b	bot_nodcr
 movea.l	a1,a5
bot_nodcr:
 move.b	(a0)+,(a1)+
 bpl.b	bot_envloop
 move.w	#$19,-(sp)
 trap	#1					; gemdos Dgetdrv
 addq.w	#2,sp
 addi.b	#'A',d0
 move.b	d0,(a5)


* Diese Schleife wird beim Aufloesungswechsel
* durchlaufen

resolut_change_loop:
	DEB	'AES ausf',$81,'hren'
	IFNE	MILANCOMP
* CPU-Cache einschalten
 move.w	#1,-(sp)				; enable
 move.w	#5,-(sp)				; set data cache mode
 move.w	#160,-(sp)			; Xbios CachCtrl
 trap	#14
 addq.l	#6,sp

 move.w	#1,-(sp)				; enable
 move.w	#7,-(sp)				; set instruction cache mode
 move.w	#160,-(sp)			; Xbios CachCtrl
 trap	#14
 addq.l	#6,sp
	ENDIF

 pea 	deflt_env
 pea 	aessys_s(pc)			; Prozessname
 pea 	4					; Bit 2, d.h. Malloc vom TT-RAM
 move.w	#107,-(sp)			; Basepage erstellen (+prgflags+name)
 move.w	#$4b,-(sp)
 trap	#1					; gemdos Pexec
 lea 	16(sp),sp
 tst.l	d0
 bmi 	fatal_err 			; Fataler Fehler (zuwenig Speicher ?)
 movea.l	d0,a0
 move.l	exec_os,8(a0)			; TEXT eintragen (AES)
 pea 	deflt_env
 move.l	a0,-(sp)
 pea 	nullstring(pc)
 move.l	#$4b0006,-(sp) 		; Starten mit Modus 6
bot_cmd:
 trap	#1					; gemdos Pexec
 lea 	16(sp),sp

 tst.l	p_mgxinf				; INF-Datei da ?
 bne.b	bot_was_inf			; ja, ist noch eine da
 jsr		read_inf				; INF-Datei neu lesen
 move.l	d0,p_mgxinf
bot_was_inf:
 bra		resolut_change_loop		; war Aufloesungswechsel

;jmp 	sys_start 			; bei Programmende: Reset


**********************************************************************
*
* Bconout(CON) Handler fuer Boot-Log-Datei
*
* MagiC 6.01: Semaphore fuer etv_critic beruecksichtigen
*

bconout_log:
 tst.b	criticret				; Handler aktiv?
 bne.b	bcl_critic			; ja!
 move.l	act_pd.l,-(sp)			; alten Prozesszeiger merken
 move.l	log_fd_pd,act_pd.l		; Prozesszeiger fuer Handle setzen
 pea		11(sp)
 pea		1
 move.w	log_fd+2,-(sp)			; Lobyte ist Handle (prozesslokal!)
 gemdos	Fwrite
 adda.w	#12,sp
 move.l	(sp)+,act_pd.l			; alten Prozesszeiger restaurieren
 rts
bcl_critic:
 move.l	log_oldconout,-(sp)		; springe ueber alten Vektor
 rts


autoexec_s:
 DC.B	$5c,'AUTO',$5c,'AUTOEXEC.BAT',0
autodir_s:
 DC.B	$5c,'AUTO',$5c
autopgm_s:
 DC.B	'*.PRG',0
xfsdir_s:
 DC.B	$5c,'GEMSYS',$5c,'MAGIC',$5c,'XTENSION',$5c
xfspgm_s:
 DC.B	'*.XFS',0
devdir_s:
 DC.B	$5c,'GEMSYS',$5c,'MAGIC',$5c,'XTENSION',$5c
devpgm_s:
 DC.B	'*.DEV',0
aessys_s:
 DC.B	'AESSYS',0
environment_pattern:
 DC.B	'PATH=;#:',$5c,0,0,-1
cmdname:
 DC.B	'COMMAND.PRG',0

;DC.B	'GEM.PRG'
nullstring:
 DC.B	0,0,0

	EVEN


**********************************************************************
*
* void set_bootdrive( void )
*
* GEMDOS hat bei der Initialisierung das Bootlaufwerk als aktuelles
* Laufwerk gesetzt.
* Falls dieses aber nicht existiert, wird es hier auf A: gesetzt.
*

set_bootdrive:
 move.l	_drvbits,d0			; eingetragene Laufwerke
 move.w	_bootdev,d1			; von hier booten
 btst	d1,d0				; Bootlaufwerk eingetragen ?
 bne.b	stbd_ok				; ja, ausfuehren
 tst.w	d1					; Bootdevice ist schon A:
 beq.b	stbd_ok				; ja, nichts tun
 clr.w	_bootdev				; Bootdevice auf A:
 clr.w	-(sp)
 move.w	#$e,-(sp)
 trap	#1					; Dsetdrv
 addq.l	#4,sp
 bra.b	set_bootdrive			; und nochmal versuchen
stbd_ok:
 rts


	INCLUDE "read_ktb.s"


**********************************************************************
*
* long autoexec( a6 = char *pgmname )
*
* Prueft, ob im Verzeichnis <path> eine Datei AUTOEXEC.BAT liegt, und
* fuehrt sie ggf. aus.
* Rueckgabe 0: AUTOEXEC.BAT ausgefuehrt
*		 1: nicht ausgefuehrt
*
* Aufbau der Datei AUTOEXEC.BAT:
*	zeile = Leerzeile
*  oder
*	zeile = programm	; Kommentar
*
* Programm ohne Pfad: Auto-Ordner.
*

XATTR	SET	0
BUF		SET	XATTR+xattr_sizeof
OFFS 	SET	BUF+128

	IF	DEBUG3
__s1: DC.B	'AUTOEXEC.BAT ge',$94,'ffnet',13,10,0
__s2: DC.B	'Fcntl(FSTAT) erfolgreich',13,10,0
__s3: DC.B	'Speicher f',$81,'r AUTOEXEC.BAT alloziert',13,10,0
__s4: DC.B	'AUTOEXEC.BAT geladen',13,10,0
__s5: DC.B	'starte _',0
__s6: DC.B	'_',13,10,0
	EVEN
	ENDIF

autoexec:
 movem.l	a3/a4/d7,-(sp)
 lea 	-OFFS(sp),sp			; Platz fuer Programmnamen und DTA
; Datei zum Lesen oeffnen
 clr.w	-(sp)				; Oeffnen zum Lesen
 move.l	a6,-(sp)				; Pfad
 move.w	#$3d,-(sp)			; Fopen
 trap	#1
 addq.l	#8,sp
 move.l	d0,d7				; d7 = handle
 ble 	autoe_err 			; Fehler!
	IF	DEBUG3
 lea 	__s1(pc),a0
 jsr 	putstr
	ENDIF
; per FSTAT Laenge ermitteln
 move.w	#FSTAT,-(sp)
 pea 	XATTR+2(sp)
 move.w	d7,-(sp)				; handle
 move.w	#$104,-(sp)			; Fcntl
 trap	#1
 adda.w	#10,sp
 tst.l	d0
 bmi 	autoe_close			; Fehler bei FSTAT ?
	IF	DEBUG3
 lea 	__s2(pc),a0
 jsr 	putstr
	ENDIF
; Speicher allozieren
 move.l	XATTR+xattr_size(sp),-(sp)
 addq.l	#2,(sp)				; 2 Bytes mehr, Platz fuer EOF
 move.w	#$48,-(sp)			; Malloc
 trap	#1
 addq.l	#6,sp
 tst.l	d0
 beq 	autoe_close			; nicht genuegend Speicher
 move.l	d0,a4
	IF	DEBUG3
 lea 	__s3(pc),a0
 jsr 	putstr
	ENDIF
; Datei laden
 move.l	a4,-(sp)
 move.l	XATTR+xattr_size+4(sp),-(sp)
 move.w	d7,-(sp)
 move.w	#$3f,-(sp)			; Fread
 trap	#1
 adda.w	#12,sp
 tst.l	d0
 ble 	autoe_free			; nix gelesen
 clr.b	0(a4,d0.l)			; Nullbyte als Ende-Markierung
	IF	DEBUG3
 lea 	__s4(pc),a0
 jsr 	putstr
	ENDIF
 move.l	a4,a3

* Pfad kopieren

 lea 	BUF(sp),a0
 moveq	#5,d0				; strlen("\\AUTO\\")-1
autoe_rploop:
 move.b	(a6)+,(a0)+
 dbra	d0,autoe_rploop
 move.l	a0,a5

* Schleife zum Ausfuehren

autoe_lloop:
 tst.b	(a3)
 beq.b	autoe_free			; EOF
 lea 	(a5),a0
autoe_ploop:
 move.b	(a3)+,d0
 beq.b	autoe_ploope1
 cmpi.b	#$d,d0
 beq.b	autoe_ploope2
 cmpi.b	#' ',d0
 beq.b	autoe_ploope2
 cmpi.b	#9,d0				; Tab
 beq.b	autoe_ploope2
 move.b	d0,(a0)+
 bra.b	autoe_ploop
autoe_ploope1:
 subq.l	#1,a3				; EOS gelesen, Zeiger auf EOS
 bra.b	autoe_ploopen
autoe_ploope2:
 move.b	(a3)+,d0				; irgendwas, ueberlesen bis LF
 beq.b	autoe_ploope1
 cmpi.b	#$a,d0
 bne.b	autoe_ploope2
autoe_ploopen:
 clr.b	(a0)
; Pruefen, ob absoluter Pfad
	IF	DEBUG3
 lea 	__s5(pc),a0
 jsr 	putstr
 lea 	BUF(sp),a0
 bsr 	putstr
 lea 	__s6(pc),a0
 bsr 	putstr
	ENDIF
 tst.b	(a5)
 beq.b	autoe_lloop			; Leerzeile
 move.l	a5,a0
 cmpi.b	#':',1(a5)			; absoluter Pfad ?
 beq.b	autoe_abs 			; ja
 lea 	BUF(sp),a0			; nein, Pfad davorhaengen!
autoe_abs:
 pea 	nullstring(pc)
 pea 	nullstring(pc)
 pea 	(a0)
 move.l	#$4b0000,-(sp) 		; Laden und Starten
 trap	#1					; Programm ausfuehren
 lea 	16(sp),sp
 bra 	autoe_lloop

autoe_free:
 move.l	a4,-(sp)
 move.w	#$49,-(sp)			; Mfree
 trap	#1
 addq.l	#6,sp
autoe_close:
 move.w	d7,-(sp)
 move.w	#$3e,-(sp)			; Fclose
 trap	#1
 addq.l	#4,sp
 moveq	#0,d0				; Datei existierte
autoe_err:
 lea 	OFFS(sp),sp
 movem.l	(sp)+,d7/a4/a3
 rts


**********************************************************************
*
* void auto_programs( a5 = char *path, a6 = char *pgmtyp )
*
* fuehrt den AUTO- Ordner aus		(\AUTO\*.PRG)
* fuehrt den XTENSION- Ordner aus	(\GEMSYS\MAGIC\XTENSION\*.DEV)
*							(\GEMSYS\MAGIC\XTENSION\*.XFS)
*

DTA		SET	0
BUF		SET	DTA+dta_sizeof
OFFS 	SET	BUF+128

auto_programs:
 lea 	-OFFS(sp),sp			; Platz fuer Programmnamen und DTA
 move.w	#7,-(sp)				; alle Dateitypen
 move.l	a5,-(sp)				; Pfad
 move.w	#$4e,-(sp)			; Fsfirst
autop_nxtpgm:
 pea 	8+DTA(sp)
 move.w	#$1a,-(sp)
 trap	#1					; gemdos Fsetdta
 addq.w	#6,sp
 trap	#1					; Fsfirst bzw. Fsnext
 addq.w	#8,sp
 tst.l	d0					; Datei gefunden ?
 bne.b	autop_ende			; nein, Ende
 move.l	a5,a0
 move.l	a6,a2
 lea 	BUF(sp),a1			; auto_pgmname
autop_cploop:
 move.b	(a0)+,(a1)+			; Ordnername kopieren
 cmpa.l	a0,a2
 bne.b	autop_cploop
 lea 	DTA+dta_name(sp),a0
autop_catloop:
 move.b	(a0)+,(a1)+			; Dateinamen anhaengen
 bne.b	autop_catloop
 pea 	nullstring(pc)
 pea 	nullstring(pc)
 pea 	BUF+8(sp) 			; auto_pgmname
 move.l	#$4b0000,-(sp) 		; Laden und Starten
 trap	#1					; Programm ausfuehren
 lea 	16-8(sp),sp			; 6 Dummybytes auf Stack
;clr.w	-(sp)
;clr.l	-(sp)				; dummies
 move.w	#$4f,(sp) 			; ... und Fsnext
 bra.b	autop_nxtpgm			; weitersuchen
autop_ende:
 lea 	OFFS(sp),sp
 rts
