/*********************************************************************
*
* FÅr die Mag!X 3 - Version von MAGXDESK
*
* Zeigt eine Datei an.
*
*********************************************************************/

#include <tos.h>
#include <tosdefs.h>
#include <country.h>

#define TRUE 1
#define FALSE 0
#define NULL ((char *) 0)

/* Keybord states */

#define K_RSHIFT        0x0001
#define K_LSHIFT        0x0002
#define K_CTRL          0x0004
#define K_ALT           0x0008

long show_file(char *path);

int main(int argc, char *argv[])
{
	for	(argc--;argc;argc--)
		show_file(argv[argc]);
	return(0);
}


/****************************************************************
*
* Eine Datei wird angezeigt.
*
****************************************************************/

unsigned char waitkey( void )
{
	int st;
	int was0 = FALSE;
/*	extern int vdi_handle; */

	while(TRUE)
		{
		if	(Bconstat(CON))
			return((unsigned char) Bconin(CON));
/*		vq_mouse(vdi_handle, &st, &dummy, &dummy); */
st = 0;


		if	(!(st & 3))
			was0 = TRUE;
		if	(!was0)
			continue;
		if	(st & 1)			/* linke Maustaste */
			return(' ');
		if	(st & 2)			/* rechte Maustaste */
			return('Q');
		}
}

void str_conout(char *s, int len)
{
	while(len--)
		Bconout(CON, *s++);
}

void init_vt52( void )
{
	str_conout("\x1b" "E"		/* Clear- Home				*/
		 	 "\x1b" "b\xff"	/* Schriftfarbe schwarz		*/
		 	 "\x1b" "c\0"		/* Hintergrundfarbe weiû		*/
		 	 "\x1b" "e"		/* Cursor einschalten		*/
		 	 "\x1b" "q"		/* Reverse aus				*/
		 	 "\x1b" "v", 14);	/* Automatischer öberlauf ein */
}

long show_file(char *path)
{
	char *buf;
	int  mode = FALSE;
	int  handle = 0;
	int  ypos = 0;
	unsigned char t;
	long doserr,lbytes;
	const long bsize = 4*1024L;



	if	(NULL == (buf = Malloc(bsize)))
		doserr = ENSMEM;
	else doserr = Fopen(path, O_RDONLY);

	if	(doserr >= E_OK)
		{
		handle = (int) doserr;
		init_vt52();
		do	{
			fillbuf:

			doserr = Fread(handle, bsize, buf);
			if	(doserr > 0)
				{
				char c;
				int  s;

				for	(lbytes = 0; lbytes < doserr; lbytes++)
					{
					while(Kbshift(-1) & (K_LSHIFT | K_RSHIFT))
						mode = TRUE;
					c = buf[lbytes];
					s = (int) Bconstat(CON);
					if	(s || (!mode && c == '\n'))
						{
						mode = FALSE;
						ypos++;
						if	(s || ypos > 22)
							{
							long  fpos;

							if	(!s)
#if		COUNTRY==COUNTRY_DE
								str_conout("\r\n--Mehr-- "
										 "\x1b" "e", 13);
#elif	COUNTRY==COUNTRY_US
								str_conout("\r\n--More-- "
										 "\x1b" "e", 13);
#elif	COUNTRY==COUNTRY_FR
								str_conout("\r\n--Plus-- "
										 "\x1b" "e", 13);
#endif
							t = waitkey();
							if	(!s)
								str_conout("\x1b" "l", 2);
							if	(t >= 'a')
								t &= 0x5f;
							switch(t)
								{
								case 3:
								case 'Q':
								case 'N': doserr = EBREAK;
										break;
								case 'G': mode = TRUE;
										break;
								case ' ': ypos = 0;
										break;
								case 'D': ypos = 11;
										break;
								case '+': back:
								case '-':	str_conout("\r\n\n"
"------------------------------------------------------------------------------"
"\r\n\n", 84);
										fpos = Fseek(0L, handle, 1);
										if	(fpos < E_OK)
											{
											doserr = EBREAK;
											break;
											}
										fpos += lbytes - doserr;
										fpos += (t == '+') ? 4096L : -4096L;
										if	(fpos < 0)
											fpos = 0;
										fpos = Fseek(fpos, handle, 0);
										if	(fpos < E_OK && fpos != ERANGE)
											{
											doserr = EBREAK;
											break;
											}
										ypos = 0;
										goto fillbuf;
								default:  ypos = 22;
								}
							if	(doserr == EBREAK)
								break;
							if	(!s)
								continue;
							}
						}

					/* Anpassung fÅr Wordplus- Codierung */
					/* --------------------------------- */

					if	(c == 0x1c || c == 0x1d || c == 0x1e)
						c = ' ';
					Bconout(CON, c);
					}
				}
			}
		while(doserr > 0); 
		}

	if	(doserr >= E_OK)
		{
		str_conout("\r\n--EOF-- " "\x1b" "e", 12);
		t = waitkey();
		if	(t == '-')
			{
			lbytes = doserr = 0L;
			goto back;
			}
		}

	if	(buf)
		Mfree(buf);
	if	(handle)
		{
		Fclose(handle);
		}
	return(doserr);
}
