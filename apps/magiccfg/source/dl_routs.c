#include <tos.h>
#include <gemx.h>
#include <scancode.h>
#include "diallib.h"

void ConvertKeypress(int *key,int *kstate);
void CopyMaximumChars(OBJECT *obj,char *str);
char *ParseData(char *start);
/* int rc_intersect(GRECT *p1,GRECT *p2); */
void Debug(char *str,...);


void ConvertKeypress(int *key,int *kstate)
{
int ascii=*key & 0xff;
int scan=(*key>>8) & 0xff;
	if(!scan)								/*	Falls kein Scancode vorhanden ist,	*/
		return;								/*	dann gibt's nichts zu tun!	*/

	if((scan>=KbAlt1)&&(scan<=0x83))	/*	Alt+Numerische Tasten...	*/
		scan-=0x76;							/*	in Numerische Tasten wandeln	*/

	if(((scan>=99)&&(scan<=114))		/*	Zahlenblock Tasten...	*/
			||(scan==74)||(scan==78))
		*kstate|=KbNUM;

	if((scan>=115)&&(scan<=119))		/*	CTRL+Kombinationen...	*/
	{
		*kstate|=KbCTRL;
		switch(scan)
		{
			case 115:
				scan=KbLEFT;
				break;
			case 116:
				scan=KbRIGHT;
				break;
			case 117:			/*	CTRL + END	*/
				break;
			case 118:			/*	CTRL + PAGE DOWN	*/
				break;
			case 119:
				scan=KbHOME;
				break;
		}
	}

	if(*kstate & (KbCTRL|KbALT))			/*	CTRL und ALT Kombinationen ?	*/
		ascii=key_table->caps[scan];	/*	in Grossbuchstaben umwandeln	*/

	*key=(scan<<8)+ascii;
}

void CopyMaximumChars(OBJECT *obj,char *str)
{
int max_size=obj->ob_spec.tedinfo->te_txtlen-1;
	strncpy(obj->ob_spec.tedinfo->te_ptext,str,max_size);
	obj->ob_spec.tedinfo->te_ptext[max_size]=0;
}

char *ParseData(char *start)
/*
	Liefert in <start> den ersten Parameter und gibt den Pointer
	auf den n„chsten Parameter zurck.
	Um alle Parameter zu erfahren muss man folgendermassen vorgehen:

	{
	char *next,*ptr=data;
		do
		{
			next=ParseData(ptr);
			DoSomething(ptr);
			ptr=next;
		}while(*next);
	}
*/
{
int in_quote=0, more=FALSE;
	while(*start)
	{
		if(*start==' ')
		{
			if(!in_quote)
			{
				*start=0;
				more=TRUE;
			}
			else
				start++;
		}
		else if(*start=='\'')
		{
			strcpy(start,start+1);
			if(*start=='\'')
				start++;
			else
				in_quote=1-in_quote;
		}
		else
			start++;
	}
	if(more)
		return(start+1);
	else
		return(start);
}

#if 0
int rc_intersect(GRECT *p1,GRECT *p2)
{
int tx,ty,tw,th;
	tw=min((p2->g_x+p2->g_w),(p1->g_x+p1->g_w));
	th=min(p2->g_y+p2->g_h,p1->g_y+p1->g_h);
	tx=max(p2->g_x,p1->g_x);
	ty=max(p2->g_y,p1->g_y);
	p2->g_x=tx;
	p2->g_y=ty;
	p2->g_w=tw-tx;
	p2->g_h=th-ty;
	return((tw>tx)&&(th>ty));
};
#endif

void Debug(char *str,...)
{
void *list=...;
char temp[120],c,*ptr;
int is_l,done;
	ptr=temp;
	while(*str)
	{
		c=*str++;
		if(c=='%')
		{
			done=FALSE;
			is_l=FALSE;
			do
			{
				c=*str++;
				if(c=='l')
					is_l=TRUE;
				else if(c=='d')
				{
					if(is_l)
						ltoa((*((long *)(list))++),ptr,10);
					else
						itoa((*((int *)(list))++),ptr,10);
					done=TRUE;
				}
				else if(c=='u')
				{
					if(is_l)
						ultoa((*((unsigned long *)(list))++),ptr,10);
					else
						ultoa((unsigned long)(*((unsigned int *)(list))++),ptr,10);
					done=TRUE;
				}
				else if(c=='x')
				{
					*ptr++='0';
					*ptr++='x';
					if(is_l)
						ltoa((*((unsigned long *)(list))++),ptr,16);
					else
						itoa((*((unsigned int *)(list))++),ptr,16);
					done=TRUE;
				}
				else if(c=='s')
				{
				char *src=(*((char **)(list))++);
					while(*src)
						*ptr++=*src++;
					*ptr=0;
					done=TRUE;
				}
				else if(c=='c')
				{
					*ptr=(char)(*((int *)(list))++);
					if(*ptr)
						*(++ptr)=0;
					done=TRUE;
				}
				else
					done=TRUE;
			}while(!done);

			while(*ptr)
				ptr++;
		}
		else
			*ptr++=c;
	};
	*ptr=0;

	Fwrite(4 /*STDERR_FILENO*/,strlen(temp),temp);
	Fwrite(4 /*STDERR_FILENO*/,2,"\r\n");
}
