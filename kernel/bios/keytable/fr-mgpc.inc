; The French keyboard translation table, AKP 2, for MagicPC

;
; still unclear how keyboard mapping works in MagiCPC
; This is somewhat a mix between german and fr version
;
tab_unshift:
;                $0              $4              $8              $c
        dc.b    $00,$1b,$26,$82,$22,$27,$28,$26,$8a,$5f,$87,$85,$29,$5e,$08,$09
        dc.b    $71,$77,$65,$72,$74,$7a,$75,$69,$6f,$70,$24,$3d,$0d,$00,$61,$73
        dc.b    $64,$66,$67,$68,$6a,$6b,$6c,$97,$fd,$3a,$31,$7e,$79,$78,$63,$76
        dc.b    $62,$6e,$6d,$2c,$3b,$2d,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$2b,$00
        dc.b    $00,$00,$00,$7f,$00,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $3c,$00,$00,$28,$29,$2f,$2a,$37,$38,$39,$34,$35,$36,$31,$32,$33
        dc.b    $30,$2e,$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_shift:
        dc.b    $00,$1b,$31,$32,$33,$34,$35,$36,$37,$38,$39,$30,$f8,$b9,$08,$09
        dc.b    $51,$57,$45,$52,$54,$5a,$55,$49,$4f,$50,$9c,$2b,$0d,$00,$41,$53
        dc.b    $44,$46,$47,$48,$4a,$4b,$4c,$25,$00,$2f,$00,$b5,$59,$58,$43,$56
        dc.b    $42,$4e,$4d,$3f,$2e,$36,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$37,$38,$00,$2d,$34,$00,$36,$2b,$00
        dc.b    $32,$00,$30,$7f,$00,$00,$3e,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $3e,$00,$00,$28,$29,$2f,$2a,$37,$38,$39,$34,$35,$36,$31,$32,$33
        dc.b    $30,$2e,$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_caps:
        dc.b    $00,$1b,$31,$32,$33,$34,$35,$36,$37,$38,$39,$30,$f8,$b9,$08,$09
        dc.b    $51,$57,$45,$52,$54,$5a,$55,$49,$4f,$50,$9c,$2b,$0d,$00,$41,$53
        dc.b    $44,$46,$47,$48,$4a,$4b,$4c,$25,$00,$2f,$00,$b5,$59,$58,$43,$56
        dc.b    $42,$4e,$4d,$3f,$2e,$36,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$2d,$00,$00,$00,$2b,$00
        dc.b    $00,$00,$00,$7f,$00,$00,$3c,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $3e,$00,$00,$28,$29,$2f,$2a,$37,$38,$39,$34,$35,$36,$31,$32,$33
        dc.b    $30,$2e,$0d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

tab_alt:
tab_capsalt:
;                $0              $4              $8              $c
        dc.b    $00,$e6,$00,$7e,$23,$7b,$5b,$ee,$60,$5c,$5e,$40,$5d,$7d,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$7d,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$5b,$5d,$2a,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$21,$dd,$7c,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
tab_shalt:
        dc.b    $00,$e6,$00,$7e,$23,$7b,$5b,$ee,$60,$5c,$5e,$40,$5d,$7d,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$5c,$7d,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$7b,$7d,$2a,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$21,$dd,$7c,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

tab_altgr:
tab_capsaltgr:
;                $0              $4              $8              $c
        dc.b    $00,$00,$00,$7e,$23,$7b,$5b,$ee,$60,$5c,$5e,$40,$5d,$7d,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$21,$dd,$7c,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

tab_shaltgr:
;                $0              $4              $8              $c
        dc.b    $00,$00,$00,$7e,$23,$7b,$5b,$ee,$60,$5c,$5e,$40,$5d,$7d,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$21,$dd,$7c,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

 IFNE DEADKEYS
tab_dead:
        dc.b    $ba,$60,$5E,$b9,$7e,0

        ; ´a -> á
        dc.b    $61,$a0
        ; ´e -> é
        dc.b    $65,$82
        ; ´E -> É
        dc.b    $45,$90
        ; ´i -> í
        dc.b    $69,$a1
        ; ´o -> ó
        dc.b    $6F,$a2
        ; ´u -> ú
        dc.b    $75,$a3
        dc.b    0
        
        ; `a -> à
        dc.b    $61,$85
        ; `A -> À
        dc.b    $41,$b6
        ; `e -> è
        dc.b    $65,$8a
        ; `i -> ì
        dc.b    $69,$8d
        ; `o -> ò
        dc.b    $6F,$95
        ; `u -> ù
        dc.b    $75,$97
        dc.b    0

        ; ^a -> â
        dc.b    $61,$83
        ; ^e -> ê
        dc.b    $65,$88
        ; ^i -> î
        dc.b    $69,$8c
        ; ^o -> ô
        dc.b    $6F,$93
        ; ^u -> û
        dc.b    $75,$96
        ; ^A -> Â
        dc.b    $41,$c3
        ; ^E -> Ê
        dc.b    $45,$c5
        ; ^I -> Î
        dc.b    $49,$c9
        ; ^O -> Ô
        dc.b    $4f,$ce
        ; ^U -> Û
        dc.b    $55,$d1
        dc.b    0

        ; ¨a -> ä
        dc.b    $65,$89
        ; ¨i -> ï
        dc.b    $69,$8b
        ; ¨o -> ö
        dc.b    $6f,$94
        ; ¨u -> ü
        dc.b    $75,$9a
        ; ¨y -> ÿ
        dc.b    $79,$98
        ; ¨E -> Ë
        dc.b    $45,$c6
        ; ¨I -> Ï
        dc.b    $49,$ca
        ; ¨A -> Ä
        dc.b    $41,$8e
        ; ¨O -> Ö
        dc.b    $4f,$99
        ; ¨U -> Ü
        dc.b    $55,$9a
        dc.b    0

;added the following part for the tilde dead key
;works only with AltGr activated in MagiC PC keyboard options
;the ALT+~ combinaison will not be a dead key, AltGR will!
        ; ~n -> ñ
        dc.b    $6e,$a4
        ; ~N -> Ñ
        dc.b    $4e,$a5
        dc.b    0

 ENDC
