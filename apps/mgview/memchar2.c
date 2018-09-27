#include <string.h>
#include <stdio.h>

const char *memchr2(const char *s, ssize_t len)
{
	char LF = 0x0a;
	char c;
	
	for (;;)
	{
		if (--len < 0)
			break;
		c = *s++;
		if ((c -= LF) == 0)
			return --s;
		if ((c -= 3) == 0)
			return --s;
	}
	return NULL;
}
