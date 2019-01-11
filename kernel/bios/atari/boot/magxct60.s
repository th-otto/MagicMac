;OUTSIDE   EQU  0              ; memory segments on 32k pages
RESIDENT  EQU  1              ; resetfest

     INCLUDE "osbind.inc"

fstrm_beg EQU  ____md
os_chksum EQU  trp14ret

sizeof_PH equ 28



MACRO Super adr
        pea    adr
        move.w #$20,-(sp)                       ; Super
        trap   #1
        addq.w #6,sp
ENDM

MACRO PRINTLINE message
        movem.l d1-d2/a1-a2,-(a7)
        pea    message
        move   #9,-(sp)                         ; Cconws
        trap   #1
        addq.w #6,sp
        movem.l (a7)+,d1-d2/a1-a2
ENDM




        .TEXT

; for PASM

        MC68030
     	SUPER


        movea.l 4(a7),a5                        ; BasePagePointer from Stack
        move.l  p_tlen(a5),d0                   ; text segment size
        add.l   p_dlen(a5),d0                   ; data segment size
        add.l   p_blen(a5),d0                   ; bss segment size
        add.l   #1800,d0                        ; for stack and basepage
        and.b   #$FE,d0
        lea     -104(a5,d0.l),a7
        movem.l d1-d2/a1-a2,-(a7)
        move.l  d0,-(a7)
        pea     (a5)
        clr.w   -(a7)
        move.w  #$4A,-(a7)                      ; Mshrink
        trap    #1
        adda.w  #12,a7
        movem.l (a7)+,d1-d2/a1-a2
        move.l  #$4D616758,d0                   ; MagX
        bsr     GET_COOKIE
        bpl     err
        clr.l   MACHINE
        clr.w   CT60
        clr.w   EXT_CLOCK
        move.l  #$5F4D4348,d0                   ; _MCH
        bsr     GET_COOKIE
        bmi.s   L06A                            ; no cookie-jar
        movea.l d0,a0
        move.l  (a0),MACHINE
L06A:
        cmpi.l  #$30000,MACHINE                 ; Falcon
        bne.s   L0B6
        clr.l   FPU.l
        move.l  #$5F435055,d0                   ; _CPU
        bsr     GET_COOKIE
        bmi.s   L0B6                            ; no cookie-jar
        movea.l d0,a0
        move.l  (a0),CPU
        cmpi.l  #$3C,CPU                        ; 060
        bne.s   L0B6
        st      CT60
        move.l  #$5F465055,d0                   ; _FPU
        bsr     GET_COOKIE
        bmi.s   L0B6                            ; no cookie-jar
        movea.l d0,a0
        move.l  (a0),FPU
L0B6:
        PRINTLINE Info_Text
        move.w  #-1,-(a7)
        move.w  #$B,-(a7)                       ; Kbshift
        trap    #13
        addq.l  #4,a7
        and.w   #$3,d0                          ; Shift
        cmp.w   #$3,d0
        beq     err
        move.l  #$5F465251,d0                   ; _FRQ, internal clock
        bsr     GET_COOKIE
        bmi     L1CA
        movea.l d0,a0
        move.l  (a0),d0
        cmp.l   #$20,d0
        bls     L1CA
        link    a5,#-4
        clr.w   -2(a5)
        lea     -4(a5),a0
        moveq   #2,d1
        bsr     CONV_DECI
        PRINTLINE Text_Internal_clock
        PRINTLINE -4(a5)
        PRINTLINE Text_Mhz
        unlk    a5
        move.l  #$5F465245,d0                   ; _FRE, external clock
        bsr     GET_COOKIE
        bmi.s   L1CA
        movea.l d0,a0
        move.l  (a0),d0
        move.l  d0,-(a7)
        link    a5,#-4
        clr.w   -2(a5)
        lea     -4(a5),a0
        moveq   #$2,d1
        bsr     CONV_DECI
        PRINTLINE Text_external_clock
        PRINTLINE -4(a5)
        PRINTLINE Text_Mhz
        unlk    a5
        move.l  (a7)+,d0
        cmp.l   #$20,d0
        bne.s   L1CA
        st      EXT_CLOCK
