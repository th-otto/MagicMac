	include	"mgx_xfs.inc"


XFS_SYNC                equ 0x01
XFS_PTERM               equ 0x02
XFS_GARBCOLL            equ 0x03 /* not implemented in MagiCPC */
XFS_FREEDD              equ 0x04
XFS_DRV_OPEN            equ 0x05
XFS_DRV_CLOSE           equ 0x06
XFS_PATH2DD             equ 0x07
XFS_SFIRST              equ 0x08
XFS_SNEXT               equ 0x09
XFS_FOPEN               equ 0x0a
XFS_DELETE              equ 0x0b
XFS_LINK                equ 0x0c
XFS_XATTR               equ 0x0d
XFS_ATTRIB              equ 0x0e
XFS_CHOWN               equ 0x0f
XFS_CHMOD               equ 0x10
XFS_DCREATE             equ 0x11
XFS_DDELETE             equ 0x12
XFS_DD2NAME             equ 0x13
XFS_DOPENDIR            equ 0x14
XFS_DREADDIR            equ 0x15
XFS_DREWINDDIR          equ 0x16
XFS_DCLOSEDIR           equ 0x17
XFS_DPATHCONF           equ 0x18
XFS_DFREE               equ 0x19
XFS_WLABEL              equ 0x1a
XFS_RLABEL              equ 0x1b
XFS_SYMLINK             equ 0x1c
XFS_READLINK            equ 0x1d
XFS_DCNTL               equ 0x1e
XFS_MEMPOOL_GET         equ 0x20
XFS_MEMPOOL_SET         equ 0x21
XFS_PC_GETSIZE          equ 0x24
XFS_PC_LOAD             equ 0x25
XFS_DEV_CLOSE           equ 0x28
XFS_DEV_READ            equ 0x29
XFS_DEV_WRITE           equ 0x2a
XFS_DEV_STAT            equ 0x2b
XFS_DEV_SEEK            equ 0x2c
XFS_DEV_DATIME          equ 0x2d
XFS_DEV_IOCTL           equ 0x2e
XFS_DDEV_SER_OPEN       equ 0x3c
XFS_DDEV_SER_CLOSE      equ 0x3d
XFS_DDEV_SER_READ       equ 0x3e
XFS_DDEV_SER_WRITE      equ 0x3f
XFS_DDEV_SER_STAT       equ 0x40
XFS_DDEV_SER_SEEK       equ 0x41
XFS_DDEV_SER_DATIME     equ 0x42
XFS_DDEV_SER_IOCTL      equ 0x43
XFS_DDEV_SER_DELETE     equ 0x44
XFS_DDEV_SER_GETC       equ 0x45
XFS_DDEV_SER_GETLINE    equ 0x46
XFS_DDEV_SER_PUTC       equ 0x47
XFS_DDEV_SER_CONINSTAT  equ 0x48
XFS_DDEV_SER_CONIN      equ 0x49
XFS_DDEV_SER_CONOUTSTAT equ 0x4a
XFS_DDEV_SER_CONOUT     equ 0x4b
XFS_DDEV_SER_RSCONF     equ 0x4c

mec2_opcode equ 0x45bf
p_cookie = 0x5a0

		xref vt52_printf
 
		.text

start:
		pea.l      install_cookie(pc)
		move.w     #38,-(a7) ; Supexec
		trap       #14
		addq.l     #6,a7
		lea        mpc_info(pc),a0
		dc.w mec2_opcode,XFS_MEMPOOL_GET
		move.l     d0,d7
		move.l     d0,-(a7)
		move.w     #72,-(a7) ; Malloc
		trap       #1
		addq.l     #6,a7
		tst.l      d0
		ble.s      start1
		movea.l    d0,a0
		move.l     d7,d0
		dc.w mec2_opcode,XFS_MEMPOOL_SET
		bsr.s      install_xfs
start1:
		moveq.l    #1,d0
		rts

mpc_info:
	dc.w 0x0030
	dc.w 0x0596
	dc.l 0x10000
	dc.l mpc_xfs
	dc.l mpc_dev

install_xfs:
		pea        mpc_xfs(pc)
		clr.l      -(a7)
		move.w     #KER_INSTXFS,-(a7)
		move.w     #0x0130,-(a7) ; Dcntl
		trap       #1
		adda.w     #12,a7
		move.l     d0,kernel
		rts

init_xfs2:
		pea.l      copyright_msg(pc)
		move.w     #9,-(a7)
		trap       #1
		addq.l     #6,a7
		moveq.l    #1,d0
		rts

copyright_msg:
	dc.b "XFS_PC.LDR Version 1.00, (c) 1996 by F.Schmerbeck",13,10,0
	.even

install_cookie:
		move.l     p_cookie.l,d0
		beq.s      install_cookie3
		movea.l    d0,a0
		moveq.l    #0,d0
		bra.s      install_cookie2
install_cookie1:
		addq.w     #1,d0
		addq.l     #8,a0
install_cookie2:
		tst.l      (a0)
		bne.s      install_cookie1
		addq.w     #2,d0
		cmp.w      6(a0),d0
		bge.s      install_cookie3
		move.l     (a0),8(a0)
		move.l     4(a0),12(a0)
		move.l     #'MgPC',(a0)
		clr.l      4(a0)
install_cookie3:
		rts

mpc_xfs:
		dc.b 'MPC_XFS '
		dc.l 0 ; next
		dc.l 0 ; flags
		dc.l mpc_init
		dc.l mpc_sync
		dc.l mpc_pterm
		dc.l mpc_garbcoll
		dc.l mpc_freeDD
		dc.l mpc_drv_open
		dc.l mpc_drv_close
		dc.l mpc_path2DD
		dc.l mpc_sfirst
		dc.l mpc_snext
		dc.l mpc_fopen
		dc.l mpc_fdelete
		dc.l mpc_link
		dc.l mpc_xattr
		dc.l mpc_attrib
		dc.l mpc_chown
		dc.l mpc_chmod
		dc.l mpc_dcreate
		dc.l mpc_ddelete
		dc.l mpc_DD2name
		dc.l mpc_dopendir
		dc.l mpc_dreaddir
		dc.l mpc_drewinddir
		dc.l mpc_dclosedir
		dc.l mpc_dpathconf
		dc.l mpc_dfree
		dc.l mpc_wlabel
		dc.l mpc_rlabel
		dc.l mpc_symlink
		dc.l mpc_readlink
		dc.l mpc_dcntl

mpc_dev:
		dc.l mpc_dev_close
		dc.l mpc_dev_read
		dc.l mpc_dev_write
		dc.l mpc_dev_stat
		dc.l mpc_dev_seek
		dc.l mpc_dev_datime
		dc.l mpc_dev_ioctl
		dc.l 0 ; dev_getc
		dc.l 0 ; dev_getline
		dc.l 0 ; dev_putc

/*
 * long xfs_init(void)
 */
mpc_init:
		moveq.l    #0,d0
		rts

/*
 * long xfs_sync(a0 = DMD *)
 */
mpc_sync:
		dc.w mec2_opcode,XFS_SYNC
		rts

/*
 * long xfs_pterm(a0 = PD *)
 */
mpc_pterm:
		dc.w mec2_opcode,XFS_PTERM
		rts

/*
 * long xfs_garbcoll(a0 = DMD *)
 */
mpc_garbcoll:
		dc.w mec2_opcode,XFS_GARBCOLL
		rts

/*
 * void xfs_freedd(a0 = DD *)
 */
mpc_freeDD:
		dc.w mec2_opcode,XFS_FREEDD
		rts

/*
 * long xfs_drv_open(a0 = DMD *)
 */
mpc_drv_open:
		dc.w mec2_opcode,XFS_DRV_OPEN
		cmpi.w     #1,d0
		bne.s      mpc_drv_open1
		movea.l    kernel(pc),a1
		movea.l    mxk_ker_proc_info(a1),a1 ; WTF? thats nonsense
		jsr        (a1)
		moveq.l    #0,d0
mpc_drv_open1:
		rts

/*
 * long xfs_drv_close(a0 = DMD *, d0.w = mode)
 */
mpc_drv_close:
		dc.w mec2_opcode,XFS_DRV_CLOSE
		rts

/*
 * xfs_path2DD(a0 = DD *reldir, d0.w = mode, a1 = char *pathname)
 */
mpc_path2DD:
		dc.w mec2_opcode,XFS_PATH2DD
		rts

/*
 * long xfs_sfirst(a0 = DD *, a1 = char *name, d0.l = DTA *, d1.w = attrib)
 */
mpc_sfirst:
		dc.w mec2_opcode,XFS_SFIRST
		rts

/*
 * long xfs_snext(a0 = DTA *, a1 = DMD *)
 */
mpc_snext:
		dc.w mec2_opcode,XFS_SNEXT
		rts

/*
 * long xfs_fopen(a0 = DD *, a1 = char *name, d0.w = mode, d1.w = attrib)
 */
mpc_fopen:
		dc.w mec2_opcode,XFS_FOPEN
		rts

/*
 * long xfs_fdelete(a0 = DD *, a1 = char *name)
 */
mpc_fdelete:
		dc.w mec2_opcode,XFS_DELETE
		rts

/*
 * long xfs_link(a0 = DD *olddir, a1 = DD *newdir, d0 = char *oldname, d1 = char *newname, d2.w = flag_link)
 */
mpc_link:
		dc.w mec2_opcode,XFS_LINK
		rts

/*
 * long xfs_xattr(a0 = DD *, a1 = char *name, d0 = XATTR *, d1.w = mode)
 */
mpc_xattr:
		dc.w mec2_opcode,XFS_XATTR
		rts

