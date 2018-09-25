// https://de.wikipedia.org/wiki/Atari-ST-Zeichensatz
// https://de.wikipedia.org/wiki/Macintosh_Roman

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>


#define NELEMS(table) (sizeof(table)/sizeof(table[0]))


int verbose = 0;
int reverse = 0;
const char *converted_atari_file_ext = ".ataritext";
const char *converted_utf8_file_ext = ".utf8";


static void convert(const char *filename);

int main(int argc, char *argv[])
{
	for (argc--,argv++; argc; argc--,argv++)
	{
		if (!strcmp(*argv, "-v"))
		{
			verbose = 1;
		}
		else
		if (!strcmp(*argv, "-r"))
		{
			reverse = !reverse;
		}
		else
		{
			convert(*argv);
		}
	}
}


#define ATARI_UC_CEDILLE	0x80		// Ç
#define ATARI_U_LC_UMLAUT	0x81		// ü
#define ATARI_LC_E_ACUT		0x82		// é
#define ATARI_LC_A_CIRC		0x83		// â
#define ATARI_A_LC_UMLAUT	0x84		// ä
#define ATARI_LC_A_GRAV		0x85		// à
#define ATARI_LC_A_BOLLE	0x86		// å
#define ATARI_LC_CEDILLE	0x87		// ç
#define ATARI_LC_E_CIRC		0x88		// ê
#define ATARI_LC_E_TREMA	0x89		// ë
#define ATARI_LC_E_GRAV		0x8a		// è
#define ATARI_LC_I_TREMA	0x8b		// ï
#define ATARI_LC_I_CIRC     0x8c 		// î
#define ATARI_LC_I_GRAV     0x8d 		// ì
#define ATARI_A_UC_UMLAUT	0x8e		// Ä
#define ATARI_UC_A_BOLLE	0x8f		// Å
#define ATARI_UC_E_ACUT		0x90		// É
#define ATARI_LC_AE			0x91		// æ
#define ATARI_UC_AE			0x92		// Æ
#define ATARI_LC_O_CIRC		0x93		// ô
#define ATARI_O_LC_UMLAUT	0x94		// ö
#define ATARI_LC_O_GRAV		0x95		// ò
#define ATARI_LC_U_CIRC		0x96		// û
#define ATARI_LC_U_GRAV		0x97		// ù
#define ATARI_LC_Y_TREMA	0x98 		// ÿ
#define ATARI_O_UC_UMLAUT	0x99		// Ö
#define ATARI_U_UC_UMLAUT	0x9a		// Ü
#define ATARI_CENT			0x9b 		// ¢
#define ATARI_POUND			0x9c 		// £
#define ATARI_YEN			0x9d 		// ¥
#define ATARI_LC_ESZETT   	0x9e		// ß
#define ATARI_FLORIN		0x9f 		// ƒ
#define ATARI_LC_A_ACUT     0xa0		// á
#define ATARI_LC_I_ACUT		0xa1 		// í
#define ATARI_LC_O_ACUT     0xa2		// ó
#define ATARI_LC_U_ACUT     0xa3		// ú
#define ATARI_LC_ENJE		0xa4 		// ñ
#define ATARI_UC_ENJE		0xa5 		// Ñ
#define ATARI_ORDINAL_A 	0xa6 		// ª
#define ATARI_ORDINAL_O 	0xa7 		// º
#define ATARI_INV_QUEST		0xa8 		// ¿
#define ATARI_NEGATION_A	0xa9		// ⌐
#define ATARI_NEGATION 		0xaa		// ¬
#define ATARI_HALF			0xab		// ½
#define ATARI_QUARTER		0xac 		// ¼
#define ATARI_INV_EXCL		0xad 		// ¡
#define ATARI_GUILL_L		0xae 		// «
#define ATARI_GUILL_R		0xaf 		// »
#define ATARI_LC_A_TILDE	0xb0		// ã
#define ATARI_LC_O_TILDE	0xb1		// õ
#define ATARI_UC_O_SLASH	0xb2		// Ø
#define ATARI_LC_O_SLASH	0xb3		// ø
#define ATARI_LC_OE			0xb4		// œ
#define ATARI_UC_OE			0xb5		// Œ
#define ATARI_UC_A_GRAV		0xb6		// À
#define ATARI_UC_A_TILDE	0xb7		// Ã
#define ATARI_UC_O_TILDE	0xb8		// Õ
#define ATARI_TREMA			0xb9		// ¨
#define ATARI_ACUT			0xba		// ´
#define ATARI_CROSS			0xbb		// †
#define ATARI_ALINEA		0xbc		// ¶
#define ATARI_COPYRIGHT		0xbd		// ©
#define ATARI_REG_TM		0xbe		// ®
#define ATARI_UNREG_TM		0xbf		// ™
#define ATARI_LC_IJ			0xc0		// ĳ
#define ATARI_UC_IJ			0xc1		// Ĳ
#define ATARI_ALEPH			0xc2		// א
#define ATARI_BETH			0xc3		// ב
#define ATARI_GIMEL			0xc4		// ג
#define ATARI_DALETH		0xc5		// ד
#define ATARI_HE			0xc6		// ה
#define ATARI_WAW			0xc7		// ו
#define ATARI_ZAJIN			0xc8		// ז
#define ATARI_CHET			0xc9		// ח
#define ATARI_TETH			0xca		// ט
#define ATARI_JOD			0xcb		// י
#define ATARI_KAPH			0xcc		// כ
#define ATARI_LAMED			0xcd		// ל
#define ATARI_MEM			0xce		// מ
#define ATARI_NUN			0xcf		// נ
#define ATARI_SAMECH		0xd0 		// ס
#define ATARI_AJIN			0xd1		// ע
#define ATARI_PE			0xd2		// פ
#define ATARI_TZADE			0xd3		// צ
#define ATARI_KOPH			0xd4		// ק
#define ATARI_RESCH			0xd5		// ר
#define ATARI_SCHIN			0xd6		// ש
#define ATARI_TAW			0xd7		// ת
#define ATARI_NUN2			0xd8		// ן
#define ATARI_KAPH2			0xd9		// ך
#define ATARI_MEM2			0xda		// ם
#define ATARI_PE2			0xdb		// ף
#define ATARI_SADE			0xdc		// ץ
#define ATARI_PARAGRAPH		0xdd		// §
#define ATARI_LOG_AND		0xde		// ∧
#define ATARI_INFINITE		0xdf		// ∞
#define ATARI_ALPHA 		0xe0		// α
#define ATARI_BETA          0xe1        // β
#define ATARI_GAMMA         0xe2        // Γ
#define ATARI_PI			0xe3		// π
#define ATARI_UC_SIGMA		0xe4		// Σ
#define ATARI_LC_SIGMA		0xe5		// σ
#define ATARI_LC_MY			0xe6		// µ
#define ATARI_TAU			0xe7		// τ
#define ATARI_UC_PHI		0xe8		// Φ
#define ATARI_THETA			0xe9		// Θ
#define ATARI_UC_OMEGA		0xea		// Ω
#define ATARI_LC_DELTA		0xeb		// δ
#define ATARI_INTEGRAL		0xec		// ∮
#define ATARI_LC_PHI		0xed		// σ
#define ATARI_ELEMENT		0xee		// ∈
#define ATARI_INTERSECT		0xef        // ∩
#define ATARI_IDENT			0xf0		// ≡
#define ATARI_PLUSMINUS		0xf1		// ±
#define ATARI_GE			0xf2		// ≥
#define ATARI_LE			0xf3		// ≤
#define ATARI_INTEGRAL1		0xf4		// ⌠
#define ATARI_INTEGRAL2		0xf5		// ⌡
#define ATARI_DIV			0xf6		// ÷
#define ATARI_NEARLY_EQ		0xf7		// ≈
#define ATARI_DEGREE		0xf8		// °
#define ATARI_BULLET		0xf9		// •
#define ATARI_INTERPUNCT	0xfa		// ·
#define ATARI_ROOT			0xfb		// √
#define ATARI_N_SUPER		0xfc		// ⁿ
#define ATARI_2_SUPER		0xfd		// ²
#define ATARI_3_SUPER		0xfe		// ³
#define ATARI_MACRON		0xff		// ¯


