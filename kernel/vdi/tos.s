; ph_branch = 0x601a
; ph_tlen = 0x00000196
; ph_dlen = 0x00000000
; ph_blen = 0x00000000
; ph_slen = 0x000009f4
; ph_res1 = 0x00000000
; ph_prgflags = 0x00000000
; ph_absflag = 0x0000
; CP/M relocation bytes = 0x00000196

Bconin:
[00000000] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000004] 3f00                      move.w    d0,-(a7)
[00000006] 3f3c 0002                 move.w    #ST_RAM_p,-(a7)
[0000000a] 4e4d                      trap      #13
[0000000c] 588f                      addq.l    #4,a7
[0000000e] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000012] 4e75                      rts
Bconout:
[00000014] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[00000018] 3f01                      move.w    d1,-(a7)
[0000001a] 3f00                      move.w    d0,-(a7)
[0000001c] 3f3c 0003                 move.w    #TT_RAM_p,-(a7)
[00000020] 4e4d                      trap      #13
[00000022] 5c8f                      addq.l    #6,a7
[00000024] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[00000028] 4e75                      rts
Cconws:
[0000002a] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[0000002e] 2f08                      move.l    a0,-(a7)
[00000030] 3f3c 0009                 move.w    #CCONWS,-(a7)
[00000034] 4e41                      trap      #1
[00000036] 5c8f                      addq.l    #6,a7
[00000038] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[0000003c] 4e75                      rts
Dgetdrv:
[0000003e] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000042] 3f3c 0019                 move.w    #DGETDRV,-(a7)
[00000046] 4e41                      trap      #1
[00000048] 548f                      addq.l    #2,a7
[0000004a] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[0000004e] 4e75                      rts
Dgetpath:
[00000050] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000054] 3f00                      move.w    d0,-(a7)
[00000056] 2f08                      move.l    a0,-(a7)
[00000058] 3f3c 0047                 move.w    #DGETPATH,-(a7)
[0000005c] 4e41                      trap      #1
[0000005e] 508f                      addq.l    #8,a7
[00000060] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000064] 4e75                      rts
Fgetdta:
[00000066] 48e7 6060                 movem.l   d1-d2/a1-a2,-(a7)
[0000006a] 3f3c 002f                 move.w    #FGETDTA,-(a7)
[0000006e] 4e41                      trap      #1
[00000070] 548f                      addq.l    #2,a7
[00000072] 2040                      movea.l   d0,a0
[00000074] 4cdf 0606                 movem.l   (a7)+,d1-d2/a1-a2
[00000078] 4e75                      rts
Fsetdta:
[0000007a] 48e7 e0e0                 movem.l   d0-d2/a0-a2,-(a7)
[0000007e] 2f08                      move.l    a0,-(a7)
[00000080] 3f3c 001a                 move.w    #FSETDTA,-(a7)
[00000084] 4e41                      trap      #1
[00000086] 5c8f                      addq.l    #6,a7
[00000088] 4cdf 0707                 movem.l   (a7)+,d0-d2/a0-a2
[0000008c] 4e75                      rts
Fsfirst:
[0000008e] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000092] 3f00                      move.w    d0,-(a7)
[00000094] 2f08                      move.l    a0,-(a7)
[00000096] 3f3c 004e                 move.w    #FSFIRST,-(a7)
[0000009a] 4e41                      trap      #1
[0000009c] 508f                      addq.l    #8,a7
[0000009e] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[000000a2] 4e75                      rts
Fsnext:
[000000a4] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[000000a8] 3f3c 004f                 move.w    #FSNEXT,-(a7)
[000000ac] 4e41                      trap      #1
[000000ae] 548f                      addq.l    #2,a7
[000000b0] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[000000b4] 4e75                      rts
Fcreate:
[000000b6] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[000000ba] 3f00                      move.w    d0,-(a7)
[000000bc] 2f08                      move.l    a0,-(a7)
[000000be] 3f3c 003c                 move.w    #FCREATE,-(a7)
[000000c2] 4e41                      trap      #1
[000000c4] 508f                      addq.l    #8,a7
[000000c6] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[000000ca] 4e75                      rts
Fopen:
[000000cc] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[000000d0] 3f00                      move.w    d0,-(a7)
[000000d2] 2f08                      move.l    a0,-(a7)
[000000d4] 3f3c 003d                 move.w    #FOPEN,-(a7)
[000000d8] 4e41                      trap      #1
[000000da] 508f                      addq.l    #8,a7
[000000dc] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[000000e0] 4e75                      rts
Fseek:
[000000e2] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[000000e6] 3f02                      move.w    d2,-(a7)
[000000e8] 3f01                      move.w    d1,-(a7)
[000000ea] 2f00                      move.l    d0,-(a7)
[000000ec] 3f3c 0042                 move.w    #FSEEK,-(a7)
[000000f0] 4e41                      trap      #1
[000000f2] 4fef 000a                 lea.l     10(a7),a7
[000000f6] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[000000fa] 4e75                      rts
Fread:
[000000fc] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000100] 2f08                      move.l    a0,-(a7)
[00000102] 2f01                      move.l    d1,-(a7)
[00000104] 3f00                      move.w    d0,-(a7)
[00000106] 3f3c 003f                 move.w    #FREAD,-(a7)
[0000010a] 4e41                      trap      #1
[0000010c] 4fef 000c                 lea.l     12(a7),a7
[00000110] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000114] 4e75                      rts
Fclose:
[00000116] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[0000011a] 3f00                      move.w    d0,-(a7)
[0000011c] 3f3c 003e                 move.w    #FCLOSE,-(a7)
[00000120] 4e41                      trap      #1
[00000122] 588f                      addq.l    #4,a7
[00000124] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000128] 4e75                      rts
Fwrite:
[0000012a] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[0000012e] 2f08                      move.l    a0,-(a7)
[00000130] 2f01                      move.l    d1,-(a7)
[00000132] 3f00                      move.w    d0,-(a7)
[00000134] 3f3c 0040                 move.w    #PRIVATER,-(a7)
[00000138] 4e41                      trap      #1
[0000013a] 4fef 000c                 lea.l     12(a7),a7
[0000013e] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000142] 4e75                      rts
Malloc_s:
[00000144] 48e7 7060                 movem.l   d1-d3/a1-a2,-(a7)
[00000148] 323c 4033                 move.w    #$4033,d1
[0000014c] 7444                      moveq.l   #68,d2
malloc:
[0000014e] 3f01                      move.w    d1,-(a7)
[00000150] 2f00                      move.l    d0,-(a7)
[00000152] 3f02                      move.w    d2,-(a7)
[00000154] 4e41                      trap      #1
[00000156] 508f                      addq.l    #8,a7
[00000158] 2200                      move.l    d0,d1
[0000015a] 5381                      subq.l    #1,d1
[0000015c] 6602                      bne.s     malloc_e
[0000015e] 7000                      moveq.l   #0,d0
malloc_e:
[00000160] 2040                      movea.l   d0,a0
[00000162] 4cdf 060e                 movem.l   (a7)+,d1-d3/a1-a2
[00000166] 4e75                      rts
Mfree_sy:
[00000168] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[0000016c] 2f08                      move.l    a0,-(a7)
[0000016e] 3f3c 0049                 move.w    #MFREE,-(a7)
[00000172] 4e41                      trap      #1
[00000174] 5c8f                      addq.l    #6,a7
[00000176] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[0000017a] 4e75                      rts
Mshrink_:
[0000017c] 48e7 60e0                 movem.l   d1-d2/a0-a2,-(a7)
[00000180] 2f00                      move.l    d0,-(a7)
[00000182] 2f08                      move.l    a0,-(a7)
[00000184] 4267                      clr.w     -(a7)
[00000186] 3f3c 004a                 move.w    #MSHRINK,-(a7)
[0000018a] 4e41                      trap      #1
[0000018c] 4fef 000c                 lea.l     12(a7),a7
[00000190] 4cdf 0706                 movem.l   (a7)+,d1-d2/a0-a2
[00000194] 4e75                      rts
;
00000000 a M68000
00000000 a COL40
00000000 a TV
00000000 a MALLOC_d
00000000 a ST_RAM_o
00000000 a p_lowtap
00000000 a ST_VIDEO
00000000 a BPS1
00000000 a E_OK
00000000 a ST_LOW
00000001 a GEMDOS
00000001 a MALLOC_t
00000001 a STE_VIDE
00000001 a BPS2
00000001 a ST_MID
00000001 a BCONSTAT
00000001 a TT_RAM_o
00000002 a os_versi
00000002 a BCONIN
00000002 a ST_HIGH
00000002 a CON
00000002 a MALLOC_m
00000002 a ST_RAM_p
00000002 a BPS4
00000002 a TT_VIDEO
00000002 a ph_tlen
00000002 a PHYSBASE
00000003 a MALLOC_a
00000003 a BCONOUT
00000003 a FALCONMD
00000003 a CLM_BIT
00000003 a BPS8
00000003 a LOGBASE
00000003 a TT_RAM_p
00000003 a FALCON_V
00000004 a BPS16
00000004 a GETREZ
00000004 a p_hitpa
00000004 a TT_MID
00000004 a VGA_BIT
00000005 a SETEXC
00000005 a SETSCREE
00000005 a PAL_BIT
00000005 a CURS_GET
00000006 a OVS_BIT
00000006 a TT_HIGH
00000006 a SETPALET
00000006 a ph_dlen
00000006 a TICKCAL
00000007 a STC_BIT
00000007 a TT_LOW
00000007 a SETCOLOR
00000007 a NUMCOLS
00000008 a COL80
00000008 a VTF_BIT
00000008 a os_beg
00000008 a p_tbase
00000009 a CCONWS
0000000a a M68010
0000000a a ph_blen
0000000b a KBSHIFT
0000000c a p_tlen
0000000d a BIOS
0000000e a IOREC
0000000e a XBIOS
0000000e a DSETDRV
0000000e a ph_slen
00000010 a VGA
00000010 a p_dbase
00000010 a PRIVATE_
00000014 a M68020
00000014 a p_dlen
00000014 a SCRDMP
00000014 a os_magic
00000015 a CURSCONF
00000015 a SCRNMALL
00000018 a p_bbase
00000019 a DGETDRV
0000001a a FSETDTA
0000001c a p_blen
0000001c a VBLVEC
0000001c a PH_LEN
0000001c a os_conf
0000001e a M68030
00000020 a PAL
00000020 a GLOBAL_M
00000020 a DOSOUND
00000020 a p_dta
00000021 a GEMDOSVE
00000022 a KBDVBASE
00000024 a p_parent
00000024 a kbshift
00000026 a SUPEXEC
00000028 a M68040
00000028 a run
0000002a a TGETDATE
0000002c a p_env
0000002d a BIOSVEC
0000002e a XBIOSVEC
0000002f a FGETDTA
00000030 a SUPER_ME
00000031 a PTERMRES
0000003b a DSETPATH
0000003c a FCREATE
0000003d a FOPEN
0000003e a FCLOSE
0000003f a FREAD
00000040 a PRIVATER
00000040 a FWRITE
00000040 a BLITMODE
00000040 a OVERSCAN
00000042 a FSEEK
00000044 a MXALLOC
00000047 a DGETPATH
00000048 a MALLOC
00000049 a MFREE
0000004a a MSHRINK
0000004b a PEXEC
0000004e a FSFIRST
0000004f a FSNEXT
00000050 a ESETSHIF
00000052 a ESETBANK
00000053 a ESETCOLO
00000054 a ESETPALE
00000056 a ESETGRAY
00000057 a ESETSMEA
00000058 a VSETMODE
00000059 a MON_TYPE
0000005a a VSETSYNC
0000005b a VGETSIZE
0000005d a VSETRGB
0000005e a VGETRGB
00000080 a STMODES
00000084 a GEMDOSVE
00000096 a VSETMASK
000000b4 a BIOSVEC_
000000b8 a XBIOSVEC
00000100 a VERTFLAG
00000400 a etv_time
00000426 a resvalid
0000042a a resvecto
00000442 a timer_ms
0000044c a sshiftmd
0000044e a v_bas_ad
00000452 a vblsem
00000454 a nvbls
00000456 a vbl_queu
00000466 a frclock
00000484 a conterm
000004a8 a con_stat
000004ba a hz_200
000004ee a dumpflag
000004f2 a sysbase
00000502 a dump_vec
00000586 a o_con
00000592 a o_rawcon
0000059e a longfram
000005a0 a p_cookie
000005ac a bell_hoo
00004000 a DONT_FRE
0000601a a PH_MAGIC
ffffffe0 a EINVFN
00000000 T Bconin
00000014 T Bconout
0000002a T Cconws
0000003e T Dgetdrv
00000050 T Dgetpath
00000066 T Fgetdta
0000007a T Fsetdta
0000008e T Fsfirst
000000a4 T Fsnext
000000b6 T Fcreate
000000cc T Fopen
000000e2 T Fseek
000000fc T Fread
00000116 T Fclose
0000012a T Fwrite
00000144 T Malloc_s
0000014e t malloc
00000160 t malloc_e
00000168 T Mfree_sy
0000017c T Mshrink_
;
; CP/M Relocations:
