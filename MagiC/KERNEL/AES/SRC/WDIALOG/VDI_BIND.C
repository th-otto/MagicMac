/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

typedef struct
{
	WORD	contrl[12];
	WORD	intin[16];
	WORD	ptsin[16];
	WORD	intout[16];
	WORD	ptsout[16];
} VDI_SMALL;

static void	init_vdi_pb( VDIPB *pb, VDI_SMALL *p );
static void	vdi_str_to_c( UWORD *src, UBYTE *des, WORD len );
static WORD	c_str_to_vdi( UBYTE *src, UWORD *des );
static WORD	set_color( WORD opcode, WORD handle, WORD color_index );
static void	vdi_text( WORD opcode, WORD handle, WORD x, WORD y, BYTE *string );

/* VDI-String in einen C-String umwandeln */
static void	vdi_str_to_c( UWORD *src, UBYTE *des, WORD len )
{
	while ( len > 0 )
	{
		*des++ = (UBYTE) *src++;										/* nur das Low-Byte kopieren */
		len--;
	}
	*des++ = 0;																/* Ende des Strings */
}

/* C-String in einen VDI-String umwandeln */
static WORD	c_str_to_vdi( UBYTE *src, UWORD *des )
{
	WORD	len;

	len = 0;

	while (( *des++ = *src++ ) != 0 )
		len++;

	return( len );															/* LÑnge des Strings ohne Null-Byte */
}

/*----------------------------------------------------------------------------------------*/ 
/* VDI-PB intialisieren																							*/
/* Funktionsresultat:	-																						*/
/*	pb:						Zeiger auf den PB																	*/
/*	p:							Zeiger auf eine (kleine) Parameterstruktur								*/
/*----------------------------------------------------------------------------------------*/ 
static void	init_vdi_pb( VDIPB *pb, VDI_SMALL *p )
{
	pb->contrl = p->contrl;
	pb->intin = p->intin;
	pb->ptsin = p->ptsin;
	pb->intout = p->intout;
	pb->ptsout = p->ptsout;
}

