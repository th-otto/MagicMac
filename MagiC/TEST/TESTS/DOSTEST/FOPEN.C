#include <tos.h>

int data[2048];

int main()
{
	long retcode;
	int handle;

	while(!Cconis())
		{
		retcode = Fopen("$$$", 0);
		if	(retcode < 0L)
			return((int) retcode);
		handle = (int) retcode;
		retcode = Fread(handle, 4096L, data);
		if	(retcode != 4096L)
			return((int) retcode);
		if	((data[0] != 0) ||
			 (data[ 100] !=  100) ||
			 (data[ 200] !=  200) ||
			 (data[ 300] !=  300) ||
			 (data[ 400] !=  400) ||
			 (data[ 500] !=  500) ||
			 (data[ 600] !=  600) ||
			 (data[ 700] !=  700) ||
			 (data[ 800] !=  800) ||
			 (data[ 900] !=  900) ||
			 (data[1000] != 1000) ||
			 (data[1100] != 1100) ||
			 (data[1200] != 1200) ||
			 (data[1300] != 1300) ||
			 (data[1400] != 1400) ||
			 (data[1500] != 1500) ||
			 (data[1600] != 1600) ||
			 (data[1700] != 1700) ||
			 (data[1800] != 1800) ||
			 (data[1900] != 1900) ||
			 (data[2000] != 2000))
			Cconws("\7" "Lesefehler!\r\n");
		Fclose(handle);
		}
	return(0);
}