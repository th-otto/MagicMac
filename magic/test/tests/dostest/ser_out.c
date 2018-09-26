#include <tos.h>
#include <stdio.h>
#include <stdlib.h>

#define	TIOCFLUSH		(('T'<< 8) | 8)#define	TIOCIBAUD		(('T'<< 8) | 18)#define	TIOCOBAUD		(('T'<< 8) | 19)#define	TIOCGFLAGS		(('T'<< 8) | 22)#define	TIOCSFLAGS		(('T'<< 8) | 23)
/* Anzahl der Stoppbits */
#define TF_STOPBITS 0x0003
/* 0x0000  nicht erlaubt
ERWEITERUNGSVORSCHLAG: So wird der Synchronmode aktiviert. Die restlichen 
Parameter erhalten im Synchronmode andere Bedeutungen. Diese sind sp„ter 
noch festzulegen. */
#define TF_1STOP   0x0001 /* 1 Stoppbit */
#define TF_15STOP  0x0002 /* 1.5 Stoppbit */
#define TF_2STOP   0x0003 /* 2 Stoppbit */

/* Anzahl der Bits pro Zeichen */
#define TF_CHARBITS 0x000C
#define TF_8BIT	0x0 /* 8 Bit */
#define TF_7BIT	0x4
#define TF_6BIT	0x8
#define TF_5BIT	0xC /* 5 Bit */

/* Handshakemodi und Parit„t */
#define TF_FLAG  0xF000
#define T_TANDEM 0x1000 /* XON/XOFF (=^Q/^S) Flužkontrolle aktiv */
#define T_RTSCTS 0x2000 /* RTS/CTS Flužkontrolle aktiv */
#define T_EVENP  0x4000 /* even (gerade) Parit„t aktiv */
#define T_ODDP   0x8000 /* odd (ungerade) Parit„t aktiv */
/* even und odd schliežen sich gegenseitig aus */


#define BUFSIZ 1024

char buf[BUFSIZ];

int main(int argc, char *argv[])
{
	char *filename;
	long err;
	int fh,auxfh;
	/* 57600 baud, 1 Stop-Bit, 8 Bit, RTS/CTS, keine Parit„t */
	long speed = 57600L;
	int flags = TF_1STOP + TF_8BIT + T_RTSCTS;
	long read;


	if	(argc != 2)
	{
		Cconws("Syntax: ser_out file\r\n");
		return(1);
	}

	/* Serielle Schnittstelle ”ffnen */

	err = Fopen("u:\\dev\\aux", O_WRONLY);
	if	(err < 0)
	{
		Cconws("Fehler beim ™ffnen von AUX\r\n");
		return((int) err);
	}

	auxfh = (int) err;

	/* serielle Schnittstelle konfigurieren */

	err = Fcntl(auxfh, (long) &speed, TIOCOBAUD);
	if	(err < 0)
	{
		Cconws("Fehler bei Fcntl(TIOCOBAUD)\r\n");
		Fclose(auxfh);
		return((int) err);
	}

	err = Fcntl(auxfh, (long) &flags, TIOCSFLAGS);
	if	(err < 0)
	{
		Cconws("Fehler bei Fcntl(TIOCSFLAGS)\r\n");
		Fclose(auxfh);
		return((int) err);
	}

	/* Datei fr Ausgabe ”ffnen */

	filename = argv[1];
	err = Fopen(filename, O_RDONLY);
	if	(err < 0)
	{
		Cconws("Fehler beim ™ffnen der auszugebenden Datei\r\n");
		Fclose(auxfh);
		return((int) err);
	}

	fh = (int) err;

	/* Ausgabe */

	do
	{
		err = Fread(fh, BUFSIZ, buf);
		if	(err < 0)
		{
			Cconws("Fehler beim Lesen der auszugebenden Datei\r\n");
			break;
		}
		read = err;
		err = Fwrite(auxfh, read, buf);
		if	(err < 0)
		{
			Cconws("Fehler beim Schreiben auf AUX\r\n");
			break;
		}
	}
	while((!err) && (read == BUFSIZ));

	Fclose(fh);
	Fclose(auxfh);

	return(0);
}