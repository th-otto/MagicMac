/*
*
* Test zum NachrichtenÅberlauf. Schickt Nachrichten
* an ein beliebiges Programm, dessen ap_id Åbergeben wird.
*
*/

#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[])
{
	int id;
	int buf[8];


	if	(argc != 2)
		{
		Cconws("Syntax: MSG_OVL ap_id\r\n");
		return(1);
		}

	id = atoi(argv[1]);
	for	(;;)
		appl_write(id, 16, buf);
}
