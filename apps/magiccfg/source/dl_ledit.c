#include <tos.h>
#include <gemx.h>
#include <mint\cookie.h>
#include "diallib.h"
#include SPEC_DEFINITION_FILE

#if USE_LONGEDITFIELDS == YES

int magic_version=-1;

void InitScrollTED(OBJECT *obj, XTED *xted, int txt_len);
void DoInitLongEdit(void);
void DoExitLongEdit(void);


void InitScrollTED(OBJECT *obj, XTED *xted, int txt_len)
{
TEDINFO *tedinfo=obj->ob_spec.tedinfo;
char *src,*dst,*txt,*tmplt;
int tmplt_len=0,i;

	if(magic_version==-1)				/*	Kein MagiC vorhanden ?	*/
	{
		txt=(char *)Malloc((txt_len<<1)+tmplt_len+2);
		if(txt==NULL)
		{
			form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
			return;
		}
		*txt=0;
		tedinfo->te_ptext=txt;
		tedinfo->te_txtlen=txt_len+1;
		return;
	}
	else if(magic_version<0x520)
		txt_len=min(128,txt_len);

#if DEBUG == ON
	Debug("InitScrollTED()\ndesired len: %d", txt_len);

	Debug("ptext : \"%s\" - Len:%d",tedinfo->te_ptext,tedinfo->te_txtlen);
	Debug("ptmplt: \"%s\" - Len:%d - Strlen:%d",
		tedinfo->te_ptmplt,
		tedinfo->te_tmplen,
		(int)strlen(tedinfo->te_ptmplt));
	Debug("pvalid : \"%s\" - Strlen:%d",tedinfo->te_pvalid,(int)strlen(tedinfo->te_pvalid));
#endif

	if(tedinfo->te_ptmplt==NULL)	/*	evtl. schon initialisiert ?	*/
		return;

	src=tedinfo->te_ptmplt;
	while(*src)
	{
		if(*src!='_')
			tmplt_len++;
		src++;
	}

#if DEBUG==ON
	Debug("txt_len %d, tmplt_len %d --> Total %d",txt_len,tmplt_len,(txt_len<<1)+tmplt_len+2);
#endif

	txt=(char *)Malloc((txt_len<<1)+tmplt_len+2);
	if(txt==NULL)
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
		return;
	}
	*txt=0;
	tmplt=&txt[txt_len+1];
	src=tedinfo->te_ptmplt;
	dst=tmplt;
	i=txt_len;
	while(*src)
	{
		if(*src=='_')
		{
			do
			{
				src++;
			}while(*src=='_');
			for(;i>0;i--)
				*dst++='_';
		}
		else
			*dst++=*src++;
	}
	*dst=0;

	xted->xte_ptmplt=tmplt;
	xted->xte_pvalid=tedinfo->te_pvalid;
	xted->xte_vislen=tedinfo->te_tmplen-1;
	xted->xte_scroll=0;
	tedinfo->te_ptext=txt;
	tedinfo->te_txtlen=txt_len+1;
	tedinfo->te_ptmplt=NULL;
	tedinfo->te_tmplen=tmplt_len+txt_len+1;

	tedinfo->te_just=TE_LEFT;		/* wichtig! */
	tedinfo->te_pvalid=(void *)xted;

#if DEBUG==ON
	Debug("nTmplt: \"%s\" - Len:%d - Strlen:%d\n",tmplt, tedinfo->te_tmplen,(int)strlen(tmplt));
	Debug("nPtxt : \"%s\" - Len:%d\n",txt, tedinfo->te_txtlen);
#endif
}


void DoInitLongEdit(void)
{
int i;
MAGX_COOKIE *cookie;
	if(!Getcookie('MagX',(long *)&cookie))
		magic_version=cookie->aesvars->version;

	for(i=0;i<long_edit_count;i++)
		InitScrollTED(&tree_addr[long_edit[i].tree][long_edit[i].obj],&long_edit[i].xted,long_edit[i].len);
}

void DoExitLongEdit(void)
{
int i;
	for(i=0;i<long_edit_count;i++)
		Mfree(long_edit[i].xted.xte_ptmplt);
}

#endif