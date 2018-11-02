#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

#ifndef O_BINARY
#  ifdef _O_BINARY
#    define O_BINARY _O_BINARY
#  else
#    define O_BINARY 0
#  endif
#endif 

#define _(x) x

typedef struct _rs_header {
/* 0x00 */	uint16_t  rsh_vrsn;			/* version number (should be 1) */
/* 0x02 */	uint16_t  rsh_object;		/* offset to first object */
/* 0x04 */	uint16_t  rsh_tedinfo;		/* offset to TEDINFO structures */
/* 0x06 */	uint16_t  rsh_iconblk;		/* offset to ICONBLK structures */
/* 0x08 */	uint16_t  rsh_bitblk;		/* offset to BITBLK structures */
/* 0x0a */	uint16_t  rsh_frstr;		/* offset to free string (alert box texts) */
/* 0x0c */	uint16_t  rsh_string;		/* offset to string pool */
/* 0x0e */	uint16_t  rsh_imdata;		/* offset to image data */
/* 0x10 */	uint16_t  rsh_frimg;		/* offset to free images */
/* 0x12 */	uint16_t  rsh_trindex;		/* offset to tree addresses */
/* 0x14 */	uint16_t  rsh_nobs;			/* number of objects */
/* 0x16 */	uint16_t  rsh_ntree;		/* number of trees */
/* 0x18 */	uint16_t  rsh_nted;			/* number of TEDINFOs */
/* 0x1a */	uint16_t  rsh_nib;			/* number of ICONBLKs */
/* 0x1c */	uint16_t  rsh_nbb;			/* number of BITBLKs */
/* 0x1e */	uint16_t  rsh_nstring;		/* number of free strings */
/* 0x20 */	uint16_t  rsh_nimages;		/* number of free images */
/* 0x22 */	uint16_t  rsh_rssize;		/* total resource size */
} RS_HEADER;
#define SIZEOF_RS_HEADER ((size_t)(0x24))


#define	 TRUE	1
#define	 FALSE  0


static uint16_t getbeshort(const char *ptr)
{
	return ((ptr[0] << 8) & 0xff00) | (ptr[1] & 0x00ff);
}


static uint32_t getbelong(const char *ptr)
{
	return ((uint32_t)getbeshort(ptr) << 16) | ((uint32_t)getbeshort(ptr + 2));
}


#if 0
static void putbeshort(char *ptr, uint16_t val)
{
	ptr[0] = (val >> 8) & 0xff;
	ptr[1] = val & 0xff;
}
#endif


#if 0
static void putbelong(char *ptr, uint32_t val)
{
	putbeshort(ptr, val >> 16);
	putbeshort(ptr + 2, val);
}
#endif



static void get_rsc_header(const char *ptr, RS_HEADER *hdr)
{
	hdr->rsh_vrsn = getbeshort(ptr + 0);
	hdr->rsh_object = getbeshort(ptr + 2);
	hdr->rsh_tedinfo = getbeshort(ptr + 4);
	hdr->rsh_iconblk = getbeshort(ptr + 6);
	hdr->rsh_bitblk = getbeshort(ptr + 8);
	hdr->rsh_frstr = getbeshort(ptr + 10);
	hdr->rsh_string = getbeshort(ptr + 12);
	hdr->rsh_imdata = getbeshort(ptr + 14);
	hdr->rsh_frimg = getbeshort(ptr + 16);
	hdr->rsh_trindex = getbeshort(ptr + 18);
	hdr->rsh_nobs = getbeshort(ptr + 20);
	hdr->rsh_ntree = getbeshort(ptr + 22);
	hdr->rsh_nted = getbeshort(ptr + 24);
	hdr->rsh_nib = getbeshort(ptr + 26);
	hdr->rsh_nbb = getbeshort(ptr + 28);
	hdr->rsh_nstring = getbeshort(ptr + 30);
	hdr->rsh_nimages = getbeshort(ptr + 32);
	hdr->rsh_rssize = getbeshort(ptr + 34);
}

