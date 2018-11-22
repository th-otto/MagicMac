#include "wdlgmain.h"

#define strlen mystrlen

#undef Malloc
#define	Malloc(size) mmalloc(size)
#undef Mfree
#define	Mfree(addr) Mfree(addr)


static WORD radio_bgcol;
static WORD magic_version;


WORD get_aes_info(WORD *font_id, WORD *font_height, WORD *hor_3d, WORD *ver_3d)
{
	MAGX_COOKIE *magic;
	WORD work_out[57];
	WORD attrib[10];
	WORD pens;
	WORD flags;
	
	vq_extnd(vdi_handle, 0, work_out);
	vqt_attributes(vdi_handle, attrib);

	flags = 0;
	pens = work_out[13];		/* number of pens */
	*font_id = attrib[0];		/* standard font */
	*font_height = attrib[7];	/* standard height */
	*hor_3d = 0;
	*ver_3d = 0;
	radio_bgcol = WHITE;

	if (mt_appl_find("?AGI", NULL) == 0)	/* appl_getinfo() vorhanden? */
		flags |= GAI_INFO;

	if (aes_global[0] >= 0x0401)	/* mindestens AES 4.01? */
		flags |= GAI_INFO;

	magic = (MAGX_COOKIE *)Supexec(get_magic);
	magic_version = 0;
	
	if (magic)			/* MagiC vorhanden? */
	{
		if (magic->aesvars)	/* MagiC-AES aktiv? */
		{
			magic_version = magic->aesvars->version; /* MagiC-Versionsnummer */
			flags |= GAI_MAGIC | GAI_INFO;
		}
	}
		
	if (flags & GAI_INFO)		/* ist appl_getinfo() vorhanden? */
	{
		WORD ag1;
		WORD ag2;
		WORD ag3;
		WORD ag4;

		if (mt_appl_getinfo(0, &ag1, &ag2, &ag3, &ag4, NULL)) /* Unterfunktion 0, Fonts */
		{
			*font_id = ag2;
			*font_height = ag1;
		}

		if (mt_appl_getinfo(2, &ag1, &ag2, &ag3, &ag4, NULL) && ag3) /* Unterfunktion 2, Farben */
			flags |= GAI_CICN;

		if (mt_appl_getinfo(7, &ag1, &ag2, &ag3, &ag4, NULL)) /* Unterfunktion 7 */
			flags |= ag1 & (GAI_WDLG|GAI_LBOX|GAI_FNTS|GAI_FSEL|GAI_PDLG);

		if (mt_appl_getinfo(12, &ag1, &ag2, &ag3, &ag4, NULL) && (ag1 & 8)) /* AP_TERM? */
			flags |= GAI_APTERM;

		if (mt_appl_getinfo(13, &ag1, &ag2, &ag3, &ag4, NULL)) /* Unterfunktion 13, Objekte */
		{
			if (flags & GAI_MAGIC) /* MagiC spezifische Funktion! */
			{
				if (ag4 & 0x08) /* G_SHORTCUT supported ? */
					flags |= GAI_GSHORTCUT;
			}
				
			if (ag1 && ag2) /* 3D-Objekte und objc_sysvar() vorhanden? */
			{
				if (mt_objc_sysvar(0, AD3DVALUE, 0, 0, hor_3d, ver_3d, NULL)) /* 3D-Look eingeschaltet? */
				{
					if (pens >= 16) /* mindestens 16 Farben? */
					{
						WORD dummy;
						
						flags |= GAI_3D;
						mt_objc_sysvar(0, BACKGRCOL, 0, 0, &radio_bgcol, &dummy, NULL);
					}
				}
			}
		}
	}
	
	return flags;
}


void pdlg_do3d_rsrc(OBJECT *obj, WORD nobs, WORD hor, WORD ver)
{
	while (nobs != 0)
	{
		if (obj->ob_flags & FL3DIND)
		{
			obj->ob_x += hor;
			obj->ob_y += ver;
			obj->ob_width -= 2 * hor;
			obj->ob_height -= 2 * ver;
		}
		obj++;
		nobs--;
	}
}


void pdlg_no3d_rsrc(OBJECT *obj, WORD nobs, WORD flag)
{
	radio_bgcol = WHITE;
	while (nobs != 0)
	{
		if (flag &&
			(obj->ob_type & 0xff) == G_FTEXT &&
			(obj->ob_flags & FL3DMASK) &&
			obj->ob_spec.tedinfo->te_thickness == -2)
		{
			obj->ob_state |= OUTLINED;
			obj->ob_spec.tedinfo->te_thickness = -1;
			obj->ob_type = G_FBOXTEXT;
		}
		obj->ob_flags &= ~FL3DMASK;
		obj++;
		nobs--;
	}
}


#if !PDLG_SLB


