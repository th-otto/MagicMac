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
int gl_hhbox, gl_hwbox, gl_hhchar, gl_hwchar;
int ap_id;
int aes_handle;		/* Screen-Workstation des AES */


int pxy[10];
int pxy2[4];
int pxy3[4];

/* Linienzug */

static void test1(int x, int y, int w, int h)
{
	register int i;


	pxy[0] = x;		/* x1 */
	pxy[1] = y;		/* y1 */
	pxy[2] = x+w-1;	/* x2 */
	pxy[3] = y;		/* y2 */
	pxy[4] = x+w-1;	/* x3 */
	pxy[5] = y+h-1;	/* y3 */
	pxy[6] = x;		/* x4 */
	pxy[7] = y+h-1;	/* y4 */
	pxy[8] = x;		/* x5 */
	pxy[9] = y;		/* y5 */

	pxy2[0] = x+1;
	pxy2[1] = y+1;
	pxy2[2] = x+w-2;
	pxy2[3] = y+h-2;

	pxy3[0] = x+1;
	pxy3[1] = y+h-2;
	pxy3[2] = x+w-2;
	pxy3[3] = y+1;

	for	(i = MD_REPLACE; i <= MD_ERASE; i++)
	{
		vswr_mode(vdi_handle, i);
		v_pline(vdi_handle, 5, pxy);
		v_pline(vdi_handle, 2, pxy2);
		v_pline(vdi_handle, 2, pxy3);

		pxy[0] += w + 10;
		pxy[2] += w + 10;
		pxy[4] += w + 10;
		pxy[6] += w + 10;
		pxy[8] += w + 10;

		pxy2[0] += w + 10;
		pxy2[2] += w + 10;

		pxy3[0] += w + 10;
		pxy3[2] += w + 10;
	}
}

/* bunter Linienzug */

static void test2(void)
{
	vsl_color(vdi_handle, 2);

	test1(100, 130, 50, 100);
}


/* Linienzug mit verschiedenen Linienmustern */

static void test3(void)
{
	register int style;

	vsl_color(vdi_handle, 4);

	for	(style = 1; style < 7; style++)
	{
		vsl_type(vdi_handle, style);

		test1(100, 240 + (style-1) * 43, 30, 40);
	}
}


/* Linienzug mit Userdef */

static void test4(void)
{
	vsl_udsty(vdi_handle, 0xff00);
	vsl_color(vdi_handle, 6);
	vsl_type(vdi_handle, 7);
	test1(500, 130, 100, 110);
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
	pxy[4] = x+w-1;	/* x3 */
	pxy[5] = y+h-1;	/* y3 */
	pxy[6] = x;		/* x4 */
	pxy[7] = y+h-1;	/* y4 */
	pxy[8] = x;		/* x5 */
	pxy[9] = y;		/* y5 */

	vswr_mode(vdi_handle, wrmode);
	vsl_color(vdi_handle, 4);
	vsl_type(vdi_handle, style);
	vsl_udsty(vdi_handle, 0xff00);

	v_pline(vdi_handle, 5, pxy);
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

	err = Fopen("pvditst.ini", 0);
	if	(err < 0)
	{
		if	(err == -33)
			err = 0;

		test1(100, 20, 50, 100);

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