/*** ---------------------------------------------------------------------- ***/

static int test_header(RS_HEADER *header, long filesize)
{
	uint16_t vrsn;

	vrsn = header->rsh_vrsn;
	if (vrsn != 0 && vrsn != 4)
		return FALSE;
	if (header->rsh_rssize > filesize)
		return FALSE;
#if 0
	if (header->rsh_rssize < (filesize - sizeof(*header)))
		return FALSE;
#endif
	if (header->rsh_object & 1)
		return FALSE;
	if (header->rsh_object > header->rsh_rssize)
		return FALSE;
	if (header->rsh_object < SIZEOF_RS_HEADER && header->rsh_nobs != 0)
		return FALSE;
	if (header->rsh_tedinfo & 1)
		return FALSE;
	if (header->rsh_tedinfo > header->rsh_rssize)
		return FALSE;
	if (header->rsh_tedinfo < SIZEOF_RS_HEADER && header->rsh_nted != 0)
		return FALSE;
	if (header->rsh_tedinfo >= header->rsh_rssize && header->rsh_nted != 0)
		return FALSE;
	if (header->rsh_iconblk & 1)
		return FALSE;
	if (header->rsh_iconblk > header->rsh_rssize)
		return FALSE;
	if (header->rsh_iconblk < SIZEOF_RS_HEADER && header->rsh_nib != 0)
		return FALSE;
	if (header->rsh_iconblk >= header->rsh_rssize && header->rsh_nib != 0)
		return FALSE;
	if (header->rsh_bitblk & 1)
		return FALSE;
	if (header->rsh_bitblk > header->rsh_rssize)
		return FALSE;
	if (header->rsh_bitblk < SIZEOF_RS_HEADER && header->rsh_nbb != 0)
		return FALSE;
	if (header->rsh_frstr > header->rsh_rssize)
		return FALSE;
	if (header->rsh_frstr >= header->rsh_rssize && header->rsh_nstring != 0)
		return FALSE;
	if (header->rsh_string > header->rsh_rssize)
		return FALSE;
	/*
	 * There seems to be at least one resource editor out there
	 * that puts bogus values into rsh_imdata
	 */
	if (header->rsh_imdata > filesize && (header->rsh_nbb != 0 || header->rsh_nib != 0))
		return FALSE;
	if (header->rsh_frimg > header->rsh_rssize)
		return FALSE;
	if (header->rsh_trindex & 1)
		return FALSE;
	if (header->rsh_trindex > header->rsh_rssize)
		return FALSE;
	if (header->rsh_nobs == 0 || header->rsh_ntree == 0)
		return FALSE;
	if (header->rsh_frstr == 0)
		return FALSE;
	if (header->rsh_nobs > 2729) /* (65536 - sizeof(RS_HEADER) - sizeof(OBJECT *)) / (sizeof(OBJECT)) */
		return FALSE;
	if (header->rsh_ntree > 2339) /* (65536 - sizeof(RS_HEADER)) / (sizeof(OBJECT) + sizeof(OBJECT *)) */
		return FALSE;
	return TRUE;
}

/*** ---------------------------------------------------------------------- ***/

static void print_header(const RS_HEADER *header)
{
	printf("rsh_vrsn:     $%04x\n", header->rsh_vrsn);
	printf("rsh_object:   $%04x\n", header->rsh_object);
	printf("rsh_tedinfo:  $%04x\n", header->rsh_tedinfo);
	printf("rsh_iconblk:  $%04x\n", header->rsh_iconblk);
	printf("rsh_bitblk:   $%04x\n", header->rsh_bitblk);
	printf("rsh_frstr:    $%04x\n", header->rsh_frstr);
	printf("rsh_string:   $%04x\n", header->rsh_string);
	printf("rsh_imdata:   $%04x\n", header->rsh_imdata);
	printf("rsh_frimg:    $%04x\n", header->rsh_frimg);
	printf("rsh_trindex:  $%04x\n", header->rsh_trindex);
	printf("rsh_nobs:     $%04x\n", header->rsh_nobs);
	printf("rsh_ntree:    $%04x\n", header->rsh_ntree);
	printf("rsh_nted:     $%04x\n", header->rsh_nted);
	printf("rsh_nib:      $%04x\n", header->rsh_nib);
	printf("rsh_nbb:      $%04x\n", header->rsh_nbb);
	printf("rsh_nstring:  $%04x\n", header->rsh_nstring);
	printf("rsh_nimages:  $%04x\n", header->rsh_nimages);
	printf("rsh_rssize:   $%04x\n", header->rsh_rssize);
}