L1CA:
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #$0,-(a7)
        pea     magx_name+1
        move.w  #$003D,-(a7)                    ; Fopen
        trap    #1
        addq.w  #8,a7
        movem.l (a7)+,d1-d2/a1-a2
        move.w  d0,d7
        bmi     err
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #2,-(a7)
        move.w  d7,-(a7)
        move.l  #0,-(a7)
        move.w  #$0042,-(a7)                    ; Fseek
        trap    #1
        adda.w  #10,a7
        movem.l (a7)+,d1-d2/a1-a2
        move.l  d0,d6
        ble     err
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #0,-(a7)
        move.w  d7,-(a7)
        move.l  #0,-(a7)
        move.w  #$0042,-(a7)                    ; Fseek
        trap    #1
        adda.w  #10,a7
        movem.l (a7)+,d1-d2/a1-a2
        tst.l   d0
        bmi     err
        movem.l d1-d2/a1-a2,-(a7)
        move.l  d6,-(a7)
        move.w  #$0048,-(a7)                    ; Malloc
        trap    #1
        addq.w  #6,a7
        movem.l (a7)+,d1-d2/a1-a2
        tst.l   d0
        ble     err
        movea.l d0,a6
        movem.l d1-d2/a1-a2,-(a7)
        pea     (a6)
        move.l  d6,-(a7)
        move.w  d7,-(a7)
        move.w  #$003F,-(a7)                    ; Fread
        trap    #1
        adda.w  #12,a7
        movem.l (a7)+,d1-d2/a1-a2
        move.l  d0,-(a7)
        movem.l d1-d2/a1-a2,-(a7)
        move.w  d7,-(a7)
        move.w  #$003E,-(a7)                    ; Fclose
        trap    #1
        addq.w  #4,a7
        movem.l (a7)+,d1-d2/a1-a2
        cmp.l   (a7)+,d6
        bne     err
        tst.l   d0
        bmi     err
        cmpi.w  #$601A,(a6)
        bne     err
        movea.l sizeof_PH+os_magic(a6),a0
        lea     sizeof_PH(a6,a0.l),a0
        cmpi.l  #$87654321,(a0)+
        bne     err
        movea.l (a0)+,a5
        addq.l  #4,a0
        cmpi.l  #$4D414758,(a0)                 ; MAGX
        bne     err
        movem.l d1-d2/a1-a2,-(a7)
        Super 0
        movem.l (a7)+,d1-d2/a1-a2

        move.l  #$01000000,fstrm_beg
        cmpi.l  #$1357BD13,ramvalid
        bne.s   no_ttram
        cmpi.l  #$01080000,ramtop
        bcs.s   no_ttram
        movea.l #$01000000,a5
no_ttram:
        cmpi.l  #$00020000,MACHINE              ; Atari TT or Hades?
        bcs.s   ver_st
        move.w  #$0300,d0
        cmpi.l  #$00030000,MACHINE              ; Falcon?
        bcs.s   ver_tt
        move.w  #$0400,d0
ver_tt:
        move.w  d0,os_version+sizeof_PH(a6)
ver_st:
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #$0019,-(a7)                    ; Dgetdrv
        trap    #1
        addq.w  #2,a7
        movem.l (a7)+,d1-d2/a1-a2
        movea.l os_magic+sizeof_PH(a6),a0
        lea     sizeof_PH(a6,a0.l),a0
        lea     $007A(a0),a0
        cmpi.l  #$5F5F5F5F,(a0)
        bne.s   do_reloc
        add.b   #$41,d0
        move.b  d0,(a0)+
        move.b  #$3A,(a0)+
        lea     magx_name,a1
namecpy_loop:
        move.b  (a1)+,(a0)+
        bne.s   namecpy_loop
do_reloc:
        move.l  2(a6),d0
        add.l   6(a6),d0
        move.l  d0,d5
        add.l   14(a6),d0
        lea     sizeof_PH(a6,d0.l),a3
        lea     0(a6,d6.l),a2
        cmpa.l  a2,a3
        bcc.s   end_reloc
        lea     sizeof_PH(a6),a0                    ; reloge MagiC
        move.l  (a3)+,d0
reloc_loop:
        adda.l  d0,a0
        move.l  a5,d0
        add.l   d0,(a0)
reloc_loop2:
        cmpa.l  a2,a3
        bhi.s   end_reloc
        moveq   #0,d0
        move.b  (a3)+,d0
        beq.s   end_reloc
        cmp.b   #$01,d0
        bne.s   reloc_loop
        lea     $00FE(a0),a0
        bra.s   reloc_loop2

