#include <tos.h>
#include <gemx.h>
#include <string.h>
#include "diallib.h"
#include "defs.h"


char	*asc_ret="\r\n",
		*asc_nullstr="",
		*asc_space=" ",
		*asc_comment=";",
		*asc_sektion="#[";

char	*asc_mag="#_MAG";

char	*asc_ctr="#_CTR",
		*asc_shelbuf="#[shelbuf]";
		
char	*asc_aes="#[aes]",
		*asc_acc="#_ACC", *asc_app="#_APP", *asc_aut="#_AUT",
		*asc_bkg="#_BKG", *asc_buf="#_BUF", *asc_dev="#_DEV",
		*asc_env="#_ENV", *asc_fsl="#_FSL", *asc_flg="#_FLG",
		*asc_obs="#_OBS", *asc_scp="#_SCP", *asc_shl="#_SHL",
		*asc_slb="#_SLB", *asc_trm="#_TRM", *asc_tsl="#_TSL",
		*asc_txt="#_TXT", *asc_txb="#_TXB", *asc_txs="#_TXS",
		*asc_wnd="#_WND", *asc_inw="#_INW",
		*asc_deaenv=";#_ENV";

char	*asc_vfat="#[vfat]",
		*asc_drives="drives=";

char	*asc_boot="#[boot]",
		*asc_image="image=",
		*asc_bootlog="log=",
		*asc_cookies="cookies=",
		*asc_tiles="tiles=";

char	*asc_ctrlfield="#a000000\15\12#b001001\15\12#c77700070006000"
		"70055200505552220770557075055507703111302\15\12"
		"#d                                            ;\r\n";

char *GetPosition(char *src, char *string);
char *GetLine(char *dst, char *src);
void NoComments(char *str);
char *GetDataStart(char *ptr, int cnt);
long GetmaxLinesize(char *src);

char *BCD_To_ASCII(char *ptr, long num)
{
register char *st=ptr;
	if((num & 0xf000)!=0)
		*ptr++=((num>>12)&0xf)+'0';

	*ptr++=((num>>8)&0xf)+'0';
	*ptr++='.';
	*ptr++=((num>>4)&0xf)+'0';
	*ptr++=(num&0xf)+'0';
	*ptr++=0;
	return(st);
}