void	rect_sort( VRECT *rect )
{
	WORD	tmp;
	
	if ( rect->x1 > rect->x2 )
	{
		tmp = rect->x1;
		rect->x2 = rect->x1;
		rect->x1 = tmp;
	}
	if ( rect->y1 > rect->y2 )
	{
		tmp = rect->y1;
		rect->y2 = rect->y1;
		rect->y1 = tmp;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Schnittmenge von rect1 und rect2 bestimmen															*/
/* Bei rect1 und rect2 muû x1 <= x2 und y1 <= y2 sein!												*/
/* Funktionsresultat:	0: kein Schnitt 1: Rechtecke schneiden sich								*/
/*								die Struktur *p2 enthÑlt dann die SchnittflÑche							*/
/*	rect1:					erstes Rechteck																	*/
/*	rect2:					zweites Rechteck																	*/
/*	dst:						Zeiger auf das Schnitt-Rechteck												*/
/*----------------------------------------------------------------------------------------*/ 
WORD rect_intersect( VRECT *rect1, VRECT *rect2, VRECT *dst )
{
	if ( rect1->x1 > rect2->x1 )										/* am weitesten rechts liegende x1-Koordinate bestimmen */
		dst->x1 = rect1->x1;												
	else
		dst->x1 = rect2->x1;

	if ( rect1->y1 > rect2->y1 )										/* am weitesten unten liegenden y1-Koordinate bestimmen */
		dst->y1 = rect1->y1;
	else
		dst->y1 = rect2->y1;

	if ( rect1->x2 < rect2->x2 )										/* am weitesten links liegende x2-Koordinate bestimmen */
		dst->x2 = rect1->x2;
	else
		dst->x2 = rect2->x2;

	if ( rect1->y2 < rect2->y2 )										/* am weitesten oben liegende y2-Koordinate bestimmen */
		dst->y2 = rect1->y2;
	else
		dst->y2 = rect2->y2;

	if ( dst->x1 > dst->x2 )											/* horizontal keine öberschneidung? */
		return( 0 );
	if ( dst->y1 > dst->y2 )											/* vertikal keine öberschneidung? */
		return( 0 );
		
	return( 1 );															/* Rechtecke schneiden sich */
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontnamen und -art zurÅckliefern																			*/
/* Funktionsergebnis:	Font-ID																				*/
/*	handle:					VDI-Handle																			*/
/* index:					Index des Fonts (1 - Anzahl)													*/
/*	name:						String fÅr Fontnamen																*/
/*	font_format:			Fontformat																			*/
/*	flags:					...																					*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vqt_ext_name( WORD handle, WORD index, BYTE *name, UWORD *font_format, UWORD *flags )
{
	VDIPB pb;
	WORD	contrl[12];
	WORD	intin[16];
	WORD	ptsin[16];
	WORD	intout[48];
	WORD	ptsout[16];

	pb.contrl = contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	intin[0] = index;
	intin[1] = 0;

	contrl[0] = 130;
	contrl[1] = 0;
	contrl[3] = 2;
	contrl[5] = 1;
	contrl[6] = handle;

	vdi( &pb );

	vdi_str_to_c( (UWORD *)&intout[1], (UBYTE *) name, 31 );	/* den Namen in einen C-String umwandeln */

	if ( contrl[4] <= 34 )												/* wird das Fontformat nicht zurÅckgeliefert? */
	{
		*flags = 0;
		*font_format = 0;
		if ( contrl[4] == 33 )											/* wird auch der Fonttyp nicht zurÅckgeliefert? */
			name[32] = 0;													/* dann ist es ein Bitmap-Font */
		else
			name[32] = (BYTE) intout[33];								/* Fonttyp */
	}
	else
	{
		name[32] = (BYTE) intout[33];									/* Fonttyp */
		*flags = (intout[34] >> 8) & 0xff;							/* Flags */
		*font_format = intout[34] & 0xff;							/* Fontformat */
	}

	return( intout[0] );													/* Font-ID */
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontnamen und Grîûeninformationn zurÅckliefern														*/
/* Funktionsergebnis:	Font-ID																				*/
/*	handle:					VDI-Handle																			*/
/*	flags:					angeforderte Informationen														*/
/*	id:						Font-ID oder 0																		*/
/* index:					Index des Fonts (1 - Anzahl) oder 0											*/
/*	info:						Strukur fÅr die RÅckgabewerte													*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vqt_xfntinfo( WORD handle, WORD flags, WORD id, WORD index, XFNT_INFO *info )
{
	VDIPB pb;
	WORD	contrl[12];
	WORD	intin[16];
	WORD	ptsin[16];
	WORD	intout[16];
	WORD	ptsout[16];

	pb.contrl = contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	info->size = (LONG) sizeof( XFNT_INFO );

	intin[0] = flags;
	intin[1] = id;
	intin[2] = index;
	*(XFNT_INFO **)&intin[3] = info;

	contrl[0] = 229;
	contrl[1] = 0;
	contrl[3] = 5;
	contrl[5] = 0;
	contrl[6] = handle;

	vdi( &pb );

	return( intout[1] );
}

#if	CALL_MAGIC_KERNEL

static WORD	set_color( WORD opcode, WORD handle, WORD color_index )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = color_index;

	p.contrl[0] = opcode;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

static void	vdi_text( WORD opcode, WORD handle, WORD x, WORD y, BYTE *string )
{
	VDIPB pb;
	WORD	contrl[12];
	WORD	intin[128];
	WORD	ptsin[16];
	WORD	intout[16];
	WORD	ptsout[16];

	pb.contrl = contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	ptsin[0] = x;
	ptsin[1] = y;

	contrl[0] = opcode;
	contrl[1] = 1;
	contrl[3] = c_str_to_vdi( (UBYTE *) string, (UWORD *) intin );
	contrl[6] = handle;

	vdi( &pb );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fonts laden																										*/
/* Funktionsergebnis:	Anzahl der zusÑtzlichen Fonts													*/
/*	handle:					VDI-Handle																			*/
/*	select:					muû 0 sein																			*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vst_load_fonts( WORD handle, WORD select )
{
	VDIPB	pb;
	VDI_SMALL	p;															/* Paramterstruktur */
	
	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = select;

	p.contrl[0] = 119;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fonts entfernen																								*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	select:					muû 0 sein																			*/
/*----------------------------------------------------------------------------------------*/ 
static void	vst_unload_fonts( WORD handle, WORD select )
{
	VDIPB	pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = select;

	p.contrl[0] = 120;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );
}

/*----------------------------------------------------------------------------------------*/ 
/* ZusÑtzliche GerÑteinformationen erfragen																*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	flag:						Art der Information																*/
/* work_out:				Feld fÅr Informationen															*/
/*----------------------------------------------------------------------------------------*/ 
static void	vq_extnd( WORD handle, WORD flag, WORD *work_out )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	pb.intout = work_out;
	pb.ptsout = work_out + 45;

	p.contrl[0] = 102;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;
	p.intin[0] = flag;
	
	vdi( &pb );
}

/*----------------------------------------------------------------------------------------*/ 
/* Clipping-Rechteck setzen																					*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	clip_flag:				Flag fÅr Clipping aus/an														*/
/*	area:						Clipping-Rechteck																	*/
/*----------------------------------------------------------------------------------------*/ 
static void	vs_clip( WORD handle, WORD clip_flag, WORD *area )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */
	pb.ptsin = area;

	p.contrl[0] = 129;
	p.contrl[1] = 2;
	p.contrl[3] = 1;
	p.contrl[6] = handle;
	p.intin[0] = clip_flag;

	vdi( &pb );
}
	
