#include <tos.h>
#include <aes.h>
#define USE_SHUTDOWNPRG 1


#if USE_SHUTDOWNPRG
#include <stdlib.h>
#include <string.h>
#define SHUTDOWNPRG "C:\\GEMSYS\\GEMDESK\\SHUTDOWN.PRG"
#else
#include <stdio.h>
#endif

int devices[]={1,1,3,6};



int main( void )
{
#if USE_SHUTDOWNPRG
	WORD ret;
	WORD dev;
	char tail[128];


	ret = appl_init();
	if	(ret < 0)
		return(-1);

	dev = form_alert(0,"[2][Welche Ger„tenummer fr VDI?][1|3|6]");
	if	((dev > 0) && (dev < 4))
		{
		itoa(dev, tail+1, 10);
		tail[0] = strlen(tail+1);
		ret = shel_write(SHW_EXEC, TRUE, SHW_CHAIN, SHUTDOWNPRG, tail);
		if	(!ret)
			return(-1);
		}
	appl_exit();
	return(0);

#else

    int     msgbuf[8];
    char    ignorantname[32], text[128];
    int     s,pid, dummy,dev;

    appl_init();

    dev=form_alert(0,"[2][Welches Device: |shel_write(5,dev,0,0L,0L)][1|3|6]");

    /* Reschange starten */
    if (shel_write(5,devices[dev], 0, NULL, NULL) == 0)
    {

        form_alert(1, "[3][shel_write() liefert Fehler][ OK ]");

        /* Jemand versteht AP_TERM nicht */
        s=0;
        while(appl_search(s, ignorantname, &dummy, &pid)==1)
        {
            sprintf(text,
                    "[4][Die Anwendung %s|kann sich nicht beenden.]"
                    "[Schade|Anwendung abbrechen]",
                    ignorantname);

            if (form_alert(2, text) == 2)
            {
                Pkill(pid, SIGTERM);
                Fselect(2000, NULL, NULL, NULL);    /* 2sec Ruhe */
            }
            s=1;
        }
    }
    else
    {
        /* Reschange erfolgreich gestartet. Nun auf eine
         * Antwort vom AES warten,mal ohne timeout! */
        do { evnt_mesag(msgbuf); } while (msgbuf[0] != RESCH_COMPLETED);

        if (msgbuf[3] == 0)
        {
            /* Reschange wurde aktiv abgelehnt */
            appl_search(-msgbuf[4], ignorantname, &dummy, &pid);
            sprintf(text, "[4][Die Anwendung %s|"
                          "hat den Reschange abgelehnt|Fehlercode = %d]"
                          "[ OK ]",
                          ignorantname, msgbuf[5]);
            form_alert(1, text);
            
        }
        else
        {
            /* Reschange war erfolgreich */
            form_alert(1, "[4][Reschange erfolgreich beendet.][ OK ]");
         }
    }

    appl_exit();
    return 0;
#endif
}
