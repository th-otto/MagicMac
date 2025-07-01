/*
*
* Video-Initialisierung fuer Raven
*
*/

boot_init_video:
 move.b   #2,sshiftmd.w
 move.l   #RAVEN_PADDR_ISA_RAM16+$A0000,a0
 move.l   a0,_v_bas_ad
 rts
 
