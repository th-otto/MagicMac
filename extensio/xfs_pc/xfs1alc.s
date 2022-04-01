mec2_opcode equ 0x45bf
p_cookie = 0x5a0
KER_INSTXFS = 0x200
mxk_ker_proc_info = 96


		xref _vt52_printf
 
		.text

start:
		bsr.s      hello
		pea.l      icookie
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		movea.l    #mpc_info,a0
		.dc.w mec2_opcode,0x20
		move.l     d0,d7
		move.l     d0,-(a7)
		move.w     #72,-(a7) ; Malloc
		trap       #1
		addq.l     #6,a7
		tst.l      d0
		ble.s      start1
		movea.l    d0,a0
		move.l     d7,d0
		.dc.w mec2_opcode,0x21
		bsr.s      install_xfs
start1:
		moveq.l    #1,d0
		rts

mpc_info:
	.dc.w 0x0030
	.dc.w 0x0596
	.dc.l 0x10000
	.dc.l mpc_xfs
	.dc.l mpc_dev

install_xfs:
		move.l     #mpc_xfs,-(a7)
		clr.l      -(a7)
		move.w     #KER_INSTXFS,-(a7)
		move.w     #0x0130,-(a7) ; Dcntl
		trap       #1
		adda.w     #12,a7
		move.l     d0,kernel
		rts

hello:
		rts

init_xfs2:
		pea.l      copyright_msg
		jsr        _vt52_printf
		addq.l     #4,a7
		moveq.l    #1,d0
		rts

copyright_msg:
	.dc.b "/,'XFS_PC.LDR Version 1.00, (c) 1996 by F.Schmerbeck',/",0
	.even

icookie:
		move.l     p_cookie.l,d0
		beq.s      icookie3
		movea.l    d0,a0
		moveq.l    #0,d0
		bra.s      icookie2
icookie1:
		addq.w     #1,d0
		addq.l     #8,a0
icookie2:
		tst.l      (a0)
		bne.s      icookie1
		addq.w     #2,d0
		cmp.w      6(a0),d0
		bge.s      icookie3
		move.l     (a0),8(a0)
		move.l     4(a0),12(a0)
		move.l     cookie_id,(a0)
		clr.l      4(a0)
icookie3:
		rts

cookie_id: .dc.l 'MgPC'

getkey:
		move.w     #2,-(a7)
		move.w     #2,-(a7) ; Bconin
		trap       #13
		addq.l     #4,a7
		andi.l     #255,d0
		rts

		.dc.w 0x23f9
		.dc.b 'XFS_LDI.'
		
mpc_xfs:
		.dc.b 'MPC_XFS '
		.dc.l 0 ; next
		.dc.l 0 ; flags
		.dc.l init
		.dc.l sync
		.dc.l pterm
		.dc.l garbcoll
		.dc.l freeDD
		.dc.l drv_open
		.dc.l drv_close
		.dc.l path2DD
		.dc.l sfirst
		.dc.l snext
		.dc.l fopen
		.dc.l fdelete
		.dc.l link
		.dc.l xattr
		.dc.l attrib
		.dc.l chown
		.dc.l chmod
		.dc.l dcreate
		.dc.l ddelete
		.dc.l DD2name
		.dc.l dopendir
		.dc.l dreaddir
		.dc.l drewinddir
		.dc.l dclosedir
		.dc.l dpathconf
		.dc.l dfree
		.dc.l wlabel
		.dc.l rlabel
		.dc.l symlink
		.dc.l readlink
		.dc.l dcntl

mpc_dev:
		.dc.l dev_close
		.dc.l dev_read
		.dc.l dev_write
		.dc.l dev_stat
		.dc.l dev_seek
		.dc.l dev_datime
		.dc.l dev_ioctl
		.dc.l 0 ; dev_getc
		.dc.l 0 ; dev_getline
		.dc.l 0 ; dev_putc

	.dc.w 0x23f9
	.dc.b 'XFS1.O',0,'.'

/*
 * long xfs_init(void)
 */
init:
		moveq.l    #0,d0
		rts

/*
 * long xfs_sync(a0 = DMD *)
 */
sync:
		.dc.w mec2_opcode,0x01
		rts

/*
 * long xfs_pterm(a0 = PD *)
 */
pterm:
		.dc.w mec2_opcode,0x02
		rts

/*
 * long xfs_garbcoll(a0 = DMD *)
 */
garbcoll:
		.dc.w mec2_opcode,0x03
		rts

/*
 * void xfs_freedd(a0 = DD *)
 */
freeDD:
		.dc.w mec2_opcode,0x04
		rts

/*
 * long xfs_drv_open(a0 = DMD *)
 */
drv_open:
		.dc.w mec2_opcode,0x05
		cmpi.w     #1,d0
		bne.s      drvopen1
		movea.l    kernel,a1
		movea.l    mxk_ker_proc_info(a1),a1 ; WTF? thats nonsense
		jsr        (a1)
		moveq.l    #0,d0
drvopen1:
		rts

/*
 * long xfs_drv_close(a0 = DMD *, d0.w = mode)
 */
drv_close:
		.dc.w mec2_opcode,0x06
		rts

/*
 * xfs_path2DD(a0 = DD *reldir, d0.w = mode, a1 = char *pathname)
 */
path2DD:
		.dc.w mec2_opcode,0x07
		rts

