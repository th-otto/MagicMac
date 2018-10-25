/*
 * https://de.wikipedia.org/wiki/Atari-ST-Zeichensatz
 * https://de.wikipedia.org/wiki/Macintosh_Roman
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>


#define NELEMS(table) (sizeof(table)/sizeof(table[0]))


int verbose = 0;
int reverse = 0;
long lineno;
const char *converted_atari_file_ext = ".ataritext";
const char *converted_utf8_file_ext = ".utf8";


static void convert(const char *filename);

int main(int argc, char *argv[])
{
	for (argc--, argv++; argc; argc--, argv++)
	{
		if (!strcmp(*argv, "-v"))
		{
			verbose = 1;
		} else if (!strcmp(*argv, "-r"))
		{
			reverse = !reverse;
		} else
		{
			convert(*argv);
		}
	}
}


#define ATARI_UC_CEDILLE	0x80		/* Ç */
#define ATARI_U_LC_UMLAUT	0x81		/* ü */
#define ATARI_LC_E_ACUT		0x82		/* é */
#define ATARI_LC_A_CIRC		0x83		/* â */
#define ATARI_A_LC_UMLAUT	0x84		/* ä */
#define ATARI_LC_A_GRAV		0x85		/* à */
#define ATARI_LC_A_BOLLE	0x86		/* å */
#define ATARI_LC_CEDILLE	0x87		/* ç */
#define ATARI_LC_E_CIRC		0x88		/* ê */
#define ATARI_LC_E_TREMA	0x89		/* ë */
#define ATARI_LC_E_GRAV		0x8a		/* è */
#define ATARI_LC_I_TREMA	0x8b		/* ï */
#define ATARI_LC_I_CIRC     0x8c		/* î */
#define ATARI_LC_I_GRAV     0x8d		/* ì */
#define ATARI_A_UC_UMLAUT	0x8e		/* Ä */
#define ATARI_UC_A_BOLLE	0x8f		/* Å */
#define ATARI_UC_E_ACUT		0x90		/* É */
#define ATARI_LC_AE			0x91		/* æ */
#define ATARI_UC_AE			0x92		/* Æ */
#define ATARI_LC_O_CIRC		0x93		/* ô */
#define ATARI_O_LC_UMLAUT	0x94		/* ö */
#define ATARI_LC_O_GRAV		0x95		/* ò */
#define ATARI_LC_U_CIRC		0x96		/* û */
#define ATARI_LC_U_GRAV		0x97		/* ù */
#define ATARI_LC_Y_TREMA	0x98		/* ÿ */
#define ATARI_O_UC_UMLAUT	0x99		/* Ö */
#define ATARI_U_UC_UMLAUT	0x9a		/* Ü */
#define ATARI_CENT			0x9b		/* ¢ */
#define ATARI_POUND			0x9c		/* £ */
#define ATARI_YEN			0x9d		/* ¥ */
#define ATARI_LC_ESZETT   	0x9e		/* ß */
#define ATARI_FLORIN		0x9f		/* ƒ */
#define ATARI_LC_A_ACUT     0xa0		/* á */
#define ATARI_LC_I_ACUT		0xa1		/* í */
#define ATARI_LC_O_ACUT     0xa2		/* ó */
#define ATARI_LC_U_ACUT     0xa3		/* ú */
#define ATARI_LC_ENJE		0xa4		/* ñ */
#define ATARI_UC_ENJE		0xa5		/* Ñ */
#define ATARI_ORDINAL_A 	0xa6		/* ª */
#define ATARI_ORDINAL_O 	0xa7		/* º */
#define ATARI_INV_QUEST		0xa8		/* ¿ */
#define ATARI_NEGATION_A	0xa9		/* ⌐ */
#define ATARI_NEGATION 		0xaa		/* ¬ */
#define ATARI_HALF			0xab		/* ½ */
#define ATARI_QUARTER		0xac		/* ¼ */
#define ATARI_INV_EXCL		0xad		/* ¡ */
#define ATARI_GUILL_L		0xae		/* « */
#define ATARI_GUILL_R		0xaf		/* » */
#define ATARI_LC_A_TILDE	0xb0		/* ã */
#define ATARI_LC_O_TILDE	0xb1		/* õ */
#define ATARI_UC_O_SLASH	0xb2		/* Ø */
#define ATARI_LC_O_SLASH	0xb3		/* ø */
#define ATARI_LC_OE			0xb4		/* œ */
#define ATARI_UC_OE			0xb5		/* Œ */
#define ATARI_UC_A_GRAV		0xb6		/* À */
#define ATARI_UC_A_TILDE	0xb7		/* Ã */
#define ATARI_UC_O_TILDE	0xb8		/* Õ */
#define ATARI_TREMA			0xb9		/* ¨ */
#define ATARI_ACUT			0xba		/* ´ */
#define ATARI_CROSS			0xbb		/* † */
#define ATARI_ALINEA		0xbc		/* ¶ */
#define ATARI_COPYRIGHT		0xbd		/* © */
#define ATARI_REG_TM		0xbe		/* ® */
#define ATARI_UNREG_TM		0xbf		/* ™ */
#define ATARI_LC_IJ			0xc0		/* ĳ */
#define ATARI_UC_IJ			0xc1		/* Ĳ */
#define ATARI_ALEPH			0xc2		/* א */
#define ATARI_BETH			0xc3		/* ב */
#define ATARI_GIMEL			0xc4		/* ג */
#define ATARI_DALETH		0xc5		/* ד */
#define ATARI_HE			0xc6		/* ה */
#define ATARI_WAW			0xc7		/* ו */
#define ATARI_ZAJIN			0xc8		/* ז */
#define ATARI_CHET			0xc9		/* ח */
#define ATARI_TETH			0xca		/* ט */
#define ATARI_JOD			0xcb		/* י */
#define ATARI_KAPH			0xcc		/* כ */
#define ATARI_LAMED			0xcd		/* ל */
#define ATARI_MEM			0xce		/* מ */
#define ATARI_NUN			0xcf		/* נ */
#define ATARI_SAMECH		0xd0		/* ס */
#define ATARI_AJIN			0xd1		/* ע */
#define ATARI_PE			0xd2		/* פ */
#define ATARI_TZADE			0xd3		/* צ */
#define ATARI_KOPH			0xd4		/* ק */
#define ATARI_RESCH			0xd5		/* ר */
#define ATARI_SCHIN			0xd6		/* ש */
#define ATARI_TAW			0xd7		/* ת */
#define ATARI_NUN2			0xd8		/* ן */
#define ATARI_KAPH2			0xd9		/* ך */
#define ATARI_MEM2			0xda		/* ם */
#define ATARI_PE2			0xdb		/* ף */
#define ATARI_SADE			0xdc		/* ץ */
#define ATARI_PARAGRAPH		0xdd		/* § */
#define ATARI_LOG_AND		0xde		/* ∧ */
#define ATARI_INFINITE		0xdf		/* ∞ */
#define ATARI_ALPHA 		0xe0		/* α */
#define ATARI_BETA          0xe1		/* β */
#define ATARI_GAMMA         0xe2		/* Γ */
#define ATARI_PI			0xe3		/* π */
#define ATARI_UC_SIGMA		0xe4		/* Σ */
#define ATARI_LC_SIGMA		0xe5		/* σ */
#define ATARI_LC_MY			0xe6		/* µ */
#define ATARI_TAU			0xe7		/* τ */
#define ATARI_UC_PHI		0xe8		/* Φ */
#define ATARI_THETA			0xe9		/* Θ */
#define ATARI_UC_OMEGA		0xea		/* Ω */
#define ATARI_LC_DELTA		0xeb		/* δ */
#define ATARI_INTEGRAL		0xec		/* ∮ */
#define ATARI_LC_PHI		0xed		/* φ */
#define ATARI_ELEMENT		0xee		/* ∈ */
#define ATARI_INTERSECT		0xef		/* ∩ */
#define ATARI_IDENT			0xf0		/* ≡ */
#define ATARI_PLUSMINUS		0xf1		/* ± */
#define ATARI_GE			0xf2		/* ≥ */
#define ATARI_LE			0xf3		/* ≤ */
#define ATARI_INTEGRAL1		0xf4		/* ⌠ */
#define ATARI_INTEGRAL2		0xf5		/* ⌡ */
#define ATARI_DIV			0xf6		/* ÷ */
#define ATARI_NEARLY_EQ		0xf7		/* ≈ */
#define ATARI_DEGREE		0xf8		/* ° */
#define ATARI_BULLET		0xf9		/* ∙ */
#define ATARI_INTERPUNCT	0xfa		/* · */
#define ATARI_ROOT			0xfb		/* √ */
#define ATARI_N_SUPER		0xfc		/* ⁿ */
#define ATARI_2_SUPER		0xfd		/* ² */
#define ATARI_3_SUPER		0xfe		/* ³ */
#define ATARI_MACRON		0xff		/* ¯ */


