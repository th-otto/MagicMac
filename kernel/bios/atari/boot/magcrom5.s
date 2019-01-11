buserror   equ 8

memvalid       EQU $420
memctrl        EQU $424
resvalid       EQU $426
resvector      EQU $42a
phystop        EQU $42e
memval2        EQU $43a       /* Validates memctrl and memconf if $237698AA */
palmode        EQU $448
sshiftmd       EQU $44c
_v_bas_ad      EQU $44e
____md         EQU $49e
fstrm_beg      EQU ____md
_hz_200        EQU $4ba
_sysbase       EQU $4f2
_shell_p       EQU $4f6
memval3        EQU $51a       /* If $5555AAAA, reset        */
_p_cookies     EQU $5a0
ramtop         EQU $5a4
ramvalid       EQU $5a8

memconf           EQU $ffff8001

VBASE_HIGH        EQU $ffff8201
VBASE_MID         EQU $ffff8203
VBASE_LOW         EQU $ffff820d

M_dma_fifo        EQU $ffff8606           /* Word */

/* MFP */
giread            EQU $ffff8800           /* Selektiertes Register auslesen */
giselect          EQU $ffff8800           /* select Chip-Register anwaehlen */
giwrite           EQU $ffff8802           /* Schreiben in angewaehltes Register */

gpip              EQU $fffffa01           /* GPIP-Data-Register */
aer               EQU $fffffa03           /* Active-Edge-Register */
ddr               EQU $fffffa05           /* data direction register */
iera              EQU $fffffa07           /* Interrupt-Enable-Register A */
ierb              EQU $fffffa09           /* Interrupt-Enable-Register B */
ipra              EQU $fffffa0b           /* Interrupt-Pending-Register A */
iprb              EQU $fffffa0d           /* Interrupt-Pending-Register B */
isra              EQU $fffffa0f           /* Interrupt-In-Service-Register A */
isrb              EQU $fffffa11           /* Interrupt-In-Service-Register B */
imra              EQU $fffffa13           /* Interrupt-Mask-Register A */
imrb              EQU $fffffa15           /* Interrupt-Mask-Register B */
vr                EQU $fffffa17           /* vector register */
tacr              EQU $fffffa19           /* Timer A Control Register */
tbcr              EQU $fffffa1b           /* Timer B Control Register */
tcdcr             EQU $fffffa1d           /* Timer C+D Control Register */
tadr              EQU $fffffa1f           /* Timer A Data Register */
tbdr              EQU $fffffa21           /* Timer B Data Register */
tcdr              EQU $fffffa23           /* Timer C Data Register */
tddr              EQU $fffffa25           /* Timer D Data Register */
scr               EQU $fffffa27           /* Sync.-Character Register */
ucr               EQU $fffffa29           /* USART-Control-Register */
rsr               EQU $fffffa2b           /* Receiver-Status-Register */
tsr               EQU $fffffa2d           /* Transmitter-Status-Register */
udr               EQU $fffffa2f           /* USART-Data-Register */


/* ACIA */
keyctl            EQU $fffffc00           /* ACIA Status Register */
keybd             EQU $fffffc02           /* ACIA Data Register */
midictl           EQU $fffffc04           /* MIDI-ACIA Status Register */
midi              EQU $fffffc06           /* MIDI-ACIA Data Register */

ST_SHIFT          EQU $ffff8260
EXTCLK            EQU $ffff820a

ST_PALETTE        EQU $ffff8240

mste_clk          EQU $fffffc20

vme_mask          EQU $FFFF8E0D
vme_intr          EQU $FFFF8E01

cartbase          EQU  $00fa0000


sizeof_PH      equ 28

BUFSIZE        equ 0x80000
mmutable_ram   equ 0x700 /* CPU root table in memory */
FASTRAM_START  equ 0x01000000
SCREENSIZE     equ 0x8000


		offset 0xf2fc
config_status    equ 0xf2f0
led_counter      equ 0xf2fc
cpu_type         equ 0xf2fe /* unused */
new_phystop      equ 0xf300
altram_new       equ 0xf304
clocktype        equ 0xf34e
fastramsize      equ 0xf360
cursor_y         equ 0xf364
cursor_x         equ 0xf366
lastpress        equ 0xf368
hd_pause_timer   equ 0xf36c
hd_pause_stop    equ 0xf36e
timer_sieve      equ 0xf370
logo_counter     equ 0xf374
timer_c_value    equ 0xf378
timer_c_counter  equ 0xf37a
lastkey          equ 0xf37c
fastram_on       equ 0xf380
real_ramtop      equ 0xf382
real_phystop     equ 0xf386


        .TEXT
     	.SUPER

start:
        move.w  #6,hddelay
        movea.l 4(a7),a6
        bsr     copy_version
        lea     title_msg,a0
        bsr     cconws
        lea     stack,a7
        movea.l a7,a0
        suba.l  #start,a0
        adda.l  #BUFSIZE+256,a0
        move.l  a0,-(a7)
        move.l  a6,-(a7)
        clr.w   -(a7)
        move.w  #$004A,-(a7)    /* Mshrink */
        trap    #1
        adda.w  #12,a7
        tst.l   d0
        bpl.s   mem_ok
        lea     memerror_msg,a0
        bra     errexit

all_done:
        bsr     set_boot_pref_magic
        lea     nvram_msg,a0
        bsr     cconws
wait_key:
        lea     key_msg,a0
        bsr     cconws
        move.w  #1,-(a7)        /* Cconin */
        trap    #1
        addq.l  #2,a7
exit:
        clr.w   -(a7)           /* Pterm0 */
        trap    #1

mem_ok:
        clr.l   -(a7)
        move.w  #$0020,-(a7)    /* Super */
        trap    #1
        movea.l _p_cookies,a0
        beq.s   cookieend
cookieloop:
        move.l  (a0)+,d0
        beq.s   cookieend
        move.l  (a0)+,d1
        cmp.l   #$5F4D4348,d0   /* '_MCH' */
        bne.s   cookieloop
        move.l  d1,machine
        bra.s   cookieloop
cookieend:

        lea     128(a6),a6      /* a6 = command line */
        lea     buffer(pc),a0
        move.b  #0,(a0)
        move.b  (a6)+,d0        /* BUG: d0 not cleared; BUG: ARGV not handled */
copycmd:
        move.b  (a6)+,(a0)+
        dbf     d0,copycmd
        move.b  #0,-(a0)
        bsr     find_magic_ram
        bmi     errexit
        move.l  #$00FC0000,tosstart
        lea     buffer(pc),a6
        tst.b   (a6)
        beq     cmdline_done
scan_cmdline:
        move.b  (a6)+,d1
        beq     cmdline_done
        cmp.b   #' ',d1
        beq.s   scan_cmdline
        or.b    #$20,d1
        cmp.b   #'p',d1
        beq.s   set_hddelay
        cmp.b   #'a',d1
        beq.s   set_altram
        cmp.b   #'r',d1
        beq.s   set_reloc
        cmp.b   #'k',d1
        beq.s   set_coldboot
        cmp.b   #'t',d1
        beq.s   set_testmode
        cmp.b   #'b',d1
        beq.s   set_led
        bra.s   scan_cmdline

set_testmode:
        move.l  phystop,testmode_phystop
        move.l  romsize,d0
        sub.l   d0,testmode_phystop
        move.l  testmode_phystop,tosstart
        move.w  #2,eprom_type
        move.b  #'0',eprom_addr_msg
        move.b  #'0',eprom_addr_msg+1
        bra.s   cmdline_done

set_reloc:
        bsr     scan_reloc
        beq.s   cmdline_done
        bra     scan_cmdline

set_hddelay:
        bsr     scan_hddelay
        beq.s   cmdline_done
        bra     scan_cmdline

set_altram:
        bsr     scan_altram
        beq.s   cmdline_done
        bra     scan_cmdline

set_coldboot:
        bsr     scan_coldboot
        bra     scan_cmdline

set_led:
        move.w  #-1,led_blink
        bra     scan_cmdline


cmdline_done:
        bsr     copy_version
        cmpi.w  #4,eprom_type
        bne.s   no_double
        bsr     load_tos_img
        beq     errexit
no_double:
        cmpi.l  #$00030000,romsize
        beq.s   double_ok
        lea     magix_too_large_err,a0
        tst.w   eprom_type
        beq     errexit
        cmpi.w  #1,eprom_type
        beq     errexit
        lea     too_larg_for_double_err,a0
        cmpi.w  #4,eprom_type
        bne.s   double_ok
        cmpi.l  #$00040000,tos_img_size
        bhi     errexit
double_ok:
        lea     eprom_msg(pc),a0
        bsr     cconws
        lea     reset_msg,a0
        bsr     cconws
        lea     buffer,a6
        move.l  a6,d0
        move.l  d0,eprom1_buffer
        add.l   #$00020000,d0
        move.l  d0,eprom2_buffer
        add.l   #$00020000,d0
        move.l  d0,rom_buffer
        pea     (a6)
        move.l  #$00040000,-(a7)
        move.w  magic_fd,-(a7)
        move.w  #$003F,-(a7)    /* Fread */
        trap    #1
        adda.w  #12,a7
        move.l  d0,d6
        move.w  magic_fd,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.w  #4,a7
        tst.l   d0
        bmi     exit
        cmpi.w  #$601A,(a6)
        bne     exit
        movea.l sizeof_PH+20(a6),a0 /* offset to gem_mupb */
        lea     sizeof_PH(a6,a0.l),a0
        cmpi.l  #$87654321,(a0)+
        bne     exit
        addq.l  #8,a0
        cmpi.l  #$4D414758,(a0)    /* 'MAGX' */
        bne     exit
        lea     sizeof_PH(a6),a1
        lea     $7D00(a1),a2
        move.b  1(a1),d0           /* get branch offset of syshdr */
        ext.w   d0
        lea     6(a1,d0.w),a1
        cmpi.w  #$4E70,(a1)        /* reset? */
        bne.s   no_reset_inst
        move.w  #$4E71,(a1)+       /* -> nop */
