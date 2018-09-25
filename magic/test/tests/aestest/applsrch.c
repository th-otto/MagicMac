#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <tosdefs.h>
#include <aes.h>
#include <magx.h>
#include <ctype.h>

int main()
{
	char apname[16];
	register int i;
 	int aptyp, apid;


	appl_init();

	/* sfirst */
	i = appl_search(0, apname, &aptyp, &apid);
	while(i)
		{
		printf("Name = \"%s\" typ = %2d apid = %d\n",
				apname, aptyp, apid);
		i = appl_search(1, apname, &aptyp, &apid);
		}

	appl_exit();
	return(0);
}