void ProcessAES(char *line)
{
char *ptr;


	/*
	 *		Folgende "Flags" drfen noch ';' beinhalten!!
	 *		Dies sind: #_ENV (aktiv und inaktiv) und #_FSL
	 */

	if(strncmpi(line,asc_env,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
		{
		ENV_VAR *envmem=NULL;
			envmem=(ENV_VAR *)Malloc(sizeof(ENV_VAR)+max(strlen(ptr)+(MPATHMAX>>2),MPATHMAX));
			if(envmem!=NULL)
			{
				envmem->next=NULL;
				envmem->selected=0;
				strcpy(&envmem->var,ptr);
				envmem->active=TRUE;
				
				if(mgx_EnvVar==NULL)
					mgx_EnvVar=envmem;
				else
				{
				ENV_VAR *eptr;
					eptr=mgx_EnvVar;
					while(eptr->next!=NULL)
						eptr=eptr->next;
					eptr->next=envmem;
				}
			}
		}
	}

	if(strncmpi(line,asc_deaenv,6)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
		{
		ENV_VAR *envmem=NULL;
			envmem=(ENV_VAR *)Malloc(sizeof(ENV_VAR)+max(strlen(ptr)+(MPATHMAX>>2),MPATHMAX));
			if(envmem!=NULL)
			{
				envmem->next=NULL;
				envmem->selected=0;
				strcpy(&envmem->var,ptr);
				envmem->active=FALSE;
				
				if(mgx_EnvVar==NULL)
					mgx_EnvVar=envmem;
				else
				{
				ENV_VAR *eptr;
					eptr=mgx_EnvVar;
					while(eptr->next!=NULL)
						eptr=eptr->next;
					eptr->next=envmem;
				}
			}
		}
	}
	
	if(strncmpi(line,asc_fsl,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_fsl_mode=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_fsl_mask,ptr);
	}





	/*
	 *		Folgende "Flags" drfen keine ';' beinhalten!!
	 */

	NoComments(line);								/*	Kommentar entfernen	*/

	if(strncmpi(line,asc_acc,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_ACC-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_app,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_START-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_aut,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_AUTO-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_bkg,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_desk_back=atol(ptr);
	}

	if(strncmpi(line,asc_buf,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_shl_buf_size=atol(ptr);
	}

	if(strncmpi(line,asc_dev,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_res_dev=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_res_mode=atol(ptr);
	}

	if(strncmpi(line,asc_flg,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_flags=atol(ptr);
	}

	if(strncmpi(line,asc_obs,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_obs_ow=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_obs_oh=atol(ptr);
		ptr=GetDataStart(line,3);				/*	3. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_obs_bw=atol(ptr);
		ptr=GetDataStart(line,4);				/*	4. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_obs_bh=atol(ptr);
	}

	if(strncmpi(line,asc_scp,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_SCRAP-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_shl,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_SHELL-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_slb,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
		{
		LIB_ITEM *SlbItem=NULL;
		int temp_version;
			temp_version=atoi(ptr);
			ptr=GetDataStart(line,2);		/*	2. Parameter ermitteln	*/

			SlbItem=(LIB_ITEM *)Malloc(sizeof(LIB_ITEM)+max(strlen(ptr)+(MPATHMAX>>2),MPATHMAX));
			if(SlbItem!=NULL)
			{
				SlbItem->next=NULL;
				SlbItem->selected=0;
				SlbItem->version=temp_version;
				if(ptr!=NULL)
					strcpy(&SlbItem->str,ptr);

				if(mgx_SlbItems==NULL)
					mgx_SlbItems=SlbItem;
				else
				{
				LIB_ITEM *sptr;
					sptr=mgx_SlbItems;

					while(sptr->next!=NULL)
						sptr=sptr->next;
					sptr->next=SlbItem;
				}
			}
		}
	}


	if(strncmpi(line,asc_trm,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			strcpy(mgx_Pfade[PA_TERMINAL-PA_SCRAP],ptr);
	}

	if(strncmpi(line,asc_tsl,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_tsl_time=atol(ptr)*5;
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_tsl_prior=atol(ptr);
	}

	if(strncmpi(line,asc_txt,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txb_h=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txs_h=atol(ptr);
		ptr=GetDataStart(line,3);				/*	3. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txb_id=atol(ptr);
		mgx_txs_id=mgx_txb_id;
	}

	if(strncmpi(line,asc_txb,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txb_id=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txb_aqui=atol(ptr);
		ptr=GetDataStart(line,3);				/*	3. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txb_h=atol(ptr);
	}

	if(strncmpi(line,asc_txs,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txs_id=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txs_aqui=atol(ptr);
		ptr=GetDataStart(line,3);				/*	3. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_txs_h=atol(ptr);
	}

	if(strncmpi(line,asc_wnd,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_win_cnt=atol(ptr);
	}

	if(strncmpi(line,asc_inw,5)==0)
	{
		ptr=GetDataStart(line,1);				/*	1. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_inw_objh=atol(ptr);
		ptr=GetDataStart(line,2);				/*	2. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_inw_fontid=atol(ptr);
		ptr=GetDataStart(line,3);				/*	3. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_inw_mflag=atol(ptr);
		ptr=GetDataStart(line,4);				/*	4. Parameter ermitteln	*/
		if(ptr!=NULL)
			mgx_inw_fonth=atol(ptr);
	}

}

void ProcessVFAT(char *line)
{
char *ptr;
	NoComments(line);							/*	Kommentar entfernen	*/
	
	if(strncmpi(line,asc_drives,7)==0)
	{
		strupr(line);								/*	Uppercase String	*/

		ptr=line+7;
		while(*ptr)
		{
			if (*ptr >= 'A' && *ptr <= 'Z')		/*	Buchstaben von A bis Z	*/
			{
				mgx_vfat_drives |= 1UL << (*ptr-'A');		/*	...Bit setzen	*/
			} else if (*ptr >= '1' && *ptr <= '6')		/*	Buchstaben von A bis Z	*/
			{
				mgx_vfat_drives |= 1UL << (*ptr-('1' - 26));		/*	...Bit setzen	*/
			}
			ptr++;
		}
	}
}

void ProcessBOOT(char *line)
/*
Es wird noch weitere Erweiterungen geben, und zwar wegen des von Euch 
so dringend erwarteten Startbildes. Ich bin aber noch am Konzipieren, 
vermutlich sieht das so aus:

	#[boot]
	image=c:\ash.img
	log=NUL:
	cookies=50
	tiles=c:\test.img

*/
{
	NoComments(line);							/*	Kommentar entfernen	*/
	
	if(strncmpi(line,asc_image,6)==0)
		strcpy(mgx_image,line+6);

	if(strncmpi(line,asc_bootlog,4)==0)
		strcpy(mgx_bootlog,line+4);

	if(strncmpi(line,asc_cookies,8)==0)
		mgx_cookies=atol(line+8);

	if(strncmpi(line,asc_tiles,6)==0)
		strcpy(mgx_tiles,line+6);
	
}


#define	IN_UNKNOWN	0
#define	IN_AES		1
#define	IN_VFAT		2
#define	IN_SHELBUF	3
#define	IN_BOOT		4

void LoadMAGX(char *buf)
{
char *line, *ptr;
int where=IN_UNKNOWN, done=FALSE;
	line=(char *)Malloc(max(GetmaxLinesize(buf)+1,MPATHMAX));
	if(!line)
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
		return;
	}
	ptr=buf;
	do
	{
		ptr=GetLine(line,ptr);					/*	Zeile auslesen	*/
		if(strncmpi(line,asc_aes,6)==0)
			where=IN_AES;
		else if(strncmpi(line,asc_vfat,7)==0)
			where=IN_VFAT;
		else if(strncmpi(line,asc_boot,7)==0)
			where=IN_BOOT;
		else if((strncmpi(line,asc_shelbuf,10)==0)||
				(strncmpi(line,asc_ctr,5)==0))
		{
			where=IN_SHELBUF;
			done=TRUE;
		}
		else if(strncmpi(line,asc_sektion,2)==0)
			where=IN_UNKNOWN;

		switch(where)
		{
			case IN_AES:
				ProcessAES(line);
				break;
			case IN_VFAT:
				ProcessVFAT(line);
				break;
			case IN_BOOT:
				ProcessBOOT(line);
				break;
			case IN_UNKNOWN:
				break;
		}
		if(*ptr==0)
			done=TRUE;
	}while(!done);
}


void ProcessMore(char *src, char *dst, int here, char *temp)
{
char *ptr;
int where=IN_UNKNOWN, done=FALSE, WriteIt;

	ptr=src;
	do
	{
		ptr=GetLine(temp,ptr);					/*	Zeile auslesen	*/
		if(strncmpi(temp,asc_aes,6)==0)
			where=IN_AES;
		else if(strncmpi(temp,asc_vfat,7)==0)
			where=IN_VFAT;
		else if(strncmpi(temp,asc_boot,7)==0)
			where=IN_BOOT;
		else if((strncmpi(temp,asc_shelbuf,10)==0)||
				(strncmpi(temp,asc_ctr,5)==0))
		{
			where=IN_SHELBUF;
			done=TRUE;
		}
		else if(strncmpi(temp,asc_sektion,2)==0)
			where=IN_UNKNOWN;
		
		if((where==here)&&(strlen(temp)))
		{
			WriteIt=FALSE;
			switch(where)
			{
				case IN_AES:
					 if((strncmpi(temp,asc_aes,6)!=0)&&
					 		(strncmpi(temp,asc_buf,5)!=0)&&
							(strncmpi(temp,asc_bkg,5)!=0)&&
							(strncmpi(temp,asc_env,5)!=0)&&
							(strncmpi(temp,asc_deaenv,6)!=0)&&
							(strncmpi(temp,asc_dev,5)!=0)&&
							(strncmpi(temp,asc_flg,5)!=0)&&
							(strncmpi(temp,asc_fsl,5)!=0)&&
							(strncmpi(temp,asc_tsl,5)!=0)&&
							(strncmpi(temp,asc_txb,5)!=0)&&
							(strncmpi(temp,asc_txs,5)!=0)&&
							(strncmpi(temp,asc_txt,5)!=0)&&
							(strncmpi(temp,asc_wnd,5)!=0)&&
							(strncmpi(temp,asc_acc,5)!=0)&&
							(strncmpi(temp,asc_app,5)!=0)&&
							(strncmpi(temp,asc_scp,5)!=0)&&
							(strncmpi(temp,asc_aut,5)!=0)&&
							(strncmpi(temp,asc_trm,5)!=0)&&
							(strncmpi(temp,asc_shl,5)!=0)&&
							(strncmpi(temp,asc_obs,5)!=0)&&
							(strncmpi(temp,asc_inw,5)!=0)&&
							(strncmpi(temp,asc_slb,5)!=0))
						WriteIt=TRUE;

					break;
				case IN_VFAT:
					if((strncmpi(temp,asc_vfat,7)!=0)&&
							(strncmpi(temp,asc_drives,7)!=0))
						WriteIt=TRUE;
					break;
				case IN_BOOT:
					if((strncmpi(temp,asc_boot,7)!=0)&&
							(strncmpi(temp,asc_image,6)!=0)&&
							(strncmpi(temp,asc_bootlog,4)!=0)&&
							(strncmpi(temp,asc_tiles,6)!=0)&&
							(strncmpi(temp,asc_cookies,8)!=0))
						WriteIt=TRUE;
					break;
				case IN_UNKNOWN:
					if((strncmpi(temp,asc_mag,5)!=0))
						WriteIt=TRUE;
					break;
			}
			if(WriteIt)
			{
				strcat(dst,temp);
				strcat(dst,asc_ret);
			};
		}

		if(*ptr==0)
			done=TRUE;
	}while(!done);
		
}

void ProcessEnd(char *src, char *dst, char *temp)
{
char *ptr;

	ptr=src;
	do
	{
		ptr=GetLine(temp,ptr);					/*	Zeile auslesen	*/
		if((strncmpi(temp,asc_shelbuf,10)==0)||
			(strncmpi(temp,asc_ctr,5)==0))
			break;

	}while(*ptr!=0);
	
	if(MagiC_Version>0x0520)
	{
		strcat(dst,asc_shelbuf);
		strcat(dst,asc_ret);
	}

	if(strncmpi(temp,asc_shelbuf,10)==0)
		ptr=GetLine(temp,ptr);					/*	Zeile auslesen	*/

	strcat(dst,asc_ctr);
	strcat(dst,asc_ret);
	
	if(*ptr==0)
		strcat(dst,asc_ctrlfield);
	
	if(strncmpi(temp,asc_ctr,5)==0)
		ptr=GetLine(temp,ptr);					/*	Zeile auslesen	*/
		
	strcat(dst,temp);
	strcat(dst,asc_ret);

	do
	{
		ptr=GetLine(temp,ptr);					/*	Zeile auslesen	*/
		strcat(dst,temp);
		strcat(dst,asc_ret);
	}while(*ptr);
}

int SaveMAGX(char *dst,char *src)
{
char *line;

	if(src==NULL)
		src=asc_nullstr;
	
	line=(char *)Malloc(max(GetmaxLinesize(src)+1,MPATHMAX));
	if(!line)
	{
		form_alert(1,tree_addr[DIAL_LIBRARY][DI_MEMORY_ERROR].ob_spec.free_string);
		return(TRUE);
	}

	strcpy(dst,"#_MAG MAG!X V");
	strcat(dst,BCD_To_ASCII(line,mgx_version));
	strcat(dst,asc_ret);

	if((*mgx_image)||(*mgx_bootlog)||(mgx_cookies!=0)||
		(GetPosition(src,asc_boot)))
	{
		strcat(dst,asc_boot);
		strcat(dst,asc_ret);
		if(*mgx_image)
		{
			strcat(dst,asc_image);
			strcat(dst,mgx_image);
			strcat(dst,asc_ret);
		}

		if(*mgx_bootlog)
		{
			strcat(dst,asc_bootlog);
			strcat(dst,mgx_bootlog);
			strcat(dst,asc_ret);
		}
	
		if(mgx_cookies!=0)
		{
			strcat(dst,asc_cookies);
			strcat(dst,ltoa(mgx_cookies,line,10));
			strcat(dst,asc_ret);
		}

		if(*mgx_tiles)
		{
			strcat(dst,asc_tiles);
			strcat(dst,mgx_tiles);
			strcat(dst,asc_ret);
		}	
		ProcessMore(src, dst, IN_BOOT, line);
	}
	if((mgx_vfat_drives!=0)||(GetPosition(src,asc_vfat)))
	{
		strcat(dst,asc_vfat);
		strcat(dst,asc_ret);

		if(mgx_vfat_drives!=0)
		{
		long bitset=1L;
		int i;
		char *ptr;
			ptr=line;
			for(i=0;i<32;i++)
			{
				if(bitset & mgx_vfat_drives)
				{
					if (i < 26)
						*ptr++ = i + 'a';
					else
						*ptr++ = i - 26 + '1';
				}
				bitset=bitset<<1;
			}
			*ptr=0;

			strcat(dst,asc_drives);
			strcat(dst,line);
			strcat(dst,asc_ret);
		}
	
		ProcessMore(src, dst, IN_VFAT, line);
	}

	

	strcat(dst,asc_aes);
	strcat(dst,asc_ret);

	if(mgx_desk_back!=0)
	{
		strcat(dst,asc_bkg);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_desk_back,line,10));
		strcat(dst,asc_ret);
	}
	if(mgx_shl_buf_size!=0)
	{
		strcat(dst,asc_buf);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_shl_buf_size,line,10));
		strcat(dst,asc_ret);
	}
	if((mgx_res_dev!=0))
	{
		strcat(dst,asc_dev);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_res_dev,line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_res_mode,line,10));
		strcat(dst,asc_ret);
	}
	if(mgx_flags!=0)
	{
		strcat(dst,asc_flg);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_flags,line,10));
		strcat(dst,asc_ret);
	}
	if(MagiC_Version>0x520)
	{
		if((mgx_txb_aqui==0)||(mgx_txb_aqui==0)||
			(mgx_obs_ow)||(mgx_obs_oh))
		{
			strcat(dst,asc_obs);
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_obs_ow,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_obs_oh,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_obs_bw,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_obs_bh,line,10));
			strcat(dst,asc_ret);
		}
	}
	if(mgx_tsl_time!=0)
	{
		strcat(dst,asc_tsl);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_tsl_time/5,line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_tsl_prior,line,10));
		strcat(dst,asc_ret);
	}
	if(MagiC_Version<0x520)
	{
		if((mgx_txb_id!=1)||(mgx_txb_h!=0)||(mgx_txs_h!=0))
		{
			strcat(dst,asc_txt);
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_txb_h,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_txs_h,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_txb_id,line,10));
			strcat(dst,asc_ret);
		}
	}
	else
	{
		strcat(dst,asc_txb);
		strcat(dst,asc_space);
		strcat(dst,ltoa(max(mgx_txb_id,1),line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_txb_aqui,line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_txb_h,line,10));
		strcat(dst,asc_ret);

		strcat(dst,asc_txs);
		strcat(dst,asc_space);
		strcat(dst,ltoa(max(mgx_txs_id,1),line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_txs_aqui,line,10));
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_txs_h,line,10));
		strcat(dst,asc_ret);
	}
	if(mgx_win_cnt!=0)
	{
		strcat(dst,asc_wnd);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_win_cnt,line,10));
		strcat(dst,asc_ret);
	}
	if(MagiC_Version>0x520)
	{
		if((mgx_inw_objh)||(mgx_inw_fontid)||(mgx_inw_mflag)||(mgx_inw_fonth))
		{
			strcat(dst,asc_inw);
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_inw_objh,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_inw_fontid,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_inw_mflag,line,10));
			strcat(dst,asc_space);
			strcat(dst,ltoa(mgx_inw_fonth,line,10));
			strcat(dst,asc_ret);
		}
	}

	if(strcmp(mgx_Pfade[1],asc_nullstr)!=0)
	{
		strcat(dst,asc_acc);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[1]);
		strcat(dst,asc_ret);
	}
	if(strcmp(mgx_Pfade[2],asc_nullstr)!=0)
	{
		strcat(dst,asc_app);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[2]);
		strcat(dst,asc_ret);
	}
	if(strcmp(mgx_Pfade[4],asc_nullstr)!=0)
	{
		strcat(dst,asc_aut);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[4]);
		strcat(dst,asc_ret);
	}
	if(strcmp(mgx_Pfade[0],asc_nullstr)!=0)
	{
		strcat(dst,asc_scp);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[0]);
		strcat(dst,asc_ret);
	}
	if(strcmp(mgx_Pfade[3],asc_nullstr)!=0)
	{
		strcat(dst,asc_shl);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[3]);
		strcat(dst,asc_ret);
	}
	if(strcmp(mgx_Pfade[5],asc_nullstr)!=0)
	{
		strcat(dst,asc_trm);
		strcat(dst,asc_space);
		strcat(dst,mgx_Pfade[5]);
		strcat(dst,asc_ret);
	}
	if(mgx_EnvVar!=NULL)
	{
	ENV_VAR *eptr;
		eptr=mgx_EnvVar;
		while(eptr!=NULL)
		{
			if(strcmp(&eptr->var,asc_nullstr)!=0)
			{
				if(eptr->active==FALSE)
					strcat(dst,asc_comment);
				strcat(dst,asc_env);
				strcat(dst,asc_space);
				strcat(dst,&eptr->var);
				strcat(dst,asc_ret);
			}
			eptr=eptr->next;
		};
	}
	if((strcmp(mgx_fsl_mask,asc_nullstr)!=0)||(mgx_fsl_mode!=0))
	{
		strcat(dst,asc_fsl);
		strcat(dst,asc_space);
		strcat(dst,ltoa(mgx_fsl_mode,line,10));
		strcat(dst,asc_space);
		strcat(dst,mgx_fsl_mask);
		strcat(dst,asc_ret);
	}
	if(mgx_SlbItems!=NULL)
	{
	LIB_ITEM *ptr;
		ptr=mgx_SlbItems;
		while(ptr!=NULL)
		{
			if(strcmp(&ptr->str,asc_nullstr)!=0)
			{
				strcat(dst,asc_slb);
				strcat(dst,asc_space);
				strcat(dst,itoa(ptr->version,line,10));
				strcat(dst,asc_space);
				strcat(dst,&ptr->str);
				strcat(dst,asc_ret);
			}
			ptr=ptr->next;
		};
	}
	ProcessMore(src, dst, IN_AES, line);

	ProcessMore(src, dst, IN_UNKNOWN, line);

	ProcessEnd(src, dst, line);

	return(FALSE);
}


char *GetPosition(char *src, char *string)
{
long len;
	len=strlen(string);
	while(*src)
	{
		if(strncmpi(src,string,len)==0)
			return(src);
		while((*src)&&(*src!=0x0a))
			src++;
		src++;
	}
	return(NULL);
}

char *GetLine(char *dst, char *src)
{
	while(*src)
	{
		if((unsigned char)*src>=' ')
			*dst++=*src;
		else if(*src==0x0a)
			break;
		src++;
	}
	*dst=0;

	if(*src)
		return(++src);

	return(src);
}

void NoComments(char *str)
{
char *start=str;
	while(*str)
	{
		if(*str==';')
			break;
		str++;
	}
	*str--=0;
	while((str>start)&&(*str==' '))
		*str--=0;
}

char *GetDataStart(char *ptr, int cnt)
{
	while(cnt)
	{
		if(ptr)
		{
			ptr=strchr(ptr,' ');
			if(ptr)
			{
				do
				{
					ptr++;
				}while(*ptr==' ');
			}
		}
		cnt--;
	}
	return(ptr);
}

long GetmaxLinesize(char *src)
{
long maximum=0,length;
	while(*src)
	{
		length=0;
		while(*src)
		{
			if((unsigned char)*src>=' ')
				length++;
			else if(*src==0x0a)
				break;
			src++;
		}
		maximum=max(maximum,length);
		src++;
	}

	return(maximum);
}
