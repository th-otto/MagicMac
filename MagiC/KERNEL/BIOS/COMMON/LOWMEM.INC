* "Öffentliche" BIOS-Variablen"

proc_lives     EQU $380
proc_regs      EQU $384
proc_pc        EQU $3c4
proc_usp       EQU $3c8
proc_stk       EQU $3cc
etv_timer      EQU $400
etv_critic     EQU $404
etv_term       EQU $408
etv_xtra       EQU $40c
memvalid       EQU $420
memctrl        EQU $424
resvalid       EQU $426
resvector      EQU $42a
phystop        EQU $42e
_membot        EQU $432
_memtop        EQU $436
memval2        EQU $43a
flock          EQU $43e
seekrate       EQU $440
_timer_ms      EQU $442
_fverify       EQU $444
_bootdev       EQU $446
palmode        EQU $448       ; unbenutzt
defshiftmd     EQU $44a
sshiftmd       EQU $44c
_v_bas_ad      EQU $44e
vblsem         EQU $452
nvbls          EQU $454
_vblqueue      EQU $456
colorptr       EQU $45a
screenpt       EQU $45e
_vbclock       EQU $462
_frclock       EQU $466
hdv_init       EQU $46a
swv_vec        EQU $46e
hdv_bpb        EQU $472
hdv_rw         EQU $476
hdv_boot       EQU $47a
hdv_mediach    EQU $47e
_cmdload       EQU $482
conterm        EQU $484
trp14ret       EQU $486       ; hier unbenutzt
os_chksum      EQU trp14ret   ; in Mag!X Checksumme des Systems
criticret      EQU $48a       ; MagiC 6.01: DOS-Event-Critic aktiv
themd          EQU $48e
____md         EQU $49e       ; hier unbenutzt
fstrm_beg      EQU ____md     ; in Mag!X Beginn des TT-RAMs
savptr         EQU $4a2
_nflops        EQU $4a6
con_state      EQU $4a8       ; hier unbenutzt
save_row       EQU $4ac       ; hier unbenutzt
sav_context    EQU $4ae       ; hier unbenutzt
_bufl          EQU $4b2       ; hier unbenutzt
_hz_200        EQU $4ba
the_env        EQU $4be       ; hier unbenutzt
_drvbits       EQU $4c2
_dskbufp       EQU $4c6
_autopath      EQU $4ca       ; hier unbenutzt
_vbl_list      EQU $4ce
_dumpflg       EQU $4ee
_prtabt        EQU $4f0       ; hier unbenutzt
_sysbase       EQU $4f2
_shell_p       EQU $4f6       ; hier unbenutzt
end_os         EQU $4fa
exec_os        EQU $4fe
scr_dump       EQU $502
prv_lsto       EQU $506
prv_lst        EQU $50a
prv_auxo       EQU $50e
prv_aux        EQU $512
pun_ptr        EQU $516       ; hier unbenutzt
memval3        EQU $51a
dev_vecs       EQU $51e       /* long dev_vecs[8*4]         */
cpu_typ        EQU $59e       /* int cpu_typ                */
_p_cookies     EQU $5a0       /* long *cookie               */
fstrm_top      EQU $5a4
fstrm_valid    EQU $5a8
bell_hook      EQU $5ac       /* long *pointer auf pling    */
kcl_hook       EQU $5b0       /* long *pointer auf keyklick */