const char *Atari2Unicode[] = {
     /* #define ATARI_UC_CEDILLE	0x80 */ "Ç",  /* U+00c7 */
     /* #define ATARI_U_LC_UMLAUT	0x81 */ "ü",  /* U+00fc */
     /* #define ATARI_LC_E_ACUT		0x82 */ "é",  /* U+00e9 */
     /* #define ATARI_LC_A_CIRC		0x83 */ "â",  /* U+00e2 */
     /* #define ATARI_A_LC_UMLAUT	0x84 */ "ä",  /* U+00e4 */
     /* #define ATARI_LC_A_GRAV		0x85 */ "à",  /* U+00e0 */
     /* #define ATARI_LC_A_BOLLE	0x86 */ "å",  /* U+00e5 */
     /* #define ATARI_LC_CEDILLE	0x87 */ "ç",  /* U+00e7 */
     /* #define ATARI_LC_E_CIRC		0x88 */ "ê",  /* U+00ea */
     /* #define ATARI_LC_E_TREMA	0x89 */ "ë",  /* U+00eb */
     /* #define ATARI_LC_E_GRAV		0x8a */ "è",  /* U+00e8 */
     /* #define ATARI_LC_I_TREMA	0x8b */ "ï",  /* U+00ef */
     /* #define ATARI_LC_I_CIRC     0x8c */ "î",  /* U+00ee */
     /* #define ATARI_LC_I_GRAV     0x8d */ "ì",  /* U+00ec */
     /* #define ATARI_A_UC_UMLAUT	0x8e */ "Ä",  /* U+00c4 */
     /* #define ATARI_UC_A_BOLLE	0x8f */ "Å",  /* U+00c5 */
     /* #define ATARI_UC_E_ACUT		0x90 */ "É",  /* U+00c9 */
     /* #define ATARI_LC_AE			0x91 */ "æ",  /* U+00e6 */
     /* #define ATARI_UC_AE			0x92 */ "Æ",  /* U+00c6 */
     /* #define ATARI_LC_O_CIRC		0x93 */ "ô",  /* U+00f4 */
     /* #define ATARI_O_LC_UMLAUT	0x94 */ "ö",  /* U+00f6 */
     /* #define ATARI_LC_O_GRAV		0x95 */ "ò",  /* U+00f2 */
     /* #define ATARI_LC_U_CIRC		0x96 */ "û",  /* U+00fb */
     /* #define ATARI_LC_U_GRAV		0x97 */ "ù",  /* U+00f9 */
     /* #define ATARI_LC_Y_TREMA	0x98 */ "ÿ",  /* U+00ff */
     /* #define ATARI_O_UC_UMLAUT	0x99 */ "Ö",  /* U+00d6 */
     /* #define ATARI_U_UC_UMLAUT	0x9a */ "Ü",  /* U+00dc */
     /* #define ATARI_CENT			0x9b */ "¢",  /* U+00a2 */
     /* #define ATARI_POUND			0x9c */ "£",  /* U+00a3 */
     /* #define ATARI_YEN			0x9d */ "¥",  /* U+00a5 */
     /* #define ATARI_LC_ESZETT   	0x9e */ "ß",  /* U+00df */
     /* #define ATARI_FLORIN		0x9f */ "ƒ",  /* U+0192 */
     /* #define ATARI_LC_A_ACUT     0xa0 */ "á",  /* U+00e1 */
     /* #define ATARI_LC_I_ACUT		0xa1 */ "í",  /* U+00ed */
     /* #define ATARI_LC_O_ACUT     0xa2 */ "ó",  /* U+00f3 */
     /* #define ATARI_LC_U_ACUT     0xa3 */ "ú",  /* U+00fa */
     /* #define ATARI_LC_ENJE		0xa4 */ "ñ",  /* U+00f1 */
     /* #define ATARI_UC_ENJE		0xa5 */ "Ñ",  /* U+00d1 */
     /* #define ATARI_ORDINAL_A 	0xa6 */ "ª",  /* U+00aa */
     /* #define ATARI_ORDINAL_O 	0xa7 */ "º",  /* U+00ba */
     /* #define ATARI_INV_QUEST		0xa8 */ "¿",  /* U+00bf */
     /* #define ATARI_NEGATION_A	0xa9 */ "⌐", /* U+2310 */
     /* #define ATARI_NEGATION 		0xaa */ "¬",  /* U+00ac */
     /* #define ATARI_HALF			0xab */ "½",  /* U+00bd */
     /* #define ATARI_QUARTER		0xac */ "¼",  /* U+00bc */
     /* #define ATARI_INV_EXCL		0xad */ "¡",  /* U+00a1 */
     /* #define ATARI_GUILL_L		0xae */ "«",  /* U+00ab */
     /* #define ATARI_GUILL_R		0xaf */ "»",  /* U+00bb */
     /* #define ATARI_LC_A_TILDE	0xb0 */ "ã",  /* U+00e3 */
     /* #define ATARI_LC_O_TILDE	0xb1 */ "õ",  /* U+00f5 */
     /* #define ATARI_UC_O_SLASH	0xb2 */ "Ø",  /* U+00d8 */
     /* #define ATARI_LC_O_SLASH	0xb3 */ "ø",  /* U+00f8 */
     /* #define ATARI_LC_OE			0xb4 */ "œ",  /* U+0153 */
     /* #define ATARI_UC_OE			0xb5 */ "Œ",  /* U+0152 */
     /* #define ATARI_UC_A_GRAV		0xb6 */ "À",  /* U+00c0 */
     /* #define ATARI_UC_A_TILDE	0xb7 */ "Ã",  /* U+00c3 */
     /* #define ATARI_UC_O_TILDE	0xb8 */ "Õ",  /* U+00d5 */
     /* #define ATARI_TREMA			0xb9 */ "¨",  /* U+00a8 */
     /* #define ATARI_ACUT			0xba */ "´",  /* U+00b4 */
     /* #define ATARI_CROSS			0xbb */ "†", /* U+2020 */
     /* #define ATARI_ALINEA		0xbc */ "¶",  /* U+00b6 */
     /* #define ATARI_COPYRIGHT		0xbd */ "©",  /* U+00a9 */
     /* #define ATARI_REG_TM		0xbe */ "®",  /* U+00ae */
     /* #define ATARI_UNREG_TM		0xbf */ "™", /* U+2122 */
     /* #define ATARI_LC_IJ			0xc0 */ "ĳ",  /* U+0133 */
     /* #define ATARI_UC_IJ			0xc1 */ "Ĳ",  /* U+0132 */
     /* #define ATARI_ALEPH			0xc2 */ "א",  /* U+05d0 */
     /* #define ATARI_BETH			0xc3 */ "ב",  /* U+05d1 */
     /* #define ATARI_GIMEL			0xc4 */ "ג",  /* U+05d2 */
     /* #define ATARI_DALETH		0xc5 */ "ד",  /* U+05d3 */
     /* #define ATARI_HE			0xc6 */ "ה",  /* U+05d4 */
     /* #define ATARI_WAW			0xc7 */ "ו",  /* U+05d5 */
     /* #define ATARI_ZAJIN			0xc8 */ "ז",  /* U+05d6 */
     /* #define ATARI_CHET			0xc9 */ "ח",  /* U+05d7 */
     /* #define ATARI_TETH			0xca */ "ט",  /* U+05d8 */
     /* #define ATARI_JOD			0xcb */ "י",  /* U+05d9 */
     /* #define ATARI_KAPH			0xcc */ "כ",  /* U+05db */
     /* #define ATARI_LAMED			0xcd */ "ל",  /* U+05dc */
     /* #define ATARI_MEM			0xce */ "מ",  /* U+05de */
     /* #define ATARI_NUN			0xcf */ "נ",  /* U+05e0 */
     /* #define ATARI_SAMECH		0xd0 */ "ס",  /* U+05e1 */
     /* #define ATARI_AJIN			0xd1 */ "ע",  /* U+05e2 */
     /* #define ATARI_PE			0xd2 */ "פ",  /* U+05e4 */
     /* #define ATARI_TZADE			0xd3 */ "צ",  /* U+05e6 */
     /* #define ATARI_KOPH			0xd4 */ "ק",  /* U+05e7 */
     /* #define ATARI_RESCH			0xd5 */ "ר",  /* U+05e8 */
     /* #define ATARI_SCHIN			0xd6 */ "ש",  /* U+05e9 */
     /* #define ATARI_TAW			0xd7 */ "ת",  /* U+05ea */
     /* #define ATARI_NUN2			0xd8 */ "ן",  /* U+05df */
     /* #define ATARI_KAPH2			0xd9 */ "ך",  /* U+05da */
     /* #define ATARI_MEM2			0xda */ "ם",  /* U+05dd */
     /* #define ATARI_PE2			0xdb */ "ף",  /* U+05e3 */
     /* #define ATARI_SADE			0xdc */ "ץ",  /* U+05e5 */
     /* #define ATARI_PARAGRAPH		0xdd */ "§",  /* U+00a7 */
     /* #define ATARI_LOG_AND		0xde */ "∧", /* U+2227 */
     /* #define ATARI_INFINITE		0xdf */ "∞", /* U+221e */
     /* #define ATARI_ALPHA 		0xe0 */ "α",  /* U+03b1 */
     /* #define ATARI_BETA          0xe1 */ "β",  /* U+03b2 */
     /* #define ATARI_GAMMA         0xe2 */ "Γ",  /* U+0393 */
     /* #define ATARI_PI			0xe3 */ "π",  /* U+03c0 */
     /* #define ATARI_UC_SIGMA		0xe4 */ "Σ",  /* U+03a3 */
     /* #define ATARI_LC_SIGMA		0xe5 */ "σ",  /* U+03c3 */
     /* #define ATARI_LC_MY			0xe6 */ "µ",  /* U+00b5 */
     /* #define ATARI_TAU			0xe7 */ "τ",  /* U+03c4 */
     /* #define ATARI_UC_PHI		0xe8 */ "Φ",  /* U+03a6 */
     /* #define ATARI_THETA			0xe9 */ "Θ",  /* U+0398 */
     /* #define ATARI_UC_OMEGA		0xea */ "Ω",  /* U+03a9 */
     /* #define ATARI_LC_DELTA		0xeb */ "δ",  /* U+03b4 */
     /* #define ATARI_INTEGRAL		0xec */ "∮", /* U+222e */
     /* #define ATARI_LC_PHI		0xed */ "φ",  /* U+03c6 */
     /* #define ATARI_ELEMENT		0xee */ "∈", /* U+2208 */
     /* #define ATARI_INTERSECT		0xef */ "∩", /* U+2229 */
     /* #define ATARI_IDENT			0xf0 */ "≡", /* U+2261 */
     /* #define ATARI_PLUSMINUS		0xf1 */ "±",  /* U+00b1 */
     /* #define ATARI_GE			0xf2 */ "≥", /* U+2265 */
     /* #define ATARI_LE			0xf3 */ "≤", /* U+2264 */
     /* #define ATARI_INTEGRAL1		0xf4 */ "⌠", /* U+2320 */
     /* #define ATARI_INTEGRAL2		0xf5 */ "⌡", /* U+2321 */
     /* #define ATARI_DIV			0xf6 */ "÷",  /* U+00f7 */
     /* #define ATARI_NEARLY_EQ		0xf7 */ "≈", /* U+2248 */
     /* #define ATARI_DEGREE		0xf8 */ "°",  /* U+00b0 */
#if 1
     /* #define ATARI_BULLET		0xf9 */ "∙", /* U+2219 */
#else
     /* #define ATARI_BULLET		0xf9 */ "•", /* U+2022 */
#endif
     /* #define ATARI_INTERPUNCT	0xfa */ "·",  /* U+00b7 */
     /* #define ATARI_ROOT			0xfb */ "√", /* U+221a */
     /* #define ATARI_N_SUPER		0xfc */ "ⁿ", /* U+207f */
     /* #define ATARI_2_SUPER		0xfd */ "²",  /* U+00b2 */
     /* #define ATARI_3_SUPER		0xfe */ "³",  /* U+00b3 */
     /* #define ATARI_MACRON		0xff */ "¯",  /* U+00af */
};


