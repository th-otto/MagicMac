; ph_branch = 0x601a
; ph_tlen = 0x0000020c
; ph_dlen = 0x000000d2
; ph_blen = 0x00000000
; ph_slen = 0x00000046
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000000
; ph_absflag = 0x0000
; CP/M relocation bytes = 0x000002de

load_MAC:
[00000000] 2f0b                      move.l    a3,-(a7)
[00000002] 2f0c                      move.l    a4,-(a7)
[00000004] 4fef ff80                 lea.l     -128(a7),a7
[00000008] 2648                      movea.l   a0,a3
[0000000a] 2849                      movea.l   a1,a4
[0000000c] 41d7                      lea.l     (a7),a0
[0000000e] 4eb9 0000 0000            jsr       strgcpy
[00000014] 49f9 0000 0000            lea.l     load_MAC,a4
[0000001a] 302b 0020                 move.w    32(a3),d0
[0000001e] 7205                      moveq.l   #5,d1
[00000020] 41fa 0014                 lea.l     $00000036(pc),a0
[00000024] b058                      cmp.w     (a0)+,d0
[00000026] 57c9 fffc                 dbeq      d1,$00000024
[0000002a] 6600 00a0                 bne       $000000CC
[0000002e] 3028 000a                 move.w    10(a0),d0
[00000032] 4efb 0002                 jmp       $00000036(pc,d0.w)
[00000036] 0001 0002                 ori.b     #$02,d1
[0000003a] 0004 0008                 ori.b     #$08,d4
[0000003e] 0010 0020                 ori.b     #$20,(a0)
[00000042] 0018 0026                 ori.b     #$26,(a0)+
[00000046] 004a 006e                 ori.w     #$006E,a2 ; apollo only
[0000004a] 007c 008a                 ori.w     #$008A,sr
[0000004e] 224c                      movea.l   a4,a1
[00000050] 41d7                      lea.l     (a7),a0
[00000052] 4eb9 0000 0000            jsr       strgcat
[00000058] 6000 0072                 bra.w     $000000CC
[0000005c] 7002                      moveq.l   #2,d0
[0000005e] b0ab 0026                 cmp.l     38(a3),d0
[00000062] 660e                      bne.s     $00000072
[00000064] 43ec 0009                 lea.l     9(a4),a1
[00000068] 41d7                      lea.l     (a7),a0
[0000006a] 4eb9 0000 0000            jsr       strgcat
[00000070] 605a                      bra.s     $000000CC
[00000072] 43ec 0014                 lea.l     20(a4),a1
[00000076] 41d7                      lea.l     (a7),a0
[00000078] 4eb9 0000 0000            jsr       strgcat
[0000007e] 604c                      bra.s     $000000CC
[00000080] 7002                      moveq.l   #2,d0
[00000082] b0ab 0026                 cmp.l     38(a3),d0
[00000086] 660e                      bne.s     $00000096
[00000088] 43ec 001d                 lea.l     29(a4),a1
[0000008c] 41d7                      lea.l     (a7),a0
[0000008e] 4eb9 0000 0000            jsr       strgcat
[00000094] 6036                      bra.s     $000000CC
[00000096] 43ec 0029                 lea.l     41(a4),a1
[0000009a] 41d7                      lea.l     (a7),a0
[0000009c] 4eb9 0000 0000            jsr       strgcat
[000000a2] 6028                      bra.s     $000000CC
[000000a4] 43ec 0033                 lea.l     51(a4),a1
[000000a8] 41d7                      lea.l     (a7),a0
[000000aa] 4eb9 0000 0000            jsr       strgcat
[000000b0] 601a                      bra.s     $000000CC
[000000b2] 43ec 003e                 lea.l     62(a4),a1
[000000b6] 41d7                      lea.l     (a7),a0
[000000b8] 4eb9 0000 0000            jsr       strgcat
[000000be] 600c                      bra.s     $000000CC
[000000c0] 43ec 0049                 lea.l     73(a4),a1
[000000c4] 41d7                      lea.l     (a7),a0
[000000c6] 4eb9 0000 0000            jsr       strgcat
[000000cc] 41d7                      lea.l     (a7),a0
[000000ce] 4eb9 0000 0000            jsr       load_prg
[000000d4] 4fef 0080                 lea.l     128(a7),a7
[000000d8] 285f                      movea.l   (a7)+,a4
[000000da] 265f                      movea.l   (a7)+,a3
[000000dc] 4e75                      rts
load_ATA:
[000000de] 48e7 1810                 movem.l   d3-d4/a3,-(a7)
[000000e2] 4fef ff80                 lea.l     -128(a7),a7
[000000e6] 3600                      move.w    d0,d3
[000000e8] 3801                      move.w    d1,d4
[000000ea] 2648                      movea.l   a0,a3
[000000ec] 2248                      movea.l   a0,a1
[000000ee] 41d7                      lea.l     (a7),a0
[000000f0] 4eb9 0000 0000            jsr       strgcpy
[000000f6] 47f9 0000 0000            lea.l     load_MAC,a3
[000000fc] 3003                      move.w    d3,d0
[000000fe] b07c 0007                 cmp.w     #$0007,d0
[00000102] 6200 00ea                 bhi       $000001EE
[00000106] d040                      add.w     d0,d0
[00000108] 303b 0006                 move.w    $00000110(pc,d0.w),d0
[0000010c] 4efb 0002                 jmp       $00000110(pc,d0.w)
J1:
[00000110] 0010                      dc.w $0010   ; $00000120-$00000110
[00000112] 0020                      dc.w $0020   ; $00000130-$00000110
[00000114] 0030                      dc.w $0030   ; $00000140-$00000110
[00000116] 0040                      dc.w $0040   ; $00000150-$00000110
[00000118] 00b4                      dc.w $00b4   ; $000001c4-$00000110
[0000011a] 00de                      dc.w $00de   ; $000001ee-$00000110
[0000011c] 00c2                      dc.w $00c2   ; $000001d2-$00000110
[0000011e] 00d0                      dc.w $00d0   ; $000001e0-$00000110
[00000120] 43eb 0054                 lea.l     84(a3),a1
[00000124] 41d7                      lea.l     (a7),a0
[00000126] 4eb9 0000 0000            jsr       strgcat
[0000012c] 6000 00cc                 bra       $000001FA
[00000130] 43eb 005e                 lea.l     94(a3),a1
[00000134] 41d7                      lea.l     (a7),a0
[00000136] 4eb9 0000 0000            jsr       strgcat
[0000013c] 6000 00bc                 bra       $000001FA
[00000140] 43eb 0067                 lea.l     103(a3),a1
[00000144] 41d7                      lea.l     (a7),a0
[00000146] 4eb9 0000 0000            jsr       strgcat
[0000014c] 6000 00ac                 bra       $000001FA
[00000150] 7007                      moveq.l   #7,d0
[00000152] c044                      and.w     d4,d0
[00000154] b07c 0004                 cmp.w     #$0004,d0
[00000158] 625c                      bhi.s     $000001B6
[0000015a] d040                      add.w     d0,d0
[0000015c] 303b 0006                 move.w    $00000164(pc,d0.w),d0
[00000160] 4efb 0002                 jmp       $00000164(pc,d0.w)
J2:
[00000164] 000a                      dc.w $000a   ; $0000016e-$00000164
[00000166] 001a                      dc.w $001a   ; $0000017e-$00000164
[00000168] 0028                      dc.w $0028   ; $0000018c-$00000164
[0000016a] 0036                      dc.w $0036   ; $0000019a-$00000164
[0000016c] 0044                      dc.w $0044   ; $000001a8-$00000164
[0000016e] 43eb 0070                 lea.l     112(a3),a1
[00000172] 41d7                      lea.l     (a7),a0
[00000174] 4eb9 0000 0000            jsr       strgcat
[0000017a] 6000 007e                 bra.w     $000001FA
[0000017e] 43eb 0079                 lea.l     121(a3),a1
[00000182] 41d7                      lea.l     (a7),a0
[00000184] 4eb9 0000 0000            jsr       strgcat
[0000018a] 606e                      bra.s     $000001FA
[0000018c] 43eb 0082                 lea.l     130(a3),a1
[00000190] 41d7                      lea.l     (a7),a0
[00000192] 4eb9 0000 0000            jsr       strgcat
[00000198] 6060                      bra.s     $000001FA
[0000019a] 43eb 008c                 lea.l     140(a3),a1
[0000019e] 41d7                      lea.l     (a7),a0
[000001a0] 4eb9 0000 0000            jsr       strgcat
[000001a6] 6052                      bra.s     $000001FA
[000001a8] 43eb 0097                 lea.l     151(a3),a1
[000001ac] 41d7                      lea.l     (a7),a0
[000001ae] 4eb9 0000 0000            jsr       strgcat
[000001b4] 6044                      bra.s     $000001FA
[000001b6] 43eb 00a2                 lea.l     162(a3),a1
[000001ba] 41d7                      lea.l     (a7),a0
[000001bc] 4eb9 0000 0000            jsr       strgcat
[000001c2] 6036                      bra.s     $000001FA
[000001c4] 43eb 00ab                 lea.l     171(a3),a1
[000001c8] 41d7                      lea.l     (a7),a0
[000001ca] 4eb9 0000 0000            jsr       strgcat
[000001d0] 6028                      bra.s     $000001FA
[000001d2] 43eb 00b5                 lea.l     181(a3),a1
[000001d6] 41d7                      lea.l     (a7),a0
[000001d8] 4eb9 0000 0000            jsr       strgcat
[000001de] 601a                      bra.s     $000001FA
[000001e0] 43eb 00be                 lea.l     190(a3),a1
[000001e4] 41d7                      lea.l     (a7),a0
[000001e6] 4eb9 0000 0000            jsr       strgcat
[000001ec] 600c                      bra.s     $000001FA
[000001ee] 43eb 00c9                 lea.l     201(a3),a1
[000001f2] 41d7                      lea.l     (a7),a0
[000001f4] 4eb9 0000 0000            jsr       strgcat
[000001fa] 41d7                      lea.l     (a7),a0
[000001fc] 4eb9 0000 0000            jsr       load_prg
[00000202] 4fef 0080                 lea.l     128(a7),a7
[00000206] 4cdf 0818                 movem.l   (a7)+,d3-d4/a3
[0000020a] 4e75                      rts