/*
 * long xfs_sfirst(a0 = DD *, a1 = char *name, d0.l = DTA *, d1.w = attrib)
 */
sfirst:
		.dc.w mec2_opcode,0x08
		rts

/*
 * long xfs_snext(a0 = DTA *, a1 = DMD *)
 */
snext:
		.dc.w mec2_opcode,0x09
		rts

/*
 * long xfs_fopen(a0 = DD *, a1 = char *name, d0.w = mode, d1.w = attrib)
 */
fopen:
		.dc.w mec2_opcode,0x0a
		rts

/*
 * long xfs_fdelete(a0 = DD *, a1 = char *name)
 */
fdelete:
		.dc.w mec2_opcode,0x0b
		rts

/*
 * long xfs_link(a0 = DD *olddir, a1 = DD *newdir, d0 = char *oldname, d1 = char *newname, d2.w = flag_link)
 */
link:
		.dc.w mec2_opcode,0x0c
		rts

/*
 * long xfs_xattr(a0 = DD *, a1 = char *name, d0 = XATTR *, d1.w = mode)
 */
xattr:
		.dc.w mec2_opcode,0x0d
		rts

/*
 * long xfs_attrib(a0 = DD *, a1 = char *name, d0.w = rwflag, d1.w = attrib)
 */
attrib:
		.dc.w mec2_opcode,0x0e
		rts

/*
 * long xfs_chown(a0 = DD *, a1 = char *name, d0.w = uid, d1.w = gid)
 */
chown:
		.dc.w mec2_opcode,0x0f
		rts

/*
 * long xfs_chmod(a0 = DD *, a1 = char *name, d0.w = mode)
 */
chmod:
		.dc.w mec2_opcode,0x10
		rts

/*
 * long xfs_dcreate(a0 = DD *, a1 = char *name, d0.w = mode)
 */
dcreate:
		.dc.w mec2_opcode,0x11
		rts

/*
 * long xfs_ddelete(a0 = DD *)
 */
ddelete:
		.dc.w mec2_opcode,0x12
		rts

/*
 * long xfs_DD2name(a0 = DD *, a1 = char *name, d0.w = size)
 */
DD2name:
		.dc.w mec2_opcode,0x13
		rts

/*
 * long xfs_dopendir(a0 = DD *dd, d0.w = tosflag)
 */
dopendir:
		.dc.w mec2_opcode,0x14
		rts

/*
 * long xfs_dreaddir(a0 = DD *, d0.w = size, a1 = buf, d1.l = XATTR *xattr, d2.l = long *)
 */
dreaddir:
		.dc.w mec2_opcode,0x15
		rts

/*
 * long xfs_drewinddir(a0 = DD *)
 */
drewinddir:
		.dc.w mec2_opcode,0x16
		rts

/*
 * long xfs_dclosedir(a0 = DD *)
 */
dclosedir:
		.dc.w mec2_opcode,0x17
		rts

/*
 * long xfs_dpathconf(a0 = dd *, d0.w = which)
 */
dpathconf:
		.dc.w mec2_opcode,0x18
		rts

/*
 * long xfs_dfree(a0 = DD *, a1 = DISKINFO *)
 */
dfree:
		.dc.w mec2_opcode,0x19
		rts

/*
 * long xfs_wlabel(a0 = DD *, a1 = char *name)
 */
wlabel:
		.dc.w mec2_opcode,0x1a
		rts

/*
 * long xfs_rlabel(a0 = DD *, d1 = char *buf, d0.w = len)
 */
rlabel:
		.dc.w mec2_opcode,0x1b
		rts

/*
 * long xfs_symlink(a0 = DD *, a1 = char *from, d0.l = char *to)
 */
symlink:
		.dc.w mec2_opcode,0x1c
		rts

/*
 * long xfs_readlink(a0 = DD *, a1 = char *name, d0.l = char *buf, d1.w = size)
 */
readlink:
		.dc.w mec2_opcode,0x1d
		rts

/*
 * long xfs_dcntl(a0 = DD *, a1 = char *name, d0.w = cmd, d1.l = arg)
 */
dcntl:
		.dc.w mec2_opcode,0x1e
		rts

/*
 * long dev_close(FD *f)
 */
dev_close:
		.dc.w mec2_opcode,0x28
		rts

/*
 * long dev_read(a0 = FD *, d0.l = count, a1 = buf)
 */
dev_read:
		.dc.w mec2_opcode,0x29
		rts

/*
 * long dev_write(a0 = FD *, d0.l = count, a1 = buf)
 */
dev_write:
		.dc.w mec2_opcode,0x2a
		rts

/*
 * long dev_stat(a0 = FD *, a1 = unsel, d0.w = rwflag, d1.l = apcode)
 */
dev_stat:
		.dc.w mec2_opcode,0x2b
		rts

/*
 * long dev_seek(a0 = FD *, d0.l = pos, d1.w = whence)
 */
dev_seek:
		.dc.w mec2_opcode,0x2c
		rts

/*
 * long dev_datime(a0 = FD *, a1 = short *time, d0.w = rwflag)
 */
dev_datime:
		.dc.w mec2_opcode,0x2d
		rts

/*
 * long dev_ioctl(a0 = FD *, d0.w = cmd, a1 = buf)
 */
dev_ioctl:
		.dc.w mec2_opcode,0x2e
		rts

	.dc.w 0x23f9
	.dc.b "XFS2.O",0,"."

	.data

kernel: .dc.l 0