/*
 * long xfs_attrib(a0 = DD *, a1 = char *name, d0.w = rwflag, d1.w = attrib)
 */
mpc_attrib:
		dc.w mec2_opcode,XFS_ATTRIB
		rts

/*
 * long xfs_chown(a0 = DD *, a1 = char *name, d0.w = uid, d1.w = gid)
 */
mpc_chown:
		dc.w mec2_opcode,XFS_CHOWN
		rts

/*
 * long xfs_chmod(a0 = DD *, a1 = char *name, d0.w = mode)
 */
mpc_chmod:
		dc.w mec2_opcode,XFS_CHMOD
		rts

/*
 * long xfs_dcreate(a0 = DD *, a1 = char *name, d0.w = mode)
 */
mpc_dcreate:
		dc.w mec2_opcode,XFS_DCREATE
		rts

/*
 * long xfs_ddelete(a0 = DD *)
 */
mpc_ddelete:
		dc.w mec2_opcode,XFS_DELETE
		rts

/*
 * long xfs_DD2name(a0 = DD *, a1 = char *name, d0.w = size)
 */
mpc_DD2name:
		dc.w mec2_opcode,XFS_DD2NAME
		rts

/*
 * long xfs_dopendir(a0 = DD *dd, d0.w = tosflag)
 */
mpc_dopendir:
		dc.w mec2_opcode,XFS_DOPENDIR
		rts

/*
 * long xfs_dreaddir(a0 = DD *, d0.w = size, a1 = buf, d1.l = XATTR *xattr, d2.l = long *)
 */
mpc_dreaddir:
		dc.w mec2_opcode,XFS_DREADDIR
		rts

/*
 * long xfs_drewinddir(a0 = DD *)
 */
mpc_drewinddir:
		dc.w mec2_opcode,XFS_DREWINDDIR
		rts

/*
 * long xfs_dclosedir(a0 = DD *)
 */
mpc_dclosedir:
		dc.w mec2_opcode,XFS_DCLOSEDIR
		rts

/*
 * long xfs_dpathconf(a0 = dd *, d0.w = which)
 */
mpc_dpathconf:
		dc.w mec2_opcode,XFS_DPATHCONF
		rts

/*
 * long xfs_dfree(a0 = DD *, a1 = DISKINFO *)
 */
mpc_dfree:
		dc.w mec2_opcode,XFS_DFREE
		rts

/*
 * long xfs_wlabel(a0 = DD *, a1 = char *name)
 */
mpc_wlabel:
		dc.w mec2_opcode,XFS_WLABEL
		rts

/*
 * long xfs_rlabel(a0 = DD *, d1 = char *buf, d0.w = len)
 */
mpc_rlabel:
		dc.w mec2_opcode,XFS_RLABEL
		rts

/*
 * long xfs_symlink(a0 = DD *, a1 = char *from, d0.l = char *to)
 */
mpc_symlink:
		dc.w mec2_opcode,XFS_SYMLINK
		rts

/*
 * long xfs_readlink(a0 = DD *, a1 = char *name, d0.l = char *buf, d1.w = size)
 */
mpc_readlink:
		dc.w mec2_opcode,XFS_READLINK
		rts

/*
 * long xfs_dcntl(a0 = DD *, a1 = char *name, d0.w = cmd, d1.l = arg)
 */
mpc_dcntl:
		dc.w mec2_opcode,XFS_DCNTL
		rts

/*
 * long dev_close(FD *f)
 */
mpc_dev_close:
		dc.w mec2_opcode,XFS_DEV_CLOSE
		rts

/*
 * long dev_read(a0 = FD *, d0.l = count, a1 = buf)
 */
mpc_dev_read:
		dc.w mec2_opcode,XFS_DEV_READ
		rts

/*
 * long dev_write(a0 = FD *, d0.l = count, a1 = buf)
 */
mpc_dev_write:
		dc.w mec2_opcode,XFS_DEV_WRITE
		rts

/*
 * long dev_stat(a0 = FD *, a1 = unsel, d0.w = rwflag, d1.l = apcode)
 */
mpc_dev_stat:
		dc.w mec2_opcode,XFS_DEV_STAT
		rts

/*
 * long dev_seek(a0 = FD *, d0.l = pos, d1.w = whence)
 */
mpc_dev_seek:
		dc.w mec2_opcode,XFS_DEV_SEEK
		rts

/*
 * long dev_datime(a0 = FD *, a1 = short *time, d0.w = rwflag)
 */
mpc_dev_datime:
		dc.w mec2_opcode,XFS_DEV_DATIME
		rts

/*
 * long dev_ioctl(a0 = FD *, d0.w = cmd, a1 = buf)
 */
mpc_dev_ioctl:
		dc.w mec2_opcode,XFS_DEV_IOCTL
		rts

	.data

kernel: dc.l 0