no_reset_inst:

/*
 * patch out the test for resvalid in keyb.s/warmb_03
 * why???
 */
        sf      d1
warmb_scan:
        movea.l a1,a0
        cmpi.l  #$31415926,(a0)+
        bne.s   warmb_next
        cmpi.w  #resvalid,(a0)+
        bne.s   warmb_next
        move.b  #0x60,(a0)         /* change bne -> bra */
        bra.s   warmb_done
warmb_next:
        addq.l  #2,a1
        cmpa.l  a2,a1
        bcs.s   warmb_scan
warmb_done:

/*
 * set version to 0x300 for TT
 */
        cmpi.l  #$00020000,machine
        bcs.s   not_tt
        move.w  #$0300,sizeof_PH+2(a6)
not_tt:


start_of_magic_rom equ fstrm_beg /* WTF */

/*
 * relocate magic.ram
 */
        move.l  2(a6),d0       /* length of text segment */
        add.l   6(a6),d0       /* length of data segment */
        move.l  d0,d5
        movea.l tosstart,a5
        adda.l  romsize,a5
        suba.w  #$0100,a5
        suba.l  d5,a5
        move.l  a5,start_of_magic_rom
        add.l   14(a6),d0      /* length of symbol table */
        lea     sizeof_PH(a6,d0.l),a3
        lea     0(a6,d6.l),a2
        cmpa.l  a2,a3
        bcc.s   relocdone
        lea     sizeof_PH(a6),a0
        move.l  (a3)+,d0       /* get first reloc offset FIXME: check for zero */
reloc1:
        adda.l  d0,a0
        move.l  a5,d0
        add.l   d0,(a0)
reloc2:
        cmpa.l  a2,a3
        bhi.s   relocdone
        moveq   #0,d0
        move.b  (a3)+,d0
        beq.s   relocdone
        cmpi.b  #1,d0
        bne.s   reloc1
        lea     254(a0),a0
        bra.s   reloc2
relocdone:

/*
 * save a copy of the ROM header
 */
        move.w  #24-1,d0
        lea     sizeof_PH(a6),a0
        lea     romhdr,a1
copyhdr:
        move.w  (a0)+,(a1)+
        dbf     d0,copyhdr

        bsr     search_magic_version

/*
 * adjust addresses in copy
 * FIXME: gem_magics is not adjusted
 */
        lea     romhdr,a0
        move.l  tosstart,4(a0)
        addi.l  #$00000030,4(a0)
        move.l  tosstart,8(a0)
        move.l  tosstart,16(a0)
        addi.l  #$00000030,16(a0)
        cmpi.w  #$1995,26(a0)
        bcc.s   no_magic4
        move.l  #$6000FFC6,$004C(a6)
        move.l  tosstart,d0
        add.l   #$00000034,d0
        move.l  d0,resetcode+2
no_magic4:


/*
 * initialize 256k of ROM buffer
 */
        movea.l rom_buffer,a0
        move.w  #-1,d0
initloop1:
        move.l  #$FFFFFFFF,(a0)+
        dbf     d0,initloop1

/*
 * copy file to end of rom_buffer
 */
        move.l  romsize,d1
        sub.l   #$00000100,d1
        sub.l   d5,d1
        add.l   rom_buffer,d1
        movea.l d1,a0
        subq.l  #8,a0
        lea     resetcode,a1
        move.l  (a1)+,(a0)+
        move.l  (a1)+,(a0)+
        lea     sizeof_PH(a6),a1
        move.l  romsize,d0
        sub.l   #$00000100,d0
        add.l   rom_buffer,d0
copyloop1:
        move.w  (a1)+,(a0)+
        cmpa.l  d0,a0
        bne.s   copyloop1

        add.l   start_of_magic_rom,d5
        move.l  d5,end_of_magic_rom
        move.b  memconf,old_memconf
        move.l  a5,rom_start_of_magic_rom
        move.w  palmode,old_palmode


/*
 * copy our code to start of rom_buffer
 */
        lea     start_of_romcode,a0
        movea.l rom_buffer,a1
        move.l  #end_of_romcode,d0
copyloop2:
        move.w  (a0)+,(a1)+
        cmp.l   a0,d0
        bne.s   copyloop2

        cmpi.w  #4,eprom_type
        beq.s   update_img
        move.w  #0,-(a7)
        pea     magixrom_img_name
        move.w  #$003C,-(a7)    /* Fcreate */
        trap    #1
        addq.l  #8,a7
        tst.w   d0
        bmi     exit
        move.w  d0,d5
        move.l  #$00030000,d7
        tst.w   eprom_type
        beq.s   write_image
        move.l  #$00040000,d7
        bra.s   write_image

update_img:
        move.w  #1,-(a7)
        pea     magixrom_img_name
        move.w  #$003D,-(a7)    /* Fopen */
        trap    #1
        addq.l  #8,a7
        lea     error_0_msg,a0
        tst.w   d0
        bmi     errexit
        move.w  d0,d5
        move.w  #2,-(a7)
        move.w  d5,-(a7)
        move.l  #0,-(a7)
        move.w  #$0042,-(a7)    /* Fseek */
        trap    #1
        lea     10(a7),a7
        lea     error_1_msg,a0
        move.l  #BUFSIZE,d1
        sub.l   romsize,d1
        cmp.l   d1,d0
        bne     errexit
        move.l  romsize,d7

write_image:
        move.l  rom_buffer,-(a7)
        move.l  d7,-(a7)
        move.w  d5,-(a7)
        move.w  #$0040,-(a7)    /* Fwrite */
        trap    #1
        lea     12(a7),a7
        cmp.l   d7,d0
        bne     exit
        move.w  d5,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.l  #4,a7

        tst.l   testmode_phystop
        bne     dotest
        bsr     write_romimage
        cmpi.w  #4,eprom_type
        beq     write_image7
        movea.l eprom1_buffer,a0
        move.w  #-1,d0
write_image1:
        move.l  #$FFFFFFFF,(a0)+
        dbf     d0,write_image1
        movea.l rom_buffer,a3
        cmpi.w  #3,eprom_type
        beq.s   write_image4
        move.w  #$3FFF,d4
        move.w  #2,d5
        tst.w   eprom_type
        beq.s   write_image2
        move.w  #-1,d4
        clr.w   d5
        cmpi.w  #2,eprom_type
        bne.s   write_image2
        move.w  #$6530,eprom_filename+4 /* 'e0' */
write_image2:
        movea.l eprom1_buffer,a0
        movea.l eprom2_buffer,a1
        move.w  d4,d0
write_image3:
        move.b  (a3)+,(a0)+
        move.b  (a3)+,(a1)+
        move.b  (a3)+,(a0)+
        move.b  (a3)+,(a1)+
        dbf     d0,write_image3
        movea.l eprom1_buffer,a2
        bsr     write_rom
        movea.l eprom2_buffer,a2
        bsr     write_rom
        addq.b  #1,eprom_filename+5
        dbf     d5,write_image2
        bra     write_image7
write_image4:
        move.l  #$65306865,eprom_filename+4 /* 'e0he' */
        move.w  #-1,d4
        movea.l eprom1_buffer,a1
        movea.l eprom2_buffer,a2
        movea.l rom_buffer,a0
write_image5:
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        dbf     d4,write_image5
        movea.l eprom1_buffer,a2
        bsr     write_rom
        movea.l eprom2_buffer,a2
        bsr     write_rom
        move.l  #$65306C65,eprom_filename+4 /* 'e0le' */
        move.w  #-1,d4
        movea.l eprom1_buffer,a1
        movea.l eprom2_buffer,a2
        movea.l rom_buffer,a0
        lea     2(a0),a0
write_image6:
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        dbf     d4,write_image6
        movea.l eprom1_buffer,a2
        bsr     write_rom
        movea.l eprom2_buffer,a2
        bsr     write_rom
write_image7:
        lea     key_msg,a0
        bra     all_done

dotest:
        lea     testmode_msg,a0
        bsr     cconws
        move.w  #1,-(a7)        /* Cconin */
        trap    #1
        addq.l  #2,a7
        move    #$2700,sr
        movea.l testmode_phystop,a5
        movea.l rom_buffer,a6
        move.l  a5,d0
        add.l   romsize,d0
        subq.l  #4,d0
dotest1:
        move.l  (a6)+,(a5)+
        cmpa.l  d0,a5
        bcs.s   dotest1
        clr.l   memvalid
        movea.l testmode_phystop,a0
        jmp     (a0)

find_magic_ram:
        movem.l a6,-(a7)
        move.w  #-1,magic_fd
        move.l  #$00030000,romsize
        lea     magic_ram_path(pc),a6
        bsr     findfile
        bpl.s   magic_found
        lea     magic_ram_path+3(pc),a6
        bsr     findfile
        bpl.s   magic_found
        move.b  #'x',magic_name_x
        lea     magix_ram_path(pc),a6
        bsr     findfile
        bpl.s   magic_found
        lea     magix_ram_path+3(pc),a6
        bsr     findfile
        bpl.s   magic_found
find_magic_end:
        movem.l (a7)+,a6
        lea     magix_not_found_err,a0
        tst.w   magic_fd
        rts
magic_found:
        move.w  #$002F,-(a7)    /* Fgetdta */
        trap    #1
        addq.l  #2,a7
        movea.l d0,a0
        move.l  26(a0),d0
        cmp.l   #$0002C000,d0
        bcs.s   magic_found1
        move.l  #$00040000,romsize
magic_found1:
        clr.w   -(a7)
        move.l  a6,-(a7)
        move.w  #$003D,-(a7)    /* Fopen */
        trap    #1
        addq.l  #8,a7
        move.w  d0,magic_fd
        bra.s   find_magic_end

findfile:
        move.w  #$0017,-(a7)
        move.l  a6,-(a7)
        move.w  #$004E,-(a7)    /* Fsfirst */
        trap    #1
        addq.l  #8,a7
        move.l  d0,d7
        rts

write_rom:
        move.l  #$00008000,d0
        move.l  #$2E303332,eprom_filename+8 /* '.032' */
        tst.w   eprom_type
        beq.s   write_rom1
        move.l  #$00020000,d0
        move.l  #$2E313238,eprom_filename+8 /* '.128' */
        cmpi.w  #3,eprom_type
        bne.s   write_rom1
        move.l  #$00010000,d0
        move.l  #$2E303634,eprom_filename+8 /* '.064' */
write_rom1:
        move.l  d0,-(a7)
        move.w  #0,-(a7)
        pea     eprom_filename
        move.w  #$003C,-(a7)    /* Fcreate */
        trap    #1
        addq.l  #8,a7
        tst.w   d0
        bmi.s   write_rom2
        move.w  d0,d1
        move.l  (a7),d0
        move.l  a2,-(a7)
        move.l  d0,-(a7)
        move.w  d1,-(a7)
        move.w  #$0040,-(a7)    /* Fwrite */
        trap    #1
        lea     12(a7),a7
        cmp.l   (a7)+,d0
        bne.s   write_rom2
        move.w  d1,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.l  #4,a7
write_rom2:
        cmpi.b  #'e',eprom_filename+7
        bne.s   write_rom3
        move.b  #'o',eprom_filename+7
        rts
write_rom3:
        move.b  #'e',eprom_filename+7
        rts

write_romimage:
        movem.l d0-d7/a0-a6,-(a7)
        tst.l   tos_img_size
        beq     splitend
        move.l  #BUFSIZE,d0
        bsr     malloc
        tst.l   d0
        ble     splitend
        move.l  d0,img_buffer
        lea     magixrom_img_name(pc),a0
        movea.l img_buffer(pc),a1
        move.l  #BUFSIZE,d0
        bsr     loadimg
        tst.l   d0
        beq     split3
        move.l  d0,img_size
        lea     crc_msg(pc),a0
        bsr     cconws
        move.l  tos_img_size(pc),d6
        moveq   #$20,d7
        cmpi.l  #BUFSIZE,d6
        beq.s   calccrc1
        moveq   #$10,d7
calccrc1:
        lsr.l   #2,d7
        sub.l   d7,d6
        lsr.l   #1,d7
        movea.l d7,a3
        move.l  a3,d0
        moveq   #0,d1
calccrc2:
        lsr.w   #1,d0
        beq.s   calccrc3
        addq.l  #1,d1
        bra.s   calccrc2
calccrc3:
        lsr.l   d1,d6
        movea.l d6,a4
        movea.l img_buffer(pc),a2
        lea     rom_crc_table(pc),a1
        cmpa.w  #1,a3
        bhi.s   calccrc6
calccrc4:
        movea.l a2,a0
        move.l  a4,d2
        moveq   #0,d0
        moveq   #0,d1
calccrc5:
        move.b  (a0),d3
        adda.l  a3,a0
        eor.b   d3,d1
        add.w   d1,d1
        lea     0(a1,d1.w),a5
        moveq   #0,d1
        move.b  (a5)+,d1
        eor.b   d0,d1
        move.b  (a5),d0
        subq.l  #1,d2
        bne.s   calccrc5
        move.b  d0,0(a0,a3.l)
        move.b  d1,(a0)
        addq.l  #1,a2
        subq.l  #1,d7
        bne.s   calccrc4
        bra.s   calccrc_done
calccrc6:
        subq.l  #2,a3
calccrc7:
        movea.l a2,a0
        moveq   #0,d0
        moveq   #0,d1
        moveq   #0,d5
        moveq   #0,d6
        moveq   #2,d4
calccrc8:
        move.l  a4,d2
calccrc9:
        move.b  (a0)+,d3
        eor.b   d3,d1
        add.w   d1,d1
        lea     0(a1,d1.w),a5
        moveq   #0,d1
        move.b  (a5)+,d1
        eor.b   d0,d1
        move.b  (a5),d0
        move.b  (a0)+,d3
        eor.b   d3,d6
        add.w   d6,d6
        lea     0(a1,d6.w),a5
        moveq   #0,d6
        move.b  (a5)+,d6
        eor.b   d5,d6
        move.b  (a5),d5
        adda.l  a3,a0
        subq.l  #2,d2
        bne.s   calccrc9
        subq.l  #1,d4
        bne.s   calccrc8
        move.b  d0,2(a0,a3.l)
        move.b  d1,(a0)+
        move.b  d5,2(a0,a3.l)
        move.b  d6,(a0)
        addq.l  #2,a2
        subq.l  #2,d7
        bne.s   calccrc7
calccrc_done:
        lea     magixrom_img_name(pc),a0
        movea.l img_buffer(pc),a1
        move.l  img_size(pc),d0
        bsr     writeimg
        lea     crlf(pc),a0
        bsr     cconws
        move.l  #$65306865,eprom_filename+4 /* 'e0he' */
        move.l  #$2E313238,eprom_filename+8 /* '.128' */
        move.w  #-1,d4
        movea.l eprom1_buffer,a1
        movea.l eprom2_buffer,a2
        movea.l img_buffer(pc),a0
split1:
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        dbf     d4,split1
        movea.l eprom1_buffer,a2
        bsr     write_rom
        movea.l eprom2_buffer,a2
        bsr     write_rom
        move.l  #$65306C65,eprom_filename+4 /* 'e0le' */
        move.w  #-1,d4
        movea.l eprom1_buffer,a1
        movea.l eprom2_buffer,a2
        movea.l img_buffer(pc),a0
        lea     2(a0),a0
split2:
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        move.b  (a0)+,(a1)+
        move.b  (a0)+,(a2)+
        lea     2(a0),a0
        dbf     d4,split2
        movea.l eprom1_buffer,a2
        bsr     write_rom
        movea.l eprom2_buffer,a2
        bsr     write_rom
split3:
        movea.l img_buffer(pc),a0
        bsr     mfree
splitend:
        movem.l (a7)+,d0-d7/a0-a6
        rts

loadimg:
        movem.l d3-d4,-(a7)
        movem.l d1-d2/a0-a2,-(a7)
        move.l  d0,d4
        move.w  #0,-(a7)
        pea     (a0)
        move.w  #$003D,-(a7)    /* Fopen */
        trap    #1
        addq.l  #8,a7
        tst.w   d0
        bmi.s   loadimg1
        move.w  d0,d3
        movem.l (a7),d1-d2/a0-a2
        pea     (a1)
        move.l  d4,-(a7)
        move.w  d3,-(a7)
        move.w  #$003F,-(a7)    /* Fread */
        trap    #1
        lea     12(a7),a7
        move.w  d3,-(a7)
        move.l  d0,d3
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.l  #4,a7
        move.l  d3,d0
        bra.s   loadimg2
loadimg1:
        clr.l   d0
loadimg2:
        movem.l (a7)+,d1-d2/a0-a2
        movem.l (a7)+,d3-d4
        rts

writeimg:
        movem.l d3-d4,-(a7)
        movem.l d1-d2/a0-a2,-(a7)
        move.l  d0,d4
        move.w  #0,-(a7)
        pea     (a0)
        move.w  #$003C,-(a7)    /* Fcreate */
        trap    #1
        addq.l  #8,a7
        tst.w   d0
        bmi.s   writeimg1
        move.w  d0,d3
        movem.l (a7),d1-d2/a0-a2
        pea     (a1)
        move.l  d4,-(a7)
        move.w  d3,-(a7)
        move.w  #$0040,-(a7)    /* Fwrite */
        trap    #1
        lea     12(a7),a7
        move.w  d3,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.l  #4,a7
        moveq   #1,d0
        bra.s   writeimg2
writeimg1:
        clr.l   d0
writeimg2:
        movem.l (a7)+,d1-d2/a0-a2
        movem.l (a7)+,d3-d4
        rts

malloc:
        move.l  d0,-(a7)
        move.w  #$0048,-(a7)    /* Malloc */
        trap    #1
        addq.l  #6,a7
        tst.l   d0
        bgt.s   malloc_ok
        clr.l   d0
malloc_ok:
        rts

mfree:
        pea     (a0)
        move.w  #$0049,-(a7)    /* Mfree */
        trap    #1
        addq.l  #6,a7
        rts

copy_version:
        lea     version,a0
        lea     bootversionstring+1,a1
        lea     version2,a2
        move.w  #10-1,d0
copy_version_loop:
        move.b  (a0),(a1)+
        move.b  (a0)+,(a2)+
        dbf     d0,copy_version_loop
        move.w  eprom_type,d0
        add.w   #'0',d0
        move.b  d0,1(a1)
        rts

        movem.l d0,-(a7)
        move.b  #'.',1(a4)
        move.w  d4,d0
        and.w   #$000F,d0
        add.w   #'0',d0
        move.b  d0,3(a4)
        lsr.w   #4,d4
        move.w  d4,d0
        and.w   #$000F,d0
        add.w   #'0',d0
        move.b  d0,2(a4)
        lsr.w   #4,d4
        move.w  d4,d0
        and.w   #$000F,d0
        add.w   #'0',d0
        move.b  d0,(a4)
        movem.l (a7)+,d0
        rts

/*
 * FIXME no need to search here; we can get offsets from header
 */
search_magic_version:
        movem.l d0-d2/a0-a2,-(a7)
        movea.l a6,a0
        move.w  #2,d1
search_magic_version1:
        move.w  #$7FFF,d2
search_magic_version2:
        cmpi.l  #$87654321,(a0)
        bne.s   search_magic_version3
        cmpi.l  #$4D414758,12(a0)   /* 'MAGX' */
        bne.s   search_magic_version3
        lea     romhdr(pc),a1
        move.b  16(a0),25(a1)       /* copy&swap date ?? why swap? */
        move.b  17(a0),24(a1)
        move.w  18(a0),26(a1)
        move.w  48(a0),2(a1)        /* copy version */
        bra.s   search_magic_version4
search_magic_version3:
        lea     2(a0),a0
        dbf     d2,search_magic_version2
        dbf     d1,search_magic_version1
search_magic_version4:
        movem.l (a7)+,d0-d2/a0-a2
        rts


/*
 * scan p[nn] switch from command line
 */
scan_hddelay:
        move.b  (a6)+,d1
        beq.s   scan_hddelay_end
        move.b  (a6)+,d0
        beq.s   scan_hddelay_end
        and.w   #15,d0
        cmp.w   #10,d0
        bcc.s   scan_hddelay2
        and.w   #15,d1
        cmp.w   #10,d1
        bcc.s   scan_hddelay2
        lea     delay_msg,a0
        move.b  d1,(a0)
        addi.b  #'0',(a0)
        move.b  d0,1(a0)
        addi.b  #'0',1(a0)
        mulu.w  #10,d1
        add.w   d1,d0
        cmp.w   #25,d0
        bcs.s   scan_hddelay1
        move.w  #40,d0
        move.b  #'2',(a0)
        move.b  #'5',1(a0)
scan_hddelay1:
        move.w  d0,hddelay
scan_hddelay2:
        andi    #$fffb,sr       /* clear zero flag */
scan_hddelay_end:
        rts

/*
 * scan a[+-0] switch from command line
 */
scan_altram:
        move.l  #0,altram_end
        move.b  (a6)+,d1
        beq.s   scan_altram_end
        cmp.b   #'-',d1
        bne.s   scan_altram1
        move.l  #$00A00000,altram_end
        move.b  #'A',altram_test_msg
        bra.s   scan_altram2
scan_altram1:
        cmp.b   #'+',d1
        bne.s   scan_altram2
        move.l  #$00C00000,altram_end
        move.b  #'C',altram_test_msg_addr
        move.b  #'A',altram_test_msg
scan_altram2:
        andi    #$fffb,sr /* clear zero flag */
scan_altram_end:
        rts

/*
 * scan k switch from command line (reset is coldboot)
 */
scan_coldboot:
        lea     clr_memvalid,a0
        move.l  #0x42B80420,(a0)+       /* clr.l memvalid */
        lea     reset_msg,a0
        move.b  #'R',(a0)
        rts

/*
 * scan r[n] switch from command line
 */
scan_reloc:
        move.b  (a6)+,d1
        beq     scan_reloc_end
        and.w   #7,d1
        move.w  d1,eprom_type
        cmp.w   #2,d1
        bmi.s   scan_reloc1
        move.l  #$00E00000,tosstart
        move.b  #'E',eprom_addr_msg
        move.b  #'0',eprom_addr_msg+1
        cmp.w   #4,d1
        bne.s   scan_reloc1
        move.l  #$00E50000,tosstart
        move.b  #'5',eprom_addr_msg+1
        cmpi.l  #$00030000,romsize
        beq.s   scan_reloc1
        move.l  #$00E40000,tosstart
        move.b  #'4',eprom_addr_msg+1
scan_reloc1:
        tst.w   eprom_type
        beq.s   scan_reloc2
        move.b  #'2',eprom_msg
        cmpi.w  #3,eprom_type
        bcs.s   scan_reloc2
        move.b  #'4',eprom_msg
scan_reloc2:
        andi    #$fffb,sr /* clear zero flag */
scan_reloc_end:
        rts

load_tos_img:
        clr.w   -(a7)
        pea     tos_img_name(pc)
        move.w  #$003D,-(a7)    /* Fopen */
        trap    #1
        addq.l  #8,a7
        lea     tos_img_open_err,a0
        move.w  d0,d5
        bmi     load_tos_img_err
        lea     buffer,a5
        move.w  #$4FFF,d0
load_tos_img1:
        move.l  #$FFFFFFFF,(a5)+
        move.l  #$FFFFFFFF,(a5)+
        move.l  #$FFFFFFFF,(a5)+
        move.l  #$FFFFFFFF,(a5)+
        dbf     d0,load_tos_img1
        lea     buffer,a5
        move.l  a5,-(a7)
        move.l  #BUFSIZE,-(a7)
        move.w  d5,-(a7)
        move.w  #$003F,-(a7)    /* Fread */
        trap    #1
        adda.w  #12,a7
        move.l  d0,tos_img_size
        move.w  d5,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.w  #4,a7
        lea     tos_img_close_err,a0
        tst.l   d0
        bmi     load_tos_img_err
        lea     tos_img_wrong_err,a0
        cmpi.w  #$602E,(a5)
        bne     load_tos_img_err

/*
 * search for the first cmpi.l,
 * which is the test for diagnostic cartridge,
 * and replace it with a start to the relocated
 * MagiC, either $E50000 or $E40000
 */
        movem.l d0/a0-a1,-(a7)
        movea.l a5,a0
load_tos_img2:
        cmpi.w  #$0CB9,(a0)+    /* cmpi.l */
        bne.s   load_tos_img2
        /* FIXME: would be safer to check 4(a0) for 0xfa0000 here */
        subq.w  #2,a0
        move.w  #5-1,d0
        lea     jmpreal1(pc),a1
        cmpi.l  #$00030000,romsize
        beq.s   load_tos_img3
        lea     jmpreal2(pc),a1
load_tos_img3:
        move.w  (a1)+,(a0)+
        dbf     d0,load_tos_img3
        movea.l a0,a1
        suba.l  a5,a1
        adda.l  #$00E00000,a1
        move.l  a1,tos_rom_addr
        move.b  #$60,(a0)+
        move.l  tos_img_size,d0
        cmp.l   #$00040000,d0
        bhi.s   load_tos_img4
        movea.l a5,a0
        adda.l  #$00040000,a0
        move.w  #$4EF9,$0030(a0)
        move.l  #$00E50030,$0032(a0)
load_tos_img4:
        movem.l (a7)+,d0/a0-a1
        move.l  #$00050000,d6
        cmpi.l  #$00030000,romsize
        beq.s   load_tos_img5
        move.l  #$00040000,d6
load_tos_img5:
        move.w  #0,-(a7)
        pea     magixrom_img_name
        move.w  #$003C,-(a7)    /* Fcreate */
        trap    #1
        addq.l  #8,a7
        lea     magix_create_err,a0
        tst.w   d0
        bmi.s   load_tos_img_err
        move.w  d0,d5
        move.l  a5,-(a7)
        move.l  d6,-(a7)
        move.w  d5,-(a7)
        move.w  #$0040,-(a7)    /* Fwrite */
        trap    #1
        lea     12(a7),a7
        lea     magix_create_err,a0
        cmp.l   d6,d0
        bne.s   load_tos_img_err
        move.w  d5,-(a7)
        move.w  #$003E,-(a7)    /* Fclose */
        trap    #1
        addq.l  #4,a7
        andi    #$fffb,sr       /* clear zero flag */
        rts
load_tos_img_err:
        ori     #4,sr           /* set zero flag */
        rts

errexit:
        movea.l a0,a4
        lea     stop_msg,a0
        bsr     cconws
        movea.l a4,a0
        bsr     cconws
        bra     wait_key

cconws:
        movem.l d0-d2/a0-a2,-(a7)
        move.l  a0,-(a7)
        move.w  #9,-(a7)    /* Cconws */
        trap    #1
        addq.l  #6,a7
        movem.l (a7)+,d0-d2/a0-a2
        rts


start_of_romcode:
romhdr:
        bra.s   clr_memvalid
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.l   0
        .dc.w   0

clr_memvalid:
        nop
        nop
        move    #$2700,sr
        move.w  #$0100,M_dma_fifo
        move.w  #0,M_dma_fifo
        reset
        move.b  #$0A,memconf
        lea     $07FC,a7
        cmpi.l  #$FA52235F,cartbase
        bne.s   syshdr_l1
        lea     syshdr_l1(pc),a6
        jmp     cartbase+4

syshdr_l1:
        lea     bot_ok1(pc),a0
        move.w  #0,cpu_type
        move.l  a0,$0010                /* illegal instruction */
        move.l  a0,$002C                /* Line-F */
        movea.l a7,a1
        move.l  #$00000808,d0
        dc.w    $4e7b,$0002             /* movec d0,cacr */
        moveq   #0,d0
        dc.w    $4e7b,$0801             /* movec d0,vbr */
        lea     mmu_notc(pc),a0
        .dc.l   0xf0104000              /* pmove (a0),TC */
        .dc.l   0xf0100800              /* pmove (a0),TT0 */
        .dc.l   0xf0100c00              /* pmove (a0),TT1 */
bot_ok1:
        movea.l a1,a7
        bsr     clr_vme_intr
        lea     giread,a0
        move.b  #8,(a0)
        clr.b   2(a0)
        move.b  #9,(a0)
        clr.b   2(a0)
        move.b  #10,(a0)
        clr.b   2(a0)
        move.b  #7,(a0)
        move.b  #$C0,2(a0)
        move.b  #14,(a0)
        move.b  #$07,2(a0)
        nop
        move.w  old_palmode(pc),d0
        beq.s   no_palmode
        bsr     delay
        move.b  #$02,EXTCLK
no_palmode:
        lea     ST_PALETTE,a1
        lea     palette(pc),a0
        move.w  #16-1,d0
copy_palette:
        move.w  (a0)+,(a1)+
        dbf     d0,copy_palette
        move.b  #1,VBASE_HIGH
        clr.b   VBASE_MID
        move.b  memctrl,d6
        move.b  d6,memconf
        move.l  phystop,d5
        move.l  #$5741524D,d6 /* 'WARM' */
        lea     memval_ret(pc),a6
        bra     check_memvalid
memval_ret:
        beq     do_warmboot
        move.b  old_memconf(pc),d6
        move.b  d6,memconf
        move.l  testmode_phystop(pc),d5
        tst.l   d5
        bne     no_memconf
        clr.w   d6
        move.b  #$0A,memconf
        movea.w #8,a0
        lea     $00200008.l,a1
        clr.w   d0
memcheck1:
        move.w  d0,(a0)+
        move.w  d0,(a1)+
        add.w   #0xfa54,d0
        cmpa.w  #$0200,a0
        bne.s   memcheck1
        move.b  #90,VBASE_LOW
        tst.b   VBASE_MID
        move.b  VBASE_LOW,d0
        cmp.b   #90,d0
        bne.s   memcheck2
        clr.b   VBASE_LOW
        tst.w   ST_PALETTE
        tst.b   VBASE_LOW
        bne.s   memcheck2
        move.l  #$00040000,d7
        bra.s   memcheck3

memcheck2:
        move.l  #$00000200,d7
memcheck3:
        move.l  #$00200000,d1
        bsr     checkcrc
        move.b  d6,memconf
        lea     $00008000.l,a7
        lea     memcheck7(pc),a0
        move.l  a0,buserror
        move.w  #0xfb55,d3
        move.l  #$00020000,d7
        movea.l d7,a0
memcheck4:
        movea.l a0,a1
        move.w  d0,d2
        moveq   #43-1,d1
memcheck5:
        move.w  d2,-(a1)
        add.w   d3,d2
        dbf     d1,memcheck5
        movea.l a0,a1
        moveq   #43-1,d1
memcheck6:
        cmp.w   -(a1),d0
        bne.s   memcheck7
        clr.w   (a1)
        add.w   d3,d0
        dbf     d1,memcheck6
        adda.l  d7,a0
        bra.s   memcheck4
memcheck7:
        suba.l  d7,a0
        move.l  a0,d5

no_memconf:
        movea.w #buserror+2,a0
        moveq   #0,d0
        move.w  #$0FFE,d1
clearlowmem:
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        dbf     d1,clearlowmem
        move.b  d6,memctrl
        move.l  d5,phystop
        move.l  #$237698AA,memval2
        move.l  #$5555AAAA,memval3
        lea     no_fastrefresh(pc),a0
        move.l  a0,buserror
        move.w  #0,$FFD000E0.l
no_fastrefresh:
        lea     memcheck12(pc),a0
        move.l  a0,buserror
        move.w  #0xfb55,d3
        moveq   #0,d0
        move.l  #$00020000,d7
        movea.l #$01020000,a0
        movea.l a0,a2
        movea.l d7,a1
        move.l  (a1),d1
        not.l   d1
        move.l  d1,(a0)
        cmp.l   (a1),d1
        bne.s   memcheck9
        bra.s   memcheck12

memcheck8:
        move.l  a0,-4(a0)
        cmpa.l  -4(a2),a0
        beq.s   memcheck12
memcheck9:
        movea.l a0,a1
        move.w  d0,d2
        moveq   #43-1,d1
memcheck10:
        move.w  d2,-(a1)
        add.w   d3,d2
        dbf     d1,memcheck10
        movea.l a0,a1
        moveq   #43-1,d1
memcheck11:
        cmp.w   -(a1),d0
        bne.s   memcheck12
        clr.w   (a1)
        add.w   d3,d0
        dbf     d1,memcheck11
        adda.l  d7,a0
        bra.s   memcheck8

memcheck12:
        suba.l  d7,a0
        cmpa.l  #FASTRAM_START,a0
        bne.s   memcheck13
        suba.l  a0,a0
memcheck13:
        move.l  a0,ramtop
        move.l  #$1357BD13,ramvalid
        move.l  end_of_magic_rom(pc),fstrm_beg
        tst.l   ramtop
        bne.s   memcheck15
        move.l  altram_end(pc),d0
        beq.s   do_warmboot
        bsr     checkmem
        tst.l   altram_new
        beq.s   do_warmboot
        move.l  end_of_magic_rom(pc),d0
        cmp.l   new_phystop,d0
        bhi.s   memcheck14
        move.l  d0,altram_new
memcheck14:
        move.l  altram_new,fstrm_beg
        subi.l  #18,new_phystop
        move.l  new_phystop,ramtop
        bra.s   do_warmboot
memcheck15:
        move.l  #FASTRAM_START,fstrm_beg

do_warmboot:
        movea.w #$3DE8,a7
        clr.l   _shell_p
        cmp.l   #$5741524D,d6 /* 'WARM' */
        bne.s   do_coldboot
        movea.l _sysbase,a0
        movea.l 20(a0),a0
        cmpi.l  #$87654321,(a0)
        bne.s   warmboot1
        cmpi.l  #$4D414758,12(a0) /* 'MAGX' */
        beq     do_reset
warmboot1:
        bsr     checkrom
        bcc     do_reset
        bra     hardreset

do_coldboot:
        movea.l phystop,a0
        suba.l  #SCREENSIZE,a0
        movea.l a0,a4
        move.w  #(SCREENSIZE/16)-1,d1
        move.l  a0,_v_bas_ad
        move.b  _v_bas_ad+1,VBASE_HIGH
        move.b  _v_bas_ad+2,VBASE_MID
        moveq   #0,d0
clearscreen:
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        dbf     d1,clearscreen
        lea     gpip,a0
        moveq   #0,d0
        movep.l d0,0(a0)  /* FIXME: avoid movep */
        movep.l d0,8(a0)
        movep.l d0,16(a0)
        bsr     delay
        move.b  #$03,keyctl
        move.b  #$16,keyctl
        moveq   #1,d1
        move.l  #160,d5
        btst    #7,gpip
        bne.s   screen
        moveq   #2,d1
        moveq   #80,d5
screen:
        bsr     delay
        move.b  d1,ST_SHIFT
        move.b  d1,sshiftmd
        bsr     select_floppy0
        move.w  #0,logo_counter
        move.w  #-1,clocktype
        bsr     check_boot_pref
        bcs.s   screen1
        move.w  #10,logo_counter
screen1:
        clr.l   _hz_200
        lea     timer_c_interrupt(pc),a1
        move.l  a1,$0114  /* Timer C */
        lea     justrte(pc),a1
        move.l  a1,$0070  /* VBL interrupt */
        moveq   #0,d0
        lea     gpip,a0
        movep.w d0,2(a0)  /* FIXME: avoid movep */
        movep.l d0,6(a0)
        movep.l d0,14(a0)
        move.b  #$48,22(a0)
        move    #$2500,sr
        bsr     set_vme_intr
        move.w  #12,timer_c_value
        move.w  timer_c_value,timer_c_counter
        move.b  #0,tcdcr
        move.b  #$10,tcdr
        move.b  #$20,ierb
        move.b  #$20,imrb
        move.b  #0,iprb
        move.b  #0,isrb
        move.b  #$50,tcdcr
        clr.w   lastpress
        move.b  #$80,d0
        bsr     sendikbd
        move.b  #1,d0
        bsr     sendikbd
        move.l  _hz_200,d0
        add.l   #200,d0
waitikbd:
        move.l  _hz_200,d1
        add.l   #20,d1
waitikbd1:
        cmp.l   _hz_200,d0
        bcs.s   waitikbd2
        cmp.l   _hz_200,d1
        bcs.s   waitikbd2
        btst    #0,keyctl
        beq.s   waitikbd1
        move.b  keybd,d1
        bra.s   waitikbd
waitikbd2:

        move.b  #$12,d0
        bsr     sendikbd
        move.b  #$1A,d0
        bsr     sendikbd
        clr.w   lastkey
        movea.l a4,a0
        move.w  hddelay(pc),d0
        move.w  d0,d1
        mulu.w  #5,d0
        move.w  #$0101,timer_sieve
        cmpi.b  #2,sshiftmd
        bne.s   sieve1
        lsl.l   #1,d0
        move.w  #$1111,timer_sieve
sieve1:

        cmp.w   #12,d1
        bhi.s   sieve2
        lsl.l   #1,d0
        move.w  #$1111,timer_sieve
        cmpi.b  #2,sshiftmd
        bne.s   sieve2
        move.w  #$5555,timer_sieve
sieve2:

        cmp.w   #6,d1
        bhi.s   sieve3
        lsl.l   #1,d0
        move.w  #$5555,timer_sieve
        cmpi.b  #2,sshiftmd
        bne.s   sieve3
        move.w  #-1,timer_sieve
sieve3:

        move.w  d0,hd_pause_timer
        subq.w  #1,d0
drawbar:
        move.w  #$3FFC,(a0)
        adda.l  d5,a0
        dbf     d0,drawbar
        bsr     drawlogo
        bsr     printdate
        bsr     printtime
        bsr     printversion
        bsr     printmem
        movea.l a4,a6
        st      hd_pause_stop
        st      fastram_on
        move.l  ramtop,real_ramtop

