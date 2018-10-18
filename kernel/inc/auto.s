	DEB	'Bootlaufwerk setzen'
 bsr 	set_bootdrive			; Bootlaufwerk als aktuelles
;move.l	$bffff,-(sp)			; TOS 3.06
;trap	#$d					; bios Kbshift
;addq.l	#4,sp
;btst	#2,d0				; CTRL ?
;bne.b	no_autop				; ja, AUTO nicht ausführen

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
 beq.b	bot_no_coo
 cmpi.l	#NCOOKIES,d0
 bcs.b	bot_no_coo			; Mindestgröße
	DEB	'ja, neue Cookies anlegen!'
 move.l	d0,-(sp)				; Anzahl merken
 lsl.l	#3,d0				; * 8 wg. 2 LONGs pro Eintrag
 move.l	d0,-(sp)
 gemdos	Malloc
 addq.l	#6,sp
 move.l	(sp)+,d1				; Anzahl zurück
 tst.l	d0
 beq.b 	bot_no_coo			; nicht genügend Speicher
 move.l	_p_cookies,a0
 move.l	d0,a1
bot_coo_cp_loop:
 move.l	(a0)+,(a1)+			; Cookie-Schlüssel kopieren
 beq.b	bot_coo_cp_ende		; Ende-Zeichen
 move.l	(a0)+,(a1)+
 bra.b	bot_coo_cp_loop
bot_coo_cp_ende:
 move.l	d1,(a1)+				; neue Länge eintragen
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

* Jetzt (ab MagiC 6) log-Datei öffnen

	DEB	'BOOT.LOG öffnen?'
 move.l	p_mgxinf,a0
 jsr		rinf_log				; Log-Datei öffnen
 move.l	d0,log_fd
 bmi.b	bot_nolog
 move.l	dev_vecs+$68,log_oldconout	; alten Bconout-Vektor merken
 move.l	#bconout_log,dev_vecs+$68; Vektor umsetzen
 move.l	act_pd,log_fd_pd			; PD für Handle merken
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

* Jetzt alle Geräte wieder löschen (waren nur für Hddriver)

 jsr		deleddev

* Jetzt XTENSION-Ordner, dann AUTO-Ordner

	DEB	'Gerätetreiber (DEV) laden'
 lea 	devdir_s(pc),a5
 lea 	devpgm_s(pc),a6
 bsr 	auto_programs			; \GEMSYS\MAGIC\XTENSION\*.DEV
	DEB	'Dateisysteme (XFS) laden'
 lea 	xfsdir_s(pc),a5
 lea 	xfspgm_s(pc),a6
 bsr 	auto_programs			; \GEMSYS\MAGIC\XTENSION\*.XFS
	DEB	'BIOS-Gerätedateien aus MAGX.INF konfigurieren'
 move.l	p_mgxinf,a0
 jsr		rinf_bdev
	DEB	'Restliche Gerätedateien initialisieren'
 jsr		iniddev1
	DEB	'Geräte-Handles aus MAGX.INF zuweisen'
 move.l	p_mgxinf,a0
 jsr		rinf_dvh
	DEB	'Restliche Handles des DOS initialisieren'
 jsr		iniddev2
	DEB	'AUTOEXEC.BAT ausführen'
 lea 	autoexec_s(pc),a6
 bsr 	autoexec				; \AUTO\AUTOEXEC.BAT
 tst.w	d0					; ausgeführt ?
 beq.b	no_autop				; ja, OK
	DEB	'kein AUTOEXEC.BAT => AUTO-Ordner ausführen'
 lea 	autodir_s(pc),a5
 lea 	autopgm_s(pc),a6
 bsr 	auto_programs			; \AUTO\*.PRG
no_autop:

* Boot-Log schließen

	DEB	'BOOT.LOG schließen'
 move.l	log_fd,d0
 bmi.b	bot_nolog2
 move.l	dev_vecs+$68,a1
 cmpa.l	#bconout_log,a1
 bne.b	bot_logchg			; Achtung: Vektor geändert!
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


* Diese Schleife wird beim Auflösungswechsel
* durchlaufen

resolut_change_loop:
	DEB	'AES ausführen'
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
 pea 	aessys_s(pc)			; Prozeßname
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
 bra		resolut_change_loop		; war Auflösungswechsel

;jmp 	sys_start 			; bei Programmende: Reset


**********************************************************************
*
* Bconout(CON) Handler für Boot-Log-Datei
*
* MagiC 6.01: Semaphore für etv_critic berücksichtigen
*

