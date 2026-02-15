*
*
*
set_com:
 subq.w   #2,SP_ARGC(sp)
 bge.b    setcom_4
 move.l   a5,-(sp)
 lea      d+environment(pc),a5     * keine Parameter
 bra.b    setcom_3                 * Environment ausgeben
setcom_loop:
 bsr      crlf_stdout              * newline und Eintrag ausdrucken
 move.l   a5,a0
 bsr      strstdout
setcom_2:
 tst.b    (a5)+                    * Suchen n„chsten Eintrag
 bne.b    setcom_2
setcom_3:
 tst.b    (a5)                     * Zwei Nullbytes hintereinander => Ende
 bne.b    setcom_loop
 bsr      crlf_stdout
 move.l   (sp)+,a5
 bra.b    setcom_end
setcom_4:
 movea.l  SP_ARGV(sp),a0
 move.l   4(a0),a0
 bsr      env_set
 tst.w    d0
 beq.b    setcom_end
 subq.w   #2,d0
 beq.b    setcom_5
 lea      syntaxfehlers(pc),a0
 bsr      get_country_str
 bsr      strcon
setcom_5:
 bsr      inc_errlv
setcom_end:
 rts