menu:
        addq.l  #5,d1
menu1:
        cmp.l   _hz_200,d1
        bhi.s   menu1
        bsr     checkkey
        beq.s   no_key
        cmp.w   #$003B,d0
        beq.s   handle_key_f1
        cmp.w   #$003C,d0
        beq.s   handle_key_f2
        cmp.w   #$0043,d0
        beq.s   handle_key_f9
        cmp.w   #$0042,d0
        beq.s   handle_key_f8
        bne.s   refreshinfo

/*
 * F1: prepare to start MagiC
 */
handle_key_f1:
        move.w  #0,logo_counter
        bsr     set_boot_pref_magic
        bra.s   no_key

/*
 * F2: prepare to start TOS
 */
handle_key_f2:
        bsr     checkrom
        bcc.s   no_key
        move.w  #10,logo_counter
        bsr     set_boot_pref_tos
        bra.s   no_key

handle_key_f9:
        not.b   hd_pause_stop
        bra.s   no_key

handle_key_f8:
        not.b   fastram_on
        bne.s   set_fastram_on
        move.l  fstrm_beg,ramtop
        bra.s   set_fastram_off
set_fastram_on:
        move.l  real_ramtop,ramtop
set_fastram_off:
        bsr     printmem
        bra.s   no_key

refreshinfo:
        bsr     drawlogo
        st      hd_pause_stop
        bsr     hd_pause_check
        bne.s   refreshinfo
        bra.s   menu2

no_key:
        bsr     printtime
        bsr     drawlogo
        rol     timer_sieve
        bcc     menu
        bsr     hd_pause_check
        bne     menu

menu2:
        move    #$2700,sr
        bsr     clr_vme_intr
        cmpi.w  #10,logo_counter
        bne.s   menu3
        bra.s   hardreset

menu3:
        move.l  #$31415926,resvalid
        move.l  rom_start_of_magic_rom(pc),resvector
        move.w  old_palmode(pc),palmode
        movea.w #$0600,a0
        moveq   #0,d0
        move.w  #$0FFF,d1
menu4:
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        dbf     d1,menu4
        cmpi.l  #FASTRAM_START,fstrm_beg
        bcc.s   menu5
        move.l  #FASTRAM_START,fstrm_beg
menu5:
        lea     mmurom_table(pc),a0
        lea     mmutable_ram,a1
        move.w  #(mmuromend-mmurom_table)/4-1,d0
mmucopy:
        move.l  (a0)+,(a1)+
        dbf     d0,mmucopy
do_reset:
        bsr     set_boot_pref_magic
        movea.l rom_start_of_magic_rom(pc),a5
        movea.l 4(a5),a5
        lea     4(a5),a5
        move.l  #$752019F3,memvalid
        jmp     (a5)

hardreset:
        bsr     set_boot_pref_tos
        move    #$2700,sr
        move.b  #0,ierb
        move.b  #0,imrb
        cmp.l   #$5741524D,d6 /* 'WARM' */
        beq.s   hardreset2
        lea     buserror,a0
        move.w  #$3FFD,d0
        clr.l   d1
hardreset1:
        move.l  d1,(a0)+
        dbf     d0,hardreset1
hardreset2:
        movea.l tos_rom_addr(pc),a1
        jmp     (a1)

drawlogo:
        movem.l d0-d1/a0,-(a7)
        clr.l   d0
        move.w  logo_counter,d0
        cmp.w   #9,d0
        bhi.s   drawlogo1
        addq.w  #1,logo_counter
        cmpi.w  #10,logo_counter
        bne.s   drawlogo5
        clr.w   logo_counter
        bsr     toggle_floppy
        bra.s   drawlogo5
drawlogo1:
        addq.w  #1,led_counter
        cmpi.w  #18,led_counter
        bne.s   drawlogo2
        bsr     select_floppy0
drawlogo2:
        cmpi.w  #24,led_counter
        bne.s   drawlogo3
        bsr     deselect_floppy0
drawlogo3:
        cmpi.w  #30,led_counter
        bne.s   drawlogo4
        bsr     select_floppy0
drawlogo4:
        cmpi.w  #36,led_counter
        blt.s   drawlogo5
        bsr     deselect_floppy0
        move.w  #0,led_counter
drawlogo5:
        lea     magclogo(pc),a0
        lsl.w   #4,d0
        lsl.w   #5,d0
        adda.l  d0,a0
        move.w  #64-1,d1
        move.l  d5,d0
        mulu.w  hd_pause_timer,d0
drawlogo6:
        cmpi.b  #2,sshiftmd
        bne.s   drawlogo7
        move.l  (a0)+,0(a4,d0.l)
        move.l  (a0)+,4(a4,d0.l)
        bra.s   drawlogo8
drawlogo7:
        move.w  (a0),0(a4,d0.l)
        move.w  (a0)+,2(a4,d0.l)
        move.w  (a0),4(a4,d0.l)
        move.w  (a0)+,6(a4,d0.l)
        move.w  (a0),8(a4,d0.l)
        move.w  (a0)+,10(a4,d0.l)
        move.w  (a0),12(a4,d0.l)
        move.w  (a0)+,14(a4,d0.l)
drawlogo8:
        add.l   d5,d0
        dbf     d1,drawlogo6
        movem.l (a7)+,d0-d1/a0
        rts

hd_pause_check:
        tst.b   hd_pause_stop
        beq.s   hd_pause_check1
        tst.w   hd_pause_timer
        beq.s   hd_pause_check1
        subq.w  #1,hd_pause_timer
hd_pause_check1:
        tst.w   hd_pause_timer
        rts

        bra     menu2 /* FIXME: dead code */

justrte:
        rte

timer_c_interrupt:
        subq.w  #1,timer_c_counter
        bne.s   timer_c_interrupt1
        move.w  timer_c_value,timer_c_counter
        addq.l  #1,_hz_200
        move.b  #$DF,$00FFFA11.l /* FIXME: should be isrb */
        rte

timer_c_interrupt1:
        movem.l d0-d3/a0,-(a7)
        move.b  $00FFFC00.l,d0 /* FIXME: shoud be keyctl */
        move.b  $00FFFC02.l,d1 /* FIXME: shoud be keybd */
        btst    #0,d0
        beq.s   timer_c_interrupt5
        and.w   #$00FF,d1
        tst.w   lastpress
        bne.s   timer_c_interrupt6
        cmp.w   #$0044,d1 /* F10? */
        beq.s   timer_c_interrupt2
        cmp.w   #$005D,d1 /* Shift-F10? */
        beq.s   timer_c_interrupt2
        cmp.w   #$0053,d1 /* Delete? */
        bne.s   timer_c_interrupt3
timer_c_interrupt2:
        move.l  #0,memvalid
        bra     romhdr
timer_c_interrupt3:
        cmp.w   #$0038,d1 /* Alternate? */
        beq.s   timer_c_interrupt5
        cmp.w   #$001D,d1 /* Control? */
        beq.s   timer_c_interrupt5
        cmp.w   #$002A,d1 /* LeftShift? */
        beq.s   timer_c_interrupt5
        cmp.w   #$0036,d1 /* RightShift? */
        beq.s   timer_c_interrupt5
        /* FIXME: should also ignore AltGR */
        move.w  #-1,d0
        tst.b   d1
        bpl.s   timer_c_interrupt4
        clr.w   d0
timer_c_interrupt4:
        and.l   #$0000007F,d1
        cmp.w   #$0075,d1
        bgt.s   timer_c_interrupt5
        move.w  d0,lastkey
        tst.w   d0
        beq.s   timer_c_interrupt5
        move.w  d1,lastkey
timer_c_interrupt5:
        move.b  #$DF,$00FFFA11.l /* FIXME: should be isrb */
        movem.l (a7)+,d0-d3/a0
        rte
timer_c_interrupt6:
        cmp.w   lastpress,d1
        bne.s   timer_c_interrupt5
        clr.w   lastpress
        bra.s   timer_c_interrupt5

sendikbd:
        move.l  _hz_200,d1
        add.l   #50,d1
sendikbd1:
        cmp.l   _hz_200,d1
        bcs.s   sendikbd2
        tst.w   lastpress
        bne.s   sendikbd1
sendikbd2:
        btst    #1,keyctl
        beq.s   sendikbd2
        move.b  d0,keybd
        clr.l   lastpress /* BUG: should be clr.w */
        rts

checkkey:
        move.w  lastkey,d0
        clr.w   lastkey
        tst.w   d0
        rts

checkmem:
        movea.l phystop,a0
        move    sr,-(a7)
        movea.l a7,a6
        ori     #$0700,sr
        lea     checkmem8(pc),a1
        move.l  a1,buserror
checkmem1:
        move.l  a0,new_phystop
        move.l  (a0),d6
        move.l  #$31415926,(a0)
        cmpi.l  #$31415926,(a0)
        bne.s   checkmem8
        move.l  d6,(a0)
        tst.l   altram_new
        beq.s   checkmem2
        bra.s   checkmem3
checkmem2:
        move.l  a0,altram_new
checkmem3:
        adda.l  #0x00080000,a0
        cmpa.l  altram_end(pc),a0
        bcs.s   checkmem1
checkmem4:
        tst.l   altram_new
        beq.s   checkmem7
        movea.l altram_new,a0
        movea.l a0,a1
        move.l  new_phystop,d0
        move.l  (a0),d1
checkmem5:
        move.l  #$31415926,(a1)
        adda.l  #0x00080000,a0
        cmp.l   a0,d0
        bne.s   checkmem6
        cmpi.l  #$31415926,(a0)
        bne.s   checkmem5
        move.l  #$01070001,(a1)
        cmpi.l  #$01070001,(a0)
        bne.s   checkmem5
        move.l  a0,new_phystop
