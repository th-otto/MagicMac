	include	"mgx_xfs.inc"

	export real_kernel
	export kernel
	export install_kernel

	TEXT
	
; Zeiger auf die tatsÑchliche Kernelstruktur speichern und die
; Variablen in die C-Struktur Åbertragen (auch wenn das C-Programm
; auf sie eigentlich nur Åber real_kernel zugreifen soll)
install_kernel:
	lea		my_mx_kernel,a1
	move.w	mxk_version(a0),mxk_version(a1)
	move.l	mxk_act_pd(a0),mxk_act_pd(a1)
	move.l	mxk_act_appl(a0),mxk_act_appl(a1)
	move.l	mxk_keyb_app(a0),mxk_keyb_app(a1)
	move.l	mxk_pe_slice(a0),mxk_pe_slice(a1)
	move.l	mxk_pe_timer(a0),mxk_pe_timer(a1)
	move.w	mxk_int_msize(a0),mxk_int_msize(a1)
	move.l  a1,a0
	rts

; Ab hier folgen die Routinen, die das AusfÅhren der Kernelfunktionen
; Åbernehmen und dabei dafÅr sorgen, daû die Register gerettet werden
my_fast_clrmem:
	move.l	a2,-(sp)
	move.l	real_kernel,a2
	move.l	mxk_fast_clrmem(a2),a2
	jsr		(a2)
	move.l	(sp)+,a2
	rts

my_toupper:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_toupper(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my__sprintf:
	move.l	4(sp),d0
	movem.l d3-d7/a2-a6,-(sp)
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	move.l	real_kernel,a6
	move.l	mxk__sprintf(a6),a6
	jsr		(a6)
	lea		12(sp),sp
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_appl_yield:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_appl_yield(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_appl_suspend:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_appl_suspend(a6),a6
	jmp		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_appl_begcritic:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_appl_begcritic(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_appl_endcritic:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_appl_endcritic(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_evnt_IO:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_evnt_IO(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_evnt_mIO:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_evnt_mIO(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_evnt_emIO:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_evnt_emIO(a6),a6
	jsr (a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_appl_IOcomplete:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_appl_IOcomplete(a6),a6
	jsr (a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_evnt_sem:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_evnt_sem(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_Pfree:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_Pfree(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_int_malloc:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_int_malloc(a6),a6
	jsr		(a6)
	move.l	d0,a0
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_int_mfree:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_int_mfree(a6),a6
	jsr (a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_resv_intmem:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_resv_intmem(a6),a6
	jsr (a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_diskchange:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_diskchange(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_DMD_rdevinit:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_DMD_rdevinit(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_proc_info:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_ker_proc_info(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_mxalloc:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_ker_mxalloc(a6),a6
	jsr		(a6)
	move.l	d0,a0
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_mfree:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_ker_mfree(a6),a6
	jsr		(a6)
	movem.l (sp)+,d3-d7/a2-a6
	rts

my_mshrink:
	movem.l d3-d7/a2-a6,-(sp)
	move.l	real_kernel,a6
	move.l	mxk_ker_mshrink(a6),a6
	jsr		(a6)
	move.l	d0,a0
	movem.l (sp)+,d3-d7/a2-a6
	rts

	DATA
	
; Dies ist die Kernelstruktur, die von install_xfs zurÅckgeliefert
; wird
my_mx_kernel:
	dc.w	0
	dc.l	my_fast_clrmem
	dc.l	my_toupper
	dc.l	my__sprintf
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	my_appl_yield
	dc.l	my_appl_suspend
	dc.l	my_appl_begcritic
	dc.l	my_appl_endcritic
	dc.l	my_evnt_IO
	dc.l	my_evnt_mIO
	dc.l	my_evnt_emIO
	dc.l	my_appl_IOcomplete
	dc.l	my_evnt_sem
	dc.l	my_Pfree
	dc.w	0
	dc.l	my_int_malloc
	dc.l	my_int_mfree
	dc.l	my_resv_intmem
	dc.l	my_diskchange
	dc.l	my_DMD_rdevinit
	dc.l	my_proc_info
	dc.l	my_mxalloc
	dc.l	my_mfree
	dc.l	my_mshrink

	bss
	
; Hier steht spÑter der Zeiger auf die echte Kernelstruktur
real_kernel:
	ds.l	1
kernel:
	ds.l	1
