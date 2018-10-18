; ph_branch = 0x601a
; ph_tlen = 0x00000146
; ph_dlen = 0x00000000
; ph_blen = 0x00000000
; ph_slen = 0x000002a0
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000000
; ph_absflag = 0x0000
; CP/M relocation bytes = 0x00000146

clear_me:
[00000000] 2200                      move.l    d0,d1
[00000002] 7000                      moveq.l   #0,d0
memset:
[00000004] 2248                      movea.l   a0,a1
[00000006] 2408                      move.l    a0,d2
[00000008] c47c 0001                 and.w     #$0001,d2
[0000000c] 6706                      beq.s     memset_a
[0000000e] 12c0                      move.b    d0,(a1)+
[00000010] 5381                      subq.l    #1,d1
[00000012] 6b24                      bmi.s     memset_e
memset_a:
[00000014] 1400                      move.b    d0,d2
[00000016] e14a                      lsl.w     #8,d2
[00000018] 1400                      move.b    d0,d2
[0000001a] 3002                      move.w    d2,d0
[0000001c] 4840                      swap      d0
[0000001e] 3002                      move.w    d2,d0
[00000020] 7403                      moveq.l   #3,d2
[00000022] c441                      and.w     d1,d2
[00000024] e489                      lsr.l     #2,d1
[00000026] 6002                      bra.s     memset_s
memset_l:
[00000028] 22c0                      move.l    d0,(a1)+
memset_s:
[0000002a] 5381                      subq.l    #1,d1
[0000002c] 6afa                      bpl.s     memset_l
[0000002e] 5342                      subq.w    #1,d2
[00000030] 6b06                      bmi.s     memset_e
memset_b:
[00000032] 12c0                      move.b    d0,(a1)+
[00000034] 5342                      subq.w    #1,d2
[00000036] 6afa                      bpl.s     memset_b
memset_e:
[00000038] 4e75                      rts
copy_mem:
[0000003a] 7201                      moveq.l   #1,d1
[0000003c] 3408                      move.w    a0,d2
[0000003e] c441                      and.w     d1,d2
[00000040] 6624                      bne.s     copy_so
[00000042] 3409                      move.w    a1,d2
[00000044] c441                      and.w     d1,d2
[00000046] 6706                      beq.s     copy_cnt
[00000048] 6026                      bra.s     copy_sb_
copy_pre:
[0000004a] 12d8                      move.b    (a0)+,(a1)+
[0000004c] 5380                      subq.l    #1,d0
copy_cnt:
[0000004e] 7203                      moveq.l   #3,d1
[00000050] c280                      and.l     d0,d1
[00000052] e480                      asr.l     #2,d0
[00000054] 6002                      bra.s     copy_a_s
copy_a_l:
[00000056] 22d8                      move.l    (a0)+,(a1)+
copy_a_s:
[00000058] 5380                      subq.l    #1,d0
[0000005a] 6afa                      bpl.s     copy_a_l
[0000005c] 6002                      bra.s     copy_b_s
copy_b_l:
[0000005e] 12d8                      move.b    (a0)+,(a1)+
copy_b_s:
[00000060] 5341                      subq.w    #1,d1
[00000062] 6afa                      bpl.s     copy_b_l
[00000064] 4e75                      rts
copy_so:
[00000066] 3409                      move.w    a1,d2
[00000068] c441                      and.w     d1,d2
[0000006a] 66de                      bne.s     copy_pre
[0000006c] 6002                      bra.s     copy_sb_
copy_sb_:
[0000006e] 12d8                      move.b    (a0)+,(a1)+
copy_sb_:
[00000070] 5380                      subq.l    #1,d0
[00000072] 6afa                      bpl.s     copy_sb_
[00000074] 4e75                      rts
copy_me_:
[00000076] 2200                      move.l    d0,d1
[00000078] e481                      asr.l     #2,d1
[0000007a] 6408                      bcc.s     copy_ma_
[0000007c] 32d8                      move.w    (a0)+,(a1)+
[0000007e] 6004                      bra.s     copy_ma_
copy_ma_:
[00000080] 22d8                      move.l    (a0)+,(a1)+
[00000082] 5381                      subq.l    #1,d1
copy_ma_:
[00000084] 6afa                      bpl.s     copy_ma_
[00000086] 4e75                      rts
strgcat:
[00000088] 4a18                      tst.b     (a0)+
[0000008a] 66fc                      bne.s     strgcat
[0000008c] 5388                      subq.l    #1,a0
strcpy:
[0000008e] 10d9                      move.b    (a1)+,(a0)+
[00000090] 66fc                      bne.s     strcpy
[00000092] 4e75                      rts
strglen:
[00000094] 2248                      movea.l   a0,a1
strlen_l:
[00000096] 4a19                      tst.b     (a1)+
[00000098] 66fc                      bne.s     strlen_l
[0000009a] 2009                      move.l    a1,d0
[0000009c] 9088                      sub.l     a0,d0
[0000009e] 5380                      subq.l    #1,d0
[000000a0] 4e75                      rts
strgcmp:
[000000a2] 7000                      moveq.l   #0,d0
[000000a4] 7200                      moveq.l   #0,d1
strcmp_l:
[000000a6] 1018                      move.b    (a0)+,d0
[000000a8] 1219                      move.b    (a1)+,d1
[000000aa] b041                      cmp.w     d1,d0
[000000ac] 6d0a                      blt.s     strcmp_l
[000000ae] 6e0c                      bgt.s     strcmp_g
[000000b0] 8200                      or.b      d0,d1
[000000b2] 66f2                      bne.s     strcmp_l
strcmp_e:
[000000b4] 7000                      moveq.l   #0,d0
[000000b6] 4e75                      rts
strcmp_l:
[000000b8] 70ff                      moveq.l   #-1,d0
[000000ba] 4e75                      rts
strcmp_g:
[000000bc] 7001                      moveq.l   #1,d0
[000000be] 4e75                      rts
strgupr:
[000000c0] 2248                      movea.l   a0,a1
strupr_l:
[000000c2] 1011                      move.b    (a1),d0
[000000c4] b03c 0061                 cmp.b     #$61,d0
[000000c8] 6d2e                      blt.s     strupr_s
[000000ca] b03c 007a                 cmp.b     #$7A,d0
[000000ce] 6e06                      bgt.s     strupr_a
[000000d0] 903c 0020                 sub.b     #$20,d0
[000000d4] 6022                      bra.s     strupr_s
strupr_a:
[000000d6] b03c 0084                 cmp.b     #$84,d0
[000000da] 6606                      bne.s     strupr_o
[000000dc] 103c 008e                 move.b    #$8E,d0
[000000e0] 6016                      bra.s     strupr_s
strupr_o:
[000000e2] b03c 0094                 cmp.b     #$94,d0
[000000e6] 6606                      bne.s     strupr_u
[000000e8] 103c 0099                 move.b    #$99,d0
[000000ec] 600a                      bra.s     strupr_s
strupr_u:
[000000ee] b03c 0081                 cmp.b     #$81,d0
[000000f2] 6604                      bne.s     strupr_s
[000000f4] 103c 009a                 move.b    #$9A,d0
strupr_s:
[000000f8] 12c0                      move.b    d0,(a1)+
[000000fa] 66c6                      bne.s     strupr_l
[000000fc] 4e75                      rts
intstrg:
[000000fe] 42a7                      clr.l     -(a7)
[00000100] 42a7                      clr.l     -(a7)
[00000102] 42a7                      clr.l     -(a7)
[00000104] 43ef 000a                 lea.l     10(a7),a1
intstrg_:
[00000108] 80fc 000a                 divu.w    #$000A,d0
[0000010c] 4840                      swap      d0
[0000010e] d03c 0030                 add.b     #$30,d0
[00000112] 1300                      move.b    d0,-(a1)
[00000114] 4240                      clr.w     d0
[00000116] 4840                      swap      d0
[00000118] 4a40                      tst.w     d0
[0000011a] 66ec                      bne.s     intstrg_
[0000011c] 2008                      move.l    a0,d0
intstrg_:
[0000011e] 10d9                      move.b    (a1)+,(a0)+
[00000120] 66fc                      bne.s     intstrg_
[00000122] 2040                      movea.l   d0,a0
[00000124] 4fef 000c                 lea.l     12(a7),a7
[00000128] 4e75                      rts
strgint:
[0000012a] 7000                      moveq.l   #0,d0
[0000012c] 7200                      moveq.l   #0,d1
[0000012e] 6010                      bra.s     strgint_
strgint_:
[00000130] 923c 0030                 sub.b     #$30,d1
[00000134] b27c 0009                 cmp.w     #$0009,d1
[00000138] 620a                      bhi.s     strgint_
[0000013a] c0fc 000a                 mulu.w    #$000A,d0
[0000013e] d081                      add.l     d1,d0
strgint_:
[00000140] 1218                      move.b    (a0)+,d1
[00000142] 66ec                      bne.s     strgint_
strgint_:
[00000144] 4e75                      rts
;
00000000 T clear_me
00000004 t memset
00000004 T fill_mem
00000014 t memset_a
00000028 t memset_l
0000002a t memset_s
00000032 t memset_b
00000038 t memset_e
0000003a T copy_mem
0000004a t copy_pre
0000004e t copy_cnt
00000056 t copy_a_l
00000058 t copy_a_s
0000005e t copy_b_l
00000060 t copy_b_s
00000066 t copy_so
0000006e t copy_sb_
00000070 t copy_sb_
00000076 T copy_me_
00000080 t copy_ma_
00000084 t copy_ma_
00000088 T strgcat
00000088 t strcat
0000008e T strgcpy
0000008e t strcpy
00000094 T strglen
00000094 t strlen
00000096 t strlen_l
000000a2 T strgcmp
000000a2 t strcmp
000000a6 t strcmp_l
000000b4 t strcmp_e
000000b8 t strcmp_l
000000bc t strcmp_g
000000c0 T strgupr
000000c0 t strupr
000000c2 t strupr_l
000000d6 t strupr_a
000000e2 t strupr_o
000000ee t strupr_u
000000f8 t strupr_s
000000fe T intstrg
00000108 t intstrg_
0000011e t intstrg_
0000012a T strgint
00000130 t strgint_
00000140 t strgint_
00000144 t strgint_
;
; CP/M Relocations:
