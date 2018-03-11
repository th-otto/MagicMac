#include <stdio.h>

int main(void)
{
 unsigned char* ptr = (unsigned char *) (0x2070-0x15c);
 long i;

 while(1)
  {
  printf("%02x  ", (unsigned int) (*ptr));
  for(i = 0; i < 10000; i++)
  	;
  }
}
