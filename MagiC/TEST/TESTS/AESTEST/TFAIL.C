/*
*
* Dieses Programm reagiert auf AP_TERM immer mit AP_TFAIL
*
*/

#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <magx.h>

#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

#ifndef NULL
#define NULL ((char *) 0)
#endif

int main()
{
	int buf[8];


	appl_init();

	/* dem AES sagen: ich verstehe AP_TERM */
	shel_write(SHW_INFRECGN, 1, 0, NULL, NULL);

	for	(;;)
		{
		evnt_mesag(buf);
	
		if	(buf[0] == AP_TERM)
			{
			printf("AP_TERM. Grund: %d\r\n", buf[5]);
			buf[0] = AP_TFAIL;
			buf[1] = 4711;
			shel_write(SHW_AESSEND, 0, 0, (void *) buf, NULL);
			}

		else	{
			Cconws("Unbekannte Nachricht empfangen.\r\n");
			printf("Code %d\n", buf[0]);
			Cconin();
			appl_exit();
			return(2);
			}
		}
}
