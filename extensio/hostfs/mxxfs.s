/*
 *
 * Assembler-Part of the XFS interface
 * Developed using PASM.
 *
 * (C) Andreas Kromke 1997
 * (C) Thorsten Otto 2018
 *
 */

     INCLUDE "mgx_xfs.inc"


/*
 * The interface between the XFS the C-Part.
 * All parameters are passed on the stack.
 * Note that this still expect compilers
 * to use short (16-bit) ints.
 */

     XREF cdecl_hostxfs		; XFS jump table


/*
 *
 * Dies sind die eigentlichen Treiber, die ber eine
 * Assemblerschnittstelle mit dem MagiX- Kernel und
 * ber eine cdecl-Schnittstelle mit dem C-Teil
 * kommunizieren.
 *
 */

     XDEF hostxfs		; Hier ist das XFS

	DATA

hostxfs:
 DC.B     'HOSTFS',0,0            ; Name
 DC.L     0                        ; n„chstes XFS
 DC.L     0                        ; Flags
 DC.L     hostxfs_init
 DC.L     hostxfs_sync
 DC.L     hostxfs_pterm
 DC.L     hostxfs_garbcoll
 DC.L     hostxfs_freeDD
 DC.L     hostxfs_drv_open
 DC.L     hostxfs_drv_close
 DC.L     hostxfs_path2DD
 DC.L     hostxfs_sfirst
 DC.L     hostxfs_snext
 DC.L     hostxfs_fopen
 DC.L     hostxfs_fdelete
 DC.L     hostxfs_link
 DC.L     hostxfs_xattr
 DC.L     hostxfs_attrib
 DC.L     hostxfs_chown
 DC.L     hostxfs_chmod
 DC.L     hostxfs_dcreate
 DC.L     hostxfs_ddelete
 DC.L     hostxfs_DD2name
 DC.L     hostxfs_dopendir
 DC.L     hostxfs_dreaddir
 DC.L     hostxfs_drewinddir
 DC.L     hostxfs_dclosedir
 DC.L     hostxfs_dpathconf
 DC.L     hostxfs_dfree
 DC.L     hostxfs_wlabel
 DC.L     hostxfs_rlabel
 DC.L     hostxfs_symlink
 DC.L     hostxfs_readlink
 DC.L     hostxfs_dcntl


	TEXT

/**********************************************************************
 *
 * void xfs_init( void )
 */

hostxfs_init:
 move.l	cdecl_hostxfs+xfs_init(pc),d0
 beq.s hostxfs_noinit
 move.l d0,a0
 jsr      (a0)
hostxfs_noinit:
 rts


/**********************************************************************
 *
 * void xfs_sync( a0 = DMD *d )
 */

hostxfs_sync:
 move.l   a0,-(sp)
 move.l	cdecl_hostxfs+xfs_sync(pc),a0
 jsr      (a0)
 addq.l   #4,sp
 rts


/**********************************************************************
 *
 * void xfs_pterm( a0 = DMD *d, a1 = PD *pd )
 *
 * Ein Programm wird gerade terminiert. Das XFS kann alle von diesem
 * Programm belegten Ressourcen freigeben.
 * Alle Ressourcen, von dem der Kernel wei (d.h. ge”ffnete Dateien)
 * sind bereits vom Kernel freigegeben worden.
 */

hostxfs_pterm:
 move.l   a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_pterm(pc),a0
 jsr      (a0)
 addq.l   #8,sp
 rts


/**********************************************************************
 *
 * long xfs_garbcoll( a0 = DMD *dir )
 *
 * Sucht nach einem unbenutzten FD
 * Rckgabe TRUE, wenn mindestens einer gefunden wurde.
 */

hostxfs_garbcoll:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_garbcoll(pc),a0
 jsr      (a0)
 addq.l   #4,sp
 rts


/**********************************************************************
 *
 * void xfs_freeDD( a0 = DD *dir )
 *
 * Der Kernel hat den Referenzz„hler des DD auf 0 dekrementiert.
 * Die Struktur kann jetzt freigegeben werden.
 */

hostxfs_freeDD:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_freeDD(pc),a0
 jsr      (a0)
 addq.l   #4,sp
 rts


/**********************************************************************
 *
 * long xfs_drv_open( a0 = DMD *dmd )
 *
 * Initialisiert den DMD.
 * Diskwechsel auf der MAC-Seite sind z.Zt. noch nicht m”glich,
 * daher wird bereits hier ein E_OK geliefert.
 */

hostxfs_drv_open:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_drv_open(pc),a0
 jsr      (a0)
 addq.l   #4,sp
 rts


/**********************************************************************
 *
 * long xfs_drv_close( a0 = DMD *dmd, d0 = int mode)
 *
 * mode == 0:   Frage, ob schlieen erlaubt, ggf. schlieen
 *         1:   Schlieen erzwingen, mu E_OK liefern
 */