/*** ---------------------------------------------------------------------- ***/

static void write_file(const char *filename, const char *address, long size)
{
	int fd;
	long written;
	
	fd = open(filename, O_CREAT|O_TRUNC|O_BINARY|O_WRONLY, 0644);
	if (fd < 0)
	{
		fprintf(stderr, _("can't create %s: %s\n"), filename, strerror(errno));
		exit(EXIT_FAILURE);
	}
	written = write(fd, address, (size_t)size);
	close(fd);
	if (written != size)
	{
		fprintf(stderr, _("error writing %s: %s\n"), filename, strerror(errno));
		exit(EXIT_FAILURE);
	}
	printf(_("wrote %s size %ld\n"), filename, size);
}

/*** ---------------------------------------------------------------------- ***/

int main(int argc, char **argv)
{
	int handle;
	const char *filename;
	long size;
	char *buffer;
	char *address;
	const char *end;
	RS_HEADER gemhdr;
	int found;
	
	if (argc != 2)
	{
		fprintf(stderr, _("usage: findrsc <input>\n"));
		return EXIT_FAILURE;
	}
	filename = argv[1];
	handle = open(filename, O_RDONLY | O_BINARY);	/* open source file */
	if (handle < 0)
	{
		fprintf(stderr, _("%s not found\n"), filename);
		return EXIT_FAILURE;
	}
	size = lseek(handle, 0L, SEEK_END);
	lseek(handle, 0L, SEEK_SET);
	
	if (size < SIZEOF_RS_HEADER)
	{
		fprintf(stderr, _("%s file too short\n"), filename);
		return EXIT_FAILURE;
	}
	buffer = malloc(size);
	if (!buffer)
	{
		fprintf(stderr, _("No memory !\n"));
		return EXIT_FAILURE;
	}
	read(handle, buffer, size);
	close(handle);

	address = buffer;
	end = buffer + size - SIZEOF_RS_HEADER;
	
	found = 0;
	while (address < end)
	{
		unsigned long offset;
		unsigned long outsize;
		char outname[128];
		
		offset = (unsigned long)(address - buffer);
		get_rsc_header(address, &gemhdr);
		if (test_header(&gemhdr, size - offset))
		{
			++found;
			outsize = gemhdr.rsh_rssize;
			if (gemhdr.rsh_vrsn & 4)
			{
				char *xhdr = address + gemhdr.rsh_rssize;
				if (xhdr + 12 <= end)
				{
					unsigned long xfilesize = getbelong(xhdr);
					unsigned long colortab = getbelong(xhdr + 4);
					if (xfilesize >= gemhdr.rsh_rssize &&
						xfilesize <= size &&
						colortab >= gemhdr.rsh_rssize &&
						colortab < size &&
						!(colortab & 1))
					{
						outsize = xfilesize;
					}
				}
			}
			
			printf(_("found resource at $%08lx: %04lx\n"),
				offset, outsize);
				
			printf("Header:\n");
			print_header(&gemhdr);
			if (1)
			{
				sprintf(outname, "rsc%d.rsc", found);
				write_file(outname, address, outsize);
			}
			address += outsize;
		} else
		{
			address += 2;
		}
	}
	
	if (found == 0)
	{
		fprintf(stderr, _("%s: no resource found\n"), filename);
		return EXIT_FAILURE;
	}
	
	return EXIT_SUCCESS;
}
