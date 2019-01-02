/*
	@(#)spin/cfgread.c
	
	2b included from FS specific init function
	
	Julian F. Reschke, 30. Mai 1997
*/

char *
sccsid (void)
{
#ifdef MINT
	return "@(#)spin.xfs " VERSIONSTRING ", Copyright (c) Julian F. Reschke, " __DATE__;
#endif
#ifdef MAGIC
	return "@(#)spinmxfs.prg " VERSIONSTRING ", Copyright (c) Julian F. Reschke & Andreas Kromke, " __DATE__;
#endif
}


/* eingelesene Konfigurationsdatei parsen */

static char *
strtok2 (char **string, char *toks)
{
	char *s1 = *string;
	char *ret;

	if (! *string) return NULL;

	while (s1 == (ret = strpbrk (s1, toks)))
		s1 += 1;
	
	/* Anfang des Tokens gefunden */
	ret = s1;
	
	/* Ende suchen */;
	s1 = strpbrk (ret, toks);

	if (!s1)	/* kein weiteres */
		*string = NULL;
	else
	{
		*s1++ = '\0';
		*string = *s1 ? s1 : NULL;
	}
	
	return ret;
}

static int drive_from_letter(int drv)
{
	if (drv >= 'A' && drv <= 'Z')
		drv = drv - 'A';
	else if (drv >= 'a' && drv <= 'z')
		drv = drv - 'a';
	else if (drv >= '1' && drv <= '6')
		drv = (drv - '1') + 26;
	else
		return -1;
	return drv;
}


static int letter_from_drive(int drv)
{
	return drv >= 26 ? drv - 26 + '1' : drv + 'A';
}


static void
parse_line (char *line)
{
	char *l = line;
	char *c = strtok2 (&l, ",");
	char *driver;
	char *args;
	int cacheblocks = DEFAULTCACHESIZE;
	LONG data;		/* for kernel__sprintf */
	char *str;

	if (!c) return;
	
	driver = strtok2 (&l, ",");
	if (!driver) return;

	args = l;
	if (!args) return;
	
	l = driver;
	driver = strtok2 (&l, " \t");
	
	c = strrchr (driver, '\\');
	if (c) driver = c + 1;
	c = strrchr (driver, ':');
	if (c) driver = c + 1;

	/* Falscher Treibername? */
	if (stricmp (driver, "hs-iso.dos") &&
		stricmp (driver, "iso9660f.dos")) return;

	/* Parameter? */
	if (l)
	{
		if (l[0] == '-' && l[1] == 'c') {
			long cachesize = 0;
			char *c = l + 2;
		
			while (*c == ' ') c += 1;
			while (isdigit (*c)) {
				cachesize *= 10;
				cachesize += *c - '0';
				c += 1;
			}

			cachesize /= 2;
			if (cachesize > DEFAULTCACHESIZE && cachesize < 500)
				cacheblocks = (int) cachesize;
		}
	}
	
	/* Cache anlegen... */
	if (!DCSize)
	{
		char buf[80];
		size_t cachesize = cacheblocks * sizeof (CACHEENTRY);

		DCCache = Mxalloc (cachesize, 2);

		if (!DCCache && cacheblocks > DEFAULTCACHESIZE)
		{
			cacheblocks = DEFAULTCACHESIZE;
			cachesize = cacheblocks * sizeof (CACHEENTRY);
			DCCache = Mxalloc (cachesize, 2);
		}

		data = cachesize / 1024;

		if (DCCache)
		{
			memset (DCCache, 0, cachesize);
			DCSize = cacheblocks;
			kernel__sprintf(buf,
						"(%L Kbytes of sector cache)\r\n",
						&data);
			Cconws (buf);
		}
		else
		{
			kernel__sprintf(buf,
					"Can't allocate %L bytes for sector caching, aborting...\r\n",
					&data);
			Cconws (buf);
			return;			
		}
	}
	
	
	/* Geraete eintragen */
	l = args;
	args = strtok2 (&l, " ,\t");
	
	while (args)
	{
		int dosdrive, metadrive;

		if (strlen (args) == 3 && args[1] == ':' &&
			(dosdrive = drive_from_letter(args[0])) >= 0 &&
			(metadrive = drive_from_letter(args[2])) >= 0)
		{
			str = "MetaDOS XBIOS device X on X:\r\n";
			str[21] = letter_from_drive(metadrive);
			str[26] = letter_from_drive(dosdrive);
			Cconws (str);
			
			mydrives[dosdrive] = Mxalloc (sizeof (LOGICAL_DEV), 0);
			if (!mydrives[dosdrive])
			{
				str = "Not enough memory for drive X:\r\n";
				str[28] = dosdrive;
				Cconws (str);
			}
			else
			{
				memset (mydrives[dosdrive], 0, sizeof (LOGICAL_DEV));
				mydrives[dosdrive]->metadevice = letter_from_drive(metadrive);
			}
		}

		args = strtok2 (&l, " ,\t");	
	}
}

static int
parse_config (char *conf)
{
	char *c = conf;
	char *line = strtok2 (&c, "\r\n");
	
	while (line) {
		if (!strnicmp (line, "*DOS,", 5))
			parse_line (line);
		
		line = strtok2 (&c, "\r\n");
	}

	return 1;
}


/* Konfigurationsdatei einlesen */

static int
read_config (void)
{
	long handle, filesize, count;
	char *scratch;
	int isok;
		
	handle = Fopen ("\\auto\\config.sys", 0);
	
	if (handle < 0) {
		Cconws ("Can't open `\\auto\\config.sys'!\r\n");
		return 0;
	}

	filesize = Fseek (0L, (int) handle, 2);
	Fseek (0L, (int) handle, 0);

	scratch = Malloc (filesize);
	if (!scratch) {
		Fclose ((int) handle);
		Cconws ("Not enough memory!\r\n!");
		return 0;
	}
	
	count = Fread ((int) handle, filesize, scratch);
	if (count != filesize) {
		Fclose ((int) handle);
		Cconws ("Read error in `\\auto\\config.sys'!\r\n!");
		return 0;
	}
	
	Fclose ((int) handle);

	isok = parse_config (scratch);

	Mfree (scratch);
	
	if (!isok && DCCache) Mfree (DCCache);
	
	return isok;
}