data:
[0000020c]                           dc.b 'MFM2.SYS',0
[00000215]                           dc.b 'MFM4IP.SYS',0
[00000220]                           dc.b 'MFM4.SYS',0
[00000229]                           dc.b 'MFM16IP.SYS',0
[00000235]                           dc.b 'MFM16.SYS',0
[0000023f]                           dc.b 'MFM256.SYS',0
[0000024a]                           dc.b 'MFM32K.SYS',0
[00000255]                           dc.b 'MFM16M.SYS',0
[00000260]                           dc.b 'MFA16.SYS',0
[0000026a]                           dc.b 'MFA4.SYS',0
[00000273]                           dc.b 'MFA2.SYS',0
[0000027c]                           dc.b 'MFA2.SYS',0
[00000285]                           dc.b 'MFA4.SYS',0
[0000028e]                           dc.b 'MFA16.SYS',0
[00000298]                           dc.b 'MFA256.SYS',0
[000002a3]                           dc.b 'MFA32K.SYS',0
[000002ae]                           dc.b 'MFA2.SYS',0
[000002b7]                           dc.b 'MFA16.SYS',0
[000002c1]                           dc.b 'MFA2.SYS',0
[000002ca]                           dc.b 'MFA256.SYS',0
[000002d5]                           dc.b 'MFA2.SYS',0
;
         U strgcpy
         U strgcat
         U load_prg
00000000 T load_MAC
000000de T load_ATA
;
; CP/M Relocations:
; $00000016 data
; $000000f8 data