bconout_log:
 tst.b	criticret				; Handler aktiv?
 bne.b	bcl_critic			; ja!
 move.l	act_pd,-(sp)			; alten Prozeßzeiger merken
 move.l	log_fd_pd,act_pd		; Prozeßzeiger für Handle setzen
 pea		11(sp)
 pea		1
 move.w	log_fd+2,-(sp)			; Lobyte ist Handle (prozeßlokal!)
 gemdos	Fwrite
 adda.w	#12,sp
 move.l	(sp)+,act_pd			; alten Prozeßzeiger restaurieren
 rts
bcl_critic:
 move.l	log_oldconout,-(sp)		; springe über alten Vektor
 rts


autoexec_s:
 DC.B	'\AUTO\AUTOEXEC.BAT',0
autodir_s:
 DC.B	'\AUTO\'
autopgm_s:
 DC.B	'*.PRG',0
xfsdir_s:
 DC.B	'\GEMSYS\MAGIC\XTENSION\'
xfspgm_s:
 DC.B	'*.XFS',0
devdir_s:
 DC.B	'\GEMSYS\MAGIC\XTENSION\'
devpgm_s:
 DC.B	'*.DEV',0
aessys_s:
 DC.B	'AESSYS',0
environment_pattern:
 DC.B	'PATH=;#:\',0,0,-1
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
 bne.b	stbd_ok				; ja, ausführen
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
* Prüft, ob im Verzeichnis <path> eine Datei AUTOEXEC.BAT liegt, und
* führt sie ggf. aus.
* Rückgabe 0: AUTOEXEC.BAT ausgeführt
*		 1: nicht ausgeführt
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
__s1: DC.B	'AUTOEXEC.BAT geöffnet',13,10,0
__s2: DC.B	'Fcntl(FSTAT) erfolgreich',13,10,0
__s3: DC.B	'Speicher für AUTOEXEC.BAT alloziert',13,10,0
__s4: DC.B	'AUTOEXEC.BAT geladen',13,10,0
__s5: DC.B	'starte _',0
__s6: DC.B	'_',13,10,0
	EVEN
	ENDIF

autoexec:
 movem.l	a3/a4/d7,-(sp)
 lea 	-OFFS(sp),sp			; Platz für Programmnamen und DTA
; Datei zum Lesen öffnen
 clr.w	-(sp)				; Öffnen zum Lesen
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
; per FSTAT Länge ermitteln
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
 addq.l	#2,(sp)				; 2 Bytes mehr, Platz für EOF
 move.w	#$48,-(sp)			; Malloc
 trap	#1
 addq.l	#6,sp
 tst.l	d0
 beq 	autoe_close			; nicht genügend Speicher
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
 moveq	#5,d0				; strlen("\AUTO\")-1
autoe_rploop:
 move.b	(a6)+,(a0)+
 dbra	d0,autoe_rploop
 move.l	a0,a5

* Schleife zum Ausführen

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
 move.b	(a3)+,d0				; irgendwas, überlesen bis LF
 beq.b	autoe_ploope1
 cmpi.b	#$a,d0
 bne.b	autoe_ploope2
autoe_ploopen:
 clr.b	(a0)
; Prüfen, ob absoluter Pfad
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
 lea 	BUF(sp),a0			; nein, Pfad davorhängen!
autoe_abs:
 pea 	nullstring(pc)
 pea 	nullstring(pc)
 pea 	(a0)
 move.l	#$4b0000,-(sp) 		; Laden und Starten
 trap	#1					; Programm ausführen
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
* führt den AUTO- Ordner aus		(\AUTO\*.PRG)
* führt den XTENSION- Ordner aus	(\GEMSYS\MAGIC\XTENSION\*.DEV)
*							(\GEMSYS\MAGIC\XTENSION\*.XFS)
*

DTA		SET	0
BUF		SET	DTA+dta_sizeof
OFFS 	SET	BUF+128

auto_programs:
 lea 	-OFFS(sp),sp			; Platz für Programmnamen und DTA
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
 move.b	(a0)+,(a1)+			; Dateinamen anhängen
 bne.b	autop_catloop
 pea 	nullstring(pc)
 pea 	nullstring(pc)
 pea 	BUF+8(sp) 			; auto_pgmname
 move.l	#$4b0000,-(sp) 		; Laden und Starten
 trap	#1					; Programm ausführen
 lea 	16-8(sp),sp			; 6 Dummybytes auf Stack
;clr.w	-(sp)
;clr.l	-(sp)				; dummies
 move.w	#$4f,(sp) 			; ... und Fsnext
 bra.b	autop_nxtpgm			; weitersuchen
autop_ende:
 lea 	OFFS(sp),sp
 rts
