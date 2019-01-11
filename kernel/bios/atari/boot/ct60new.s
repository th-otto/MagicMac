
/* OUTSIDE   EQU  0              memory segments on 32k pages */
RESIDENT  EQU  1              /* reset resident */

/*
 * set this to 1 to check this loader only;
 * it will try to apply the patches regardless of machine type,
 * and NOT boot the os
 */
PATCHONLY EQU 0

     INCLUDE "osbind.inc"

fstrm_beg EQU  ____md
os_chksum EQU  trp14ret

rw_parameter EQU 0xC60B
CT60_MODE_READ EQU 0
CT60_BOOT_ORDER EQU 3

sizeof_PH equ 28


        .TEXT
     	.SUPER

        movea.l 4(a7),a5                        /* BasePagePointer from Stack */
        lea     stack(pc),sp
        move.l  p_tlen(a5),d0                   /* text segment size */
        add.l   p_dlen(a5),d0                   /* data segment size */
        add.l   p_blen(a5),d0                   /* bss segment size */
        add.l   #256,d0                         /* for basepage */
        and.b   #0xFE,d0
        move.l  d0,-(a7)
        pea     (a5)
        clr.w   -(a7)
        move.w  #0x4A,-(a7)                     /* Mshrink */
        trap    #1
        adda.w  #12,a7

        pea    0
        move.w #0x20,-(sp)                      /* Super */
        trap   #1
		addq.w #6,sp

		move.l   _sysbase,a0
		move.l   os_base(a0),a0                 /* RAM- Kopie enthaelt kein os_palmode */
		move.w   os_palmode(a0),d0
		lsr.w    #1,d0
		move.w   d0,d4                          /* nationality */
		
        move.l  #0x4D616758,d0                  /* 'MagX' */
        bsr     GET_COOKIE
        bne     done                            /* MagX already active, we are done */
        move.l  #0x5F435055,d0                  /* '_CPU' */
        bsr     GET_COOKIE
        move.l  d0,CPU
        move.l  d0,d2
        move.l  #0x5F4D4348,d0                  /* '_MCH' */
        bsr     GET_COOKIE
        move.l  d0,MACHINE
        cmpi.l  #0x30000,d0                     /* Falcon */
        bne.s   not_ct60
        cmpi.l  #60,d2                          /* 060 */
        bne.s   not_ct60
        st      CT60
not_ct60:
        move.l  #0x5F465055,d0                  /* '_FPU' */
        bsr     GET_COOKIE
        move.l  d0,FPU

/*
 * original TOS will crash if we call a XBIOS function with a negativ number
 */
        tst.w   CT60
        beq.s   no_ctpci
        clr.l   -(SP)
        move.l  #CT60_BOOT_ORDER,-(SP)
        move.w  #CT60_MODE_READ,-(SP)
        move.w  #rw_parameter,-(SP)
        trap    #14
        lea     12(sp),sp 
        tst.l   d0
        bmi.s   no_ctpci
        cmp.w   #rw_parameter,d0
        beq.s   no_ctpci
/*
 * 0: New boot SCSI0-7 -> IDE0-1
 * 1: New boot IDE0-1 -> SCSI0-7
 * 2: New boot SCSI7-0 -> IDE1-0
 * 3: New boot IDE1-0 -> SCSI7-0
 * 4: Old boot SCSI0-7 -> IDE0-1
 * 5: Old boot IDE0-1 -> SCSI0-7
 * 6: Old boot SCSI7-0 -> IDE1-0
 * 7: Old boot IDE1-0 -> SCSI7-0
 */
		btst    #1,d0
		sne.b   d0
		ext.w   d0
		move.w  d0,IDE_SLAVE
no_ctpci:
		move.l  #0x5f504349,d0                  /* '_PCI' */
		bsr     GET_COOKIE
		sne.b   d0
		ext.w   d0
		move.w  d0,CTPCI

        lea     Info_Text(pc),a0
        bsr     cconws_country
        move.w  #-1,-(a7)
        move.w  #11,-(a7)                       /* Kbshift */
        trap    #13
        addq.l  #4,a7
        and.w   #3,d0                           /* Shift */
        cmp.w   #3,d0
        beq     dont_install

        move.l  #0x5F465251,d0                  /* _FRQ, internal clock */
        bsr     GET_COOKIE
        beq     no_ext_clock
        cmp.l   #0x20,d0
        bls     no_ext_clock
        link    a5,#-4
        clr.w   -2(a5)
        lea     -4(a5),a0
        moveq   #2,d1
        bsr     CONV_DECI
        lea     Text_Internal_clock(pc),a0
        bsr     cconws
        lea     -4(a5),a0
        bsr     cconws
        lea     Text_Mhz(pc),a0
        bsr     cconws
        unlk    a5
        move.l  #0x5F465245,d0                  /* _FRE, external clock */
        bsr     GET_COOKIE
        beq.s   no_ext_clock
        move.l  d0,-(a7)
        link    a5,#-4
        clr.w   -2(a5)
        lea     -4(a5),a0
        moveq   #2,d1
        bsr     CONV_DECI
        lea     Text_external_clock(pc),a0
        bsr     cconws
        lea     -4(a5),a0
        bsr     cconws
        lea     Text_Mhz(pc),a0
        bsr     cconws
        unlk    a5
        move.l  (a7)+,d0
        cmp.l   #0x20,d0
        bne.s   no_ext_clock
        st      EXT_CLOCK
no_ext_clock:
        move.w  #0x0,-(a7)
        pea     magx_name
        move.w  #0x003D,-(a7)                   /* Fopen */
        trap    #1
        addq.w  #8,a7
        move.w  d0,d7
        bmi     not_found

        move.w  #2,-(a7)
        move.w  d7,-(a7)
        move.l  #0,-(a7)
        move.w  #0x0042,-(a7)                   /* Fseek */
        trap    #1
        adda.w  #10,a7
        move.l  d0,d6
        ble     err_load

        move.w  #0,-(a7)
        move.w  d7,-(a7)
        move.l  #0,-(a7)
        move.w  #0x0042,-(a7)                   /* Fseek */
        trap    #1
        adda.w  #10,a7
        tst.l   d0
        bmi     err_load

        move.l  d6,-(a7)
        move.w  #0x0048,-(a7)                   /* Malloc */
        trap    #1
        addq.w  #6,a7
        tst.l   d0
        ble     err_load

        movea.l d0,a6
        pea     (a6)
        move.l  d6,-(a7)
        move.w  d7,-(a7)
        move.w  #0x003F,-(a7)                   /* Fread */
        trap    #1
        adda.w  #12,a7

        move.l  d0,-(a7)
        move.w  d7,-(a7)
        move.w  #0x003E,-(a7)                   /* Fclose */
        trap    #1
        addq.w  #4,a7
        cmp.l   (a7)+,d6
        bne     err_load

        cmpi.w  #0x601A,(a6)
        bne     err_load
        movea.l sizeof_PH+os_magic(a6),a0
        lea     sizeof_PH(a6,a0.l),a0
        cmpi.l  #0x87654321,(a0)+
        bne     err_load
        movea.l (a0)+,a5
        addq.l  #4,a0
        cmpi.l  #0x4D414758,(a0)                /* 'MAGX' */
        bne     err_load

        move.l  #0x01000000,fstrm_beg
        cmpi.l  #0x1357BD13,ramvalid
        bne.s   no_ttram
        cmpi.l  #0x01080000,ramtop
        bcs.s   no_ttram
        movea.l #0x01000000,a5
no_ttram:
        cmpi.l  #0x00020000,MACHINE             /* Atari TT or Hades? */
        bcs.s   ver_st
        move.w  #0x0300,d0
        cmpi.l  #0x00030000,MACHINE             /* Falcon? */
        bcs.s   ver_tt
        move.w  #0x0400,d0
ver_tt:
        move.w  d0,os_version+sizeof_PH(a6)
ver_st:
        move.w  #0x0019,-(a7)                   /* Dgetdrv */
        trap    #1
        addq.w  #2,a7
        movea.l os_magic+sizeof_PH(a6),a0
        lea     sizeof_PH(a6,a0.l),a0
        lea     0x007A(a0),a0
        cmpi.l  #0x5F5F5F5F,(a0)
        bne.s   do_reloc
        add.b   #0x41,d0
        move.b  d0,(a0)+
        move.b  #0x3A,(a0)+
        lea     magx_name,a1
namecpy_loop:
        move.b  (a1)+,(a0)+
        bne.s   namecpy_loop
do_reloc:
        move.l  2(a6),d0
        add.l   6(a6),d0
        move.l  d0,d5
        add.l   14(a6),d0
        lea     sizeof_PH(a6,d0.l),a3          /* a3: pointer to relocations */
        lea     0(a6,d6.l),a2                  /* a2: end of file */
        cmpa.l  a2,a3
        bcc.s   end_reloc
        lea     sizeof_PH(a6),a0               /* reloge MagiC */
        move.l  (a3)+,d0
        beq.s   end_reloc
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
        cmp.b   #1,d0
        bne.s   reloc_loop
        lea     254(a0),a0
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
  IFEQ PATCHONLY
        beq     patch_ok
  ENDC
        lea     sizeof_PH(a6),a1               /* patch */
        move.l  d5,d1
        lsr.l   #1,d1
        moveq   #0,d2

/*
 * determine the number of patches to expect
 */
        moveq   #19,d3                         /* max patches */
        tst.w   CTPCI
        beq.s   no_ctpci_patch
        addq    #1,d3
no_ctpci_patch:
        tst.w   EXT_CLOCK
        beq.s   no_ext_patch
        addq.w  #3,d3                          /* add 3 */
no_ext_patch:
        tst.w   IDE_SLAVE
        beq.s   no_ide_patch
        addq    #3,d3
no_ide_patch:


patch_loop:

/*
 * Patch 020 specific cache initialization,
 * at early part of BIOS.
 * On newer kernels, that patch should not be needed, since the
 * kernel skips that code for 040+, but the code
 * sequence is still found.
 * location:
 *    magibios.s, bot_cpu_nopmmu
 */
        move.l  (a1),d0
        cmp.l   #0x203C0000,d0                  /* MOVE.L #0x808,D0 */
        bne.s   skip_p2
        cmpi.l  #0x08084E7B,4(a1)               /* MOVEC.L D0,CACR */
        beq.s   skip_p1
        cmpi.l  #0x31114E7B,4(a1)               /* MOVE.L #0x3111,D0 */
        bne.s   skip_p2
        move.l  #0x203CA080,(a1)                /* MOVE.L #0xA0808000,D0 */
        move.l  #0x80004E7B,4(a1)
        lea     Text_Patch_cache_1(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p1:

/*
 * Patch 030 specific cache flush.
 * On newer kernels, that patch should not be needed, since the
 * kernel skips that code for 030+.
 * This sequence should be found 3 times.
 * locations:
 *    magibios.s, near syshdr_l1
 *    keyb.s, warmb_02
 *    keyb.s, coldb_020
 */
        move.l  #0x70004E7B,(a1)                /* moveq.l #0,d0; movec d0,cacr */
        move.l  #0x00024E71,4(a1)               /* nop */
        move.w  #0xF4F8,8(a1)                   /* CPUSHA BC */
        lea     Text_Patch_cache_2(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p2:

/*
 * Patch 030 specific cache flush.
 * On newer kernels, that patch should not be needed, since the
 * kernel skips that code for 030+.
 * location:
 *    fdc.s, near dma_delay
 */
        cmp.l   #0x4E7A0002,d0                  /* MOVE.L CACR,D0 */
        bne.s   skip_p3
        cmpi.l  #0x08C00003,4(a1)               /* BSET #3,D0 */
        bne.s   skip_p3
        cmpi.l  #0x4E7B0002,8(a1)               /* MOVEC.L D0,CACR */
        bne.s   skip_p3
        cmpi.l  #0x70021238,12(a1)
        bne.s   skip_p3
        move.l  #0x4E714E71,d0
        move.l  d0,(a1)
        move.l  d0,4(a1)
        move.l  d0,8(a1)
        lea     Text_Patch_cache_3(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p3:

/*
 * Patch movep instruction, which does not exist on 060.
 * location:
 *    magibios.s, near init_mfp (2 times)
 */
        cmp.l   #0x03C80000,d0                  /* MOVE.L D1,(A0) */
        bne.s   skip_p4
        cmpi.l  #0x03C80008,4(a1)               /* MOVEP.L D1,8(A0) */
        bne.s   skip_p4
        cmpi.l  #0x03C80010,8(a1)               /* MOVEP.L D1,16(A0) */
        bne.s   skip_p4
        move.l  #0x72E84230,(a1)                /* moveq.l #-24,d1;  clr.b 24(a0,d1.w) */
        move.l  #0x10185481,4(a1)               /* addq.l #2,d1 */
        move.l  #0x66F84E71,8(a1)               /* bne.s *-6; nop */
        lea     Text_Patch_movep_1(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p4:

/*
 * Patch movep instruction, which does not exist on 060.
 * locations:
 *    magibios.s, near init_mfp, somewhat later than above patch
 */
        cmp.l   #0x203C0088,d0                  /* MOVE.L #0x00880105,D0 */
        bne.s   skip_p5
        cmpi.l  #0x010501C8,4(a1)               /* MOVEP.L D0,38(A0) */
        bne.s   skip_p5
        cmpi.w  #0x0026,8(a1)
        bne.s   skip_p5
        move.l  #0x42280026,0(a1)               /* clr.b 0x26(a0) */
        move.l  #0x117C0088,4(a1)               /* move.b #0x88,0x28(a0) */
        move.l  #0x0028117C,8(a1)               /* move.b #0x01,0x2a(a0) */
        move.l  #0x0001002A,12(a1)              /* move.b #0x05,0x2c(a0) */
        move.l  #0x117C0005,16(a1)
        move.l  #0x002C6038,20(a1)              /* bra.s *+0x3a (imf_ste) */
        lea     Text_Patch_movep_2(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p5:

/*
 * Patch CPU type
 * No longer needed, and that sequence is not found anymore
 */
        cmp.l   #0x204F7000,d0                  /* move.l sp,a0; moveq #0,d0 */
        bne.s   skip_p6
        cmpi.w  #0x21FC,4(a1)                   /* move.l #set_cpu_typ,8 */
        bne.s   skip_p6
        move.l  #0x703C4E75,(a1)                /* moveq.l #60,d0; rts */
        lea     Text_Patch_CPU_type(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p6:

/*
 * During initialization of exception vectors,
 * leave the ones that were already installed
 * by the CTBIOS intact.
 * location:
 *    magibios.s, near bot_loop
 */
        cmp.l   #0x41F80008,d0                  /* lea 8.w,a0 */
        bne.s   skip_p7
        cmpi.l  #0x703D43FA,4(a1)               /* moveq #0x3d,d0; lea exc02(pc),a1 */
        bne.s   skip_p7
        move.w  #0x7008,4(a1)                   /* moveq #8,d0 */
        lea     Text_Patch_Vectors_1(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p7:

/*
 * During initialization of exception vectors,
 * leave the ones that were already installed
 * by the CTBIOS intact.
 * location:
 *    magibios.s, near bot_loop
 */
        cmp.l   #0x703D20C9,d0                  /* moveq #0x3d,d0; move.l a1,(a0)+ */
        bne.s   skip_p8
        cmpi.l  #0xD3C151C8,4(a1)               /* adda.l d1,a1; dbf d0,bot_lopp */
        bne.s   skip_p8
        move.w  #0x7008,(a1)                    /* moveq #8,d0 */
        lea     Text_Patch_Vectors_2(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p8:

/*
 * During initialization of exception vectors,
 * leave the Line-F vector intact.
 * location:
 *    magibios.s, near syshdr_l1
 */
        cmp.l   #0x21C80010,d0                  /* move.l a0,(0x10).w */
        bne.s   skip_p9
        cmpi.l  #0x21C8002C,4(a1)               /* move.l a0,(0x2c).w */
        bne.s   skip_p9
        move.l  #0x4E714E71,4(a1)               /* nop;nop */
        lea     Text_Patch_Vectors_3(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p9:

/*
 * Do not invoke reset instruction on falcon.
 * On newer kernels, that patch should not be needed, since the
 * kernel skips that code for falcon hardware.
 * location:
 *    keyb.s, near warmb_00
 */
patch_reset1:
        cmp.l   #0x4E700CB8,d0                  /* reset */
        bne.s   skip_p10
        cmpi.l  #0x31415926,4(a1)               /* cmp.l #0x31415926,0x00000426.w */
        bne     patch_done
        move.w  #0x4E71,(a1)                    /* nop */
        lea     Text_Patch_Reset_1(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p10:

/*
 * Do not invoke reset instruction on falcon.
 * On newer kernels, that patch should not be needed, since the
 * kernel skips that code for falcon hardware.
 * location:
 *    keyb.s, near coldb_busf
 */
        cmp.l   #0x4E7021F8,d0                  /* reset */
        bne.s   skip_p11
        cmpi.l  #0x00040008,4(a1)               /* move.l (0x00000004).w,(0x00000008).w */
        bne.s   patch_reset1
        move.w  #0x4E71,(a1)
        lea     Text_Patch_Reset_2(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p11:

/*
 * Skip DSP initialization.
 * location:
 *    magibios.s, near bot_cpu_weiter
 */
        cmp.l   #0x4E7B0002,d0                  /* movec d0,cacr */
        bne.s   skip_p12
        cmpi.l  #0x0C380004,4(a1)               /* cmpi.b #0x04,(machine_type).w */
        bne.s   skip_p12
        cmpi.w  #0x665E,10(a1)                  /* bne try_ext_scsidrvr */
        bne.s   skip_p12
        cmpi.w  #0x6100,12(a1)                  /* bsr dsp_stdinit */
        bne.s   skip_p12
        move.l  #0x4E714E71,12(a1)              /* nop;nop */
        lea     Text_Patch_DSP(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p12:

/*
 * Patch Floppy
 * location:
 *    fds.s, set_DMA_write
 *
 * WARNING: really badly written patch; 3 of the values below
 * are branch offsets, which can change any time the source is changed
 */
        cmp.l   #0x610008A6,d0                  /* bsr d7_todma */
        bne.s   skip_p13
        cmpi.l  #0x61000AF2,4(a1)               /* bsr teste_fa01 */
        bne.s   skip_p13
        cmpi.l  #0x3CBC0180,8(a1)               /* move.w #0x180,(a6) */
        bne.s   skip_p13
        move.l  #0x610008BA,4(a1)               /* bsr dma_delay */
        lea     Text_Patch_Floppy(pc),a0
        bsr     print_addr
        /* not counted for number of patches */
        bra     patch_done
skip_p13:

/*
 * Patch FPU type detection.
 * That patch should no longer be needed, since the
 * kernel should now correctly identify 060.
 * location:
 *    fpudetec.inc, is040
 */
        cmp.l   #0x54415441,d0                  /* addq.w #2,d1; addq.w #2,d1 */
        bne.s   skip_p14
        cmpi.l  #0x54415441,4(a1)               /* addq.w #2,d1; addq.w #2,d1 */
        bne.s   skip_p14
        cmpi.w  #0x50F8,8(a1)                   /* st is_fpu */
        bne.s   skip_p14
        move.w  #0x7210,6(a1)                   /* moveq.l #16,d1 */
        lea     Text_Patch_FPU_Cookie(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        tst.l   FPU
        bne     patch_done
        move.w  #0x7200,6(a1)                   /* moveq.l #0,d1 */
        bra     patch_done
skip_p14:

/*
 * Patch FPU context save.
 * That patch should no longer be needed, since the
 * kernel should now correctly handle 060 fpu.
 * location:
 *    aesevt.s, ad_chgcntxt
 */
        cmp.l   #0xF3274A17,d0                  /* fsave -(a7); tst.b (a7) */
        bne.s   skip_p15
        cmpi.l  #0x670CF227,4(a1)               /* beq.s ad_no_fpu */
        bne.s   skip_p15
        cmpi.l  #0xE0FFF227,8(a1)               /* fmovem.x fp0-fp7,-(a7) */
        bne.s   skip_p15
        move.l  #0x4E714E71,2(a1)               /* nop;nop */
        lea     Text_Patch_FPU_save(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p15:

/*
 * Patch FPU context restore.
 * That patch should no longer be needed, since the
 * kernel should now correctly handle 060 fpu.
 * location:
 *    not found?
 */
        tst.l   FPU
        bne.s   skip_p16
        cmp.l   #0xF3790100,d0                  /* FPU FRESTORE */
        bne.s   skip_p16
        move.l  #0x4E714E71,(a1)
        move.w  #0x4E71,4(a1)
        lea     Text_Patch_FPU_restore(pc),a0
        /* not counted; that sequence is not found in 6.20 kernel */
        bsr     print_addr
        bra     patch_done
skip_p16:

/*
 * Patch PMMU 030 tree.
 * That patch should no longer be needed, since the
 * kernel should skip that code for 060.
 * location:
 *    magibios.s, bot_loop5
 */
        cmp.l   #0x703F20D9,d0                  /* moveq.l #0x3f,d0; move.l (a1)+,(a0)+ */
        bne.s   skip_p17
        cmpi.l  #0x51C8FFFC,4(a1)               /* dbf d0,bot_loop5 */
        bne.s   skip_p17
        move.w  #0x4E71,2(a1)                   /* nop */
        lea     Text_Patch_PMMU(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p17:

/*
 * Patch external clock 32MHz RGB monitor 1.
 * Only needed when _FRE cookie was set.
 * location:
 *    ivid.s, boot_iv_l2
 */
        tst.w   EXT_CLOCK
        beq.s   skip_p19
        cmp.l   #0x720211C1,d0                  /* moveq.l #2,d1 */
        bne.s   skip_p18
        cmpi.w  #0x820A,4(a1)                   /* move.b d1,(0xFFFF820A).w */
        bne.s   skip_p18
        move.l  #0x4E714E71,(a1)
        move.w  #0x4E71,4(a1)
        lea     Text_Patch_Monitor_1(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p18:

/*
 * Patch external clock 32MHz RGB monitor 2.
 * Only needed when _FRE cookie was set.
 * locations:
 *    video.s, falcon_set_vco2
 *    video.s, falc_set_vxx
 */
        cmp.l   #0x31D8820A,d0                  /* move.w (a0)+,(0xFFFF820A).w */
        bne.s   skip_p19
        cmpi.w  #0x4E75,4(a1)                   /* rts */
        bne.s   skip_p19
        move.l  #0x4E714E71,(a1)                /* nop;nop */
        lea     Text_Patch_Monitor_2(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p19:

/*
 * Patch PSG printer.
 * location:
 *    magibios.s, outprn_putc
 */
        cmp.l   #0x40C1007C,d0                  /* move.w sr,d1 */
        bne     skip_p20
        cmpi.l  #0x070043F8,4(a1)               /* ori.w #0x0700,sr */
        bne     skip_p20
        cmpi.l  #0x880045E9,8(a1)               /* lea.l (0xFFFF8800).w,a1 */
        bne     skip_p20
        cmpi.l  #0x000212BC,12(a1)              /* lea.l 2(a1),a2 */
        bne     skip_p20
        cmpi.l  #0x00071011,16(a1)              /* move.b #0x07,(a1); move.b (a1),d0 */
        bne     skip_p20
        cmpi.l  #0x000000C0,20(a1)              /* ori #0xc0,d0 */
        bne     skip_p20
        cmpi.l  #0x148012BC,24(a1)              /* move.b d0,(a2) */
        bne     skip_p20
        cmpi.l  #0x000F1498,28(a1)              /* move.b #15,(a1); move.b (a0)+,(a2) */
        bne     skip_p20
        cmpi.l  #0x12BC000E,32(a1)              /* move.b #14,(a1) */
        bne     skip_p20
        cmpi.l  #0x10110200,36(a1)              /* move.b (a1),d0 */
        bne     skip_p20
        cmpi.l  #0x00DF1480,40(a1)              /* andi.b #0xDF,d0 */
        bne     skip_p20
        cmpi.l  #0x14800000,44(a1)              /* move.b d0,(a2); move.b d0,(a2) */
        bne     skip_p20
        cmpi.l  #0x00201480,48(a1)              /* ori.b #0x20,d0; move.b d0,(a2) */
        bne     skip_p20
        cmpi.l  #0x46C170FF,52(a1)              /* move.w d1,sr; moveq.l #-1,d0 */
        bne     skip_p20
        cmpi.w  #0x4E75,0x0038(a1)              /* rts */
        bne     skip_p20
        /* replace by: */
        move.l  #0x40E7007C,(a1)                /* move.w    sr,-(a7) */
        move.l  #0x070043F8,4(a1)               /* ori.w     #0x0700,sr */
        move.l  #0x880045E9,8(a1)               /* lea.l     (0xFFFF8800).w,a1 */
        move.l  #0x0002720F,12(a1)              /* lea.l     2(a1),a2; moveq.l #15,d1 */
        move.l  #0x1018611C,16(a1)              /* move.b    (a0)+,d0; bsr.s write_psg */
        move.l  #0x720E6112,20(a1)              /* moveq.l   #14,d1; bsr.s read_psg */
        move.l  #0x08800005,24(a1)              /* bclr      #5,d0 */
        move.l  #0x611208C0,28(a1)              /* bsr.s     write_psg */
        move.l  #0x0005610C,32(a1)              /* bset      #5,d0; bsr.s write_psg */
        move.l  #0x46DF70FF,36(a1)              /* move.w    (a7)+,sr; moveq.l #-1,d0 */
        move.l  #0x4E751281,40(a1)              /* rts */
        move.l  #0x10114E75,44(a1)              /* read_psg: move.b d1,(a1); move.b (a1),d0; rts */
        move.l  #0x12811480,48(a1)              /* write_psg: move.b d1,(a1); move.b d0,(a2); rts */
        move.l  #0x4E754E71,52(a1)
        move.w  #0x4E71,0x0038(a1)              /* nop */
        lea     Text_Patch_PSG(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
skip_p20:

/*
 * Patch for CTPCI support
 * location:
 *    magibios.s, bot_l4
 */
		tst.w   CTPCI
		beq.s   skip_p21
		cmp.l   #0x46FC2300,d0                  /* move #0x2300,SR */
		bne.s   skip_p21
		cmp.w   #0x7001,4(a1)                   /* moveq #1,d0 */
		bne.s   skip_p21
		move.w  #0x4E40,4(a1)                   /* trap #0 TOS */
        lea     Text_Patch_CTPCI(pc),a0
		addq    #1,d2
        bsr     print_count_and_addr
		bra     patch_done
skip_p21:

/*
 * Patch to boot from IDE slave first
 * location:
 *    drive.s, dmaboot (2 times)
 */
		tst.w   IDE_SLAVE
		beq.s   skip_p22
		cmp.l   #0x70102078,d0                  /* moveq #0x10,d0 */
		bne.s   skip_p22
		cmp.w   #0x04C6,4(a1)                   /* movea.l (_dskbufp).w,a0 */
		bne.s   skip_p22
		move.w  #0x7011,(a1)                    /* moveq #0x11,d0 */
        lea     Text_Patch_IDE_slave(pc),a0
		addq    #1,d2
        bsr     print_count_and_addr
		moveq   #49,d0
		move.l  a1,a0
p22_loop:
        addq.l  #2,a0
		cmp.l   #0x78106100,(a0)                /* moveq #0x10,D4 */
		dbeq    d0,p22_loop
		bne     patch_done
		move.w  #0x7811,(a0)                    /* moveq #0x11,D4 */
        lea     Text_Patch_IDE_slave(pc),a0
		addq    #1,d2
        bsr     print_count_and_addr
		bra     patch_done  
skip_p22:

        nop
/*
 * Now check for code in newer kernels, were above patches
 * have already been applied, to get the count of needed
 * patches right.
 */
        cmp.l   #0x70e81181,d0                  /* moveq #-24,d0 */
        bne.s   done_p4
        cmp.l   #0x00185480,4(a1)               /* move.b d1,24(a0,d0.w); addq.l #2,d0 */
        bne.s   done_p4
        cmp.w   #0x66f8,8(a1)                   /* bne.s init_mfp_loop */
        bne.s   done_p4
        lea     Text_Patch_movep_1_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
done_p4:

        cmp.l   #0x117C0088,d0                  /* move.b #0x88,0x28(a0) */
        bne.s   done_p5
        cmp.l   #0x0028117C,4(a1)               /* move.b #0x01,0x2a(a0) */
        bne.s   done_p5
        cmp.l   #0x0001002A,8(a1)
        bne.s   done_p5
        cmp.l   #0x117C0005,12(a1)              /* move.b #0x05,0x2c(a0) */
        bne.s   done_p5
        cmp.l   #0x002c0c38,16(a1)
        bne.s   done_p5
        lea     Text_Patch_movep_2_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
done_p5:

        cmp.l   #0x204F7000,d0                  /* move.l sp,a0; moveq #0,d0 */
        bne.s   done_p6
        cmpi.w  #0x4e71,4(a1)                   /* nop */
        bne.s   done_p6
        lea     Text_Patch_CPU_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
done_p6:

        cmp.l   #0x21C80010,d0                  /* move.l a0,(0x10).w */
        bne.s   done_p9
        cmpi.l  #0x4e7121c8,4(a1)               /* nop;move.l a0,(0x2c).w */
        bne.s   done_p9
        lea     Text_Patch_Vectors_3_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
done_p9:

        cmp.l   #0x54415441,d0                  /* addq.w #2,d1; addq.w #2,d1 */
        bne.s   done_p14
        cmpi.l  #0x54415441,4(a1)               /* addq.w #2,d1; addq.w #2,d1 */
        bne.s   done_p14
        cmpi.w  #0x3001,8(a1)                   /* move.w d1,d0 */
        bne.s   done_p14
        lea     Text_Patch_FPU_Cookie_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
done_p14:

        cmp.l   #0xf3270c78,d0                  /* fsave -(a7) */
        bne.s   done_p15
        cmpi.l  #0x003c059e,4(a1)               /* cmpi.w #60,(0xcpu_typ).w */
        bne.s   done_p15
        lea     Text_Patch_FPU_save_ok(pc),a0
        addq.w  #1,d2
        bsr     print_count_and_addr
        bra     patch_done
done_p15:


        nop
patch_done:
        addq.w  #2,a1
        subq.l  #1,d1
        bgt     patch_loop

        cmp.w   d3,d2                          /* compare how many patches done */
        beq     patch_ok
        lea     not_all_patches_msg(pc),a0
        bsr     cconws
        bsr     print_num_patches
        lea     crlf(pc),a0
        bsr     cconws
        bra     wait_key

patch_ok:
        lea     copy_msg(pc),a0
        bsr     cconws
        lea     -10(sp),sp
        move.l  sp,a0
        move.l  a5,d0
        bsr     conv_hex
        bsr     cconws
        lea     10(sp),sp
        lea     crlf(pc),a0
        bsr     cconws
        
  IFNE PATCHONLY
		bra done
  ENDC
		
        ori     #0x700,sr                       /* disable interrupts */
        lea     toscopy(pc),a1
        lea     0x0600,a0
        moveq   #((toscopyend-toscopy+3)/4)-1,d0
startcopy:
        move.l  (a1)+,(a0)+
        dbf     d0,startcopy
        move.l  _memtop,phystop
        cmpi.l  #40,CPU
        bcs.s   not_040
        .dc.w   0xF478                          /* CPUSHA DC */
        moveq   #0x00,d0                        /* inhibe & vide caches */
        .dc.w   0x4e7b,0x0002                   /* movec d0,cacr */
        .dc.w   0xF4D8                          /* CINVA BC */
        bra.s   go_toscopy

not_040:
        cmpi.l  #20,CPU
        bcs.s   go_toscopy
        .dc.w   0x4e7a,0x0002                   /* movec cacr,d0 */
        or.w    #0x808,d0                       /* clear caches */
        .dc.w   0x4e7b,0x0002                   /* movec d0,cacr */
go_toscopy:
        jmp     0x0600


/*
 * copy magic to its excution address
 * A5: target address
 * A6: start of file, including gemdos header
 * D5: length of text+data
 */
toscopy:
        movea.l a5,a0
        lea     sizeof_PH(a6),a1
        move.l  d5,d0
        lsr.l   #3,d0
        subq.l  #1,d0
        cmpa.l  a0,a1                           /* deplace MagiC */
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
        move.l  #0x5555AAAA,memval3
     IFNE RESIDENT
        move.l  #0x31415926,resvalid
        move.l  a5,resvector
     ENDIF
        cmpa.l  #0x01000000,a5
        bne.s   cpy_st
        add.l   d5,fstrm_beg
     IFNE OUTSIDE
/* align start of FastRAM, beyond end of MagiC on 32k boundary */
		move.l   fstrm_beg,d0
		add.l    #0x00007fff,d0            /* 32k-1 addieren */
		andi.w   #0x8000,d0                /* auf volle 32k gehen */
		move.l   d0,fstrm_beg
     ENDIF
        bra.s   startit

cpy_st:
        add.l   d5,os_membot(a5)
     IFNE OUTSIDE
/* align start of ST-RAM, beyond end of MagiC on 32k boundary */
		move.l   os_membot(a5),d0
		add.l    #0x00007fff,d0            /* 32k-1 addieren */
		andi.w   #0x8000,d0                /* auf volle 32k gehen */
		move.l   d0,os_membot(a5)
     ENDIF
        movea.l os_magic(a5),a0
        cmpi.l  #0x87654321,(a0)+
        bne.s   startit
        add.l   d5,(a0)
     IFNE OUTSIDE
/* align start of ST-RAM, beyond end of AES on 32k boundary */
		move.l   (a0),d0
		add.l    #0x00007fff,d0            /* 32k-1 addieren */
		andi.w   #0x8000,d0                /* auf volle 32k gehen */
		move.l   d0,(a0)
     ENDIF
startit:
        move.l  #16000,_hz_200
        jmp     (a5)

        nop
toscopyend:


err:
done:
        clr.w   -(a7)                           /* Pterm0 */
        trap    #1
        addq.w  #2,a7
        illegal
        bra err

not_found:
        lea     magx_name(pc),a0
        bsr     cconws
		lea     not_found_msg(pc),a0
		bsr     cconws_country
		bra     err

err_load:
		lea     err_load_msg(pc),a0
		bsr     cconws_country
		bra     err

dont_install:
		lea     dont_install_msg(pc),a0
		bsr     cconws_country

wait_key:
		lea     press_key_msg(pc),a0
        bsr     cconws_country
        move.w  #7,-(a7)                        /* Crawcin */
        trap    #1
        addq.w  #2,a7
		lea     crlf(pc),a0
        bsr     cconws
		bra     err

print_count_and_addr:
        bsr     cconws
        bsr.s   print_num_patches
print_count1:
		lea     space(pc),a0
        bsr     cconws
        lea     sizeof_PH(a6),a0
        move.l  a1,d0
        sub.l   a0,d0
        lea     -10(sp),sp
        move.l  sp,a0
        bsr     conv_hex
        move.l  sp,a0
        bsr     cconws
        lea     10(sp),sp
		lea     crlf(pc),a0
        bsr     cconws
		rts
print_addr:
        bsr     cconws
		bra.s   print_count1

print_num_patches:
        move.l  d1,-(sp)
        subq.l  #4,sp
        clr.l   (sp)
        lea     open_paren(pc),a0
        bsr     cconws
        move.l  sp,a0
        move.l  d2,d0
        moveq   #2,d1
        bsr     CONV_DECI
        move.l  sp,a0
        bsr     cconws
        lea     slash(pc),a0
        bsr     cconws
        move.l  sp,a0
        move.l  d3,d0
        moveq   #2,d1
        bsr     CONV_DECI
        move.l  sp,a0
        bsr     cconws
        lea     close_paren(pc),a0
        bsr     cconws
        addq.l  #4,sp
        move.l  (sp)+,d1
		rts

/*
 * A0:target string pointer ASCII
 * D0:32 bit value
 * D1:number of digits
 */
CONV_DECI:
        bsr     CONV_DECI_SIMPLE
        subq.w  #1,d1
        beq.s   conv_deci_end
        swap    d0
        tst.w   d0
        bne.s   conv_deci_err                   /* depassement */
        moveq   #0,d0
conv_deci_loop:
        cmpi.b  #"0",0(a0,d0.w)
        bne.s   conv_deci_end
        move.b  #" ",0(a0,d0.w)                 /* enleve les zeros inutiles */
        addq.w  #1,d0
        cmp.w   d1,d0
        bne.s   conv_deci_loop
        bra.s   conv_deci_end
conv_deci_err:
        move.b  #0x3F,0(a0,d1.w)
        dbf     d1,conv_deci_err
conv_deci_end:
        rts


/*
 * A0:target string pointer ASCII
 * D0:32 bit value
 * D1:number of digits
 */
CONV_DECI_SIMPLE:
        move.w  d1,-(sp)
        subq.w  #1,d1
        move.l  d0,-(a7)
conv_simple_loop:
        moveq   #0,d0
        move.w  (a7),d0
        divu    #10,d0                          /* poids fort /10 */
        move.w  d0,(a7)                         /* resultat poids fort */
        move.w  2(a7),d0
        divu    #10,d0                          /* ((reste * 65536) + poids faible)/10 */
        move.w  d0,2(a7)                        /* resultat poids faible */
        swap    d0
        or.w    #0x0030,d0
        move.b  d0,0(a0,d1.w)
        dbf     d1,conv_simple_loop
        addq.l  #4,a7
        move.w  (sp)+,d1
        rts


/*
 * A0:target string pointer ASCII
 * D0:32 bit value
 */
conv_hex:
		swap  d0
		bsr.s conv_hex4
		swap  d0
		bsr.s conv_hex4
		clr.b (a0)
		subq.l #8,a0
		rts
conv_hex4:
		rol.w #8,d0
		bsr.s conv_hex2
		ror.w #8,d0
conv_hex2:
		ror.w #4,d0
		bsr.s conv_hex1
		rol.w #4,d0
conv_hex1:
		move.l d1,-(sp)
		move.b d0,d1
		and.w  #15,d1
		add.b  #48,d1
		cmp.b  #58,d1
		bcs.s  conv_hexdone
		add.b  #39,d1
conv_hexdone:
		move.b d1,(a0)+
		move.l (sp)+,d1
		rts

/*
 * Input:
 *   name in D0.L
 * Return:
 *   0 if cookie not found
 *   the pointer to cookie data in A0
 *   the cookie value in D0 
 */
GET_COOKIE:
        move.l  _p_cookies,d1
        movea.l d1,a0
        beq.s   cookie_notfound
cookie_loop:
        tst.l   (a0)
        beq.s   cookie_notfound
        cmp.l   (a0)+,d0
        bne.s   next_cookie
        move.l  (a0),d0
        bra.s   cookie_found
next_cookie:
        addq.w  #4,a0
        bra.s   cookie_loop
cookie_notfound:
        moveq   #0,d0
        move.l  d0,a0
cookie_found:
        rts


        .data

/**********************************************************************
 *
 * void cconws_country(a0 = char *s)
 *
 * d4: country code
 * a0: ptr to countries & strings, as below:
 * char n1,n2,...,-1      countries for 1st string
 * char s1[]              1st string
 * char n3,n4,...,-1      countries for 2nd string
 * char s2[]              2nd string
 * char -1                terminator
 * char defs[]            default string (usually english)
 *
 **********************************************************************/

cconws_country:
		bsr.s    _chk_nat
		bne.b    cconws_country
cconws:
        movem.l  d0-d2/a1-a2,-(a7)
		move.l   a0,-(sp)
		gemdos   Cconws
		addq.l   #6,sp
        movem.l  (a7)+,d0-d2/a1-a2
		rts

_chk_nat:
		move.b   (a0)+,d0
		bmi.b    _chk_ende                /* end of countries, use default */
_chk_nxt:
		cmp.b    d0,d4                    /* our nationality ? */
		beq.b    _chk_found
		move.b   (a0)+,d0                 /* next country */
		bge.b    _chk_nxt                 /* continue searching */
_chk_nxtstr:
		tst.b    (a0)+                    /* skip string */
		bne.b    _chk_nxtstr
		moveq    #1,d0                    /* not found */
		rts
_chk_found:
		tst.b    (a0)+
		bge.b    _chk_found
_chk_ende:
		moveq    #0,d0                    /* found, print string at a0 */
		rts


Info_Text:
		.dc.b -1
        .dc.b    CR,LF,LF,0x1B,'p MagiC-BOOTER ',0x1B,'q',CR,LF,0
Text_Patch_cache_1:
        .dc.b    'Patch cache 1',0
Text_Patch_cache_2:
        .dc.b    'Patch cache 2',0
Text_Patch_cache_3:
        .dc.b    'Patch cache 3',0
Text_Patch_movep_1:
        .dc.b    'Patch movep 1',0
Text_Patch_movep_1_ok:
        .dc.b    'Movep 1 ok',0
Text_Patch_movep_2:
        .dc.b    'Patch movep 2',0
Text_Patch_movep_2_ok:
        .dc.b    'Movep 2 ok',0
Text_Patch_CPU_type:
        .dc.b    'Patch CPU type',0
Text_Patch_CPU_ok:
        .dc.b    'CPU detection ok',0
Text_Patch_Vectors_1:
        .dc.b    'Patch vectors 1',0
Text_Patch_Vectors_2:
        .dc.b    'Patch vectors 2',0
Text_Patch_Vectors_3:
        .dc.b    'Patch vectors 3',0
Text_Patch_Vectors_3_ok:
        .dc.b    'Vectors 3 ok',0
Text_Patch_Reset_1:
        .dc.b    'Patch reset 1',0
Text_Patch_Reset_2:
        .dc.b    'Patch reset 2',0
Text_Patch_DSP:
        .dc.b    'Patch DSP',0
Text_Patch_Floppy:
        .dc.b    'Patch floppy',0
Text_Patch_FPU_Cookie:
        .dc.b    'Patch FPU cookie',0
Text_Patch_FPU_Cookie_ok:
        .dc.b    'FPU cookie ok',0
Text_Patch_PMMU:
        .dc.b    'Patch PMMU 030 tree',0
Text_Patch_Monitor_1:
        .dc.b    'Patch external clock 32MHz RGB monitor 1',0
Text_Patch_Monitor_2:
        .dc.b    'Patch external clock 32MHz RGB monitor 2',0
Text_Patch_FPU_save:
        .dc.b    'Patch context FPU save',0
Text_Patch_FPU_save_ok:
        .dc.b    'Context FPU save ok',0
Text_Patch_FPU_restore:
        .dc.b    'Patch context FPU restore',0
Text_Internal_clock:
        .dc.b    'Internal clock : ',CR,LF,0
Text_external_clock:
        .dc.b    ', External clock : ',0
Text_Mhz:
        .dc.b    ' Mhz',0
Text_Patch_PSG:
        .dc.b    'Patch PSG printer',0
Text_Patch_CTPCI:
		.dc.b    'Patch CTPCI',0
Text_Patch_IDE_slave:
        .dc.b    'Patch boot IDE slave',CR,LF,0
magx_name:
        .dc.b    92,'magic.ram',0
not_all_patches_msg:
        .dc.b    CR,LF,'WARNING! A part is not patched!',0
open_paren:
		.dc.b    ' ','(',0
slash:
		.dc.b    '/',0
close_paren:
		.dc.b    ')',0
crlf:
		.dc.b    CR,LF,0
space:
		.dc.b    ' ','$',0

not_found_msg:
		.dc.b   -1
		.dc.b   ' not found',13,10,0
err_load_msg:
		.dc.b   -1
		.dc.b   'Error loading magic.ram',CR,LF,0

copy_msg:
		.dc.b   'Copying magic.ram to $',0

dont_install_msg:
		.dc.b    COUNTRY_DE,COUNTRY_SG,-1
		.dc.b   'Shift-Shift: MagiC nicht installiert',CR,LF,0
		.dc.b    COUNTRY_FR,COUNTRY_SF,-1
		.dc.b   'Shift-Shift: MagiC pas install',0x82,'',CR,LF,0
		.dc.b   -1
		.dc.b   'Shift-Shift: MagiC not installed',CR,LF,0

press_key_msg:
		.dc.b    COUNTRY_DE,COUNTRY_SG,-1
		.dc.b    'Taste dr',0x81,'cken!',0
		.dc.b    COUNTRY_FR,COUNTRY_SF,-1
		.dc.b    'Appuyez sur une touche!',0
		.dc.b    -1
		.dc.b    'Press any key!',0

        .bss

CT60:      .ds.w 1
CTPCI:     .ds.w 1
IDE_SLAVE: .ds.w 1
EXT_CLOCK: .ds.w 1
MACHINE:   .ds.l 1
CPU:       .ds.l 1
FPU:       .ds.l 1

        .ds.b     1800
stack:

        end