/*
 * FIXME: using statics here will crash if this
 * code is ever used by more than one application
 */
static USERBLK *user_blks;
static OBJECT *radio_selected;
static OBJECT *radio_deselected;



static void	userdef_text(WORD x, WORD y, const char *string)
{
	WORD tmp;
	
	vswr_mode(vdi_handle, MD_TRANS);
	vst_font(vdi_handle, aes_font);
	vst_color(vdi_handle, BLACK);
	vst_effects(vdi_handle, 0);
	vst_alignment(vdi_handle, 0, 5, &tmp, &tmp);
	vst_height(vdi_handle, aes_height, &tmp, &tmp, &tmp, &tmp);
	
	v_gtext(vdi_handle, x, y, string);
}


static WORD __CDECL draw_check(PARMBLK *pb)
{
	WORD rect[4];
	WORD clip[4];
	WORD xy[10];
	char *string;
	
	string = (char *) pb->pb_parm;

	*((GRECT*)clip) = *((GRECT *)&pb->pb_xc);
	clip[2] += clip[0] - 1;
	clip[3] += clip[1] - 1;
	vs_clip(vdi_handle, 1, clip);

	*((GRECT *)rect) = *((GRECT *)&pb->pb_x);
	rect[2] = rect[0] + gl_hchar - 2;
	rect[3] = rect[1] + gl_hchar - 2;

	vswr_mode(vdi_handle, MD_REPLACE);

	vsl_color(vdi_handle, BLACK);
	xy[0] = rect[0];
	xy[1] = rect[1];
	xy[2] = rect[2];
	xy[3] = rect[1];
	xy[4] = rect[2];
	xy[5] = rect[3];
	xy[6] = rect[0];
	xy[7] = rect[3];
	xy[8] = rect[0];
	xy[9] = rect[1];
	v_pline(vdi_handle, 5, xy);

	vsf_color(vdi_handle, WHITE);
	
	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;
	vr_recfl(vdi_handle, xy);

	if (pb->pb_currstate & SELECTED)
	{
		pb->pb_currstate &= ~SELECTED;
		
		vsl_color(vdi_handle, BLACK);
		xy[0] = rect[0] + 2;
		xy[1] = rect[1] + 2;
		xy[2] = rect[2] - 2;
		xy[3] = rect[3] - 2;
		v_pline(vdi_handle, 2, xy);
		
		xy[1] = rect[3] - 2;
		xy[3] = rect[1] + 2;
		v_pline(vdi_handle, 2, xy);
	}
	userdef_text(pb->pb_x + gl_hchar + gl_wchar, pb->pb_y, string);

	return pb->pb_currstate;
}


static WORD __CDECL draw_radio(PARMBLK *pb)
{
	BITBLK *image;
	MFDB src;
	MFDB des;
	WORD clip[4];
	WORD xy[8];
	WORD image_colors[2];
	char *string;

	*((GRECT *)clip) = *((GRECT *) &pb->pb_xc);
	clip[2] += clip[0] - 1;
	clip[3] += clip[1] - 1;
	vs_clip(vdi_handle, 1, clip);

	string = (char *)pb->pb_parm;

	if (pb->pb_currstate & SELECTED)
	{
		pb->pb_currstate &= ~SELECTED;

		image = radio_selected->ob_spec.bitblk;
	} else
	{
		image = radio_deselected->ob_spec.bitblk;
	}
		
	src.fd_addr = image->bi_pdata;
	src.fd_w = image->bi_wb * 8;
	src.fd_h = image->bi_hl;
	src.fd_wdwidth = image->bi_wb / 2;
	src.fd_stand = 0;
	src.fd_nplanes = 1;
	src.fd_r1 = 0;
	src.fd_r2 = 0;
	src.fd_r3 = 0;

	des.fd_addr = 0;

	xy[0] = 0;
	xy[1] = 0;
	xy[2] = src.fd_w - 1;
	xy[3] = src.fd_h - 1;
	xy[4] = pb->pb_x;
	xy[5] = pb->pb_y;
	xy[6] = xy[4] + xy[2];
	xy[7] = xy[5] + xy[3];

	image_colors[0] = BLACK;
	image_colors[1] = radio_bgcol;

	vrt_cpyfm(vdi_handle, MD_REPLACE, xy, &src, &des, image_colors);
	userdef_text(pb->pb_x + gl_hchar + gl_wchar, pb->pb_y, string);

	return pb->pb_currstate;
}


static WORD __CDECL draw_innerframe(PARMBLK *pb)
{
	WORD clip[4];
	WORD obj[4];
	WORD xy[12];
	char *string;

	string = (char *) pb->pb_parm;

	*((GRECT *)&clip) = *((GRECT *)&pb->pb_xc);
	clip[2] += clip[0] - 1;
	clip[3] += clip[1] - 1;
	vs_clip(vdi_handle, 1, clip);

	vswr_mode(vdi_handle, MD_TRANS);
	vsl_color(vdi_handle, BLACK);
	vsl_type(vdi_handle, 1);

	*(GRECT *) obj = *(GRECT *) &pb->pb_x;
	obj[2] += obj[0] - 1;
	obj[3] += obj[1] - 1;

	xy[0] = obj[0] + gl_wchar;
	xy[1] = obj[1] + gl_hchar / 2;
	xy[2] = obj[0];
	xy[3] = xy[1];
	xy[4] = obj[0];
	xy[5] = obj[3];
	xy[6] = obj[2];
	xy[7] = obj[3];
	xy[8] = obj[2];
	xy[9] = xy[1];
	xy[10] = (WORD)(xy[0] + strlen(string) * gl_wchar);
	xy[11] = xy[1];
	
	v_pline(vdi_handle, 6, xy);

	userdef_text(obj[0] + gl_wchar, obj[1], string);

	return pb->pb_currstate;
}


static WORD __CDECL draw_underline(PARMBLK *pb)
{
	WORD clip[4];
	WORD xy[4];
	char *string;

	string = (char *) pb->pb_parm;

	*((GRECT *)&clip) = *((GRECT *)&pb->pb_xc);
	clip[2] += clip[0] - 1;
	clip[3] += clip[1] - 1;
	vs_clip(vdi_handle, 1, clip);

	vswr_mode(vdi_handle, MD_TRANS);
	vsl_color(vdi_handle, BLACK);
	vsl_type(vdi_handle, 1);

	xy[0] = pb->pb_x;
	xy[1] = pb->pb_y + pb->pb_h - 1;
	xy[2] = pb->pb_x + pb->pb_w - 1;
	xy[3] = xy[1];
	v_pline(vdi_handle, 2, xy);

	userdef_text(pb->pb_x, pb->pb_y, string);

	return pb->pb_currstate;
}


void substitute_objects(OBJECT *objects, UWORD nobs, WORD flags, OBJECT *selected, OBJECT *deselected)
{
	OBJECT *obj;
	UWORD i;
	UWORD count;
	
	if ((flags & GAI_MAGIC) &&
		magic_version >= 0x300)
	{
		user_blks = NULL;
		return;
	}
	obj = objects;
	i = nobs;
	count = 0;
	while (i != 0)
	{
		if ((obj->ob_state & WHITEBAK) &&
			(obj->ob_state & 0x8000))
		{
			switch (obj->ob_type & 0xff)
			{
			case G_BUTTON:
				count++;
				break;
			case G_STRING:
				if ((obj->ob_state & 0xff00) == 0xff00)
					count++;
				break;
			}
		}
		obj++;
		i--;
	}
	if (count != 0)
	{
		user_blks = Malloc(count * sizeof(*user_blks));
		radio_selected = selected;
		radio_deselected = deselected;
		if (user_blks != NULL)
		{
			USERBLK *blk;
			
			blk = user_blks;
			obj = objects;
			i = nobs;
			while (i != 0)
			{
				WORD type;
				UWORD state;
				
				type = obj->ob_type & 0xff;
				state = obj->ob_state;
				if (state & WHITEBAK)
				{
					if (state & 0x8000)
					{
						state &= 0xff00;
						if (flags & GAI_MAGIC)
						{
							if (type == G_BUTTON && state == 0xfe00)
							{
								blk->ub_parm = obj->ob_spec.index;
								blk->ub_code = draw_innerframe;
								obj->ob_type = G_USERDEF;
								obj->ob_flags &= ~FL3DMASK;
								obj->ob_spec.userblk = blk;
								blk++;
							}
						} else
						{
							switch (type)
							{
							case G_BUTTON:
								blk->ub_parm = obj->ob_spec.index;
								if (state == 0xfe00)
									blk->ub_code = draw_innerframe;
								else if (obj->ob_flags & RBUTTON)
									blk->ub_code = draw_radio;
								else
									blk->ub_code = draw_check;
								obj->ob_type = G_USERDEF;
								obj->ob_flags &= ~FL3DMASK;
								obj->ob_spec.userblk = blk;
								blk++;
								break;
							case G_STRING:
								if (state == 0xff00)
								{
									blk->ub_parm = obj->ob_spec.index;
									blk->ub_code = draw_underline;
									obj->ob_type = G_USERDEF;
									obj->ob_flags &= ~FL3DMASK;
									obj->ob_spec.userblk = blk;
									blk++;
								}
								break;
							}
						}
					}
				}
				obj++;
				i--;
			}
		}
	}
}


void substitute_free(void)
{
	if (user_blks)
		Mfree(user_blks);
	user_blks = NULL;
}
#endif
