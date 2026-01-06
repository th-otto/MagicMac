/*
 *
 * Assembler part of the interface to kernel functions.
 * Needed even for Pure-C, because some functions
 * clobbers registers other than d0-d2/a0-a1
 *
 * (C) Andreas Kromke 1997
 * (C) Thorsten Otto 2018
 *
 */

     INCLUDE "mgx_xfs.inc"


/*
 *
 * Wir importieren den Zeiger auf den MagiX-Kernel,
 * der bei der Installation des XFS ermittelt wurde.
 *
 * Weiterhin brauchen wir den Zeiger auf den DFS-Kernel
 * fÅr die Funktionen conv_8_3() und match_8_3().
 *
 */

     XREF p_kernel			; MagiX-Kernel
     XREF p_dfskernel
 

/*
 *
 * Dies sind die Kernelfunktionen, die hier als
 * cdecl ausgefÅhrt sind, um einen beliebigen
 * Compiler benutzen zu kînnen.
 *
 */

	XDEF	kernel_fast_clrmem
	XDEF	kernel_toupper
	XDEF	kernel__sprintf
	XDEF	kernel_appl_yield
	XDEF	kernel_appl_suspend
	XDEF	kernel_appl_begcritic
	XDEF	kernel_appl_endcritic
	XDEF	kernel_evnt_IO
	XDEF	kernel_evnt_mIO
	XDEF	kernel_evnt_emIO
	XDEF	kernel_appl_IOcomplete
	XDEF	kernel_evnt_sem
	XDEF	kernel_Pfree
    XDEF	kernel_int_malloc
    XDEF	kernel_int_mfree
    XDEF	kernel_resv_intmem
    XDEF	kernel_diskchange
    XDEF	kernel_DMD_rdevinit
    XDEF	kernel_proc_info
    XDEF	kernel_mxalloc
    XDEF	kernel_mfree
	XDEF	kernel_mshrink
	
	XDEF	kernel_match_8_3
	XDEF	kernel_conv_8_3
	XDEF	kernel_rcnv_8_3


/**********************************************************************
 *
 * void cdecl kernel_fast_clrmem(void *from, void *to)
 */

    MODULE kernel_fast_clrmem
	move.l	8(sp),a1			; end
	move.l	4(sp),a0			; start
	move.l	d2,-(sp)
	move.l	a2,-(sp)
	move.l	p_kernel,a2
	move.l	mxk_fast_clrmem(a2),a2
	jsr		(a2)
	move.l	(sp)+,a2
	move.l	(sp)+,d2
	rts
	ENDMOD

/**********************************************************************
 *
 * char cdecl kernel_toupper(char c)
 */

    MODULE kernel_toupper
    moveq	#0,d0
    move.b	5(a7),d0
	move.l	p_kernel,a0
	move.l	mxk_toupper(a0),a0
	jmp		(a0)
	ENDMOD

/**********************************************************************
 *
 * void cdecl kernel__sprintf( char *dst, const char *src, LONG *data )
 */

 MODULE kernel__sprintf
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	20(sp),-(sp)			; data
 move.l	20(sp),-(sp)			; src
 move.l	20(sp),-(sp)			; dst
 move.l	p_kernel,a2
 move.l	mxk__sprintf(a2),a2
 jsr    (a2)
 addq.l #4,sp
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_appl_yield(void)
 */

 MODULE kernel_appl_yield
 move.l	p_kernel,a0
 move.l	mxk_appl_yield(a0),a0
 jmp    (a0)
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_appl_suspend(void)
 */

 MODULE kernel_appl_suspend
 move.l	p_kernel,a0
 move.l	mxk_appl_suspend(a0),a0
 jmp    (a0)
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_appl_begcritic(void)
 */

 MODULE kernel_appl_begcritic
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_appl_begcritic(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_appl_endcritic(void)
 */

 MODULE kernel_appl_endcritic
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_appl_endcritic(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * long cdecl kernel_evnt_IO(LONG ticks_50hz, MAGX_UNSEL *unsel)
 */

 MODULE kernel_evnt_IO
 move.l 8(sp),a0
 move.l 4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_evnt_IO(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_evnt_mIO(LONG ticks_50hz, MAGX_UNSEL *unsel, WORD cnt)
 */

 MODULE kernel_evnt_mIO
 move.w 10(sp),d1
 move.l 8(sp),a0
 move.l 4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_evnt_mIO(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_evnt_emIO(APPL *ap)
 */

 MODULE kernel_evnt_emIO
 move.l 4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_evnt_emIO(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_appl_IOcomplete(APPL *ap)
 */

 MODULE kernel_appl_IOcomplete
 move.l 4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_evnt_emIO(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * long cdecl kernel_evnt_sem(WORD mode, void *sem, LONG timeout)
 */

 MODULE kernel_evnt_sem
 move.l 10(sp),d1
 move.l 6(sp),a0
 move.w 4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_evnt_sem(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_Pfree(PD *pd)
 */

 MODULE kernel_Pfree
 move.l	4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_Pfree(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl *kernel_int_malloc( void )
 */

 MODULE kernel_int_malloc
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_int_malloc(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 move.l	d0,a0				/* return pointer also in a0 */
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl kernel_int_mfree( void *block )
 */

 MODULE kernel_int_mfree
 move.l	4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_int_mfree(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void cdecl *kernel_resv_intmem(void *mem, LONG bytes)
 */

 MODULE kernel_resv_intmem
 move.l	4(sp),a0
 move.l	8(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_resv_intmem(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_diskchange( WORD drv )
 */

 MODULE kernel_diskchange
 move.w	4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_diskchange(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_DMD_rdevinit( MX_DMD *dmd )
 */

 MODULE kernel_DMD_rdevinit
 move.l	4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_DMD_rdevinit(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_proc_info( WORD code, PD *pd )
 */

 MODULE kernel_proc_info
 move.l	6(sp),a0
 move.w	4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_ker_proc_info(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_mxalloc(LONG amount, WORD mod, PD *pd)
 */

 MODULE kernel_mxalloc
 move.l	10(sp),a0
 move.w	8(sp),d1
 move.l	4(sp),d0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_ker_mxalloc(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 move.l	d0,a0				/* return pointer also in a0 */
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_mfree(void *mem)
 */

 MODULE kernel_mfree
 move.l	4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_ker_mfree(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * LONG cdecl kernel_mshrink(void *mem, LONG newlen)
 */

 MODULE kernel_mshrink
 move.l	8(sp),d0
 move.l	4(sp),a0
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_kernel,a2
 move.l	mxk_ker_mshrink(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * WORD kernel_match_8_3( const char *patt, const char *fname );
 */

 MODULE kernel_match_8_3
 move.l	4(sp),a0
 move.l	8(sp),a1
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_dfskernel,a2
 move.l	dfsk_match_8_3(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void kernel_conv_8_3( const char *from, char to[11] )
 */

 MODULE kernel_conv_8_3
 move.l	4(sp),a0
 move.l	8(sp),a1
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_dfskernel,a2
 move.l	dfsk_conv_8_3(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD

/**********************************************************************
 *
 * void kernel_rcnv_8_3( const char from[11], char *to )
 */

 MODULE kernel_rcnv_8_3
 move.l	4(sp),a0
 move.l	8(sp),a1
 move.l d2,-(sp)
 move.l a2,-(sp)
 move.l	p_dfskernel,a2
 move.l	dfsk_rcnv_8_3(a2),a2
 jsr    (a2)
 move.l	(sp)+,a2
 move.l	(sp)+,d2
 rts
 ENDMOD
