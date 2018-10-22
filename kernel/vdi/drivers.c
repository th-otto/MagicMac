#include <portab.h>
#include <tos.h>
#include <vdi.h>
#include "std.h"
#include "filediv.h"
#include "drivers.h"
#include "nvdi.h"
#include "ph.h"

extern char gdos_path[];
extern short OSC_count;
extern OSD *OSC_ptr;


struct bitmap_format std_format = {
	2L, 1, 2, 1, 0, 0, 0
};

int init_offscreen(const char *pattern);
int load_mon(void);
void init_mon(DRV_SYS *);
int delete_wk(VWK *vwk);
VWK *create_wk(long size);


int init_NOD(void)
{
	char fnamebuf[256];
	
	OSC_count = 0;
	OSC_ptr = NULL;
	strgcpy(fnamebuf, gdos_path);
	strgcat(fnamebuf, "*.NOD");
	init_offscreen(fnamebuf);
	strgcpy(fnamebuf, gdos_path);
	strgcat(fnamebuf, "*.OSD");
	init_offscreen(fnamebuf);
	if (load_mon() == FALSE || OSC_count == 0)
		return FALSE;
	return TRUE;
}


int init_offscreen(const char *pattern)
{
	OSD *osd;
	char fnamebuf[256];
	DRV_SYS header;
	DTA dta;
	DTA *olddta;
	
	olddta = Fgetdta();
	Fsetdta(&dta);
	if (Fsfirst(pattern, 0) == 0)
	{
		do
		{
			strgcpy(fnamebuf, gdos_path);
			strgcat(fnamebuf, dta.d_fname);
			read_file(fnamebuf, &header, 28, sizeof(header));
			if (strgcmp(header.magic, "OFFSCRN") == 0 && header.version > 0x280)
			{
				osd = (OSD *)Malloc_sys(sizeof(*osd));
				if (osd != NULL)
				{
					strgcpy(osd->fname, dta.d_fname);
					osd->filesize = dta.d_length;
					osd->path = gdos_path;
					osd->format = header.format;
					osd->refcount = 0;
					osd->sys = 0;
					/* BUG: unknown2 not initialized */
					osd->next = OSC_ptr;
					OSC_ptr = osd;
					OSC_count++;
				}
			}
		} while (Fsnext() == 0);
	}
	Fsetdta(olddta);
	return TRUE;
}


int load_mon(void)
{
	struct bitmap_format format;
	OSD *p;
	
	format = std_format;
	if ((p = load_NOD(&format)) != NULL)
	{
		init_mon(p->sys);
		return TRUE;
	}
	return FALSE;
}


OSD *load_NOD(struct bitmap_format *format)
{
	OSD *p;
	char fnamebuf[256];
	
	for (p = OSC_ptr; p != NULL; p = p->next)
	{
		if (p->format.colors == format->colors &&
			p->format.planes == format->planes &&
			p->format.format == format->format &&
			(p->format.flags & format->flags) == format->flags)
		{
			if (p->sys == 0)
			{
				strgcpy(fnamebuf, p->path);
				strgcat(fnamebuf, p->fname);
				p->sys = load_prg(fnamebuf);
			}
			if (p->sys != 0)
			{
				if (p->refcount == 0)
				{
					p->wk_size = p->sys->init(&nvdi_struct);
				}
				++p->refcount;
				return p;
			}
		}
	}
	return NULL;
}


int unload_NOD(OSD *drv)
{
	--drv->refcount;
	if (drv->refcount == 0)
	{
		Mfree_sys(drv->sys);
		drv->sys = NULL;
	}
	return TRUE;
}


DRV_SYS *load_prg(const char *filename)
{
	DTA *olddta;
	PH ph;
	DTA dta;
	DRV_SYS *sys;
	long fd;
	
	sys = NULL;
	olddta = Fgetdta();
	Fsetdta(&dta);
	
	if (Fsfirst(filename, 0) == 0)
	{
		fd = Fopen(filename, FO_READ);
		if (fd > 0)
		{
			if (Fread((short)fd, sizeof(ph), &ph) == sizeof(ph) && ph.ph_branch == 0x601a)
			{
				long tpa_size;
				long memsize;
				unsigned char *relocs;
				
				memsize = dta.d_length + ph.ph_blen - ph.ph_slen;
				sys = (DRV_SYS *)Malloc_sys(memsize);
				if (sys != NULL)
				{
					memsize = ph.ph_tlen + ph.ph_dlen;
					tpa_size = memsize + ph.ph_blen;
					if (Fread((short)fd, memsize, sys) == memsize)
					{
						long relocsize;

						Fseek(ph.ph_slen, (short)fd, SEEK_CUR);
						clear_mem((char *)sys + memsize, ph.ph_blen);
						relocs = (unsigned char *)sys + tpa_size;
						relocsize = -28 + dta.d_length - ph.ph_tlen - ph.ph_dlen - ph.ph_slen;
						if (Fread((short)fd, relocsize, relocs) == relocsize)
						{
							unsigned long offset;

							offset = *((unsigned long *)relocs);
							relocs += 4;
							if (offset != 0)
							{
								unsigned char *p;
								unsigned char c;

								p = (unsigned char *)sys + offset;
								*((long *)p) += (long)sys;
								while ((c = *relocs++) != 0)
								{
									if (c == 1)
									{
										p += 254;
									} else
									{
										p += (unsigned long)c;
										*((long *)p) += (long)sys;
									}
								}
							}
							Mshrink_sys(sys, tpa_size);
						} else
						{
							Mfree_sys(sys);
							sys = NULL;
						}
					} else
					{
						Mfree_sys(sys);
						sys = NULL;
					}
				}
			}
			Fclose((short)fd);
		}
	}
	
	Fsetdta(olddta);
	if (sys)
		clear_cpu_cache();
	return sys;
}


