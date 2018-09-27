/*
*
* Entfernt die Aus- und Eingabe aus einer SFX-
* Datei, damit das Entpacken unsichtbar durchgefhrt
* werden kann.
*
*/

#include <tos.h>
#include <string.h>

static LONG fast_sfx( char *path );

int main(int argc, char *argv[])
{
	LONG doserr;


	if	(argc < 2)
		{
		Cconws("FAST_SFX sfx1 sfx2 ...\r\n");
		return(1);
		}
	argc--;
	argv++;
	while(argc)
		{
		doserr = fast_sfx(*argv);
		if	(doserr)
			return((int) doserr);
		argc--;
		argv++;
		}

	return(0);
}

static LONG fast_sfx( char *path )
{
	PH ph;
	LONG doserr;
	WORD h;
	LONG pos;
	char buf[16];


	Cconws("Bearbeite ");
	Cconws(path);
	Cconws("\r\n");
	doserr = Fopen(path, O_RDWR);
	if	(doserr < 0)
		return(doserr);
	h = (WORD) doserr;
	doserr = Fread(h, sizeof(PH), &ph);
	if	(doserr < 0)
		{
		err:
		Fclose(h);
		return(doserr);
		}
	if	(doserr != sizeof(PH))
		{
		err2:
		doserr = ERROR;
		goto err;
		}
	if	(ph.branch != PH_MAGIC)
		{
		doserr = EPLFMT;
		goto err;
		}

	pos = ph.tlen - (0x1aa2 - 0x19d4) + sizeof(PH);
	doserr = Fseek(pos, h, 0);
	if	(doserr != pos)
		goto err2;
	doserr = Fread(h, 16, buf);
	if	(doserr != 16)
		goto err2;
	if	(memcmp(buf,	"\x48" "\x52"
					"\x3f" "\x3c"
					"\x00" "\x01"
					"\x4e" "\x41",
					8))
		{
		sfx_err:
		Cconws("Datei kein SFX oder schon behandelt!\r\n");
		goto err2;
		}
	doserr = Fseek(pos, h, 0);
	if	(doserr != pos)
		goto err2;
	doserr = Fwrite(h, 2, "\x4e" "\x75");
	if	(doserr < 0)
		goto err;
	if	(doserr != 2)
		goto err2;


	pos = ph.tlen - (0x1aa2 - 0x1a5e) + sizeof(PH);
	doserr = Fseek(pos, h, 0);
	if	(doserr != pos)
		goto err2;
	doserr = Fread(h, 16, buf);
	if	(doserr != 16)
		goto err2;
	if	(memcmp(buf,	"\x48" "\x52"
					"\x48" "\x50"
					"\x3f" "\x3c"
					"\x00" "\x09"
					"\x4e" "\x41",
					10))
		goto sfx_err;
	doserr = Fseek(pos, h, 0);
	if	(doserr != pos)
		goto err2;
	doserr = Fwrite(h, 2, "\x4e" "\x75");
	if	(doserr < 0)
		goto err;
	if	(doserr != 2)
		goto err2;

	Fclose(h);
	return(E_OK);	
}