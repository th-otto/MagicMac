end_com:
 bsr      sav_errlv
 move.w   SP_BATCH(sp),d0     * checken, ob im Batch- Modus
 beq.b    end_end
 move.w   #2,-(sp)
 move.w   d0,-(sp)            * Handle der Batchdatei = $16(a6)
 clr.l    -(sp)               * Ans Ende der Batchdatei gehen
 gemdos   Fseek
 adda.w   #$a,sp
end_end:
 rts
