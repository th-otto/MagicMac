/*
 *
 * Assembler-Part of the device interface
 * Developed using PASM.
 *
 * (C) Andreas Kromke 1997
 * (C) Thorsten Otto 2018
 *
 */

     INCLUDE "mgx_xfs.inc"

/*
 * The interface between the XFS the C-Part.
 * All parameters are passed on the stack.
 * Note that this still expect compilers
 * to use short (16-bit) ints.
 */

     XREF cdecl_hostdev	; C-Part of file driver
     XDEF hostdev		; MagiC part of file driver


	 TEXT

hostdev:
 DC.L     hostdev_close
 DC.L     hostdev_read
 DC.L     hostdev_write
 DC.L     hostdev_stat
 DC.L     hostdev_seek
 DC.L     hostdev_datime
 DC.L     hostdev_ioctl
 DC.L     hostdev_getc
 DC.L     hostdev_getline
 DC.L     hostdev_putc


/**********************************************************************
 **********************************************************************
 *
 * Dateitreiber
 *
 **********************************************************************
 */


/**********************************************************************
 *
 * long dev_close(a0 = FD *file)
 *
 * schreibt alles zur…k, ruft den Dateitreiber auf und gibt ggf.
 * den FD frei.
 */

hostdev_close:
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_close(pc),a0
 jsr      (a0)
 addq.l   #4,sp
 rts


/**********************************************************************
 *
 * long dev_read(a0 = FD *file, d0 = long count, a1 = char *buffer)
 */

hostdev_read:
 move.l	a1,-(sp)
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostdev+dev_read(pc),a0
 jsr      (a0)
 adda.w	#12,sp
 rts


/**********************************************************************
 *
 * long dev_write(a0 = FD *file, d0 = long count, a1 = char *buffer)
 */

hostdev_write:
 move.l	a1,-(sp)
 move.l	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostdev+dev_write(pc),a0
 jsr      (a0)
 adda.w	#12,sp
 rts


/**********************************************************************
 *
 * long dev_stat(a0 = FD *f, a1 = long *unselect,
 *                  d0 = int rwflag, d1 = long apcode)
 */

hostdev_stat:
 move.l   d1,-(sp)                 ; apcode
 move.w   d0,-(sp)                 ; rwflag
 move.l   a1,-(sp)                 ; unsel
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_stat(pc),a0
 jsr      (a0)
 lea      14(sp),sp
 rts


/**********************************************************************
 *
 * long dev_seek(a0 = FD *f,  d0 = long where, d1 = int mode)
 */

hostdev_seek:
 move.w   d1,-(sp)                 ; mode
 move.l   d0,-(sp)                 ; where
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_seek(pc),a0
 jsr      (a0)
 lea      10(sp),sp
 rts


/**********************************************************************
 *
 * long dev_ioctl(a0 = FD *f,  d0 = int cmd, a1 = void *buf)
 */

hostdev_ioctl:
 move.l   a1,-(sp)                 ; buf
 move.w   d0,-(sp)                 ; cmd
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_ioctl(pc),a0
 jsr      (a0)
 lea      10(sp),sp
 rts


/**********************************************************************
 *
 * long dev_datime(a0 = FD *file, a1 = int d[2], d0 = int set)
 */

hostdev_datime:
 move.w   d0,-(sp)                 ; set
 move.l   a1,-(sp)                 ; d
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_datime(pc),a0
 jsr      (a0)
 lea      10(sp),sp
 rts


/**********************************************************************
 *
 * long dev_getc( a0 = FD *f, d0 = int mode )
 *
 * mode & 0x0001:    cooked
 * mode & 0x0002:    echo mode
 *
 * R…kgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
 *           0x0000FF1A bei EOF
 */

hostdev_getc:
 move.w	d0,-(sp)
 move.l	a0,-(sp)
 move.l	cdecl_hostdev+dev_getc(pc),a0
 jsr      (a0)
 addq.l	#6,sp
 rts


/**********************************************************************
 *
 * long dev_getline( a0 = FD *f, a1 = char *buf, d0 = int mode, d1 = long size )
 *
 * mode & 0x0001:    cooked
 * mode & 0x0002:    echo mode
 *
 * R…kgabe: Anzahl gelesener Bytes oder Fehlercode
 */

hostdev_getline:
 move.l   d1,-(sp)                 ; size
 move.w   d0,-(sp)                 ; mode
 move.l   a1,-(sp)                 ; buf
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_getline(pc),a0
 jsr      (a0)
 lea      14(sp),sp
 rts


/**********************************************************************
 *
 * long dev_putc( a0 = FD *f, d0 = int mode, d1 = long value )
 *
 * mode & 0x0001:    cooked
 *
 * R…kgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
 */

hostdev_putc:
 move.l   d1,-(sp)                 ; val
 move.w   d0,-(sp)                 ; mode
 move.l   a0,-(sp)                 ; FD
 move.l	cdecl_hostdev+dev_putc(pc),a0
 jsr      (a0)
 lea      10(sp),sp
 rts


