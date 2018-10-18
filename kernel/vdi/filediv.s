; ph_branch = 0x601a
; ph_tlen = 0x000000b6
; ph_dlen = 0x00000000
; ph_blen = 0x00000000
; ph_slen = 0x0000009a
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000000
; ph_absflag = 0x0000
; CP/M relocation bytes = 0x000000b6

load_fil:
[00000000] 48e7 003c                 movem.l   a2-a5,-(a7)
[00000004] 4fef ffd4                 lea.l     -44(a7),a7
[00000008] 2848                      movea.l   a0,a4
[0000000a] 2a49                      movea.l   a1,a5
[0000000c] 95ca                      suba.l    a2,a2
[0000000e] 4eb9 0000 0000            jsr       Fgetdta
[00000014] 2648                      movea.l   a0,a3
[00000016] 41d7                      lea.l     (a7),a0
[00000018] 4eb9 0000 0000            jsr       Fsetdta
[0000001e] 7027                      moveq.l   #39,d0
[00000020] 204c                      movea.l   a4,a0
[00000022] 4eb9 0000 0000            jsr       Fsfirst
[00000028] 4a40                      tst.w     d0
[0000002a] 6632                      bne.s     $0000005E
[0000002c] 202f 001a                 move.l    26(a7),d0
[00000030] 4eb9 0000 0000            jsr       Malloc_s
[00000036] 2448                      movea.l   a0,a2
[00000038] 200a                      move.l    a2,d0
[0000003a] 6722                      beq.s     $0000005E
[0000003c] 222f 001a                 move.l    26(a7),d1
[00000040] 7000                      moveq.l   #0,d0
[00000042] 224a                      movea.l   a2,a1
[00000044] 204c                      movea.l   a4,a0
[00000046] 4eb9 0000 0072            jsr       read_fil
[0000004c] 2a80                      move.l    d0,(a5)
[0000004e] b0af 001a                 cmp.l     26(a7),d0
[00000052] 670a                      beq.s     $0000005E
[00000054] 204a                      movea.l   a2,a0
[00000056] 4eb9 0000 0000            jsr       Mfree_sy
[0000005c] 95ca                      suba.l    a2,a2
[0000005e] 204b                      movea.l   a3,a0
[00000060] 4eb9 0000 0000            jsr       Fsetdta
[00000066] 204a                      movea.l   a2,a0
[00000068] 4fef 002c                 lea.l     44(a7),a7
[0000006c] 4cdf 3c00                 movem.l   (a7)+,a2-a5
[00000070] 4e75                      rts
read_fil:
[00000072] 48e7 1e10                 movem.l   d3-d6/a3,-(a7)
[00000076] 2649                      movea.l   a1,a3
[00000078] 2a00                      move.l    d0,d5
[0000007a] 2c01                      move.l    d1,d6
[0000007c] 7600                      moveq.l   #0,d3
[0000007e] 4240                      clr.w     d0
[00000080] 4eb9 0000 0000            jsr       Fopen
[00000086] 2800                      move.l    d0,d4
[00000088] 4a80                      tst.l     d0
[0000008a] 6f22                      ble.s     $000000AE
[0000008c] 4242                      clr.w     d2
[0000008e] 3204                      move.w    d4,d1
[00000090] 2005                      move.l    d5,d0
[00000092] 4eb9 0000 0000            jsr       Fseek
[00000098] 204b                      movea.l   a3,a0
[0000009a] 2206                      move.l    d6,d1
[0000009c] 3004                      move.w    d4,d0
[0000009e] 4eb9 0000 0000            jsr       Fread
[000000a4] 2600                      move.l    d0,d3
[000000a6] 3004                      move.w    d4,d0
[000000a8] 4eb9 0000 0000            jsr       Fclose
[000000ae] 2003                      move.l    d3,d0
[000000b0] 4cdf 0878                 movem.l   (a7)+,d3-d6/a3
[000000b4] 4e75                      rts
;
         U Mfree_sy
         U Fsetdta
         U Fgetdta
         U Fopen
         U Fclose
         U Fseek
         U Fread
         U Fsfirst
         U Malloc_s
00000000 T load_fil
00000072 T read_fil
;
; CP/M Relocations:
; $00000048 text
