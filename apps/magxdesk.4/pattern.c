/*********************************************************************
*
* Dieses Modul enth„lt die Pattern-Match-Routine.
*
*********************************************************************/

#include <portab.h>
#include <string.h>


/*********************************************************************
*
*  Meine "toupper" mit Bercksichtigung von Umlauten.
*
*********************************************************************/

#pragma warn -pia
char toupper( unsigned char c )
{
	register char *s;
	static char lower_s[] = "„”‚…†‡‘¤°±³´À";
	static char upper_s[] = "™š¶€’¥·¸²µÁ";

	if	(c < 'a')
		return(c);
	if	(c <= 'z')
		return(c & 0x5f);
	if	(!(s = strchr(lower_s, c)))
		return(c);
	return(upper_s[s - lower_s]);
}
#pragma warn +pia


/*********************************************************************
*
* Wandelt eine Zeichenkette in Groschrift um.
*
*********************************************************************/

void upperstring( char *s )
{
	while(*s)
		*s++ = toupper(*s);
}


/*********************************************************************
*
* Pattern-Match-Routine.
* vollst„ndige regul„re Ausdrcke mit Rekursion.
*
*********************************************************************/

int pattern_match(char *pattern, char *fname)
{
	/* solange beide Zeichenketten nicht leer sind */

	while((*pattern) && (*fname))
		{
		if	(*pattern == '*')
			{
			/* erst unwahrscheinlicheren Fall als Rekursion */
			if	(pattern_match(pattern+1, fname))
				return(TRUE);
			fname++;
			continue;
			}
		if	((*pattern == '?') || (toupper(*fname) == *pattern))
			{
			pattern++;
			fname++;
			continue;
			}
		return(FALSE);
		}

	/* jetzt ist mindesten eine Zeichenkette leer */

	if	((*pattern) == (*fname))
		return(TRUE);		/* beide EOS */

	/* jetzt ist genau eine Zeichenkette leer */

	if	(*fname)
		return(FALSE);		/* pattern leer, fname nicht */

	/* jetzt ist pattern nicht leer, fname ist leer */

	while((*pattern) == '*')
		pattern++;
	return(!(*pattern));	/* OK, wenn nur '*'e brig */
}
