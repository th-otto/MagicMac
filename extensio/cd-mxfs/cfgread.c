/*
	@(#)spin/cfgread.c
	
	2b included from FS specific init function
	
	Julian F. Reschke, 30. Mai 1997
*/

char *
sccsid (void)
{
#ifdef MINT
	return "@(#)spin.xfs "VERSIONSTRING", Copyright (c) Julian F. Reschke, "__DATE__;
#endif
#ifdef MAGIC
	return "@(#)spinmxfs.prg "VERSIONSTRING", Copyright (c) Julian F. Reschke & Andreas Kromke, Jun  1 1997";
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

static void
parse_line (char *line)
{
	char *l = line;
	char *c = strtok2 (&l, ",");
	char *driver;
	char *args;
	int cacheblocks = DEFAULTCACHESIZE;
	
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

		DCCache = MXALLOC (cachesize, 2);

		if (!DCCache && cacheblocks > DEFAULTCACHESIZE)
		{
			cacheblocks = DEFAULTCACHESIZE;
			cachesize = cacheblocks * sizeof (CACHEENTRY);
			DCCache = MXALLOC (cachesize, 2);
		}

		if (DCCache)
		{
			memset (DCCache, 0, cachesize);
			DCSize = cacheblocks;
			SPRINTF (buf, "(%ld Kbytes of sector cache)\r\n", cachesize / 1024);
			CCONWS (buf);
		}
		else
		{
			SPRINTF (buf, "Can't allocate %ld bytes for sector caching, aborting...\r\n", cachesize / 1024);
			CCONWS (buf);
			return;			
		}
	}
	
	
	/* Ger„te eintragen */
	l = args;
	args = strtok2 (&l, " ,\t");
	
	while (args)
	{
		if (strlen (args) == 3 && args[1] == ':' &&
			isalpha (args[0]) && isalpha (args[2]))
		{
			int dosdrive, metadrive;
			char buf[80];
			
			SPRINTF (buf, "MetaDOS XBIOS device %c on %c:\r\n",
				args[2], args[0]);
			CCONWS (buf);
			
			dosdrive = toupper (args[0]) - 'A';
			metadrive = toupper (args[2]);

			mydrives[dosdrive] = MXALLOC (sizeof (LOGICAL_DEV), 0);
			if (!mydrives[dosdrive])
			{
				SPRINTF (buf, "Not enough memory for drive %c:\r\n", dosdrive);
				CCONWS (buf);
			}
			else
			{
				memset (mydrives[dosdrive], 0, sizeof (LOGICAL_DEV));
				mydrives[dosdrive]->metadevice = metadrive;
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
		
	handle = FOPEN ("\\auto\\config.sys", 0);
	
	if (handle < 0) {
		CCONWS ("Can't open `\\auto\\config.sys'!\r\n");
		return 0;
	}

	filesize = FSEEK (0L, (int) handle, 2);
	FSEEK (0L, (int) handle, 0);

	scratch = KMALLOC (filesize);
	if (!scratch) {
		FCLOSE ((int) handle);
		CCONWS ("Not enough memory!\r\n!");
		return 0;
	}
	
	count = FREAD ((int) handle, filesize, scratch);
	if (count != filesize) {
		FCLOSE ((int) handle);
		CCONWS ("Read error in `\\auto\\config.sys'!\r\n!");
		return 0;
	}
	
	FCLOSE ((int) handle);

	isok = parse_config (scratch);

	KFREE (scratch);
	
	if (!isok && DCCache) MFREE (DCCache);
	
	return isok;
}