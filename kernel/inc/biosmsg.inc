     IF   COUNTRY=COUNTRY_DE
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM ',$9a,'BERSCHRIEBEN ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATALER FEHLER BEIM BOOTEN:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM ANGEHALTEN ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
     IF   COUNTRY=COUNTRY_US
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM DESTROYED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATAL ERROR WHILE BOOTING:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM HALTED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
     IF   COUNTRY=COUNTRY_UK
os_corr_s:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM DESTROYED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
fatal_bios_errs:
 DC.B     '*** FATAL ERROR WHILE BOOTING:',0
fatal_errs:
 DC.B     $1b,'K',$d,$a
 DC.B     $1b,'K',$d,$a
 DC.B     '*** SYSTEM HALTED ***',$1b,'K',$d,$a
 DC.B     $1b,'K',0
     ENDIF
    IF  COUNTRY=COUNTRY_FR
os_corr_s:
 DC.B   $1b,'K',$d,$a
 DC.B   $1b,'K',$d,$a
 DC.B   '*** SYSTEME REMPLACE ***',$1b,'K',$d,$a
 DC.B   $1b,'K',0
fatal_bios_errs:
 DC.B   '*** ERREUR FATALE AU DEMARRAGE:',0
fatal_errs:
 DC.B   $1b,'K',$d,$a
 DC.B   $1b,'K',$d,$a
 DC.B   '*** ARRET DU SYSTEME ***',$1b,'K',$d,$a
 DC.B   $1b,'K',0
    ENDIF

     EVEN


