#include <aes.h>
#include <magix.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <tos.h>

void main()
{
	char	input[10];
	char	c;
	int	id,id2;
	long	code;
	long	i;


	appl_init();
	printf("P = pid->ap_id   A = ap_id->pid   N = Name->ap_id  ");
	do	{
		c = 0x5f & Cconin();
		}
	while(c != 'P' && c != 'A' && (c != 'N'));
	code = (c == 'P') ? 0xffff : 0xfffe;
	Cconws("\r\n");
	
	for	(;;)
		{
		Cconws("Zu konvertierende id ");
		i = Fread(0, 9L, input);
		if	(i <= 0)
			return;
		input[i] = '\0';
		if	(c == 'N')
			{
			strupr(input);
			while(strlen(input) < 8)
				strcat(input, " ");
			id = appl_find(input);
			printf("Name \"%s\" ===> apid %d          \n", input, id);
			}
		else	{
			id = atoi(input);
	
			i = (code << 16) | id;
	
			id2 = appl_find((void *) i);
			if	(c == 'A')
			printf("apid %d ===> pid %d          \n", id, id2);
			else	printf("pid %d ===> apid %d          \n", id, id2);
			}
		}
}