end_reloc:
        lea     sizeof_PH(a6),a0
        lea     0(a0,d5.l),a1
        moveq   #0,d0
os_chkloop:
        add.l   (a0)+,d0
        cmpa.l  a0,a1
        bcs.s   os_chkloop
        move.l  d0,os_chksum
        tst.w   CT60
        beq     LA10
        lea     sizeof_PH(a6),a1                ; patch
        move.l  d5,d1
        lsr.l   #1,d1
        moveq   #0,d2


; Patch cache 1
L3A2:
        move.l  (a1),d0                         ; caches
        cmp.l   #$203C0000,d0                   ; MOVE.L #$808,D0
        bne.s   L41A
        cmpi.l  #$08084E7B,4(a1)                ; MOVEC.L D0,CACR
        beq.s   L3EA
        cmpi.l  #$31114E7B,4(a1)                ; MOVE.L #$3111,D0
        bne.s   L41A
        move.l  #$203CA080,(a1)
        move.l  #$80004E7B,4(a1)
        PRINTLINE Text_Patch_cache_1
        addq.w  #1,d2
        bra     L95E

; Patch cache 2
L3EA:
        move.l  #$70004E7B,(a1)
        move.l  #$00024E71,4(a1)
        move.w  #$F4F8,8(a1)                    ; CPUSHA BC
        PRINTLINE Text_Patch_cache_2
        addq.w  #1,d2
        bra     L95E

; Patch cache 3
L41A:
        cmp.l   #$4E7A0002,d0                   ; MOVE.L CACR,D0
        bne.s   L46C
        cmpi.l  #$08C00003,4(a1)                ; BSET #3,D0
        bne.s   L46C
        cmpi.l  #$4E7B0002,8(a1)                ; MOVEC.L D0,CACR
        bne.s   L46C
        cmpi.l  #$70021238,12(a1)
        bne.s   L46C
        move.l  #$4E714E71,d0
        move.l  d0,(a1)
        move.l  d0,4(a1)
        move.l  d0,8(a1)
        PRINTLINE Text_Patch_cache_3
        addq.w  #1,d2
        bra     L95E

; Patch movep 1
L46C:
        cmp.l   #$03C80000,d0                   ; MOVE.L D1,(A0)
        bne.s   L4BA
        cmpi.l  #$03C80008,4(a1)                ; MOVEP.L D1,8(A0)
        bne.s   L4BA
        cmpi.l  #$03C80010,8(a1)                ; MOVEP.L D1,16(A0)
        bne.s   L4BA
        move.l  #$72E84230,(a1)
        move.l  #$10185481,4(a1)
        move.l  #$66F84E71,8(a1)
        PRINTLINE Text_Patch_movep_1
        addq.w  #1,d2
        bra     L95E

; Patch movep 2
L4BA:
        cmp.l   #$203C0088,d0                   ; MOVE.L #$00880105,D0
        bne.s   L51E
        cmpi.l  #$010501C8,4(a1)                ; MOVEP.L D0,$26(A0)
        bne.s   L51E
        cmpi.w  #$0026,8(a1)
        bne.s   L51E
        move.l  #$42280026,0(a1)
        move.l  #$117C0088,4(a1)
        move.l  #$0028117C,8(a1)
        move.l  #$0001002A,12(a1)
        move.l  #$117C0005,16(a1)
        move.l  #$002C6038,20(a1)
        PRINTLINE Text_Patch_movep_2
        addq.w  #1,d2
        bra     L95E

; Patch CPU type
L51E:
        cmp.l   #$204F7000,d0                   ; 060
        bne.s   L550
        cmpi.w  #$21FC,4(a1)
        bne.s   L550
        move.l  #$703C4E75,(a1)
        PRINTLINE Text_Patch_CPU_type
        addq.w  #1,d2
        bra     L95E

; Patch vectors 1
L550:
        cmp.l   #$41F80008,d0                   ; vectors
        bne.s   L584
        cmpi.l  #$703D43FA,4(a1)
        bne.s   L584
        move.w  #$7008,4(a1)
        PRINTLINE Text_Patch_Vectors_1
        addq.w  #1,d2
        bra     L95E

; Patch vectors 2
L584:
        cmp.l   #$703D20C9,d0                   ; vectors
        bne.s   L5B6
        cmpi.l  #$D3C151C8,4(a1)
        bne.s   L5B6
        move.w  #$7008,(a1)
        PRINTLINE Text_Patch_Vectors_2
        addq.w  #1,d2
        bra     L95E

; Patch vectors 3
L5B6:
        cmp.l   #$21C80010,d0                   ; vectors
        bne.s   L5EC
        cmpi.l  #$21C8002C,4(a1)
        bne.s   L5EC
        move.l  #$4E714E71,4(a1)
        PRINTLINE Text_Patch_Vectors_3
        addq.w  #1,d2
        bra     L95E

; Patch Reset 1
L5EC:
        cmp.l   #$4E700CB8,d0                   ; reset
        bne.s   L61A
        cmpi.l  #$31415926,4(a1)
        bne     L95E
        PRINTLINE Text_Patch_Reset_1
        addq.w  #1,d2
        bra.s   L644

; Patch Reset 2
L61A:
        cmp.l   #$4E7021F8,d0                   ; reset
        bne.s   L64C
        cmpi.l  #$00040008,4(a1)
        bne.s   L5EC
        PRINTLINE Text_Patch_Reset_2
        addq.w  #1,d2
L644:
        move.w  #$4E71,(a1)                     ; Patch reset 1 or reset 2
        bra     L95E

; Patch DSP
L64C:
        cmp.l   #$4E7B0002,d0                   ; Init DSP
        bne.s   L692
        cmpi.l  #$0C380004,4(a1)
        bne.s   L692
        cmpi.w  #$665E,10(a1)
        bne.s   L692
        cmpi.w  #$6100,12(a1)
        bne.s   L692
        move.l  #$4E714E71,$000C(a1)
        PRINTLINE Text_Patch_DSP
        addq.w  #1,d2
        bra     L95E

; Patch Floppy
L692:
        cmp.l   #$610008A6,d0                   ; floppy
        bne.s   L6D0
        cmpi.l  #$61000AF2,4(a1)
        bne.s   L6D0
        cmpi.l  #$3CBC0180,8(a1)
        bne.s   L6D0
        move.l  #$610008BA,4(a1)
        PRINTLINE Text_Patch_Floppy
        bra     L95E

; Patch FPU Cookie
L6D0:
        cmp.l   #$54415441,d0                   ; FPU cookie
        bne.s   L71C
        cmpi.l  #$54415441,4(a1)
        bne.s   L71C
        cmpi.w  #$50F8,8(a1)
        bne.s   L71C
        move.w  #$7210,6(a1)
        PRINTLINE Text_Patch_FPU_Cookie
        addq.w  #1,d2
        tst.l   FPU
        bne     L95E
        move.w  #$7200,6(a1)
        bra     L95E

; Patch context FPU
L71C:
        cmp.l   #$F3274A17,d0                   ; context FPU
        bne.s   L75C
        cmpi.l  #$670CF227,4(a1)
        bne.s   L75C
        cmpi.l  #$E0FFF227,8(a1)
        bne.s   L75C
        move.l  #$4E714E71,2(a1)
        PRINTLINE Text_Patch_FPU
        addq.w  #1,d2
        bra     L95E

L75C:
        tst.l   FPU
        bne.s   L77C
        cmp.l   #$F3790100,d0                   ; FPU FRESTORE
        bne.s   L77C
        move.l  #$4E714E71,(a1)
        move.w  #$4E71,4(a1)
        bra     L95E

; Patch PMMU 030 tree
L77C:
        cmp.l   #$703F20D9,d0                   ; PMMU tree 030
        bne.s   L7B0
        cmpi.l  #$51C8FFFC,4(a1)
        bne.s   L7B0
        move.w  #$4E71,2(a1)
        PRINTLINE Text_Patch_PMMU
        addq.w  #1,d2
        bra     L95E

; Patch external clock 32MHz RGB monitor 1
L7B0:
        tst.w   EXT_CLOCK
        beq.s   L822
        cmp.l   #$720211C1,d0                   ; clock externe
        bne.s   L7F0
        cmpi.w  #$820A,4(a1)
        bne.s   L7F0
        move.l  #$4E714E71,(a1)
        move.w  #$4E71,4(a1)
        PRINTLINE Text_Patch_Monitor_1
        addq.w  #1,d2
        bra     L95E

