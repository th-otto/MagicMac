/* Test des 68k-Emulators */

#include <tos.h>
#include <stdio.h>
#include "ass68k.h"

/* #define DATALEN	20480L */
#define DATALEN	2048L
#define FNAME		"DATA.BIN"

static long random_data[DATALEN];
static long get_random(void);
static void calc(void);


#pragma warn -par
int main(int argc, char *argv[])
{
	long ret;

	ret = get_random();

	if	(ret)
		return((int) ret);

	calc();
	return(0);
}
#pragma warn .par

/**************************************************/

static void subxw(long l1, long l2, long l3)
{
	int i1;

	i1 = subx_w((int) l1, (int) l2, (int) l3);
	printf("%04x %04x %04x %04x\n",
		(int) l1,
		(int) l2,
		(int) l3,
		i1 & 0x1f);
}

static void subxl(long l1, long l2, long l3)
{
	int i1;

	i1 = subx_l(l1, l2, (int) l3);
	printf("%08lx %08lx %04x %04x\n",
		l1,
		l2,
		(int) l3,
		i1 & 0x1f);
}


static void calc(void)
{
	register long i;
/*
	long l1,l2,l3,l4;
	int c1,c2,c3,c4;
*/
/*
	long d0_d1_d2[3];
*/
/*	c1 = c2 = c3 = c4 = 0;	*/

	subxl(0x80000000L, 0, 0x10);
	subxl(0x80000000L, 0, 0x0);
	subxl(0x80000000L, 0x7fffffffL, 0x10);
	subxl(0x80000000L, 0x7fffffffL, 0x0);
	subxl(0, 0x7fffffffL, 0x10);
	subxl(0, 0x7fffffffL, 0x0);

/*
	subxw(0x8000, 0, 0x10);
	subxw(0x8000, 0, 0x0);
	subxw(0x8000, 0x7fff, 0x10);
	subxw(0x8000, 0x7fff, 0x0);
	subxw(0, 0x7fff, 0x10);
	subxw(0, 0x7fff, 0x0);
*/
	for	(i = 0; i < DATALEN - 3; i++)
	{
/*		subxw(random_data[i], random_data[i+1], random_data[i+2]); */
		subxl(random_data[i], random_data[i+1], random_data[i+2]);

/*
		l1 = roxr_w(random_data[i], random_data[i+1] & 0x1f, &c1);
		l2 = roxr_l(random_data[i], random_data[i+1] & 0x1f, &c2);
		l3 = roxl_w(random_data[i], random_data[i+1] & 0x1f, &c3);
		l4 = roxl_l(random_data[i], random_data[i+1] & 0x1f, &c4);
		printf("%08lx %08lx %08lx %08lx %04x %04x %04x %04x\n",
			l1,l2,l3,l4,c1,c2,c3,c4);
*/
/*
		d0_d1_d2[0] = 1; /*random_data[i]; */
		d0_d1_d2[1] = random_data[i+1] & 0xffff;
		d0_d1_d2[2] = random_data[i+2] & 0xffff;
		printf("0x%08lx:%08lx/0x%08lx = ",
			d0_d1_d2[0],d0_d1_d2[1],d0_d1_d2[2]);
		divs_l(d0_d1_d2);
		printf("0x%08lx R 0x%08lx\n",
			d0_d1_d2[1],d0_d1_d2[0]);
*/
/*
		d0_d1_d2[0] = random_data[i];
		d0_d1_d2[1] = random_data[i+1];
		d0_d1_d2[2] = random_data[i+2];
		muls_l(d0_d1_d2);
		printf("%08lx %08lx %08lx\n",
			d0_d1_d2[0],d0_d1_d2[1],d0_d1_d2[2]);
*/
	}
}

/**************************************************/

static long get_random(void)
{
	long ret;
	int hdl;
	register long i;


	ret = Fopen(FNAME, O_RDONLY);

	if	(ret < 0)
	{
		for	(i = 0; i < DATALEN; i++)
		{
			random_data[i] = Random() + (Random() << 16);
		}

		ret = Fcreate(FNAME, 0);
	/*	printf("ret = %d\n", (int) ret); */
		if	(ret < 0)
			return(ret);
		hdl = (int) ret;

		ret = Fwrite(hdl, 4L*DATALEN, random_data);
	/*	printf("ret = %ld\n", ret); */
	}
	else
	{
		hdl = (int) ret;
		ret = Fread(hdl, 4L*DATALEN, random_data);
	}

	Fclose(hdl);

	if	(ret != (4L*DATALEN))
		return(-1);
	else
		return(0);
}