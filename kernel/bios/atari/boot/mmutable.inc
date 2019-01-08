mmu_notc:
        dc.l    $00000000
mmu_crp:
        dc.l    $80000002,mmutable_ram /* no limit, short desc, addr $700 */
mmu_tc:
        dc.l    $80f04445 /* enable, pagesize 32k, IS=0, TIA=4, TIB=4, TIC=4, TID=5 */
mmu_tt0:
        dc.l    $017e8107 /* for 0x01000000-0x7fffffff, caching allowed */
mmu_tt1:
        dc.l    $807e8507 /* for 0x80000000-0xfeffffff, *caching inhibited* */

/*
 * pmmu tree
 */
tia  equ mmutable_ram
tib1 equ mmutable_ram+4*16
tib2 equ mmutable_ram+4*32
tic  equ mmutable_ram+4*48


/*
 * pmmu descriptor flags
 */
/* short-format page descriptor */
PD   equ 0x01
/* short-format table descriptor */
TD   equ 0x02
/* cache inhibit (page descriptors only) */
CI   equ 0x40

mmurom_table:
/* tia: top level table (for 0x00000000-0xffffffff) */
        dc.l      tib1+TD        /* for 0x00000000-0x0fffffff, use table tib1 */
        dc.l      $10000000+PD    /* map 0x10000000-0x7fffffff to the same */
        dc.l      $20000000+PD    /*   physical addresses, allow caching   */
        dc.l      $30000000+PD
        dc.l      $40000000+PD
        dc.l      $50000000+PD
        dc.l      $60000000+PD
        dc.l      $70000000+PD
        dc.l      $80000000+PD+CI   /* map 0x80000000-0xefffffff to the same */
        dc.l      $90000000+PD+CI   /*   physical addresses, DON'T allow caching */
        dc.l      $a0000000+PD+CI
        dc.l      $b0000000+PD+CI
        dc.l      $c0000000+PD+CI
        dc.l      $d0000000+PD+CI
        dc.l      $e0000000+PD+CI
        dc.l      tib2+TD        /* for 0xf0000000-0xffffffff, use table tib2 */
/* tib1: second level table (for 0x00000000-0x0fffffff) */
        dc.l      tic+TD         /* for 0x00000000-0x00ffffff, use table tic */
        dc.l      $01000000+PD    /* map 0x01000000-0x0fffffff to the same */
        dc.l      $02000000+PD    /*   physical addresses, allow caching   */
        dc.l      $03000000+PD
        dc.l      $04000000+PD
        dc.l      $05000000+PD
        dc.l      $06000000+PD
        dc.l      $07000000+PD
        dc.l      $08000000+PD
        dc.l      $09000000+PD
        dc.l      $0a000000+PD
        dc.l      $0b000000+PD
        dc.l      $0c000000+PD
        dc.l      $0d000000+PD
        dc.l      $0e000000+PD
        dc.l      $0f000000+PD
/* tib2: second-level table (for 0xf0000000-0xffffffff) */
        dc.l      $00000000+PD+CI  /* map 0xf0000000-0xfeffffff to the same */
        dc.l      $01000000+PD+CI  /*   physical addresses, DON'T allow caching */
        dc.l      $02000000+PD+CI
        dc.l      $03000000+PD+CI
        dc.l      $04000000+PD+CI
        dc.l      $05000000+PD+CI
        dc.l      $06000000+PD+CI
        dc.l      $07000000+PD+CI
        dc.l      $08000000+PD+CI
        dc.l      $09000000+PD+CI
        dc.l      $0a000000+PD+CI
        dc.l      $0b000000+PD+CI
        dc.l      $0c000000+PD+CI
        dc.l      $0d000000+PD+CI
        dc.l      $0e000000+PD+CI
        dc.l      tic+TD           /* for 0xf0000000-0xffffffff, use table tic */
/* tic: third-level table for standard TT/Falcon addresses */
        dc.l      $00000000+PD      /* map 0xff000000-0xffefffff */
        dc.l      $00100000+PD      /*   0x00000000-0x00efffff, allow caching       */
        dc.l      $00200000+PD
        dc.l      $00300000+PD
        dc.l      $00400000+PD
        dc.l      $00500000+PD
        dc.l      $00600000+PD
        dc.l      $00700000+PD
        dc.l      $00800000+PD
        dc.l      $00900000+PD
        dc.l      $00a00000+PD+CI   /* FIXME: mmu-table is for 030 only, but TT does not have VME space here */
        dc.l      $00b00000+PD+CI
        dc.l      $00c00000+PD+CI
        dc.l      $00d00000+PD+CI
        dc.l      $00e00000+PD
        dc.l      $00f00000+PD+CI   /* map 0xfff00000-0xffffffff 0x00f00000-0x00ffffff, DON'T allow caching */
mmuromend:

