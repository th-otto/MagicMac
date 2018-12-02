#include <tos.h>
#include <stdio.h>
#include <mint/dcntl.h>

int main(int argc, char *argv[])
{
	struct ploadinfo plf;
	char fname[128] /*= "ABCDEFGHIJKLMNOPQRSTUVWXYZŽ™š"*/;
	char cmdlin[128];
	long err;
	int hdl;


	if	(argc != 2)
		{
		Cconws("PLOADINF <Pfad>\r\n");
		return(1);
		}
	plf.fnamelen = 128;
	plf.fname = fname;
	plf.cmdlin = cmdlin;
	err = Fopen(argv[1], O_RDONLY);
	if	(err < 0)
		{
		printf("Fopen => %ld\n", err);
		return((int) err);
		}
	hdl = (int) err;
	err = Fcntl(hdl, (long) &plf, PLOADINFO);
	Fclose(hdl);
	if	(err < 0)
		{
		printf("Fopen => %ld\n", err);
		return((int) err);
		}
	printf("Name = \"%s\"\n", plf.fname);
/*	Fwrite(1, 30, fname);	*/
	err = plf.cmdlin[0];
	Cconws("Kommando = \"");
	Fwrite(1, err, plf.cmdlin+1);
	Cconws("\"");
	return(0);
}