const char *Atari2Unicode[0x80] = 
{
     /* #define ATARI_UC_CEDILLE	0x80 */ "Ç",
     /* #define ATARI_U_LC_UMLAUT	0x81 */ "ü",
     /* #define ATARI_LC_E_ACUT		0x82 */ "é",
     /* #define ATARI_LC_A_CIRC		0x83 */ "â",
     /* #define ATARI_A_LC_UMLAUT	0x84 */ "ä",
     /* #define ATARI_LC_A_GRAV		0x85 */ "à",
     /* #define ATARI_LC_A_BOLLE	0x86 */ "å",
     /* #define ATARI_LC_CEDILLE	0x87 */ "ç",
     /* #define ATARI_LC_E_CIRC		0x88 */ "ê",
     /* #define ATARI_LC_E_TREMA	0x89 */ "ë",
     /* #define ATARI_LC_E_GRAV		0x8a */ "è",
     /* #define ATARI_LC_I_TREMA	0x8b */ "ï",
     /* #define ATARI_LC_I_CIRC     0x8c */ "î",
     /* #define ATARI_LC_I_GRAV     0x8d */ "ì",
     /* #define ATARI_A_UC_UMLAUT	0x8e */ "Ä",
     /* #define ATARI_UC_A_BOLLE	0x8f */ "Å",
     /* #define ATARI_UC_E_ACUT		0x90 */ "É",
     /* #define ATARI_LC_AE			0x91 */ "æ",
     /* #define ATARI_UC_AE			0x92 */ "Æ",
     /* #define ATARI_LC_O_CIRC		0x93 */ "ô",
     /* #define ATARI_O_LC_UMLAUT	0x94 */ "ö",
     /* #define ATARI_LC_O_GRAV		0x95 */ "ò",
     /* #define ATARI_LC_U_CIRC		0x96 */ "û",
     /* #define ATARI_LC_U_GRAV		0x97 */ "ù",
     /* #define ATARI_LC_Y_TREMA	0x98 */ "ÿ",
     /* #define ATARI_O_UC_UMLAUT	0x99 */ "Ö",
     /* #define ATARI_U_UC_UMLAUT	0x9a */ "Ü",
     /* #define ATARI_CENT			0x9b */ "¢",
     /* #define ATARI_POUND			0x9c */ "£",
     /* #define ATARI_YEN			0x9d */ "¥",
     /* #define ATARI_LC_ESZETT   	0x9e */ "ß",
     /* #define ATARI_FLORIN		0x9f */ "ƒ",
     /* #define ATARI_LC_A_ACUT     0xa0 */ "á",
     /* #define ATARI_LC_I_ACUT		0xa1 */ "í",
     /* #define ATARI_LC_O_ACUT     0xa2 */ "ó",
     /* #define ATARI_LC_U_ACUT     0xa3 */ "ú",
     /* #define ATARI_LC_ENJE		0xa4 */ "ñ",
     /* #define ATARI_UC_ENJE		0xa5 */ "Ñ",
     /* #define ATARI_ORDINAL_A 	0xa6 */ "ª",
     /* #define ATARI_ORDINAL_O 	0xa7 */ "º",
     /* #define ATARI_INV_QUEST		0xa8 */ "¿",
     /* #define ATARI_NEGATION_A	0xa9 */ "⌐",
     /* #define ATARI_NEGATION 		0xaa */ "¬",
     /* #define ATARI_HALF			0xab */ "½",
     /* #define ATARI_QUARTER		0xac */ "¼",
     /* #define ATARI_INV_EXCL		0xad */ "¡",
     /* #define ATARI_GUILL_L		0xae */ "«",
     /* #define ATARI_GUILL_R		0xaf */ "»",
     /* #define ATARI_LC_A_TILDE	0xb0 */ "ã",
     /* #define ATARI_LC_O_TILDE	0xb1 */ "õ",
     /* #define ATARI_UC_O_SLASH	0xb2 */ "Ø",
     /* #define ATARI_LC_O_SLASH	0xb3 */ "ø",
     /* #define ATARI_LC_OE			0xb4 */ "œ",
     /* #define ATARI_UC_OE			0xb5 */ "Œ",
     /* #define ATARI_UC_A_GRAV		0xb6 */ "À",
     /* #define ATARI_UC_A_TILDE	0xb7 */ "Ã",
     /* #define ATARI_UC_O_TILDE	0xb8 */ "Õ",
     /* #define ATARI_TREMA			0xb9 */ "¨",
     /* #define ATARI_ACUT			0xba */ "´",
     /* #define ATARI_CROSS			0xbb */ "†",
     /* #define ATARI_ALINEA		0xbc */ "¶",
     /* #define ATARI_COPYRIGHT		0xbd */ "©",
     /* #define ATARI_REG_TM		0xbe */ "®",
     /* #define ATARI_UNREG_TM		0xbf */ "™",
     /* #define ATARI_LC_IJ			0xc0 */ "ĳ",
     /* #define ATARI_UC_IJ			0xc1 */ "Ĳ",
     /* #define ATARI_ALEPH			0xc2 */ "א",
     /* #define ATARI_BETH			0xc3 */ "ב",
     /* #define ATARI_GIMEL			0xc4 */ "ג",
     /* #define ATARI_DALETH		0xc5 */ "ד",
     /* #define ATARI_HE			0xc6 */ "ה",
     /* #define ATARI_WAW			0xc7 */ "ו",
     /* #define ATARI_ZAJIN			0xc8 */ "ז",
     /* #define ATARI_CHET			0xc9 */ "ח",
     /* #define ATARI_TETH			0xca */ "ט",
     /* #define ATARI_JOD			0xcb */ "י",
     /* #define ATARI_KAPH			0xcc */ "כ",
     /* #define ATARI_LAMED			0xcd */ "ל",
     /* #define ATARI_MEM			0xce */ "מ",
     /* #define ATARI_NUN			0xcf */ "נ",
     /* #define ATARI_SAMECH		0xd0 */ "ס",
     /* #define ATARI_AJIN			0xd1 */ "ע",
     /* #define ATARI_PE			0xd2 */ "פ",
     /* #define ATARI_TZADE			0xd3 */ "צ",
     /* #define ATARI_KOPH			0xd4 */ "ק",
     /* #define ATARI_RESCH			0xd5 */ "ר",
     /* #define ATARI_SCHIN			0xd6 */ "ש",
     /* #define ATARI_TAW			0xd7 */ "ת",
     /* #define ATARI_NUN2			0xd8 */ "ן",
     /* #define ATARI_KAPH2			0xd9 */ "ך",
     /* #define ATARI_MEM2			0xda */ "ם",
     /* #define ATARI_PE2			0xdb */ "ף",
     /* #define ATARI_SADE			0xdc */ "ץ",
     /* #define ATARI_PARAGRAPH		0xdd */ "§",
     /* #define ATARI_LOG_AND		0xde */ "∧",
     /* #define ATARI_INFINITE		0xdf */ "∞",
     /* #define ATARI_ALPHA 		0xe0 */ "α",
     /* #define ATARI_BETA          0xe1 */ "β",
     /* #define ATARI_GAMMA         0xe2 */ "Γ",
     /* #define ATARI_PI			0xe3 */ "π",
     /* #define ATARI_UC_SIGMA		0xe4 */ "Σ",
     /* #define ATARI_LC_SIGMA		0xe5 */ "σ",
     /* #define ATARI_LC_MY			0xe6 */ "µ",
     /* #define ATARI_TAU			0xe7 */ "τ",
     /* #define ATARI_UC_PHI		0xe8 */ "Φ",
     /* #define ATARI_THETA			0xe9 */ "Θ",
     /* #define ATARI_UC_OMEGA		0xea */ "Ω",
     /* #define ATARI_LC_DELTA		0xeb */ "δ",
     /* #define ATARI_INTEGRAL		0xec */ "∮",
     /* #define ATARI_LC_PHI		0xed */ "σ",
     /* #define ATARI_ELEMENT		0xee */ "∈",
     /* #define ATARI_INTERSECT		0xef */ "∩",
     /* #define ATARI_IDENT			0xf0 */ "≡",
     /* #define ATARI_PLUSMINUS		0xf1 */ "±",
     /* #define ATARI_GE			0xf2 */ "≥",
     /* #define ATARI_LE			0xf3 */ "≤",
     /* #define ATARI_INTEGRAL1		0xf4 */ "⌠",
     /* #define ATARI_INTEGRAL2		0xf5 */ "⌡",
     /* #define ATARI_DIV			0xf6 */ "÷",
     /* #define ATARI_NEARLY_EQ		0xf7 */ "≈",
     /* #define ATARI_DEGREE		0xf8 */ "°",
#if 0
     /* #define ATARI_BULLET		0xf9 */ "∙",		// U+2219
#else
     /* #define ATARI_BULLET		0xf9 */ "•",		// U+2022
#endif
     /* #define ATARI_INTERPUNCT	0xfa */ "·",
     /* #define ATARI_ROOT			0xfb */ "√",
     /* #define ATARI_N_SUPER		0xfc */ "ⁿ",
     /* #define ATARI_2_SUPER		0xfd */ "²",
     /* #define ATARI_3_SUPER		0xfe */ "³",
     /* #define ATARI_MACRON		0xff */ "¯"
};


