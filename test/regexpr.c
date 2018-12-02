/*********************************************************************
*
* Dieses Modul enthaelt die Pattern-Match-Routine.
*
*********************************************************************/

#include <portab.h>
#include <tos.h>
#include <string.h>

/*********************************************************************
*
*  Meine "toupper" mit Beruecksichtigung von Umlauten.
*
*********************************************************************/

static char toupper(unsigned char c)
{
	register char *s;
	static char lower_s[] = "\204\224\201\202\205\206\207\221\244\260\261\263\264\300";
	static char upper_s[] = "\216\231\232\220\266\217\200\222\245\267\270\262\265\301";

	if (c < 'a')
		return (c);
	if (c <= 'z')
		return (c & 0x5f);
	if ((s = strchr(lower_s, c)) == NULL)
		return c;
	return (upper_s[s - lower_s]);
}


/*********************************************************************
*
* Wandelt eine Zeichenkette in Grossschrift um.
*
*********************************************************************/

static void upperstring(char *s)
{
	while (*s)
		*s++ = toupper(*s);
}


/*********************************************************************
*
* Pattern-Match-Routine.
* vollstaendige regulaere Ausdruecke mit Rekursion.
*
*********************************************************************/

static int pattern_match(char *pattern, char *fname)
{
	/* solange beide Zeichenketten nicht leer sind */

	while ((*pattern) && (*fname))
	{
		if (*pattern == '*')
		{
			/* erst unwahrscheinlicheren Fall als Rekursion */
			if (pattern_match(pattern + 1, fname))
				return (TRUE);
			fname++;
			continue;
		}
		if ((*pattern == '?') || (toupper(*fname) == *pattern))
		{
			pattern++;
			fname++;
			continue;
		}
		return (FALSE);
	}

	/* jetzt ist mindesten eine Zeichenkette leer */

	if ((*pattern) == (*fname))
		return (TRUE);					/* beide EOS */

	/* jetzt ist genau eine Zeichenkette leer */

	if (*fname)
		return (FALSE);					/* pattern leer, fname nicht */

	/* jetzt ist pattern nicht leer, fname ist leer */

	while ((*pattern) == '*')
		pattern++;
	return (!(*pattern));				/* OK, wenn nur '*'e uebrig */
}


static void readline(char *s, int len)
{
	long ret;

	ret = Fread(0, (long) len, s);
	if (ret < 0)
		Pterm((int) ret);
	s[ret] = '\0';
}


int main(void)
{
	char pattern[128],
	 fname[128];


	Cconws("\r\nMuster: ");
	readline(pattern, 127);
	upperstring(pattern);
	Cconws("\r\n => ");
	Cconws(pattern);
	Cconws("\r\n");

	for (;;)
	{
		Cconws("\r\nTestdatei: ");
		readline(fname, 127);
		if (pattern_match(pattern, fname))
			Cconws("\r\n => Match\r\n");
		else
			Cconws("\r\n => Mismatch\r\n");
	}
}