checkmem6:
        move.l  d1,(a1)
checkmem7:
        movea.l a6,a7
        move    (a7)+,sr
        rts
checkmem8:
        tst.l   altram_new
        bne.s   checkmem4
        beq.s   checkmem3

delay:
        lea     tbdr,a0
        lea     tbcr,a1
        bclr    #0,iera
        moveq   #1,d4
        clr.b   (a1)
        move.b  #$F0,(a0)
        move.b  #$08,(a1)
delay1:
        cmp.b   (a0),d4
        bne.s   delay1
delay2:
        move.b  (a0),d4
        move.w  #$0267,d3
delay3:
        cmp.b   (a0),d4
        bne.s   delay2
        dbf     d3,delay3
        move.b  #$10,(a1)
        rts

checkcrc:
        lsr.w   #2,d6
        movea.l d7,a0
        addq.l  #8,a0
        bsr     updatecrc
        beq.s   checkcrc2
        movea.l d7,a0
        adda.l  d7,a0
        addq.l  #8,a0
        bsr     updatecrc
        beq.s   checkcrc1
        movea.w #8,a0
        bsr     updatecrc
        bne.s   checkcrc2
        addq.w  #4,d6
checkcrc1:
        addq.w  #4,d6
checkcrc2:
        sub.l   #$00200000,d1
        beq.s   checkcrc
        rts

updatecrc:
        adda.l  d1,a0
        clr.w   d0
        lea     $01F8(a0),a1
updatecrc1:
        cmp.w   (a0)+,d0
        bne.s   updatecrc2
        add.w   #0xfa54,d0
        cmpa.l  a0,a1
        bne.s   updatecrc1
updatecrc2:
        rts

check_memvalid:
        cmpi.l  #$752019F3,memvalid
        bne.s   check_memvalid1
        cmpi.l  #$237698AA,memval2
        bne.s   check_memvalid1
        cmpi.l  #$5555AAAA,memval3
check_memvalid1:
        jmp     (a6)

checkrom:
        movem.l d1/a0-a2,-(a7)
        movea.l a7,a0
        lea     checkrom1(pc),a1
        move.l  a1,buserror
        lea     romhdr(pc),a2
        move.l  (a2),d1
        lea     $00E00000.l,a1 /* BUG: will not work with 192k */
        cmpi.w  #$602E,(a1)
        bne.s   checkrom1
        cmp.l   (a1),d1
        bne.s   checkrom2
checkrom1:
        movea.l a0,a7
        movem.l (a7)+,d1/a0-a2
        andi    #$FE,ccr  /* clear carry */
        rts
checkrom2:
        movea.l a0,a7
        movem.l (a7)+,d1/a0-a2
        ori     #$01,ccr  /* set carry */
        rts

check_boot_pref:
        movem.l d0-d2/a0-a2,-(a7)
        move    #$2700,sr
        bsr     check_mste_clk
        bcs.s   check_boot_pref1
        bsr     checkrom
        bcc.s   check_boot_pref1
        lea     mste_clk,a0
        bset    #0,27(a0)      /* set update-in-progress */
        move.b  13(a0),d0
        bclr    #0,27(a0)      /* clear update-in-progress */
        btst    #1,d0
        bne.s   check_boot_pref1
        andi    #$FE,ccr  /* clear carry */
        movem.l (a7)+,d0-d2/a0-a2
        rts
check_boot_pref1:
        ori     #$01,ccr  /* set carry */
        movem.l (a7)+,d0-d2/a0-a2
        rts

check_mste_clk:
        move.w  #-1,clocktype
        movem.l d0-d2/a0-a2,-(a7)
        movea.l a7,a0
        movea.l buserror,a1
        lea     no_mste_clk(pc),a2
        move.l  a2,buserror
        lea     mste_clk,a2
        bset    #0,27(a2)      /* set update-in-progress */
        movep.w 5(a2),d0  /* FIXME: avoid movep */
        move.w  #$0A05,d1
        movep.w d1,5(a2)
        movep.w 5(a2),d2
        and.w   #$0F0F,d2
        cmp.w   d1,d2
        bne.s   no_mste_clk
        movep.w d0,5(a2)
        move.l  a1,buserror
        move.b  #1,1(a2)
        bclr    #0,27(a2)      /* clear update-in-progress */
        move.b  #0,29(a2)
        andi    #$FE,ccr  /* clear carry */
        move.w  #0,clocktype
        bra.s   mste_clk_ok
no_mste_clk:
        move.l  a1,buserror
        ori     #$01,ccr  /* set carry */
mste_clk_ok:
        movea.l a0,a7
        movem.l (a7)+,d0-d2/a0-a2
        rts

set_boot_pref_magic:
        movem.l d0/a0,-(a7)
        bsr     check_mste_clk
        bcs.s   set_boot_pref_magic1
        lea     mste_clk,a0
        bset    #0,27(a0)      /* set update-in-progress */
        move.b  13(a0),d0
        and.b   #$0F,d0
        bset    #1,d0
        move.b  d0,13(a0)
        bclr    #0,27(a0)      /* clear update-in-progress */
set_boot_pref_magic1:
        movem.l (a7)+,d0/a0
        rts

set_boot_pref_tos:
        movem.l d0/a0,-(a7)
        bsr     check_mste_clk
        bcs.s   set_boot_pref_tos1
        lea     mste_clk,a0
        bset    #0,27(a0)      /* set update-in-progress */
        move.b  13(a0),d0
        and.b   #$0F,d0
        bclr    #1,d0
        move.b  d0,13(a0)
        bclr    #0,27(a0)      /* clear update-in-progress */
set_boot_pref_tos1:
        movem.l (a7)+,d0/a0
        rts

printdate:
        movem.l d0/a1-a2,-(a7)
        tst.w   clocktype
        bne.s   printdate1
        move.w  #72,cursor_x
        move.w  #1,cursor_y
        lea     mste_clk,a2
        bclr    #0,27(a2)      /* clear update-in-progress */
        move.b  17(a2),d0      /* get tens of day */
        bsr     printdigit
        move.b  15(a2),d0      /* get unit of day */
        bsr     printdigit
        move.b  #'.',d0
        bsr     printchar
        move.b  21(a2),d0      /* get tens of month */
        bsr     printdigit
        move.b  19(a2),d0      /* get units of month */
        bsr     printdigit
        move.b  #'.',d0
        bsr     printchar
        move.b  25(a2),d0      /* get tens of year */
        addq.b  #8,d0
        bsr     printdigit
        move.b  23(a2),d0      /* get units of year */
        bsr     printdigit
printdate1:
        movem.l (a7)+,d0/a1-a2
        rts

printtime:
        movem.l d0/a0-a1,-(a7)
        tst.w   clocktype
        bne.s   printtime1
        move.w  #72,cursor_x
        move.w  #0,cursor_y
        lea     mste_clk,a1
        bclr    #0,27(a1)      /* clear update-in-progress */
        move.b  11(a1),d0      /* get tens of hour */
        bsr     printdigit
        move.b  9(a1),d0       /* get unit of hour */
        bsr     printdigit
        move.b  #':',d0
        bsr     printchar
        move.b  7(a1),d0       /* get tens of minute */
        bsr     printdigit
        move.b  5(a1),d0       /* get units of minute */
        bsr     printdigit
        move.b  #':',d0
        bsr     printchar
        move.b  3(a1),d0       /* get tens of second */
        bsr     printdigit
        move.b  1(a1),d0       /* get units of second */
        bsr     printdigit
printtime1:
        movem.l (a7)+,d0/a0-a1
        rts

printmem:
        movem.l d0,-(a7)
        move.w  #69,cursor_x
        move.w  #3,cursor_y
        move.b  #'S',d0
        bsr     printchar
        move.b  #':',d0
        bsr     printchar
        addq.w  #1,cursor_x
        move.l  phystop,d0
        bsr     printhex
        move.l  #0,fastramsize
        cmpi.l  #$1357BD13,ramvalid
        bne.s   printmem1
        cmpi.l  #FASTRAM_START,ramtop
        bls.s   printmem1
        move.l  ramtop,fastramsize
        move.l  fstrm_beg,d0
        sub.l   d0,fastramsize
printmem1:
        move.w  #69,cursor_x
        move.w  #4,cursor_y
        move.b  #'F',d0
        bsr     printchar
        move.b  #':',d0
        bsr     printchar
        addq.w  #1,cursor_x
        move.l  fastramsize,d0
        bsr     printhex
        movem.l (a7)+,d0
        rts

printversion:
        movem.l d0-d1/a0-a1,-(a7)
        move.w  #67,cursor_x
        move.w  #49,cursor_y
        cmpi.b  #2,sshiftmd
        beq.s   printversion1
        move.w  #24,cursor_y
printversion1:
        lea     bootversionstring(pc),a0
        bsr     printstr
        move.w  #58,cursor_x
        subq.w  #1,cursor_y
        bsr     printstr
        lea     romhdr(pc),a1
        bsr     printtosversion
        bsr     checkrom
        bcc.s   printversion2
        move.w  #61,cursor_x
        subq.w  #1,cursor_y
        bsr     printstr
        lea     $00E00000.l,a1
        bsr     printtosversion
printversion2:
        movem.l (a7)+,d0-d1/a0-a1
        rts