hostxfs_drv_close:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_drv_close(pc),a0
 jsr      (a0)
 addq.l   #6,sp
 rts


/**********************************************************************
 *
 * DD * xfs_path2DD( a0 = DD * reldir,
 *                    a1 = char *pathname,
 *                    d0 = int  mode )
 *
 * d1 ist der Pfad ohne Laufwerk
 * -> d0 = DD *dir     oder Fehlercode
 * -> d1 = char *fname
 *
 * Wandelt den Pfadnamen, der relativ zu <reldir> gegeben ist, in
 * einen DD um.
 *
 * mode == 0: pathname zeigt auf eine beliebige Datei. Gib den DD
 *            zurck, in dem die Datei liegt.
 *            gib in a0 einen Zeiger auf den isolierten Dateinamen
 *            zurck.
 *         1: pathname ist selbst ein Verzeichnis, gib dessen DD
 *            zurck, a0 ist danach undefiniert.
 *
 * Rckgabe:
 *  d0 = DD des Pfades, Referenzz„hler entsprechend erh”ht
 *  d1 = Rest- Dateiname ohne beginnenden '\'
 * oder
 *  d0 = ELINK
 *  d1 = Restpfad ohne beginnenden '\'
 *  a0 = DD des Pfades, in dem der symbolische Link liegt. Dies ist
 *       wichtig bei relativen Pfadangaben im Link.
 *  a1 = NULL
 *            Der Pfad stellt den Parent des Wurzelverzeichnisses
 *            dar, der Kernel kann, wenn das Laufwerk U: ist, auf
 *            U:\ zurckgehen.
 *  a1 = Pfad des symbolischen Links. Der Pfad enth„lt einen
 *            symbolischen Link, wom”glich auf ein
 *            anderes Laufwerk. Der Kernel mu den Restpfad <a0>
 *            relativ zum neuen DD <a0> umwandeln.
 *            a1 zeigt auf ein Wort fr die Zeichenkettenl„nge
 *            (gerade Zahl auf gerader Adresse, inkl. EOS),
 *            danach folgt die Zeichenkette. Der Puffer kann
 *            flchtig sein, der Kernel kopiert den Pfad um.
 *
 *
 * z.Zt. werden keine SymLinks untersttzt. Auch der Parent eines
 * Wurzelverzeichnisses wird nicht korrekt behandelt.
 * Es w„re sinnvoll, einen šberblick ber alle angeforderten DDs zu haben, um
 * einer bereits referenzierten dirID keinen neuen Deskriptor anfordern
 * zu mssen, sondern einfach den Referenzz„hler zu erh”hen.
 */

hostxfs_path2DD:
 clr.l	-(sp)				; Platz fr Rckgabe Symlink
 clr.l	-(sp)				; Platz fr Rckgabe Symlink-DD
 clr.l	-(sp)				; Platz fr Rckgabe Restpfad
 pea		8(sp)				; &symlink
 pea		8(sp)				; &dd
 pea		8(sp)				; &restpfad
 move.w	d0,-(sp)				; mode
 move.l	a1,-(sp)				; pathname
 move.l	a0,-(sp)				; reldir
 move.l	cdecl_hostxfs+xfs_path2DD(pc),a0
 jsr      (a0)
 adda.w   #22,sp
 move.l	(sp)+,d1				; restpfad
 move.l	(sp)+,a0				; Symlink-DD
 move.l	(sp)+,a1				; Symlink
 rts


/**********************************************************************
 *
 * long xfs_sfirst(a0 = DD *d, a1 = char *name, d0 = DTA *dta,
 *                  d1 = int attrib)
 *
 * Rckgabe:    d0 = errcode
 *             oder
 *              d0 = ELINK
 *              a0 = char *link
 */

hostxfs_sfirst:
 clr.l	-(sp)
 pea		(sp)
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_sfirst(pc),a0
 jsr      (a0)
 adda.w	#18,sp
 move.l	(sp)+,a0
 rts


/**********************************************************************
 *
 * long xfs_snext(a0 = DTA *dta, a1 = DMD *d)
 *
 * Rckgabe:    d0 = errcode
 *             oder
 *              d0 = ELINK
 *              a0 = char *link
 */

