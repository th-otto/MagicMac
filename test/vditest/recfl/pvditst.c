/*
*
* Beispielprogramm fÅr VDI.
*
*/

#include <tos.h>
#include <stdio.h>
#include <aes.h>
#include <vdi.h>


int vdi_handle;
int work_out[57],work_in [12];	 /* VDI- Felder fÅr v_opnvwk() */
int	gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int	ap_id;
int aes_handle;		/* Screen-Workstation des AES */


int pxy[4];
static int planes_32[16 * 32];

/* gefÅlltes Rechteck */

static void test1(int x, int y, int w, int h)
{
	register int i;


	pxy[0] = x;		/* x1 */
	pxy[1] = y;		/* y1 */
	pxy[2] = x+w-1;	/* x2 */
	pxy[3] = y+h-1;	/* y2 */

	for	(i = MD_REPLACE; i <= MD_ERASE; i++)
	{
		vswr_mode(vdi_handle, i);
		vr_recfl(vdi_handle, pxy);

		pxy[0] += w + 10;
		pxy[2] += w + 10;
	}
}

/* buntes Rechteck */

static void test2(void)
{
	vsf_color(vdi_handle, 2);

	test1(100, 80, 100, 50);
}


/* Rechteck mit Schraffur oder Muster */

static void test3(void)
{
	register int style;

	vsf_color(vdi_handle, 4);

	/* 0=leer, 1=deckend, 2=gemustert, 3=schraffiert, 4=user) */

	vsf_interior(vdi_handle, 2);

	for	(style = 1; style < 25; style++)
	{
		vsf_style(vdi_handle, style);

		test1(100, 140 + (style-1) * 23, 30, 21);
	}

	vsf_interior(vdi_handle, 3);

	for	(style = 1; style < 14; style++)
	{
		vsf_style(vdi_handle, style);

		test1(300, 140 + (style-1) * 30, 30, 20);
	}
}

/* Rechteck mit Userdef */

static void test4(void)
{
	register int i;

	static int planes_2[2*16] =
	{
		0x00f0,
		0x00f1,
		0x00f2,
		0x00f3,
		0x00f4,
		0x00f5,
		0x00f6,
		0x00f7,
		0x00f8,
		0x00f9,
		0x00fa,
		0x00fb,
		0x00fc,
		0x00fd,
		0x00fe,
		0x00ff,

		0xf000,
		0xf100,
		0xf200,
		0xf300,
		0xf400,
		0xf500,
		0xf600,
		0xf700,
		0xf800,
		0xf900,
		0xfa00,
		0xfb00,
		0xfc00,
		0xfd00,
		0xfe00,
		0xff00
	};

	static int planes_32[16 * 32];
	for	(i = 0; i < 16*32; i++)
		planes_32[i] = i * 1776;


	/* FÅllfarbe 1, Muster 4 (userdef) laut NVDI 4 Handbuch */

	vsf_color(vdi_handle, 1);
	vsf_interior(vdi_handle, 4);

	/* 2 planes */

	vsf_udpat(vdi_handle, planes_2, 2);
	test1(500, 20, 100, 100);

	/* 32 planes */

	vsf_udpat(vdi_handle, planes_32, 32);
	test1(500, 130, 100, 100);
}


void ExecLine(char *line)
{
	int x,y,w,h;
	int wrmode,color;
	int interior,style;
	int n;

	if	(line[0] == ';')
		return;

	n = sscanf(line, "%d %d %d %d %d %d %d %d",
			&x,
			&y,
			&w,
			&h,
			&wrmode,
			&color,
			&interior,
			&style);	

	if	(n != 8)
	{
		Cconws("Fehler in Zeile \"");
		Cconws(line);
		Cconws("\"\r\n");
		return;
	}


	pxy[0] = x;		/* x1 */
	pxy[1] = y;		/* y1 */
	pxy[2] = x+w-1;	/* x2 */
	pxy[3] = y+h-1;	/* y2 */

	vswr_mode(vdi_handle, wrmode);
	vsf_color(vdi_handle, 4);
	vsf_interior(vdi_handle, interior);
	vsf_style(vdi_handle, style);
	vsf_udpat(vdi_handle, planes_32, 32);

	vr_recfl(vdi_handle, pxy);
}


int main( void )
{
	register int i;
	long err;
	int fh;
	char line[256];
	char c;



	if   ((ap_id = appl_init()) < 0)
	{
		Cconws("Fehler bei appl_init()");
		Pterm(-1);
	}

	aes_handle = graf_handle(&gl_hwchar, &gl_hhchar, &gl_hwbox, &gl_hhbox);

	vdi_handle = aes_handle;
	for  (i = 0; i < 10; work_in[i++] = 1)
		;
	work_in[10]=2;                     /* Rasterkoordinaten */
	v_opnvwk(work_in, &vdi_handle, work_out);

	for	(i = 0; i < 16*32; i++)
		planes_32[i] = i * 1776;

	err = Fopen("pvditst.ini", 0);
	if	(err < 0)
	{
		if	(err == EFILNF)
			err = 0;

		test1(100, 20, 100, 50);

		test2();

		test3();

		test4();
		return((int) err);
	}

	fh = (int) err;

	i = 0;
	do
	{
		err = Fread(fh, 1, &c);
		if	((err == 0) || (c == '\r') || (c == '\n') || (i > 254))
		{
			line[i] = '\0';
			if	(i)
				ExecLine(line);
			i = 0;
		}
		else
		{
			line[i++] = c;
		}
	}
	while(err == 1);

	return((int) Fclose(fh));
}