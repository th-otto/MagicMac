STRING    SET       -150        * char STRING[150]
DUMMY     SET       -(4+150)

path_com:
 link     a6,#DUMMY
 cmpi.w   #2,ARGC(a6)
 bge.b    path_2
 bsr      crlf_stdout
 lea      pathis(pc),a0            * "PATH="
 bsr      getenv
 bne.b    path_1
 lea      kein_pfads(pc),a0
 bsr      get_country_str
path_1:
 bsr      strstdout
 bsr      crlf_stdout
 bra.b    path_ende
path_2:
 lea      pathis(pc),a1
 lea      STRING(a6),a0
 bsr      strcpy
 movea.l  ARGV(a6),a0
 move.l   4(a0),a1                 * erster Parameter
set_parameter:
 lea      STRING(a6),a0
 bsr      strcat
 lea      STRING(a6),a0
 bsr      env_set
path_ende:
 unlk     a6
 rts
