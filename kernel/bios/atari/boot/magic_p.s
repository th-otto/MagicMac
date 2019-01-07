		move.l    4(a7),a5
		lea.l     stack-4(pc),a7
		movea.l   12(a5),a1
		adda.l    20(a5),a1
		adda.l    28(a5),a1
		pea.l     256(a1)
		pea.l     (a5)
		clr.w     -(a7)
		move.w    #74,-(a7) /* Mshrink */
		trap      #1
		lea.l     12(a7),a7

		bsr.s     patchit
		clr.w     -(a7)
		move.w    #0,-(a7)
		trap      #1

patchit:
		lea       title(pc),a0
		bsr       cconws

		move.w    #7,-(a7) /* Crawcin */
		trap      #1
		addq.w    #2,a7

		cmp.w     #13,d0
		bne.s     endpatch
		clr.w     -(a7)
		pea.l     magx_name(pc)
		move.w    #61,-(a7) /* Fopen */
		trap      #1
		addq.w    #8,a7
		move.w    d0,d7
		bpl.s     patchit1
		lea       no_magic_msg(pc),a0
		bsr       cconws
		move.w    #7,-(a7) /* Crawcin */
		trap      #1
		addq.w    #2,a7
endpatch:
		rts

patchit1:
/* determine file size */
		move.w    #2,-(a7)
		move.w    d7,-(a7)
		clr.l     -(a7)
		move.w    #66,-(a7) /* Fseek */
		trap      #1
		lea.l     10(a7),a7

		move.l    d0,d6
		clr.w     -(a7)
		move.w    d7,-(a7)
		clr.l     -(a7)
		move.w    #66,-(a7)
		trap      #1
		lea.l     10(a7),a7

/* get memory */
		move.l    d6,-(a7)
		move.w    #72,-(a7) /* Malloc */
		trap      #1
		addq.w    #6,a7
		tst.l     d0
		beq       nomem_err
		movea.l   d0,a6

/* slurp whole file in */
		pea.l     (a6)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		move.w    #63,-(a7) /* Fread */
		trap      #1
		lea.l     12(a7),a7

		move.w    d7,-(a7)
		move.w    #62,-(a7) /* Fclose */
		trap      #1
		addq.w    #4,a7

        cmp.w     #0x601a,(a6)
        bne       err
		lea       28(a6),a2  /* start of text */
		move.l    2(a6),d0   /* length of text segment */
		lea       0(a2,d0.l),a3 /* end of text */
		move.w    #0xF039,d2 /* pmove opcode we are searching for */
		move.w    #0x6006,d3 /* bra.s *+8 */
        moveq     #0,d0
        
patchloop:
		cmpa.l    a3,a2
		bcc.s     patchend
		cmp.w     (a2)+,d2
		bne.s     patchloop
patchop:
		move.w    d3,-2(a2)
		addq.w    #6,a2
		addq.l    #1,d0
		bra.s     patchloop
patchend:
        lea       found_msg(pc),a0
        bsr       cconws
        lea       -10(sp),sp
        move.l    sp,a0
        bsr       conv_hex
        bsr       cconws
        lea       10(sp),sp
        lea       crlf(pc),a0
        bsr       cconws
        
		clr.w     -(a7)
		pea.l     magx_name_bak(pc)
		move.w    #61,-(a7) /* Fopen */
		trap      #1
		addq.w    #8,a7
		tst.w     d0
		bmi.s     writeit
		move.w    d0,-(a7)
		move.w    #62,-(a7) /* Fclose */
		trap      #1
		addq.w    #4,a7
		lea       exists_msg(pc),a0
		bsr       cconws
		bra.s     done

writeit:
		lea       creating_msg(pc),a0
		bsr       cconws

		pea.l     magx_name_bak(pc)
		pea.l     magx_name(pc)
		clr.w     -(a7)
		move.w    #86,-(a7) /* Frename */
		trap      #1
		lea.l     12(a7),a7
		tst.w     d0
		bmi.s     err

done:
		lea       saving_msg(pc),a0
		bsr       cconws

		clr.w     -(a7)
		pea.l     magx_name(pc)
		move.w    #60,-(a7) /* Fcreate */
		trap      #1
		addq.w    #8,a7

		move.w    d0,d7
		bmi.s     err

		pea.l     (a6)
		move.l    d6,-(a7)
		move.w    d7,-(a7)
		move.w    #64,-(a7) /* Fwrite */
		trap      #1
		lea.l     12(a7),a7
		tst.l     d0
		bmi.s     err

		move.w    d7,-(a7)
		move.w    #62,-(a7) /* Fclose */
		trap      #1
		addq.w    #4,a7

		pea.l     (a6)
		move.w    #73,-(a7) /* Mfree */
		trap      #1
		addq.w    #6,a7

		lea       finish_msg(pc),a0
		bsr       cconws

		move.w    #7,-(a7) /* Crawcin */
		trap      #1
		addq.w    #2,a7
		rts

err:
		pea.l     (a6)
		move.w    #73,-(a7) /* Mfree */
		trap      #1
		addq.w    #6,a7

nomem_err:
		lea       errmsg(pc),a0
		bsr       cconws
		move.w    #7,-(a7)
		trap      #1
		addq.w    #2,a7
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
		move.b d0,d1
		and.w  #15,d1
		add.b  #48,d1
		cmp.b  #58,d1
		bcs.s  conv_hexdone
		add.b  #39,d1
conv_hexdone:
		move.b d1,(a0)+
		rts

cconws:
        movem.l  d0-d2/a1-a2,-(a7)
		move.l   a0,-(sp)
		move.w   #9,-(a7) /* Cconws */
		trap     #1
		addq.l   #6,sp
        movem.l  (a7)+,d0-d2/a1-a2
		rts

title:  
		.dc.b 27,'E'
        .ascii "~~~~~~~~MAGIC PATCH FOR CENTurbo II~~~~~~~~~"
        .dc.b 13,10,13,10
        .ascii " [Return] => Go..."
        .dc.b 13,10,0
creating_msg:
        .dc.b 13,10
        .ascii "Creating MAGIC.BAK..."
        .dc.b 13,10,0
exists_msg:
        .dc.b 13,10
        .ascii "MAGIC.BAK exist !"
        .dc.b 13,10,0
saving_msg:
        .dc.b 13,10
        .ascii "Saving new MAGIC.RAM..."
        .dc.b 13,10,0
finish_msg:
        .dc.b 13,10
        .ascii "Finish !"
        .dc.b 13,10,0
no_magic_msg:
        .dc.b 13,10
        .ascii "No MAGIC.RAM ?!"
        .dc.b 13,10
key_msg:
        .ascii "A key to exit..."
        .dc.b 13,10,0
found_msg:
        .ascii "Found patches: $"
        .dc.b 0
magx_name:
        .ascii "MAGIC.RAM"
        .dc.b 0
magx_name_bak:
        .ascii "MAGIC.BAK"
        .dc.b 0
errmsg:
        .dc.b 13,10,13,10
        .ascii "ERROR during work !!!!"
        .dc.b 13,10
        .ascii "A key to exit..."
crlf:
        .dc.b 13,10,0

     .even

	 .bss

	.ds.b 4004
stack:
