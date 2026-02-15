* void search_whole_tree(d0 = drive, d1 = is_ck)
* int drive,is_ck;
*  is_ck = 0 : von tree_com() aufgerufen
*  is_ck = 1 : von ck_com()   aufgerufen
*  Durchsucht, ausgehend von der Wurzel, rekursiv den Directory- Baum

search_whole_tree:
 link     a6,#-110
 movem.l  a5/d7,-(sp)
 lea      -110(a6),a5              ; Pufferadresse
 move.w   d1,d7                    ; is_ck
 lea      drive_to_letter(pc),a0
 move.b   0(a0,d0.w),d0
 lea      d+treelevel(pc),a0
 move.w   #8,(a0)
 move.b   d0,(a5)+
 move.b   #':',(a5)+
 move.b   #'\',(a5)+
 clr.b    (a5)
 subq.w   #3,a5
 bsr.b    search_tree
 movem.l  (sp)+,a5/d7
 unlk     a6
 rts


* void search_tree( void )
*  DurchlÑuft rekursiv den Directory- Baum, ausgehend von dem <directory>
*  <is_ck> wie oben.
*  global: a5 (Pfad), a7 (is_ck)
*  Jeder Aufruf schreibt 48 Bytes auf den Stapel
*

DTA       SET  -44                 * char DTA[44]

search_tree:
 link     a6,#DTA
 move.l   a4,-(sp)
 lea      d+treelevel(pc),a0
 subq.w   #1,(a0)
 bcs      srcht_6                  * Pfad tiefer als 8 Directories
 move.l   a5,a4
srcht_11:
 tst.b    (a4)+
 bne.b    srcht_11
 subq.w   #1,a4
 move.l   a4,a0
 lea      star_pt_star(pc),a1
 bsr      strcpy
 tst.w    d7                       * d7 = 0 => nur "tree"s ausgeben
 beq.b    srcht_3
 lea      pfads(pc),a0             * Vollen Pfadnamen angeben (ck_com())
 bsr      get_country_str
 bsr      strstdout
 move.l   a5,a0
 bsr      strstdout
 bra.b    srcht_4
srcht_3:
 clr.b    (a4)                     * Nur Directories ausgeben (tree_com())
 lea      2(a5),a0                 * Laufwerksnamen "X:" weglassen (2 Bytes)
 bsr      strstdout
 bsr      crlf_stdout
 move.b   #'*',(a4)
srcht_4:

 lea      DTA(a6),a1
 moveq    #$16,d0                  * Subdirectories + hidden + system
 move.l   a5,a0
 bsr      sfirst

 bne      srcht_end                * Directory leer
srcht_5:
 cmpi.w   #$2e2e,DTA+30(a6)        * Dateiname beginnt mit '..' => Åbergehen
 beq.b    srcht_9
 cmpi.w   #$2e00,DTA+30(a6)        * Dateiname ist '.' => Åbergehen
 beq.b    srcht_9
 move.b   DTA+21(a6),d0            * Datei- Attribute
 btst     #3,d0                    * Volume- Eintrag => Åbergehen
 bne.b    srcht_9
 btst     #4,d0                    * Subdirectory ?
 beq.b    srcht_7                  * nein
 lea      d+subdir_no(pc),a0
 addq.w   #1,(a0)                  * Anzahl der Subdirectories mitzÑhlen
 lea      DTA+30(a6),a1
 move.l   a4,a0                    * Directory- Name nach a5[] kopieren (statt "*.*")
 bsr      strcpy
 move.b   #'\',-1(a0)
 clr.b    (a0)                     * '\' anhÑngen
 bsr      search_tree              * rekursiv neuen Pfad bearbeiten
 move.l   a4,a0
 lea      star_pt_star(pc),a1
 bsr      strcpy
 bra.b    srcht_9
srcht_6:
 lea      pfadzutiefs(pc),a0
 bsr      get_country_str
 bsr      strcon
 bsr      inc_errlv
 bra.b    srcht_end
srcht_7:
 move.l   DTA+26(a6),d1      * DateilÑnge
 lea      d+normal_no(pc),a0
 lea      d+normal_len(pc),a1
 and.b    #6,d0          * alle Bits bis auf hidden & system lîschen
 beq.b    srcht_8
 addq.w   #2,a0
 addq.w   #4,a1
srcht_8:
 addq.w   #1,(a0)
 add.l    d1,(a1)
srcht_9:

 lea      DTA(a6),a0
 bsr      snext
 beq      srcht_5

srcht_end:
 lea      d+treelevel(pc),a0
 addq.w   #1,(a0)
 move.l   (sp)+,a4
 unlk     a6
 rts


DFREE_BUFFER   SET   -16

