#ifndef PD_H
#define PD_H

typedef struct pd
{
   void   *p_lowtpa;
   void   *p_hitpa;
   void   *p_tbase;
   LONG   p_tlen;
   void   *p_dbase;
   LONG   p_dlen;
   void   *p_bbase;
   LONG   p_blen;
   DTA    *p_dta;
   struct pd *p_parent;
   WORD   p_res0;
   WORD   p_res1;
   char   *p_env;
   char   p_devx[6];
   char   p_res2;
   char   p_defdrv;
   LONG   p_res3[18];
   char   p_cmdlin[128];
} PD;

#undef APPL
typedef struct {
     LONG       *ap_next;      /* 0x00: Verkettungszeiger  */
     WORD       ap_id;         /* 0x04: Application-Id     */
     } APPL;

#endif