static uint8_t processUtf8Char(const char *p, int maxlen, int *n)
{
	int unicode_len;
	int i;
	char c2[3];

	if ((maxlen >= 2) && ((p[0] & 0xe0) == 0xc0) && (p[1] & 0xc0) == 0x80)
	{
		unicode_len = 2;
	} else if ((maxlen >= 3) && ((p[0] & 0xf0) == 0xe0) && ((p[1] & 0xc0) == 0x80) && ((p[2] & 0xc0) == 0x80))
	{
		unicode_len = 3;
	} else
		if ((maxlen >= 4) && ((p[0] & 0xf8) == 0xf0) && ((p[1] & 0xc0) == 0x80) && ((p[2] & 0xc0) == 0x80)
			&& ((p[3] & 0xc0) == 0x80))
	{
		unicode_len = 4;
	} else
	{
		return 0;
	}
	(void) unicode_len;

	for (i = 0; i < NELEMS(Atari2Unicode); i++)
	{
		const char *utf = Atari2Unicode[i];
		int l = strlen(utf);

		if ((maxlen >= l) && (!memcmp(p, utf, l)))
		{
			uint8_t c = (uint8_t) (0x80 + i);

			if (verbose)
			{
				printf("replace utf8 character %s (len %u) -> Atari 0x%02x\n", utf, l, c);
			}
			*n = l;
			return c;
		}
	}

	c2[0] = p[0];
	c2[1] = p[1];
	c2[2] = '\0';
	fprintf(stderr, "Error: line %ld: cannot translate unicode 0x%02x %02x (%s)\n", lineno, p[0] & 0xff, p[1] & 0xff, c2);
	fprintf(stderr, "        Context: %.10s\n", p);

	return 0;
}


static size_t getFileSize(FILE * f)
{
	int sz;

	fseek(f, 0L, SEEK_END);
	sz = ftell(f);
	fseek(f, 0L, SEEK_SET);
	return sz;
}


static void convert(const char *filename)
{
	FILE *fi = fopen(filename, "rb");
	int fsize;
	uint8_t *buf;
	size_t pluslen;
	FILE *fo;
	
	if (fi == NULL)
	{
		fprintf(stderr, "Cannot open \"%s\" for reading\n", filename);
		return;
	}

	fsize = getFileSize(fi);
	buf = malloc(fsize);
	if (buf == NULL)
	{
		fclose(fi);
		fprintf(stderr, "Cannot read \"%s\"\n", filename);
		return;
	}

	if (fsize != fread(buf, 1, fsize, fi))
	{
		fclose(fi);
		fprintf(stderr, "Cannot read \"%s\"\n", filename);
		return;
	}

	fclose(fi);

	pluslen = reverse ? strlen(converted_utf8_file_ext) : strlen(converted_atari_file_ext);
	{
		char outname[strlen(filename) + pluslen + 1];

		strcpy(outname, filename);
		strcat(outname, reverse ? converted_utf8_file_ext : converted_atari_file_ext);
		fo = fopen(outname, "wb");
		if (fo == NULL)
		{
			fclose(fi);
			fprintf(stderr, "Cannot open \"%s\" for writing\n", outname);
			return;
		}
		printf("convert \"%s\" to \"%s\"\n", filename, outname);
	}

	lineno = 1;
	if (reverse)
	{
		/*
		 * conversion loop Atari -> utf8
		 */

		const uint8_t *p = buf;
		const uint8_t *endp = buf + fsize;

		while (p < endp)
		{
			uint8_t c = *p++;

			if (c < 0x80)
			{
				/* nothing special, just copy character */
				fwrite(&c, 1, 1, fo);
				if (c == 0x0a)
					lineno++;
			} else
			{
				/* write utf string instead */
				const char *utf = Atari2Unicode[c - 0x80];

				if (verbose)
				{
					char buf[64];
					int n;
					const char *p;

					buf[0] = '\0';
					n = strlen(utf);
					p = utf;
					while (n)
					{
						sprintf(buf + strlen(buf), "0x%02x", (*p & 0x00ff));
						n--;
						p++;
						if (n > 0)
						{
							strcat(buf, " ");
						}
					}

					printf("replace Atari character 0x%02x -> %s (%s)\n", c, utf, buf);
				}

				fwrite(utf, 1, strlen(utf), fo);
			}
		}
	} else
	{
		/*
		 * conversion loop utf8 -> Atari
		 */
		const uint8_t *p = buf;
		const uint8_t *endp = buf + fsize;
		uint8_t instring = 0;
		
		while (p < endp)
		{
			int n = 0;
			uint8_t c;
			
			c = *p;
			if (c >= 0x80)
				c = processUtf8Char((const char *) p, endp - p, &n);
			else
				n = 1;
			if (c > 0)
			{
				/* replace with atari character and advance pointer */
				if (c >= 0x80)
				{
					if (instring)
					{
						fprintf(fo, "%c,$%02x,%c", instring, c, instring);
					} else
					{
						switch (c)
						{
						case 0x84:
							fputc('a', fo);
							fputc('e', fo);
							break;
						case 0x94:
							fputc('o', fo);
							fputc('e', fo);
							break;
						case 0x81:
							fputc('u', fo);
							fputc('e', fo);
							break;
						case 0x8E:
							fputc('A', fo);
							fputc('e', fo);
							break;
						case 0x99:
							fputc('O', fo);
							fputc('e', fo);
							break;
						case 0x9A:
							fputc('U', fo);
							fputc('e', fo);
							break;
						case 0x9E:
							fputc('s', fo);
							fputc('s', fo);
							break;
						default:
							fputc(c, fo);
							break;
						}
					}
					p += n;
				} else
				{
					if (instring == 0 && (c == '\'' || c == '"'))
					{
						instring = c;
					} else if (instring && c == '\\' && (p[1] == '\'' || p[1] == '"' || p[1] == '\\'))
					{
						fputc(c, fo);
						p++;
						c = *p;
						n = 1;
					} else if (c == instring)
					{
						instring = 0;
					}
					fputc(c, fo);
					p += n;
					if (c == 0x0a)
					{
						if (instring)
							fprintf(stderr, "Warning: line %ld: missing terminating '%c'\n", lineno, instring);
						lineno++;
						instring = 0;
					}
				}
			} else
			{
				/* nothing found, just copy character */
				fputc(*p, fo);
				p++;
			}
		}
	}

	fclose(fo);
	free(buf);
}
