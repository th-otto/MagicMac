#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>

#define DEBUGGING

#define AP_DRAGDROP		63
#define DD_OK			0
#define DD_NAK			1
#define DD_EXT			2
#define DD_LEN			3
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6
#define DD_TIMEOUT		4000
#define DD_NUMEXTS		8
#ifndef DD_EXTSIZE
#define DD_EXTSIZE		32L
#define DD_NAMEMAX		128
#define DD_HDRMAX		(8+DD_NAMEMAX)
#endif

#define FAP_UNIPIPE		0x01
#define FAP_NOBLOCK		0x02
#define FAP_PSEUDOTTY	0x04

#undef EACCDN
#define	EACCDN	-36

int gl_apid;
int ddcreate(int apid, int winid, int msx, int msy, int kstate, char exts[]);
int ddstry(int fd, char *ext, char *name, long size);


int main()
{
	int client_id;
	int fd;
	int ret;
	char exts[256];
	char *data = "c:\\bin\\gemview\\verlauf.img";



	if	(0 > (gl_apid = appl_init()))
		return(-1);
	if	(0 > (client_id = appl_find("GEMVIEW ")))
		{
		client_id = shel_write(1, 1, 100, "c:\\bin\\gemview\\gemview.app", "");
		evnt_timer(3000);
		}

	fd = ddcreate(client_id, -1, 0, 0, 0, exts);
	if	(fd < 0)
		return(-1);
	printf("Empf„nger wnscht folgende Dateitypen: '%s'\n", exts);
	ret = ddstry(fd, "ARGS", "Datenname", strlen(data) + 1);
	printf("Empf„nger liefert DD_XXX: %d\n", ret);
	if	(ret == DD_OK)
		Fwrite(fd, strlen(data) + 1, data);
	Fclose(fd);
	return(0);
}


#ifdef DEBUGGING
#define debug_alert(x, y) form_alert(x, y)
#else
#define debug_alert(x, y)
#endif

/*
 * create a pipe for doing the drag & drop,
 * and send an AES message to the recipient
 * application telling it about the drag & drop
 * operation.
 *
 * Input Parameters:
 * apid:	AES id of the window owner
 * winid:	target window (0 for background)
 * msx, msy:	mouse X and Y position
 *		(or -1, -1 if a fake drag & drop)
 * kstate:	shift key state at time of event
 *
 * Output Parameters:
 * exts:	A 32 byte buffer into which the
 *		receipient's 8 favorite
 *		extensions will be copied.
 *
 * Returns:
 * A positive file descriptor (of the opened
 * drag & drop pipe) on success.
 * -1 if the receipient doesn't respond or
 *    returns DD_NAK
 * -2 if appl_write fails
 */

int ddcreate(int apid, int winid, int msx, int msy, int kstate, char exts[])
{
	int fd;
	long i;
	int msg[8];
	long fd_mask;
	char c;
	char *pipename = "U:\\PIPE\\DRAGDROP.AA";

	printf("erstelle Pipe");
	pipename[17] = 'A';
	pipename[18] = 'A' - 1;
	fd = -1;
	do	{
		pipename[18]++;
		if	(pipename[18] > 'Z')
			{
			pipename[17]++;
			if	(pipename[17] > 'Z')
				break;
			}
		fd = (int) Fcreate(pipename, FAP_NOBLOCK);
		}
	while (fd == EACCDN);

	printf(", Name %s => Handle %d\n", pipename, fd);

	if	(fd < 0)
		{
		debug_alert(1, "[1][Fcreate error][OK]");
		return fd;
		}

/* construct and send the AES message */
	msg[0] = AP_DRAGDROP;
	msg[1] = gl_apid;
	msg[2] = 0;
	msg[3] = winid;
	msg[4] = msx;
	msg[5] = msy;
	msg[6] = kstate;
	msg[7] = (pipename[17] << 8) | pipename[18];
	printf("Schicke AES- Message\n");
	if 	(!appl_write(apid, 16, msg))
		{
		printf("Empf„nger unbekannt\n");
		Fclose(fd);
		return(-1);
		}

/* now wait for a response */

	fd_mask = 1L << fd;
	printf("warte per Fselect\n");
	i = Fselect(DD_TIMEOUT, &fd_mask, 0L, 0L);
	if 	(!i || !fd_mask) {	/* timeout happened */
		{
		printf("Timeout bei Fselect\n");
		return(-1);
		}
	}

/* read the 1 byte response */
	printf("Lese 1 Byte von der Pipe\n");
	i = Fread(fd, 1L, &c);
	printf("Habe %ld Byte(s), Wert %d\n", i, c);
	if	(i != 1L)
		{
		Fclose(fd);
		printf("Lesefehler\n");
		return(-1);
		}
	if	(c != DD_OK)
		{
		Fclose(fd);
		printf("Client schickt kein DD_OK\n");
		return(-2);
		}

/* now read the "preferred extensions" */
	printf("Lese 32 Bytes von der Pipe\n");
	i = Fread(fd, DD_EXTSIZE, exts);
	printf("Habe %ld Byte(s)\n", i);
	if	(i != DD_EXTSIZE)
		{
		debug_alert(1, "[1][Error reading extensions][OK]");
		Fclose(fd);
		return(-1);
		}

/*
	oldpipesig = Psignal(SIGPIPE, SIG_IGN);
*/
	return(fd);
}


/*
 * see if the recipient is willing to accept a certain
 * type of data (as indicated by "ext")
 *
 * Input parameters:
 * fd		file descriptor returned from ddcreate()
 * ext		pointer to the 4 byte file type
 * name		pointer to the name of the data
 * size		number of bytes of data that will be sent
 *
 * Output parameters: none
 *
 * Returns:
 * DD_OK	if the receiver will accept the data
 * DD_EXT	if the receiver doesn't like the data type
 * DD_LEN	if the receiver doesn't like the data size
 * DD_NAK	if the receiver aborts
 */

int ddstry(int fd, char *ext, char *name, long size)
{
	int  hdrlen;
	long i;
	char c;

/* 4 bytes for extension, 4 bytes for size, 1 byte for
 * trailing 0
 */
	hdrlen = 9 + (int) strlen(name);
	i = Fwrite(fd, 2L, &hdrlen);

/* now send the header */
	if	(i != 2)
		return(DD_NAK);
	i = Fwrite(fd, 4L, ext);
	i += Fwrite(fd, 4L, &size);
	i += Fwrite(fd, (long)strlen(name)+1, name);
	if	(i != hdrlen)
		return(DD_NAK);

/* wait for a reply */
	i = Fread(fd, 1L, &c);
	if	(i != 1)
		return(DD_NAK);
	return(c);
}


/* Code for either recipient or originator */

/*
 * close a drag & drop operation
 */

void
ddclose(fd)
	int fd;
{
/*	(void)Psignal(SIGPIPE, oldpipesig); */
	(void)Fclose(fd);
}