VWK *create_bitmap(struct v_unknown *p, VWK *wk, MFDB *fdb, WORD *intin)
{
	OSD *osd;
	struct bitmap_format format;
	VWK *bitmap;
	
	bitmap = NULL;
	format.colors = *((long *)&intin[15]);
	format.planes = intin[17];
	format.format = intin[18];
	format.flags = intin[19];
	format.res1 = 0;
	format.res2 = 0;
	format.res3 = 0;
	if (format.colors == 0)
	{
		if (fdb->fd_nplanes == 0 || fdb->fd_nplanes == p->device_addr->format.planes)
		{
			format = p->device_addr->format;
		} else
		{
			format.planes = 1;
		}
	}
	if (format.planes == 1)
	{
		format.colors = 2;
		format.format = FORM_ID_INTERLEAVED;
		format.flags = 1;
	}
	osd = load_NOD(&format);
	if (osd != NULL)
	{
		bitmap = create_wk(osd->wk_size);
		if (bitmap != NULL)
		{
			bitmap->v_format = format;
			wk_init(NULL, osd, bitmap);
			if (intin[11] != 0)
			{
				bitmap->res_x = intin[11];
				bitmap->res_y = intin[12];
			} else
			{
				bitmap->res_x = wk->res_x;
				bitmap->res_y = wk->res_y;
			}
			if (intin[13] != 0)
			{
				bitmap->pixel_width = intin[13];
				bitmap->pixel_height = intin[14];
			} else
			{
				bitmap->pixel_width = wk->pixel_width;
				bitmap->pixel_height = wk->pixel_height;
			}
			bitmap->bitmap_dx = ((bitmap->res_x + 16) & ~15) - 1;
			bitmap->bitmap_dy = bitmap->res_y;
			bitmap->clip_xmax = bitmap->res_x;
			bitmap->clip_ymax = bitmap->res_y;
			bitmap->bitmap_w = (short)((long)(bitmap->res_x + 1) * (long)(bitmap->r_planes + 1) / 8);
			bitmap->bitmap_length = (long)bitmap->bitmap_w * (long)(bitmap->res_y + 1);
			bitmap->bitmap_drv = osd;
			
			if (fdb->fd_addr == 0)
			{
				fdb->fd_w = bitmap->res_x + 1;
				fdb->fd_h = bitmap->res_y + 1;
				fdb->fd_nplanes = bitmap->r_planes + 1;
				fdb->fd_stand = 0;
				fdb->fd_wdwidth = (bitmap->bitmap_w / (bitmap->r_planes + 1)) / 2;
				bitmap->bitmap_addr = fdb->fd_addr = Malloc_sys(bitmap->bitmap_length);
				if (fdb->fd_addr != NULL)
				{
					bitmap->v_format.flags |= 0x8000;
					clear_bitmap(bitmap);
					return bitmap;
				} else
				{
					unload_NOD(osd);
					delete_wk(bitmap);
					return NULL;
				}
			}
			
			bitmap->bitmap_addr = fdb->fd_addr;
			bitmap->bitmap_w = fdb->fd_wdwidth * 2 * fdb->fd_nplanes;
			if (fdb->fd_stand)
			{
				MFDB tmp;

				tmp = *fdb;
				tmp.fd_stand = 0;
				tmp.fd_addr = Malloc_sys(bitmap->bitmap_length);
				if (tmp.fd_addr != NULL)
				{
					transform(fdb, &tmp, bitmap);
					copy_mem(bitmap->bitmap_length, tmp.fd_addr, fdb->fd_addr);
					/* BUG: tmp bitmap leaked */
				} else
				{
					tmp.fd_addr = fdb->fd_addr;
					transform(fdb, &tmp, bitmap);
				}
			}
		}
	}
	return bitmap;
}


int delete_bitmap(VWK *vwk)
{
	unload_NOD(vwk->bitmap_drv);
	if (vwk->v_format.flags & 0x8000)
	{
		Mfree_sys(vwk->bitmap_addr);
	}
	delete_wk(vwk);
	return TRUE;
}


VWK *create_wk(long size)
{
	VWK *vwk = NULL;
	int i;
	
	for (i = 2; i <= MAX_HANDLES; i++)
	{
		if (wk_tab[i - 1] == &closed)
		{
			vwk = (VWK *)Malloc_sys(size);
			if (vwk != NULL)
			{
				clear_mem(vwk, size);
				vwk->wk_handle = i;
				wk_tab[i - 1] = vwk;
			}
			break;
		}
	}
	return vwk;
}


int delete_wk(VWK *vwk)
{
	if (wk_tab[vwk->wk_handle - 1] == vwk)
	{
		wk_tab[vwk->wk_handle - 1] = &closed;
		Mfree_sys(vwk);
		return TRUE;
	}
	return FALSE;
}