static uint8_t processUtf8Char(const char *p, int maxlen, int *n)
{
	int unicode_len = 0;

	if ((maxlen >= 2) && ((p[0] & 0xe0) == 0xc0) && (p[1] & 0xc0) == 0x80)
	{
		unicode_len = 2;
	}
	else
	if ((maxlen >= 3) && ((p[0] & 0xf0) == 0xe0) && ((p[1] & 0xc0) == 0x80) && ((p[2] & 0xc0) == 0x80))
	{
		unicode_len = 3;
	}
	else
	if ((maxlen >= 4) && ((p[0] & 0xf8) == 0xf0) && ((p[1] & 0xc0) == 0x80) && ((p[2] & 0xc0) == 0x80) && ((p[3] & 0xc0) == 0x80))
	{
		unicode_len = 4;
	}
	else
	{
		return 0;
	}

	int i;
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

	char c2[3];
	c2[0] = p[0];
	c2[1] = p[1];
	c2[2] = '\0';
	fprintf(stderr, "Error: cannot translate unicode 0x%02x %02x (%s)\n", p[0] & 0xff, p[1] & 0xff, c2);
	fprintf(stderr, "        Context: %.10s\n", p);

	return 0;
}


static size_t getFileSize(FILE *f)
{
	fseek(f, 0L, SEEK_END);
	int sz = ftell(f);
	fseek(f, 0L, SEEK_SET);
	return sz;
}


