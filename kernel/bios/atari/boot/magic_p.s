		move.l    4(a7),basep
		lea.l     stack-4,a7
		movea.l   basep,a0
		movea.l   12(a0),a1
		adda.l    20(a0),a1
		adda.l    28(a0),a1
		pea.l     256(a1)
		pea.l     (a0)
		clr.w     -(a7)
		move.w    #74,-(a7) /* Mshrink */
		trap      #1
		lea.l     12(a7),a7

		bsr.w     patchit
		clr.w     -(a7)
		move.w    #0,-(a7)
		trap      #1
		.dc.w 0x4fef,0x0000 /* lea.l     0(a7),a7*/

patchit:
		pea.l     title(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7

		move.w    #7,-(a7) /* Crawcin */
		trap      #1
		addq.w    #2,a7

		cmp.w     #13,d0
		bne.s     endpatch
		clr.w     -(a7)
		pea.l     magx_name
		move.w    #61,-(a7) /* Fopen */
		trap      #1
		addq.w    #8,a7
		move.w    d0,d7
		bpl.s     patchit1
		pea.l     no_magic_msg(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7
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

		movea.l   a6,a2
		move.w    #0xF039,d2 /* pmove opcode we are searching for */
		move.w    branch_opcode,d3
		moveq.l   #10-1,d4  /* number of locations to search */

patchloop:
		cmp.w     (a2),d2
		beq.s     patchop
		addq.w    #2,a2
		bra.s     patchloop
patchop:
		move.w    d3,(a2)
		addq.w    #8,a2
		dbf       d4,patchloop

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
		pea.l     exists_msg(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7
		bra.s     done

writeit:
		pea.l     creating_msg(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7

		pea.l     magx_name_bak(pc)
		pea.l     magx_name(pc)
		clr.w     -(a7)
		move.w    #86,-(a7) /* Frename */
		trap      #1
		lea.l     12(a7),a7
		tst.w     d0
		bmi.s     err

done:
		pea.l     saving_msg(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7

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

		pea.l     (a1) /* BUG: should be a6 */
		move.w    #73,-(a7) /* Mfree */
		trap      #1
		addq.w    #6,a7

		pea.l     finish_msg(pc)
		move.w    #9,-(a7) /* Cconws */
		trap      #1
		addq.w    #6,a7

		move.w    #7,-(a7) /* Crawcin */
		trap      #1
		addq.w    #2,a7
		rts

err:
		pea.l     (a1) /* BUG: should be a6 */
		move.w    #73,-(a7) /* Mfree */
		trap      #1
		addq.w    #6,a7

nomem_err:
		pea.l     errmsg(pc)
		move.w    #9,-(a7)
		trap      #1
		addq.w    #6,a7
		move.w    #7,-(a7)
		trap      #1
		addq.w    #2,a7
		rts

branch_opcode:
		bra.s     skipit
		dc.w      0
		dc.w      0
		dc.w      0
skipit:

		.data
title:  
		dc.b 27,'E'
        dc.b '~~~~~~~~MAGIC PATCH FOR CENTurbo II~~~~~~~~~',13,10,13,10,' [Return] => Go...',13,10,0
        dc.b 0
creating_msg:
        dc.b 13,10,'Creating MAGIC.BAK...',13,10,0
exists_msg:
        dc.b 13,10,'MAGIC.BAK exist !',13,10,0
saving_msg:
        dc.b 13,10,'Saving new MAGIC.RAM...',13,10,0
finish_msg:
        dc.b 13,10,'Finish !',13,10,0
key_msg:
        dc.b 'A key to exit...',13,10,0
no_magic_msg:
        dc.b 13,10,'No MAGIC.RAM ?!',13,10,'A key to exit...',13,10,0
magx_name:
        dc.b 'MAGIC.RAM',0
magx_name_bak:
        dc.b 'MAGIC.BAK',0
errmsg:
        dc.b 13,10,13,10,'ERROR during work !!!!',13,10,'A key to exit...',13,10,0

     even

	.bss
basep: ds.l 1

	.ds.b 4004
stack:
