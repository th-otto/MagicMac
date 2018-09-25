/*
* Konvertiert CR -> CR/LF
*/

#include <tos.h>
#include <tosdefs.h>


int main(int argc, char *argv[])
{
	int hdl;
	char	buf[1024];
	long l;
	register int i;
	register char *s;


	if	(argc != 2)
		{
		Cconws("Syntax: MAC2ST datei\r\n");
		return(-1);
		}

	hdl = (int) Fopen(argv[1], RMODE_RD);
	if	(hdl < 0)
		return(hdl);	

	do	{
		l = Fread(hdl, 1024L, buf);
		for	(s = buf,i=0; i < l; i++,s++)
			{
			if	(*s == '\r')
				Cconws("\r\n");
			else	Cconout(*s);
			}
		}
	while(l == 1024L);
	return(0);
}