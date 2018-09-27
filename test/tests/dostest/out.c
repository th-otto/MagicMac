#include <tos.h>
#include <string.h>

int main(void)
{
 char bla[400];

 memset(bla,'*',355);
 bla[355]='\r'; bla[356]='\n'; bla[357]='\0';
 Cconws(bla);
 return(0);
}
