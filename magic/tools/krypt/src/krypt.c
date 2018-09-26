/*
*
* Verschl《selt eine Datei mit Hilfe einer anderen.
* Es wird ein XOR-Verfahren verwendet, daher kann das
* Programm auch zum Entschl《seln verwendet werden.
*
* Anwendung: Update eines MagiC-Core.
* Zum Verschl《seln wird MagiC 6.20 mit Hilfe von
* MagiC 6.10 ver- und wieder ent-schl《selt.
*
*/

#include <tos.h>
#include <string.h>

#define MAGIC	"BrKrypXt"


struct header
{
	char magic[8];		/* "BrKrypXt" */
	long chksum;
};

/********************************/

static long chksum(long flen, char *buf)
{
	long sum = 0;
	long *ls;
	char *s;

	/* ganze Langworte */

	for	(ls = (long *) buf;
		 ls <= (long *) (buf+flen-sizeof(*ls));)
	{
		sum += *ls++;
	}

	/* Bytes */

	s = (char *) (ls-1);	/* letzte Addition r…kg�ngig */
	while(s < buf+flen)
		sum += *s++;

	return(sum);
}

/********************************/

static int loadfile(char *fname, long *flen, char **buf)
{
	long retcode;
	int handle;
	XATTR xattr;


	*buf = NULL;

	/* Quelldatei 杷fnen */

	retcode = Fopen(fname, O_RDONLY);
	if	(retcode < 0)
	{
		error:
		Cconws("Error opening ");
		Cconws(fname);
		return((int) retcode);
	}
	handle = (int) retcode;

	/* L�nge der Quelldatei bestimmen */

	retcode = Fcntl(handle, (long) &xattr, FSTAT);
	if	(retcode < 0)
	{
		Fclose(handle);
		goto error;
	}

	/* Speicher f〉 Quelldatei reservieren */

	*flen = xattr.size;
	*buf = Malloc(*flen);
	if	(!(*buf))
	{
		Fclose(handle);
		Cconws("out of memory");
		return(-1);
	}

	/* Quelldatei in den Speicher laden */

	retcode = Fread(handle, *flen, *buf);
	Fclose(handle);
	if	(retcode != *flen)
		goto error;

	return(0);
}

/********************************/

int main(int argc, char *argv[])
{
	long retcode;
	long in_flen,key_flen;
	char *in_buf,*key_buf;
	int ret;
	struct header h;
	struct header *ph;
	char *dst,*key,*data;
	long dstlen;
	int decrypt;
	long sum;
	int handle;


	if	(argc != 4)
	{
		Cconws("Syntax: KRYPT infile outfile keyfile");
		return(1);
	}

	/* Quelldatei 杷fnen */

	ret = loadfile(argv[1], &in_flen, &in_buf);
	if	(ret)
		return(ret);

	/* Schl《seldatei 杷fnen */

	ret = loadfile(argv[3], &key_flen, &key_buf);
	if	(ret)
	{
		Mfree(in_buf);
		return(ret);
	}

	/* feststellen, ob ver- oder entschl《seln */

	ph = (struct header *) in_buf;
	if	((in_flen >= sizeof(*ph)) && (!memcmp(ph->magic, MAGIC, sizeof(ph->magic))))
	{
		/* Datei ist verschl《selt => entschl《seln */
		dst = (char *) (ph+1);
		dstlen = in_flen - sizeof(*ph);
		decrypt = TRUE;
	}
	else
	{
		/* Datei ist nicht verschl《selt => verschl《seln */
		dst = (char *) ph;
		dstlen = in_flen;
		decrypt = FALSE;
		sum = chksum(dstlen, dst);
	}

	/* ver-/ entschl《seln */

	key = key_buf;
	data = dst;
	while(data < in_buf + in_flen)
	{
	*data++ ^= *key++;
	if	(key >= key_buf+key_flen)
		key = key_buf;
	}

	if	(decrypt)
	{
		sum = chksum(dstlen, dst);
		if	(ph->chksum != sum)
		{
		Cconws("checksum mismatch");
		return(1);
		}
	}

	/* Ausgabedatei schreiben */

	retcode = Fopen(argv[2], O_WRONLY+_REALO_CREAT+_REALO_EXCL);
	if	(retcode < 0)
	{
		error:
		Cconws("Error opening ");
		Cconws(argv[2]);
		return((int) retcode);
	}
	handle = (int) retcode;

	if	(!decrypt)
	{
		 h.chksum = sum;
		 memcpy(&h.magic, MAGIC, sizeof(h.magic));
		 retcode = Fwrite(handle, sizeof(h), &h);
		 if	(retcode != sizeof(h))
		 {
		 	goto error;
		 }
	}

	retcode = Fwrite(handle, dstlen, dst);
	if	(retcode != dstlen)
	{
	 	goto error;
	}

	Fclose(handle);
	return(0);
}