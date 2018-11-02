		XDEF mystrlen
		XDEF strcmp
		XDEF vmemcpy
		XDEF vstrcpy

**********************************************************************
*
* PUREC WORD vstrcpy(char *dst, char *src)
*

vstrcpy:
 move.b	(a1)+,(a0)+
 bne.b	vstrcpy
 rts


**********************************************************************
*
* PUREC LONG strlen(const char *string)
*
* long strlen(a0 = char *string)
*
* aendert a1/a0/d0
*

mystrlen:
 move.l	a0,a1
str1:
 tst.b	(a1)+
 bne.b	str1
 move.l a1,d0
 sub.l a0,d0
 subq.l #1,d0
 rts

**********************************************************************
*
* PUREC WORD strcmp(char *s1, char *s2)
*
* int strcmp(a0 = char *s1, a1 = char *s2)
*
* aendert nur a0/a1
*

strcmp:
 moveq #0,d0
 moveq #0,d1
smp_loop:
 move.b	(a0)+,d0
 move.b	(a1)+,d1
 cmp.w	d1,d0
 blt.b	smp_lt
 bgt.b	smp_gt
 or.b d0,d1
 bne.s smp_loop
 moveq #0,d0
 rts
smp_lt:
 moveq #-1,d0
 rts
smp_gt:
 moveq #1,d0
 rts


**********************************************************************
*
* PUREC void vmemcpy(void *dst, void *src, size_t len)
*
* void vmemcpy(a0 = void *dst, a1 = void *src, d0 = unsigned long len
*
* aendert nur d1/a0/a1
*

vmemcpy:
 tst.l d0
 beq.b	mcp_end
 move.l a0,d1
 cmpa.l	a1,a0
 bhi.b	mcp_dir2
mcp_loop1:
 move.b	(a1)+,(a0)+
 subq.l	#1,d0
 bhi.b	mcp_loop1
 movea.l d1,a0
mcp_end:
 rts
mcp_dir2:
 adda.l	d0,a0
 adda.l	d0,a1
mcp_loop2:
 move.b	-(a1),-(a0)
 subq.l	#1,d0
 bhi.b	mcp_loop2
 rts