tree_com:
 moveq    #0,d0
 bra.b    ck_tree_free

free_com:
 moveq    #2,d0
 bra.b    ck_tree_free

ck_com:
 moveq    #1,d0

ck_tree_free:
 link     a6,#DFREE_BUFFER
 movem.l  d6/d7/a5,-(sp)
 move     d0,d6               * 0 fÅr TREE, 1 fÅr CK, 2 fÅr FREE
 lea      d+normal_no(pc),a0
 clr.l    (a0)+
 clr.w    (a0)+
 clr.l    (a0)+
 clr.l    (a0)
* clr.l    normal_len
* clr.l    hid_sys_len
* clr      normal_no
* clr      hid_sys_no
* clr      subdir_no
 movea.l  ARGV(a6),a0
 movea.l  4(a0),a5
 gemdos   Dgetdrv
 addq.l   #2,sp
 move.w   d0,d7
 cmpi.w   #1,ARGC(a6)
 ble.b    ctf_1             * kein Parameter
 move.l   a5,a0
 bsr      is_newdrive
 cmpi.w   #-2,d0
 beq.b    ctf_1             * nicht "X:"
 move.w   d0,d7          * Laufwerkscode ?
 bmi      ctf_50           * Fehler
ctf_1:
 tst      d6
 beq.b    ctf_30         * TREE
 cmpi.w   #2,d6
 bne.b    ctf_31
* FREE
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree               * Zugriff gibt Speicher frei
 addq.l   #8,sp
 bra      ctf_32
ctf_31:
 move.w   d7,d0
 bsr      label_to_stdout
 move.w   d7,-(sp)
 addq.w   #1,(sp)
 pea      DFREE_BUFFER(a6)
 gemdos   Dfree
 addq.l   #8,sp
ctf_30:
 move.w   d6,d1
 move.w   d7,d0
 bsr      search_whole_tree
 tst      d6
 beq      ctf_end           * TREE
 bsr      crlf_stdout
 bsr      crlf_stdout
ctf_32:
 lea      DFREE_BUFFER(a6),a0
 move.l   12(a0),d0                     * Sektoren/Cluster
 move.l   8(a0),d1                      * Bytes/Sektor
 bsr      _ulmul                        * d0 = Bytes/Cluster
 lsr.l    #8,d0
 lsr.l    #2,d0
 move.l   4(a0),d1                      * Cluster
 bsr      _ulmul                        * d0 = Bytes
* Gesamtplatz auf Disk
 moveq    #10,d1         * Feld 10 Zeichen lang
* move.l   d0,d0
 bsr      rwrite_long
 lea      kbinsg_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
 move.w   d+hid_sys_no(pc),d0
 beq.b    ctf_2
* Gesamtgrîûe und Anzahl der Systemdateien
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+hid_sys_len(pc),d0
 bsr      rwrite_long
 lea      bytes_in_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
 move.w   d+hid_sys_no(pc),d0
 ext.l    d0
 bsr      lwrite_long
 lea      nbytesvers(pc),a0
 bsr      get_country_str
 bsr      strstdout
ctf_2:
* Gesamtgrîûe und Anzahl der Benutzerdateien
 cmpi.w   #2,d6
 beq.s    ctf_3
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+normal_len(pc),d0
 bsr      rwrite_long
 lea      bytes_in_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
 move.w   d+normal_no(pc),d0
 ext.l    d0
 bsr      lwrite_long
 lea      nbytesbens(pc),a0
 bsr      get_country_str
 bsr      strstdout
* Anzahl der Subdirectories
 move.w   d+subdir_no(pc),d0
 beq.b    ctf_3
 moveq    #10,d1         * Feld 10 Zeichen lang
* move.l  d0,d0
 bsr      rwrite_long
 lea      nverzeichns(pc),a0
 bsr      get_country_str
 bsr      strstdout
ctf_3:
 lea      DFREE_BUFFER(a6),a0
 bsr      print_free
* Jetzt Grîûe des Hauptspeichers ermitteln
 bsr      crlf_stdout
 moveq    #10,d1         * Feld 10 Zeichen lang
 move.l   d+c_phystop(pc),d0
 bsr      rwrite_long
 lea      hauptsp_s(pc),a0
 bsr      get_country_str
 bsr      strstdout
* Jetzt Grîûe des freien Speichers
 bsr      memavail
 moveq    #10,d1
* move.l   d0,d0
 bsr      rwrite_long
 lea      nbytesfreis(pc),a0
 bsr      get_country_str
 bsr      strstdout
 bra.b    ctf_end
ctf_50:
 bsr      inc_errlv			; es ist ein Fehler aufgetreten
ctf_end:
 movem.l  (sp)+,a5/d7/d6
 unlk     a6
 rts
