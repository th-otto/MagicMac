#include <tos.h>
#include <gemx.h>
#include <av.h>
#include "diallib.h"
#include SPEC_DEFINITION_FILE

#if USE_AV_PROTOCOL != NO


#if USE_AV_PROTOCOL >= 2			/*	normales/maximales AV-Protokoll	*/
void DoVA_PROTOSTATUS(int msg[8]);
void DoAV_PROTOKOLL(int flags);
void DoAV_EXIT(void);
#endif


#if USE_AV_PROTOCOL >= 2
/*
 *		Normales AV-Protokoll: Anmelden und Abmelden beim Server
 */

int server_id=0;								/*	Programm ID des Servers	*/
long server_cfg;


/************************************************
 *		VA-Befehle, bzw. Antworten vom Server		*
 ************************************************/

/*	Antwort des Servers auf AV_PROTOKOLL	*/
void DoVA_PROTOSTATUS(int msg[8])
{
char *server_name=*(char **)&msg[6];
	*(int *)&server_cfg=msg[4];
	*((int *)&server_cfg+1)=msg[3];
#if DEBUG==ON
	Debug("Server name: %s  protocol: %lx",server_name,server_cfg);
#endif
}

/************************************************
 *		AV-Befehle, bzw. Kommandos an den Server	*
 ************************************************/

/*	Anmeldung beim Server (unter Angabe des Protokolls)	*/
void DoAV_PROTOKOLL(int flags)
{
char *avserver=NULL;
	if(shel_envrn(&avserver,"AVSERVER=") && avserver)
	{
	int msg[8]={AV_PROTOKOLL,0,0,0,0,0};
	char avserver_name[9],*dst=avserver_name;
	char *appl_name=PROGRAM_UNAME;
#if DEBUG==ON
		Debug("AVSERVER=%s",avserver);
#endif

		while(*avserver && (dst<&avserver_name[8]))
			*dst++=*avserver++;

		while(dst<&avserver_name[8])
			*dst++=' ';
		*dst=0;

		server_id=appl_find(avserver_name);
		if(server_id>=0)
		{
#if DEBUG==ON
			Debug("ID: %d",server_id);
#endif
			msg[1]=ap_id;
			msg[3]=flags;
			*(char **)&msg[6]=appl_name;
			appl_write(server_id,16,msg);
		}
#if DEBUG==ON
		else
			Debug("AVSERVER nicht gestartet!");
#endif
	}
#if DEBUG==ON
	else
		Debug("Kein AVSERVER gefunden!");
#endif
}

/*	Teilt dem Server mit, dass die Applikation nicht mehr am Protokoll teilnimmt	*/
void DoAV_EXIT(void)
{
int msg[8]={AV_EXIT,0,0,0,0,0,0,0};
	msg[1]=ap_id;
	msg[3]=ap_id;
	appl_write(server_id,16,msg);
}

#endif	/* USE_AV_PROTOCOL >= 2	*/
#endif	/*	USE_AV_PROTOCOL != NO	*/