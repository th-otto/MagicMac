#include <string.h>
#include <stdio.h>

const char *memchr2(const char *s, ssize_t len)
{
	char LF = 0x0a;
	char c;
	
	for (;;)
	{
		if (--len < 0)
			return NULL;
		c = *s++;
		if ((c -= LF) == 0)
			break;
		if ((c -= 3) == 0)
			break;
	}
	return --s;
}