static void convert(const char *filename)
{
	FILE *fi = fopen(filename, "rb");
	if (fi == NULL)
	{
		fprintf(stderr, "Cannot open \"%s\" for reading\n", filename);
		return;
	}

	int fsize = getFileSize(fi);
	uint8_t *buf = malloc(fsize);
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

	size_t pluslen = (reverse) ? strlen(converted_utf8_file_ext) : strlen(converted_atari_file_ext);
	char outname[strlen(filename) + pluslen];
	strcpy(outname, filename);
	strcat(outname, (reverse) ? converted_utf8_file_ext : converted_atari_file_ext);
	FILE *fo = fopen(outname, "wb");
	if (fo == NULL)
	{
		fclose(fi);
		fprintf(stderr, "Cannot open \"%s\" for writing\n", outname);
		return;
	}
	printf("convert \"%s\" to \"%s\"\n", filename, outname);

	if (reverse)
	{


		//
		// conversion loop Atari -> utf8
		//

		const uint8_t *p = buf;
		const uint8_t *endp = buf + fsize;
		while(p < endp)
		{
			uint8_t c = *p++;
			if (c < 0x80)
			{
				// nothing special, just copy character
				fwrite(&c, 1, 1, fo);
			}
			else
			{
				// write utf string instead
				const char *utf = Atari2Unicode[c - 0x80];

				if (verbose)
				{
					char buf[64];
					buf[0] = '\0';
					int n = strlen(utf);
					const char *p = utf;
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
	}
	else
	{

		//
		// conversion loop utf8 -> Atari
		//

		const uint8_t *p = buf;
		const uint8_t *endp = buf + fsize;
		while(p < endp)
		{
			int n = 0;
			uint8_t c = processUtf8Char((const char *) p, endp - p, &n);
			if (c > 0)
			{
				// replace with atari character and advance pointer
				fwrite(&c, 1, 1, fo);
				p += n;
			}
			else
			{
				// nothing found, just copy character
				fwrite(p, 1, 1, fo);
				p++;
			}
		}
	}

	fclose(fo);
	free(buf);
}
