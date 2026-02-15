prompt_com:
 link     a6,#DUMMY
 lea      promptis(pc),a1
 lea      STRING(a6),a0
 bsr      strcpy
 lea      leers(pc),a1
 cmpi.w   #1,ARGC(a6)
 ble.b    prompt_1
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1
prompt_1:
 bra.b    set_parameter       * Siehe path_com