; Patch external clock 32MHz RGB monitor 2
L7F0:
        cmp.l   #$31D8820A,d0                   ; clock externe
        bne.s   L822
        cmpi.w  #$4E75,4(a1)
        bne.s   L822
        move.l  #$4E714E71,(a1)
        PRINTLINE Text_Patch_Monitor_2
        addq.w  #1,d2
        bra     L95E

; Patch PSG printer
L822:
        cmp.l   #$40C1007C,d0                   ; ;PSG printer
        bne     L95E
        cmpi.l  #$070043F8,4(a1)
        bne     L95E
        cmpi.l  #$880045E9,8(a1)
        bne     L95E
        cmpi.l  #$000212BC,$000C(a1)
        bne     L95E
        cmpi.l  #$00071011,$0010(a1)
        bne     L95E
        cmpi.l  #$000000C0,$0014(a1)
        bne     L95E
        cmpi.l  #$148012BC,$0018(a1)
        bne     L95E
        cmpi.l  #$000F1498,$001C(a1)
        bne     L95E
        cmpi.l  #$12BC000E,$0020(a1)
        bne     L95E
        cmpi.l  #$10110200,$0024(a1)
        bne     L95E
        cmpi.l  #$00DF1480,$0028(a1)
        bne     L95E
        cmpi.l  #$14800000,$002C(a1)
        bne     L95E
        cmpi.l  #$00201480,$0030(a1)
        bne     L95E
        cmpi.l  #$46C170FF,$0034(a1)
        bne     L95E
        cmpi.w  #$4E75,$0038(a1)
        bne     L95E
        move.l  #$40E7007C,(a1)
        move.l  #$070043F8,4(a1)
        move.l  #$880045E9,8(a1)
        move.l  #$0002720F,$000C(a1)
        move.l  #$1018611C,$0010(a1)
        move.l  #$720E6112,$0014(a1)
        move.l  #$08800005,$0018(a1)
        move.l  #$611208C0,$001C(a1)
        move.l  #$0005610C,$0020(a1)
        move.l  #$46DF70FF,$0024(a1)
        move.l  #$4E751281,$0028(a1)
        move.l  #$10114E75,$002C(a1)
        move.l  #$12811480,$0030(a1)
        move.l  #$4E754E71,$0034(a1)
        move.w  #$4E71,$0038(a1)
        PRINTLINE Text_Patch_PSG
        addq.w  #1,d2

L95E:
        addq.w  #2,a1
        subq.l  #1,d1
        bgt     L3A2
        moveq   #$13,d3                         ; max patches
        tst.w   EXT_CLOCK
        beq.s   L972
        addq.w  #3,d3                           ; add 3
L972:
        cmp.w   d3,d2                           ; compare how many patches done
        beq     LA10
        PRINTLINE ERR
        link    a5,#-4
        clr.w   -2(a5)
        lea     -4(a5),a0
        move.l  d2,d0
        moveq   #$2,d1
        bsr     CONV_DECI
        PRINTLINE  -4(a5)
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #$2F,-(a7)                      ; "/"
        move.w  #$2,-(a7)                       ; Cconout
        trap    #1
        addq.w  #4,a7
        movem.l (a7)+,d1-d2/a1-a2
        lea     -4(a5),a0
        move.l  d3,d0
        moveq   #$2,d1
        bsr     CONV_DECI
        PRINTLINE  -4(a5)
        unlk    a5
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #$29,-(a7)                      ; ")"
        move.w  #$2,-(a7)                       ; Cconout
        trap    #1
        addq.w  #4,a7
        movem.l (a7)+,d1-d2/a1-a2
        movem.l d1-d2/a1-a2,-(a7)
        move.w  #$7,-(a7)                       ; Crawcin
        trap    #1
        addq.w  #2,a7
        movem.l (a7)+,d1-d2/a1-a2
LA10:
        ori     #$700,sr                        ; not allowed interruptions
        lea     toscopy(pc),a1
        lea     $0600,a0
        moveq   #((toscopyend-toscopy+3)/4)-1,d0
startcopy:
        move.l  (a1)+,(a0)+
        dbf     d0,startcopy
        move.l  _memtop,phystop
        cmpi.l  #40,CPU
        bcs.s   LA42
        dc.w    $F478                           ; CPUSHA DC
        moveq   #$00,d0                         ; inhibe & vide caches
        movec   d0,cacr
        dc.w    $F4D8                           ; CINVA BC
        bra.s   LA5A

LA42:
        cmpi.l  #20,CPU
        bcs.s   LA5A
        movec   cacr,d0
        or.w    #$808,d0                        ; clear caches
        movec   d0,cacr
LA5A:
        jmp     $0600

toscopy:
        movea.l a5,a0
        lea     sizeof_PH(a6),a1
        move.l  d5,d0
        lsr.l   #3,d0
        subq.l  #1,d0
        cmpa.l  a0,a1                           ; deplace MagiC
        bhi.s   cpy_uloop
        beq.s   cpy_end
        adda.l  d5,a1
        adda.l  d5,a0
cpy_dloop:
        move.l  -(a1),-(a0)
        move.l  -(a1),-(a0)
        dbf     d0,cpy_dloop
        bra.s   cpy_end

cpy_uloop:
        move.l  (a1)+,(a0)+
        move.l  (a1)+,(a0)+
        dbf     d0,cpy_uloop
cpy_end:
        move.l  #$5555AAAA,memval3
     IFNE RESIDENT
        move.l  #$31415926,resvalid
        move.l  a5,resvector
     ENDIF
        cmpa.l  #$01000000,a5
        bne.s   cpy_st
        add.l   d5,fstrm_beg
     IFNE OUTSIDE
/* align start of FastRAM, beyond end of MagiC on 32k boundary */
		move.l   fstrm_beg,d0
		add.l    #$00007fff,d0            ; 32k-1 addieren
		andi.w   #$8000,d0                ; auf volle 32k gehen
		move.l   d0,fstrm_beg
     ENDIF
        bra.s   startit

cpy_st:
        add.l   d5,os_membot(a5)
     IFNE OUTSIDE
/* align start of ST-RAM, beyond end of MagiC on 32k boundary */
		move.l   os_membot(a5),d0
		add.l    #$00007fff,d0            ; 32k-1 addieren
		andi.w   #$8000,d0                ; auf volle 32k gehen
		move.l   d0,os_membot(a5)
     ENDIF
        movea.l os_magic(a5),a0
        cmpi.l  #$87654321,(a0)+
        bne.s   startit
        add.l   d5,(a0)
     IFNE OUTSIDE
/* align start of ST-RAM, beyond end of AES on 32k boundary */
		move.l   (a0),d0
		add.l    #$00007fff,d0            ; 32k-1 addieren
		andi.w   #$8000,d0                ; auf volle 32k gehen
		move.l   d0,(a0)
     ENDIF
startit:
        clr.l   _hz_200
        jmp     (a5)

        nop
toscopyend:


err:
done:
        movem.l d1-d2/a1-a2,-(a7)
        clr.w   -(a7)                           ; Pterm0
        trap    #1
        addq.w  #2,a7
        movem.l (a7)+,d1-d2/a1-a2
        illegal
        rts

; A0:target string pointer ASCII
; D0:32 bit value
; D1:number of digits
CONV_DECI:
        bsr     CONV_DECI_SIMPLE
        subq.w  #1,d1
        beq.s   LB04
        swap    d0
        tst.w   d0
        bne.s   LAFA                            ; depassement
        moveq   #$00,d0
LAE4:
        cmpi.b  #"0",0(a0,d0.w)
        bne.s   LB04
        move.b  #" ",0(a0,d0.w)                 ; enleve les zeros inutiles
        addq.w  #1,d0
        cmp.w   d1,d0
        bne.s   LAE4
        bra.s   LB04

LAFA:
        move.b  #$3F,0(a0,d1.w)
        dbf     d1,LAFA
LB04:
        rts

; A0:target string pointer ASCII
; D0:32 bit value
; D1:number of digits

CONV_DECI_SIMPLE:
        move.w  d1,-(a7)
        subq.w  #1,d1
        move.l  d0,-(a7)
LB0C:
        moveq   #$00,d0
        move.w  (a7),d0
        divu    #10,d0                          ; poids fort /10
        move.w  d0,(a7)                         ; resultat poids fort
        move.w  2(a7),d0
        divu    #10,d0                          ; ((reste * 65536) + poids faible)/10
        move.w  d0,2(a7)                        ; resultat poids faible
        swap    d0
        or.w    #$0030,d0
        move.b  d0,0(a0,d1.w)
        dbf     d1,LB0C
        addq.l  #4,a7
        move.w  (a7)+,d1
        rts


; nom dans D0.L, au retour si < 0 pas de cookie
; retourne le pointeur sur donnee cookie dans D0

GET_COOKIE:
        movem.l d1-d7/a0-a1/a6,-(a7)
        move.l  d0,d6
        suba.l  a6,a6
        movem.l d1-d2/a1-a2,-(a7)
        Super   1
        movem.l (a7)+,d1-d2/a1-a2
        tst.l   d0
        bmi.s   LB6C                            ;  mode superviseur
        movem.l d1-d2/a1-a2,-(a7)
        Super   0
        movem.l (a7)+,d1-d2/a1-a2
        movea.l d0,a6                           ;  saves SSP
LB6C:
        moveq   #$00,d7
        move.l  _p_cookies,d0
        beq.s   LB88
        movea.l d0,a0
LB76:
        tst.l   (a0)
        beq.s   LB88
        cmp.l   (a0),d6
        bne.s   LB84
        move.l  a0,d7
        addq.w  #4,d7
        bra.s   LB88

LB84:
        addq.w  #8,a0
        bra.s   LB76

LB88:
        move.l  a6,d0
        beq.s   LB9E
        movem.l d1-d2/a1-a2,-(a7)
        Super (a6)
        movem.l (a7)+,d1-d2/a1-a2
LB9E:
        moveq   #-1,d6
        move.l  d7,d0
LBA2:
        beq.s   LBA6
        moveq   #$00,d6
LBA6:
        tst.w   d6
        movem.l (a7)+,d1-d7/a0-a1/a6
        rts

        .DATA

Info_Text:
        dc.b    $0D,$0A,$0A,$1B,'p MagiC-BOOTER ',$1B,'q',$0D,$0A,$00
Text_Patch_cache_1:
        dc.b    $0D,$0A,'Patch cache 1',$00
Text_Patch_cache_2:
        dc.b    $0D,$0A,'Patch cache 2',$00
Text_Patch_cache_3:
        dc.b    $0D,$0A,'Patch cache 3',$00
Text_Patch_movep_1:
        dc.b    $0D,$0A,'Patch movep 1',$00
Text_Patch_movep_2:
        dc.b    $0D,$0A,'Patch movep 2',$00
Text_Patch_CPU_type:
        dc.b    $0D,$0A,'Patch CPU type',$00
Text_Patch_Vectors_1:
        dc.b    $0D,$0A,'Patch vectors 1',$00
Text_Patch_Vectors_2:
        dc.b    $0D,$0A,'Patch vectors 2',$00
Text_Patch_Vectors_3:
        dc.b    $0D,$0A,'Patch vectors 3',$00
Text_Patch_Reset_1:
        dc.b    $0D,$0A,'Patch reset 1',$00
Text_Patch_Reset_2:
        dc.b    $0D,$0A,'Patch reset 2',$00
Text_Patch_DSP:
        dc.b    $0D,$0A,'Patch DSP',$00
Text_Patch_Floppy:
        dc.b    $0D,$0A,'Patch floppy',$00
Text_Patch_FPU_Cookie:
        dc.b    $0D,$0A,'Patch FPU cookie',$00
Text_Patch_PMMU:
        dc.b    $0D,$0A,'Patch PMMU 030 tree',$00
Text_Patch_Monitor_1:
        dc.b    $0D,$0A,'Patch external clock 32MHz RGB monitor 1',$00
Text_Patch_Monitor_2:
        dc.b    $0D,$0A,'Patch external clock 32MHz RGB monitor 2',$00
Text_Patch_FPU:
        dc.b    $0D,$0A,'Patch context FPU',$00
Text_Internal_clock:
        dc.b    $0D,$0A,'Internal clock : ',$00
Text_external_clock:
        dc.b    ', External clock : ',$00
Text_Mhz:
        dc.b    ' Mhz',$00
Text_Patch_PSG:
        dc.b    $0D,$0A,'Patch PSG printer',$00
magx_name:
        dc.b    '\magic.ram',$00
ERR:
        dc.b    $0D,$0A,$0A,'WARNING ! A part is not patched ! (',$00

        .BSS

CT60:      DS.W 1
EXT_CLOCK: DS.W 1
MACHINE:   DS.L 1
CPU:       DS.L 1
FPU:       DS.L 1

        end
