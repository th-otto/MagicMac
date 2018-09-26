/*      MT_AES_I.H

        MagiC 6 AES Definitionen

        Copyright (c) Andreas Kromke 1998
        All Rights Reserved.
*/

#include  <aes.h>

#define init_mt_aesi() sys_set_getdisp( &aes_dispatcher, NULL )

typedef void AES_FUNCTION( AESPB *pb );		/* Register a0 -> pb */

extern void *aes_dispatcher;
extern void sys_set_getdisp( void **disp_adr, void **disp_err );
extern AES_FUNCTION *sys_set_getfn( WORD fn );
extern WORD sys_set_setfn( WORD fn, AES_FUNCTION *f );
extern void *sys_set_appl_getinfo( AES_FUNCTION *f );
extern void sys_set_colourtab( WORD *colourtab );