/*----------------------------------------------------------------------------------------*/ 
/* Schreibmodus einstellen																						*/
/* Funktionsergebnis:	eingestellter Schreibmodus														*/
/*	handle:					VDI-Handle																			*/
/*	mode:						einzustellender Modus															*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vswr_mode( WORD handle, WORD mode )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = mode;

	p.contrl[0] = 32;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Linienzug zeichnen																							*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	count:					Anzahl der Punkte																	*/
/*	pxy:						Feld mit Punkten																	*/
/*----------------------------------------------------------------------------------------*/ 
static void	v_pline( WORD handle, WORD count, WORD *pxy )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */
	pb.ptsin = pxy;
	
	p.contrl[0] = 6;
	p.contrl[1] = count;
	p.contrl[3] = 0;
	p.contrl[6] = handle;

	vdi( &pb );
}

/*----------------------------------------------------------------------------------------*/ 
/* Farbe fÅr Linien setzen																						*/
/* Funktionsergebnis:	eingestelte Farbe																	*/
/*	handle:					VDI-Handle																			*/
/*	color_index:			einzustellende Farbe																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vsl_color( WORD handle, WORD color_index )
{
	return( set_color( 17, handle, color_index ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Typ fÅr Linien setzen																						*/
/* Funktionsergebnis:	eingestelte Farbe																	*/
/*	handle:					VDI-Handle																			*/
/*	color_index:			einzustellende Farbe																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vsl_type( WORD handle, WORD style )
{
	return( set_color( 15, handle, style ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Farbe fÅr gefÅllte FlÑchen setzen																		*/
/* Funktionsergebnis:	eingestelte Farbe																	*/
/*	handle:					VDI-Handle																			*/
/*	color_index:			einzustellende Farbe																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vsf_color( WORD handle, WORD color_index )
{
	return( set_color( 25, handle, color_index ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Muster fÅr gefÅllte FlÑchen setzen																						*/
/* Funktionsergebnis:	eingestellter Stil																	*/
/*	handle:					VDI-Handle																			*/
/*	color_index:			einzustellende Farbe																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vsf_interior( WORD handle, WORD style )
{
	return( set_color( 23, handle, style ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Rechteck zeichnen																								*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	rect:						Koordinaten des Rechtecks														*/
/*----------------------------------------------------------------------------------------*/ 
static void	vr_recfl( WORD handle, WORD *rect )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */
	pb.ptsin = rect;

	p.contrl[0] = 114;
	p.contrl[1] = 2;
	p.contrl[3] = 0;
	p.contrl[6] = handle;

	vdi( &pb );
}

/*----------------------------------------------------------------------------------------*/ 
/* Text ausgeben																								*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	x:							x-Koordinate																		*/
/*	y:							y-Koordinate																		*/
/*	string:					Zeiger auf die Zeichenkette													*/
/*----------------------------------------------------------------------------------------*/ 
static void	v_gtext( WORD handle, WORD x, WORD y, BYTE *string )
{
	vdi_text( 8, handle, x, y, string );
}

/*----------------------------------------------------------------------------------------*/ 
/* Font fÅr Textausgabe setzen																				*/
/* Funktionsergebnis:	ID des eingestellten Fonts														*/
/*	handle:					VDI-Handle																			*/
/*	font:						ID des einzustellenden Fonts													*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vst_font( WORD handle, WORD font )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = font;

	p.contrl[0] = 21;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Farbe fÅr Text setzen																						*/
/* Funktionsergebnis:	eingestelte Farbe																	*/
/*	handle:					VDI-Handle																			*/
/*	color_index:			einzustellende Farbe																*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vst_color( WORD handle, WORD color_index )
{
	return( set_color( 22, handle, color_index ));
}

/*----------------------------------------------------------------------------------------*/ 
/* horizontale und vertikale Textausrichtung einstellen												*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	hor_in:					einzustellende horizontale Ausrichtung										*/
/*	vert_in:					einzustellende vertikale Ausrichtung										*/
/*	hor_out:					eingestellte horizontale Ausrichtung										*/
/*	vert_out:				eingestellte vertikale Ausrichtung											*/
/*----------------------------------------------------------------------------------------*/ 
static void	vst_alignment( WORD handle, WORD hor_in, WORD vert_in, WORD *hor_out, WORD *vert_out )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0]	= hor_in;
	p.intin[1]	= vert_in;

	p.contrl[0] = 39;
	p.contrl[1] = 0;
	p.contrl[3] = 2;
	p.contrl[6] = handle;

	vdi( &pb );

	*hor_out = p.intout[0];
	*vert_out = p.intout[1];
}

/*----------------------------------------------------------------------------------------*/ 
/* Effekte fÅr Textausgabe einstellen																		*/
/* Funktionsergebnis:	eingestellte Effekte																*/
/*	handle:					VDI-Handle																			*/
/*	effect:					einzustellende Effekte															*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vst_effects( WORD handle, WORD effect )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0]  = effect;

	p.contrl[0] = 106;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Texthîhe in pt einstellen																					*/
/* Funktionsergebnis:	eingestellte Hîhe																	*/
/*	handle:					VDI-Handle																			*/
/*	point:					einzustellende Hîhe																*/
/*	char_width:				eingestellte Zeichenbreite														*/
/*	char_height:			eingestellte Zeichenhîhe														*/
/*	cell_width:				eingestellte Zeichenzellenbreite												*/
/*	cell_height:			eingestellte Zeichenzellenhîhe												*/
/*----------------------------------------------------------------------------------------*/ 
static WORD vst_point( WORD handle, WORD point, WORD *char_width, WORD *char_height, WORD *cell_width, WORD *cell_height )
{
	register WORD *ptsout;
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0]	= point;

	p.contrl[0] = 107;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	ptsout = p.ptsout;
	*char_width = *ptsout++;
	*char_height = *ptsout++;
	*cell_width = *ptsout++;
	*cell_height = *ptsout;

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeichenbreite und RÑnder zurÅckliefern																	*/
/* Funktionsergebnis:	Index des Zeichens																*/
/*	handle:					VDI-Handle																			*/
/*	index:					Index des Zeichens																*/
/*	cell_width:				Zeichenbreite																		*/
/*	left_delta:				unwichtig																			*/
/*	right_delta:			unwichtig																			*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vqt_width( WORD handle, WORD index, WORD *cell_width, WORD *left_delta, WORD *right_delta )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.contrl[0] = 117;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;
	p.intin[0] = index;
	vdi( &pb );

	*cell_width = p.ptsout[0];
	*left_delta = p.ptsout[2];
	*right_delta = p.ptsout[4];

	return( p.intout[0] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fontinformationen Åber Grîûe liefern																	*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	minADE:					niedrigster Zeichenindex														*/
/*	maxADE:					hîchster Zeichenindex															*/
/*	distances:				AbstÑnde																				*/
/*	effects:					Verbreiterungen durch Effekte													*/
/*	maxwidth:				grîûte Zeichenbreite																*/
/*----------------------------------------------------------------------------------------*/ 
static void	vqt_fontinfo( WORD handle, WORD *minADE, WORD *maxADE, WORD *distances, WORD *maxwidth, WORD *effects )
{
	register	WORD	*ptsout;

	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.contrl[0] = 131;
	p.contrl[1] = 0;
	p.contrl[3] = 0;
	p.contrl[6] = handle;

	vdi(&pb);

	*minADE = p.intout[0];
	*maxADE = p.intout[1];

	ptsout = p.ptsout;
	*maxwidth = *ptsout++;												/* ptsout[0] */
	distances[0] = *ptsout++;											/* ptsout[1] */
	effects[0] = *ptsout++;   											/* ptsout[2] */
	distances[1] = *ptsout++;											/* ptsout[3] */
	effects[1] = *ptsout++;												/* ptsout[4] */
	distances[2] = *ptsout++;											/* ptsout[5] */
	effects[2] = *ptsout++;												/* ptsout[6] */
	distances[3] = *ptsout++;											/* ptsout[7] */
	ptsout++;
	distances[4] = *ptsout;												/* ptsout[9] */
}

/*----------------------------------------------------------------------------------------*/ 
/* Speedo-Fontheader zurÅckliefern																			*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	buffer:					Zeiger auf einen Buffer fÅr den Fontheader								*/
/*	tdf_name:				Zeiger auf einen String fÅr den TDF-Namen									*/
/*----------------------------------------------------------------------------------------*/ 
static void	vqt_fontheader( WORD handle, BYTE *buffer, BYTE *tdf_name )
{
	VDIPB pb;
	WORD	contrl[12];
	WORD	intin[2];
	WORD	intout[128];
	WORD	ptsin[2];														/* Dummy */
	WORD	ptsout[2];														/* Dummy */

	pb.contrl = contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
	pb.intout = intout;
	pb.ptsout = ptsout;

	*((char **) intin) = buffer;										/* Buffer fÅr den Fontheader */

	contrl[0] = 232;
	contrl[1] = 0;
	contrl[3] = 2;
	contrl[6] = handle;

	vdi(&pb);

	vdi_str_to_c( (UWORD *)intout, (UBYTE *) tdf_name, contrl[4] );
}

/*----------------------------------------------------------------------------------------*/ 
/* Kerning fÅr Vektortext setzen																				*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	track_mode:				einzustellendes Track-Kerning													*/
/*	pair_mode:				einzustellendes Pair-Kerning													*/
/*	tracks:					Anzahl der Kerning-Tracks														*/
/*	pairs:					Anzahl der Kerning-Paare														*/
/*----------------------------------------------------------------------------------------*/ 
static void	vst_kern( WORD handle, WORD track_mode, WORD pair_mode, WORD *tracks, WORD *pairs )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = track_mode;
	p.intin[1] = pair_mode;

	p.contrl[0] = 237;
	p.contrl[1] = 0;
	p.contrl[3] = 2;
	p.contrl[6] = handle;

	vdi( &pb );

	*tracks = p.intout[0];
	*pairs = p.intout[1];
}

/*----------------------------------------------------------------------------------------*/ 
/* Vektortext ausgeben																							*/
/* Funktionsergebnis:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	x:							x-Koordinate																		*/
/*	y:							y-Koordinate																		*/
/*	string:					Zeiger auf die Zeichenkette													*/
/*----------------------------------------------------------------------------------------*/ 
static void	v_ftext( WORD handle, WORD x, WORD y, BYTE *string )
{
	vdi_text( 241, handle, x, y, string );
}

/*----------------------------------------------------------------------------------------*/ 
/* Texthîhe in 1/65536 pt einstellen																		*/
/* Funktionsergebnis:	eingestellte Hîhe																	*/
/*	handle:					VDI-Handle																			*/
/*	height:					einzustellende Hîhe																*/
/*	char_width:				eingestellte Zeichenbreite														*/
/*	char_height:			eingestellte Zeichenhîhe														*/
/*	cell_width:				eingestellte Zeichenzellenbreite												*/
/*	cell_height:			eingestellte Zeichenzellenhîhe												*/
/*----------------------------------------------------------------------------------------*/ 
static fix31	vst_arbpt32( WORD handle, fix31 height, WORD *char_width, WORD *char_height, WORD *cell_width, WORD *cell_height )
{
	register int *ptsout;
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	*((fix31 *) p.intin) = height;

	p.contrl[0] = 246;
	p.contrl[1] = 0;
	p.contrl[3] = 2;
	p.contrl[6] = handle;

	vdi(&pb);

	ptsout = p.ptsout;
	*char_width = *ptsout++;
	*char_height = *ptsout++;
	*cell_width = *ptsout++;
	*cell_height = *ptsout;

	return( *((fix31 *) p.intout) );
}

/*----------------------------------------------------------------------------------------*/ 
/* Textbreite in 1/65536 pt einstellen																		*/
/* Funktionsergebnis:	eingestellte Breite																*/
/*	handle:					VDI-Handle																			*/
/*	width:					einzustellende Breite															*/
/*	char_width:				eingestellte Zeichenbreite														*/
/*	char_height:			eingestellte Zeichenhîhe														*/
/*	cell_width:				eingestellte Zeichenzellenbreite												*/
/*	cell_height:			eingestellte Zeichenzellenhîhe												*/
/*----------------------------------------------------------------------------------------*/ 
static fix31	vst_setsize32( WORD handle, fix31 width, WORD *char_width, WORD *char_height, WORD *cell_width, WORD *cell_height )
{
	register WORD	*ptsout;
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	*((fix31 *) p.intin) = width;

	p.contrl[0] = 252;
	p.contrl[1] = 0;
	p.contrl[3] = 2;
	p.contrl[6] = handle;

	vdi( &pb );

	ptsout = p.ptsout;
	*char_width = *ptsout++;
	*char_height = *ptsout++;
	*cell_width = *ptsout++;
	*cell_height = *ptsout;

	return( *((fix31 *) p.intout) );
}

/*----------------------------------------------------------------------------------------*/ 
/* Textneigung in 1/10 Grad einstellen																		*/
/* Funktionsergebnis:	eingestellte Neigung																*/
/*	handle:					VDI-Handle																			*/
/*	skew:						Neigung entgegen dem Uhrzeigersinn											*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	vst_skew( WORD handle, WORD skew )
{
	VDIPB pb;
	VDI_SMALL	p;															/* Paramterstruktur */

	init_vdi_pb( &pb, &p );												/* PB initialisieren */

	p.intin[0] = skew;

	p.contrl[0] = 253;
	p.contrl[1] = 0;
	p.contrl[3] = 1;
	p.contrl[6] = handle;

	vdi( &pb );

	return( p.intout[0] );
}

#endif