printtosversion:
        movem.l d0-d2/a0,-(a7)
        move.w  2(a1),d1
        rol.w   #8,d1
        move.w  d1,d0
        bsr     printdigit
        move.w  #'.',d0
        bsr     printchar
        rol.w   #4,d1
        move.w  d1,d0
        bsr     printdigit
        rol.w   #4,d1
        move.w  d1,d0
        bsr     printdigit
        move.w  #'-',d0
        bsr     printchar
        move.w  $0018(a1),d1
        move.w  d1,d0
        ror.w   #4,d0
        bsr     printdigit
        move.w  d1,d0
        bsr     printdigit
        move.w  #'.',d0
        bsr     printchar
        rol.w   #4,d1
        move.w  d1,d0
        bsr     printdigit
        rol.w   #4,d1
        move.w  d1,d0
        bsr     printdigit
        move.w  #'.',d0
        bsr     printchar
        move.w  $001A(a1),d1
        move.w  #4-1,d2
printtosversion1:
        rol.w   #4,d1
        move.w  d1,d0
        bsr     printdigit
        dbf     d2,printtosversion1
        movem.l (a7)+,d0-d2/a0
        rts

printhex:
        movem.l d0-d2/d4,-(a7)
        move.l  d0,d2
        move.w  #8-1,d4
printhex1:
        rol.l   #4,d2
        move.w  d2,d0
        bsr     printdigit
        dbf     d4,printhex1
        movem.l (a7)+,d0-d2/d4
        rts

printdigit:
        move.l  a0,-(a7)
        lea     hexdigits(pc),a0
        and.l   #15,d0
        move.b  0(a0,d0.w),d0
        bsr     printchar
        movea.l (a7)+,a0
        rts

hexdigits:
        dc.b    '0123456789ABCDEF'

printstr:
        movem.l d0,-(a7)
printstr1:
        move.b  (a0)+,d0
        beq.s   printstr2
        bsr     printchar
        bra.s   printstr1
printstr2:
        movem.l (a7)+,d0
        rts

printchar:
        movem.l d0-d2/a1,-(a7)
        lea     smallfont(pc),a1
        sub.l   #$00000020,d0
        and.l   #$0000007F,d0
        lsl.l   #3,d0
        adda.l  d0,a1
        move.w  cursor_y,d0
        lsl.w   #3,d0
        addq.w  #7,d0
        mulu.w  d5,d0
        move.w  cursor_x,d1
        cmpi.b  #2,sshiftmd
        beq.s   printchar1
        move.w  d1,d2
        and.w   #1,d2
        and.w   $0000FFFE.l,d1
        lsl.w   #1,d1
        or.w    d2,d1
printchar1:
        and.l   #$0000FFFF,d1
        add.l   d1,d0
        move.w  #8-1,d1
printchar2:
        move.b  0(a1,d1.w),0(a4,d0.l)
        cmpi.b  #2,sshiftmd
        beq.s   printchar3
        move.b  0(a1,d1.w),2(a4,d0.l)
printchar3:
        sub.l   d5,d0
        dbf     d1,printchar2
        addq.w  #1,cursor_x
        movem.l (a7)+,d0-d2/a1
        rts

toggle_floppy:
        movem.l d0/a0,-(a7)
        move.w  led_blink(pc),d0
        beq.s   toggle_floppy1
        lea     giread,a0
        move.b  #14,(a0)
        move.b  (a0),d0
        bchg    #1,d0
        nop
        move.b  #14,(a0)
        move.b  d0,2(a0)
        nop
toggle_floppy1:
        movem.l (a7)+,d0/a0
        rts

select_floppy0:
        movem.l d0/a0,-(a7)
        move.w  led_blink(pc),d0
        beq.s   noselect_floppy0
        lea     giread,a0
        move.b  #14,(a0)
        move.b  #5,2(a0)
        nop
noselect_floppy0:
        movem.l (a7)+,d0/a0
        rts

deselect_floppy0:
        movem.l d0/a0,-(a7)
        move.w  led_blink(pc),d0
        beq.s   nodeselect_floppy0
        lea     giread,a0
        move.b  #14,(a0)
        move.b  #7,2(a0)
        nop
nodeselect_floppy0:
        movem.l (a7)+,d0/a0
        rts

clr_vme_intr:
        movem.l a6,-(a7)
        lea     novme(pc),a6
        move.l  a6,buserror
        movea.l a7,a6
        move.b  #0,vme_intr
        move.b  #0,vme_mask
novme:
        movea.l a6,a7
        movem.l (a7)+,a6
        rts

set_vme_intr:
        movem.l a6,-(a7)
        lea     novme(pc),a6
        move.l  a6,buserror
        movea.l a7,a6
        move.b  #$40,vme_intr
        bra.s   novme

end_of_magic_rom:
        dc.l    0
rom_start_of_magic_rom:
        dc.l    0
machine:
        dc.l    0
altram_end:
        dc.l    0
hddelay:
        dc.w    4
old_palmode:
        dc.w    0
testmode_phystop:
        dc.l    0
old_memconf:
        dc.w    0
led_blink:
        dc.w    0
tos_rom_addr:
        dc.l    $00E00000

		include "mmutable.inc"

palette:
        dc.w    $0FFF,$0F00,$00F0,$0FF0
        dc.w    $000F,$0F0F,$00FF,$0555
        dc.w    $0333,$0F33,$03F3,$0FF3
        dc.w    $033F,$0F3F,$03FF,$0000
        dc.w    $2044,$6965,$2050,$6665
        dc.w    $696C,$2049,$636F,$6E73

magclogo:
		include "magclogo.inc"

smallfont:
		include "smllfont.inc"
        dc.l    0

bootversionstring:
        dc.b    'V'
        dc.b    '00.00.0000-0',0
        dc.b    'MAGIC! ',0
        dc.b    'TOS ',0
        dc.b    'Wilfried Mintrop 30.9.1994',0

end_of_romcode:
        dc.l     0



resetcode:
        movea.l #$00E00034,a0
        jmp     (a0)
jmpreal1:
        jmp     $00E50030
        nop
        nop
        bra.s   jmpreal1
jmpreal2:
        jmp     $00E40030
        nop
        nop
        bra.s   jmpreal1 /* BUG? should be jmpreal2 */

rom_buffer:
        dc.l    0
eprom1_buffer:
        dc.l    0
eprom2_buffer:
        dc.l    0
        dc.l    0
eprom_filename:
        dc.b    'mag_fc_e.032',0
magixrom_img_name:
        dc.b    'magixrom.img',0
eprom_type:
        dc.w    0
crlf:
        dc.b    $0D,$0A,0
        even
tos_img_size:
        dc.l    0
img_buffer:
        dc.l    1
img_size:
        dc.l    1

		include "romcrc.inc"
		
title_msg:
        dc.b    $0D,$0A,'Mag!X-Rom Maker vom '
version2:
        dc.b    '00.00.0000 von Wilfried Mintrop.',$0D,$0A
        dc.b    'Test und Relozieren des mag!'
magic_name_x:
        dc.b    'c.ram von Andreas Kromke.',$0D,$0A
        dc.b    'PAK/3 Anpassung und Doppel-BS von Steffen Engel.',$0D,$0A
        dc.b    $0D,$0A,0

eprom_msg:
        dc.b    '6 Eproms f',$81,'r Speicherbereich ab $'
eprom_addr_msg:
        dc.b    'fc0000.',$0D,$0A
        dc.b    'Mit einer Kaltstartpause von '
delay_msg:
        dc.b    ' 6 Sekunden.',$0D,$0A
altram_test_msg:
        dc.b    0,'lt-Test bis $'
altram_test_msg_addr:
        dc.b    'A00000.',$0D,$0A,0
crc_msg:
        dc.b    'Berechne CRC...',$0D,$0A,0
nvram_msg:
        dc.b    'Uhrenbit (falls vorhanden) auf Mag!C setzen.',$0D,$0A,0
key_msg:
        dc.b    $0D,$0A,'Bitte Taste dr',$81,'cken...',$0D,$0A,0
memerror_msg:
        dc.b    'Leider nicht gen',$81,'gend RAM vorhanden.',$0D,$0A,0
reset_msg:
        dc.b    0,'eset-Taste = Kaltstart.',$0D,$0A,0
testmode_msg:
        dc.b    'F',$81,'r Sprung ins S- oder Fast-RAM Taste dr',$81,'cken.',$0D,$0A,0
magic_ram_path:
        dc.b    'c:\magic.ram',0
magix_ram_path:
        dc.b    'c:\mag!x.ram',0
tos_img_name:
        dc.b    'tos.img',0
stop_msg:
        dc.b    $0D,$0A,'PROGRAMMSTOP!!!',$0D,$0A
        dc.b    'Es ist ein Fehler aufgetreten:',$0D,$0A,0
tos_img_open_err:
        dc.b    'tos.img konnte nicht ge',$94,'ffnet werden',0
tos_img_close_err:
        dc.b    'tos.img konnte nicht geschlossen werden',0
tos_img_wrong_err:
        dc.b    'Die Datei tos.img scheint nicht korrekt zu sein',0
magix_create_err:
        dc.b    'Die Datei magixrom.img konnte nicht angelegt werden',0
magix_not_found_err:
        dc.b    'Kein mag!x.ram oder magic.ram gefunden',0
magix_too_large_err:
        dc.b    'F',$81,'r Relozierung ab $fc0000 ist diese MagiC-Version zu gro',$9E,'.',0
too_larg_for_double_err:
        dc.b    'F',$81,'r Doppel-BS ist das TOS und die MagiC-Version zu gro',$9E,'.',0
error_0_msg:
        dc.b    'Fehler 0',0
error_1_msg:
        dc.b    'Fehler 1',0
        even
version:
        dc.b    '01.12.1995'

        .BSS

magic_fd:
        ds.w    1
romsize:
        ds.l    1
tosstart:
        ds.l    1

        ds.b    3240
stack:

buffer:
        ds.b    4096

        end
