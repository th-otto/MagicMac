*******
* cstart module for use within AUTO-folder programs & ACC's:
* - no argc, argv setup
* - no environment
* - just shrink memory and start main
*

				.globl _main
				.globl	_app
                .globl   errno
				
                .globl   __text
                .globl   __data
                .globl   __bss
                
Mshrink         equ     $4a
Pterm           equ     $4c

* Base page structure

TpaStart        equ 0
TpaEnd          equ 4
TextSegStart    equ 8
TextSegSize     equ 12
DataSegStart    equ 16
DataSegSize     equ 20
BssSegStart     equ 24
BssSegSize      equ 28
DtaPtr          equ 32
PntPrcPtr       equ 36
Reserved0       equ 40
EnvStrPtr       equ 44
CmdLine         equ 128
BasePageSize    equ 256


                .text

******** Tc startup code


__text:
TcStart:        move.l  a7,a4
* Setup longword aligned application stack
                move.l  #stackend,a7
                move.l  a0,a3
                move.l  a3,d0
                bne     acc
                move.l  4(a4),a4
                move.l  EnvStrPtr(a4),envptr
                lea     CmdLine(a4),a3
                move.l  a3,cmdline
                move.l  BssSegStart(a4),d2
                add.l   BssSegSize(a4),d2
                move.l  d2,pgmend
                sub.l   a4,d2
* Free not required memory
                move.l  d2,-(a7)
                move.l  a4,-(a7)
                clr.w   -(a7)
                move.w  #Mshrink,-(a7)
                trap    #1
                adda.l  #12,a7
                moveq.l #1,d0
                bra     app
acc:            clr.w   d0
app:            move.w  d0,_app
                

                jsr     _main

******** exit ***********************************************************
*
* Terminate program
*
* Entry parameters:
*   <D0.W> = Termination status : Integer
* Return parameters:
*   Never returns

exit:           move.w  d0,4(a7)
				tst.l   (a7)+
                move.w  #Pterm,-(a7)
                trap    #1

                .data
                
__data:
errno:          .dc.l    0
unused: dc.l 0

				.bss
__bss:
pgmend:         .ds.l 1
envptr:         .ds.l 1
cmdline:        .ds.l 1
_app:			.ds.w	1

stack:			.ds.l 1024
stackend:		.ds.l 1