hostxfs_snext:
 clr.l	-(sp)
 pea		(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_snext(pc),a0
 jsr      (a0)
 adda.w	#12,sp
 move.l	(sp)+,a0
 rts


/**********************************************************************
 *
 * d0 = FD * xfs_fopen(a0 = DD *d, a1 = char *name, d0 = int omode,
 *                      d1 = int attrib )
 *
 * ™ffnet und/oder erstellt Dateien, ™ffnet den Dateitreiber.
 * Der Open- Modus ist vom Kernel bereits in die interne
 * MagiX- Spezifikation konvertiert worden.
 *
 * Eine Wiederholung im Fall E_CHNG wird vom Kernel bernommen.
 *
 * Rckgabe:
 * d0 = ELINK: Datei ist symbolischer Link
 *             a0 ist der Dateiname des symbolischen Links
 */

hostxfs_fopen:
 clr.l	-(sp)
 pea		(sp)
 move.w	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_fopen(pc),a0
 jsr      (a0)
 adda.w	#16,sp
 move.l	(sp)+,a0
 rts


/*********************************************************************
 *
 * long xfs_fdelete(a0 = DD *d, a1 = char *name)
 *
 * Eine Wiederholung im Fall E_CHNG wird vom Kernel bernommen.
 *
 * Rckgabe:
 * d0 = ELINK: Datei ist symbolischer Link
 *             a0 ist der Dateiname des symbolischen Links
 *
 * Note: don't return ELINK from this function,
 * or the Kernel will remove the target file instead of the link
 *
 * Es drfen keine SubDirs oder Labels gel”scht werden.
 */

hostxfs_fdelete:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_fdelete(pc),a0
 jsr      (a0)
 addq.l	#8,sp
 rts


/**********************************************************************
 *
 * long xfs_link(a0 = DD *altdir, a1 = DD *neudir,
 *                   d0 = char *altname, d1 = char *neuname,
 *				d2 = int flag)
 *
 * d2 = 1: Flink
 * d2 = 0: Frename
 */

hostxfs_link:
 move.w	d2,-(sp)
 move.l	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_link(pc),a0
 jsr      (a0)
 adda.w	#18,sp
 rts


/**********************************************************************
 *
 * long xfs_xattr( a0 = DD *dir, a1 = char *name, d0 = XATTR *xa,
 *                  d1 = int mode )
 *
 * mode == 0:   Folge symbolischen Links  (d.h. gib ELINK zurck)
 *         1:   Folge nicht  (d.h. erstelle XATTR fr den Link)
 */

hostxfs_xattr:
 clr.l -(sp)
 pea (sp)
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_xattr(pc),a0
 jsr      (a0)
 lea 22(sp),sp
 rts


/**********************************************************************
 *
 * long xfs_attrib( a0 = DD *dir, a1 = char *name, d0 = int mode,
 *                   d1 = int attrib )
 *
 * Rckgabe:    >= 0      Attribut
 *              <  0      Fehler
 *
 * mode == 0:   Lies Attribut
 *         1:   Schreibe Attribut
 *              ELINK => a0 ist Zeiger auf Link
 */

hostxfs_attrib:
 clr.l -(sp)
 pea (sp)
 move.w	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_attrib(pc),a0
 jsr      (a0)
 lea 16(sp),sp
 move.l (sp)+,a0
 rts


/**********************************************************************
 *
 * long xfs_chown( a0 = DD *dir, a1 = char *name, d0 = int uid,
 *                  d1 = int gid )
 *
 * Rckgabe:    == 0      OK
 *              <  0      Fehler
 *              d0 = ELINK
 *              a0 = char *link
 */

hostxfs_chown:
 clr.l	-(sp)
 pea (sp)
 move.w	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_chown(pc),a0
 jsr      (a0)
 adda.w	#16,sp
 move.l (sp)+,a0
 rts


/**********************************************************************
 *
 * long xfs_chmod( a0 = DD *dir, a1 = char *name, d0 = int mode )
 *
 * Rckgabe:    == 0      OK
 *              <  0      Fehler
 *              d0 = ELINK
 *              a0 = char *link
 */

hostxfs_chmod:
 clr.l	-(sp)
 pea (sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_chmod(pc),a0
 jsr      (a0)
 adda.w	#14,sp
 move.l (sp)+,a0
 rts


/**********************************************************************
 *
 * long xfs_dcreate(a0 = DD *d, a1 = char *name, d0 = int mode )
 *
 * mode wird hier ignoriert
 */

hostxfs_dcreate:
 move.w d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dcreate(pc),a0
 jsr      (a0)
 lea 10(a7),a7
 rts


/**********************************************************************
 *
 * long xfs_ddelete( a0 = DD *d )
 *
 * Note: don't return ELINK from this function,
 * or the Kernel will remove the target file instead of the link
 *
 * Der DD darf nicht freigegeben werden (bleibt ge-lock-t!)
 */

hostxfs_ddelete:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_ddelete(pc),a0
 jsr      (a0)
 addq.l	#4,sp
 rts


/**********************************************************************
 *
 * long xfs_DD2name(a0 = DD *d, a1 = char *buf, d0 = int buflen)
 *
 * Wandelt DD in einen Pfadnamen um
 */

hostxfs_DD2name:
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_DD2name(pc),a0
 jsr      (a0)
 adda.w	#10,sp
 rts


/**********************************************************************
 *
 * FD *xfs_dopendir( a0 = DD *d, d0 = int tosflag )
 */

hostxfs_dopendir:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dopendir(pc),a0
 jsr      (a0)
 addq.l	#6,sp
 rts


/**********************************************************************
 *
 * long xfs_dreaddir( a0 = void *dh, d0 = int len, a1 = char *buf,
 *                     d1 = XATTR *xattr, d2 = long *xr )
 *
 * Fšr Dreaddir (xattr = NULL) und Dxreaddir
 */

hostxfs_dreaddir:
 move.l	d2,-(sp)
 move.l	d1,-(sp)
 move.l	a1,-(sp)
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dreaddir(pc),a0
 jsr      (a0)
 adda.w	#18,sp
 rts


/**********************************************************************
 *
 * long xfs_drewinddir( a0 = FD *d )
 */

hostxfs_drewinddir:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_drewinddir(pc),a0
 jsr      (a0)
 addq.l	#4,sp
 rts


/**********************************************************************
 *
 * long xfs_dclosedir( a0 = FD *d )
 */

hostxfs_dclosedir:
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dclosedir(pc),a0
 jsr      (a0)
 addq.l	#4,sp
 rts


/**********************************************************************
 *
 * long xfs_dpathconf( a0 = DD *d, d0 = int which )
 *
 * mode = -1:   max. legal value for n in Dpathconf(n)
 *         0:   internal limit on the number of open files
 *         1:   max. number of links to a file
 *         2:   max. length of a full path name
 *         3:   max. length of an individual file name
 *         4:   number of bytes that can be written atomically
 *         5:   information about file name truncation
 *              0 = File names are never truncated; if the file name in
 *                  any system call affecting  this  directory  exceeds
 *                  the  maximum  length (returned by mode 3), then the
 *                  error value ERANGE is  returned  from  that  system
 *                  call.
 *
 *              1 = File names are automatically truncated to the maxi-
 *                  mum length.
 *
 *              2 = File names are truncated according  to  DOS  rules,
 *                  i.e. to a maximum 8 character base name and a maxi-
 *                  mum 3 character extension.
 *         6:   0 = case-sensitiv
 *              1 = nicht case-sensitiv, immer in Groschrift
 *              2 = nicht case-sensitiv, aber unbeeinflut
 *
 *      If  any  of these items are unlimited, then 0x7fffffffL is
 *      returned.
 */

hostxfs_dpathconf:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dpathconf(pc),a0
 jsr      (a0)
 addq.l	#6,sp
 rts


/**********************************************************************
 *
 * long xfs_dfree( a0 = DD_FD *dir, a1 = long buf[4] )
 */

hostxfs_dfree:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dfree(pc),a0
 jsr      (a0)
 addq.l	#8,sp
 rts


/**********************************************************************
 *
 * long xfs_wlabel( a0 = DD *d, a1 = char *name )
 */

hostxfs_wlabel:
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_wlabel(pc),a0
 jsr      (a0)
 addq.l	#8,sp
 rts


/**********************************************************************
 *
 * long xfs_rlabel( a0 = DD *d, a1 = char *name,
 *                   d0 = char *buf, d1 = int len )
 */

hostxfs_rlabel:
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_rlabel(pc),a0
 jsr      (a0)
 adda.w	#14,sp
 rts


/**********************************************************************
 *
 * long xfs_symlink( a0 = DD *d, a1 = char *name, d0 = char *to )
 *
 * erstelle symbolischen Link
 */

hostxfs_symlink:
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_symlink(pc),a0
 jsr      (a0)
 adda.w	#12,sp
 rts


/**********************************************************************
 *
 * long xfs_readlink( a0 = DD *d, a1 = char *name, d0 = char *buf,
 *                     d1 = int buflen )
 *
 * Lies symbolischen Link
 */

hostxfs_readlink:
 move.w	d1,-(sp)
 move.l	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_readlink(pc),a0
 jsr      (a0)
 adda.w	#14,sp
 rts


/**********************************************************************
 *
 * long xfs_dcntl( a0 = DD *d, a1 = char *name, d0 = int cmd,
 *                  d1 = long arg )
 *
 * Rckgabe:    d0 = errcode
 *             oder
 *              d0 = ELINK
 *              a0 = char *link
 *
 * Fhrt Spezialfunktionen aus
 */

hostxfs_dcntl:
 clr.l	-(sp)
 pea (sp)
 move.l	d1,-(sp)
 move.w	d0,-(sp)
 move.l	a1,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostxfs+xfs_dcntl(pc),a0
 jsr      (a0)
 lea 18(sp),sp
 move.l (sp)+,a0
 rts
