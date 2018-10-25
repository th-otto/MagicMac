/*******************************************************************
*
* VFAT
*
********************************************************************/

#include <portab.h>
#include <tos.h>
#include <tosdefs.h>
#include <magx.h>
#include "pd.h"
#include "mgx_xfs.h"
#include "mgx_dfs.h"
#include "vfat_imp.h"
#include "toserror.h"

#define   MAXFOLDERNAME  64

#define FINDDIR     0
#define FINDXDIR    1
#define FINDNDIR    2
#define FINDALL     3
#define FINDLABL    4


/*----------------------------------------------------------*/
/* Tabelle fuer die Umsetzung von ASCII zu Unicode           */
/*----------------------------------------------------------*/
static UWORD map_ascii_Unicode[256] = 
{
     0x0000,        /* 0:     0    (WICHTIG!!!)   */
     0x25b2,        /* 1:     "triagup"           */
     0x25bc,        /* 2:     "triagdn"           */
     0x25ba,        /* 3:     "triagrt"           */
     0x25c4,        /* 4:     "triaglf"           */
     0x2022,        /* 5:     "bullet"            */
     0x00d7,        /* 6:     "multiply"          */
     0x221e,        /* 7:     "infinity"          */
     0x00a4,        /* 8:     "currency"          */
     0x0074,        /* 9:     "t"                 */
     0x266b,        /* 10:    "musicalnotedbl"    */
     0x266a,        /* 11:    "musicalnote"       */
     0x2191,        /* 12:    "arrowup"           */
     0x2193,        /* 13:    "arrowdown"         */
     0x2192,        /* 14:    "arrowright"        */
     0x2190,        /* 15:    "arrowleft"         */
     0x0030,        /* 16:    "zero"              */
     0x0031,        /* 17:    "one"               */
     0x0032,        /* 18:    "two"               */
     0x0033,        /* 19:    "three"             */
     0x0034,        /* 20:    "four"              */
     0x0035,        /* 21:    "five"              */
     0x0036,        /* 22:    "six"               */
     0x0037,        /* 23:    "seven"             */
     0x0038,        /* 24:    "eight"             */
     0x0039,        /* 25:    "nine"              */
     0x0065,        /* 26:    "e"                 */
     0x0045,        /* 27:    "E"                 */
     0x003f,        /* 28:    "question"          */
     0x003f,        /* 29:    "question"          */
     0x003f,        /* 30:    "question"          */
     0x25cf,        /* 31:    "circle"            */

     0x0020,        /* 32:    "space"             */
     0x0021,        /* 33:    "exclam"            */
     0x0022,        /* 34:    "quotedbl"          */
     0x0023,        /* 35:    "numbersign"        */
     0x0024,        /* 36:    "dollar"            */
     0x0025,        /* 37:    "percent"           */
     0x0026,        /* 38:    "ampersand"         */
     0x0027,        /* 39:    "quotesingle"       */
     0x0028,        /* 40:    "parenleft"         */
     0x0029,        /* 41:    "parenright"        */
     0x002a,        /* 42:    "asterisk"          */
     0x002b,        /* 43:    "plus"              */
     0x002c,        /* 44:    "comma"             */
     0x002d,        /* 45:    "hyphen"            */
     0x002e,        /* 46:    "period"            */
     0x002f,        /* 47:    "slash"             */
     0x0030,        /* 48:    "zero"              */
     0x0031,        /* 49:    "one"               */
     0x0032,        /* 50:    "two"               */
     0x0033,        /* 51:    "three"             */
     0x0034,        /* 52:    "four"              */
     0x0035,        /* 53:    "five"              */
     0x0036,        /* 54:    "six"               */
     0x0037,        /* 55:    "seven"             */
     0x0038,        /* 56:    "eight"             */
     0x0039,        /* 57:    "nine"              */
     0x003a,        /* 58:    "colon"             */
     0x003b,        /* 59:    "semicolon"         */
     0x003c,        /* 60:    "less"              */
     0x003d,        /* 61:    "equal"             */
     0x003e,        /* 62:    "greater"           */
     0x003f,        /* 63:    "question"          */
     0x0040,        /* 64:    "at"                */
     0x0041,        /* 65:    "A"                 */
     0x0042,        /* 66:    "B"                 */
     0x0043,        /* 67:    "C"                 */
     0x0044,        /* 68:    "D"                 */
     0x0045,        /* 69:    "E"                 */
     0x0046,        /* 70:    "F"                 */
     0x0047,        /* 71:    "G"                 */
     0x0048,        /* 72:    "H"                 */
     0x0049,        /* 73:    "I"                 */
     0x004a,        /* 74:    "J"                 */
     0x004b,        /* 75:    "K"                 */
     0x004c,        /* 76:    "L"                 */
     0x004d,        /* 77:    "M"                 */
     0x004e,        /* 78:    "N"                 */
     0x004f,        /* 79:    "O"                 */
     0x0050,        /* 80:    "P"                 */
     0x0051,        /* 81:    "Q"                 */
     0x0052,        /* 82:    "R"                 */
     0x0053,        /* 83:    "S"                 */
     0x0054,        /* 84:    "T"                 */
     0x0055,        /* 85:    "U"                 */
     0x0056,        /* 86:    "V"                 */
     0x0057,        /* 87:    "W"                 */
     0x0058,        /* 88:    "X"                 */
     0x0059,        /* 89:    "Y"                 */
     0x005a,        /* 90:    "Z"                 */
     0x005b,        /* 91:    "bracketleft"       */
     0x005c,        /* 92:    "backslash"         */
     0x005d,        /* 93:    "bracketright"      */
     0x005e,        /* 94:    "asciicircum"       */
     0x005f,        /* 95:    "underscore"        */
     0x0060,        /* 96:    "grave"             */
     0x0061,        /* 97:    "a"                 */
     0x0062,        /* 98:    "b"                 */
     0x0063,        /* 99:    "c"                 */
     0x0064,        /* 100:   "d"                 */
     0x0065,        /* 101:   "e"                 */
     0x0066,        /* 102:   "f"                 */
     0x0067,        /* 103:   "g"                 */
     0x0068,        /* 104:   "h"                 */
     0x0069,        /* 105:   "i"                 */
     0x006a,        /* 106:   "j"                 */
     0x006b,        /* 107:   "k"                 */
     0x006c,        /* 108:   "l"                 */
     0x006d,        /* 109:   "m"                 */
     0x006e,        /* 110:   "n"                 */
     0x006f,        /* 111:   "o"                 */
     0x0070,        /* 112:   "p"                 */
     0x0071,        /* 113:   "q"                 */
     0x0072,        /* 114:   "r"                 */
     0x0073,        /* 115:   "s"                 */
     0x0074,        /* 116:   "t"                 */
     0x0075,        /* 117:   "u"                 */
     0x0076,        /* 118:   "v"                 */
     0x0077,        /* 119:   "w"                 */
     0x0078,        /* 120:   "x"                 */
     0x0079,        /* 121:   "y"                 */
     0x007a,        /* 122:   "z"                 */
     0x007b,        /* 123:   "braceleft"         */
     0x007c,        /* 124:   "bar"               */
     0x007d,        /* 125:   "braceright"        */
     0x007e,        /* 126:   "asciitilde"        */
     0x2206,        /* 127:   "Delta"             */

     0x00c7,        /* 128:   "Ccedilla"          */
     0x00fc,        /* 129:   "udieresis"         */
     0x00e9,        /* 130:   "eacute"            */
     0x00e2,        /* 131:   "acircumflex"       */
     0x00e4,        /* 132:   "adieresis"         */
     0x00e0,        /* 133:   "agrave"            */
     0x00e5,        /* 134:   "aring"             */
     0x00e7,        /* 135:   "ccedilla"          */
     0x00ea,        /* 136:   "ecircumflex"       */
     0x00eb,        /* 137:   "edieresis"         */
     0x00e8,        /* 138:   "egrave"            */
     0x00ef,        /* 139:   "idieresis"         */
     0x00ee,        /* 140:   "icircumflex"       */
     0x00ec,        /* 141:   "igrave"            */
     0x00c4,        /* 142:   "Adieresis"         */
     0x00c5,        /* 143:   "Aring"             */
     0x00c9,        /* 144:   "Eacute"            */
     0x00e6,        /* 145:   "ae"                */
     0x00c6,        /* 146:   "AE"                */
     0x00f4,        /* 147:   "ocircumflex"       */
     0x00f6,        /* 148:   "odieresis"         */
     0x00f2,        /* 149:   "ograve"            */
     0x00fb,        /* 150:   "ucircumflex"       */
     0x00f9,        /* 151:   "ugrave"            */
     0x00ff,        /* 152:   "ydieresis"         */
     0x00d6,        /* 153:   "Odieresis"         */
     0x00dc,        /* 154:   "Udieresis"         */
     0x00a2,        /* 155:   "cent"              */
     0x00a3,        /* 156:   "sterling"          */
     0x00a5,        /* 157:   "yen"               */
     0x00df,        /* 158:   "germandbls"        */
     0x0192,        /* 159:   "florin"            */
     0x00e1,        /* 160:   "aacute"            */
     0x00ed,        /* 161:   "iacute"            */
     0x00f3,        /* 162:   "oacute"            */
     0x00fa,        /* 163:   "uacute"            */
     0x00f1,        /* 164:   "ntilde"            */
     0x00d1,        /* 165:   "Ntilde"            */
     0x00aa,        /* 166:   "ordfeminine"       */
     0x00ba,        /* 167:   "ordmasculine"      */
     0x00bf,        /* 168:   "questiondown"      */
     0x2310,        /* 169:   "revlogicalnot"     */
     0x00ac,        /* 170:   "logicalnot"        */
     0x00bd,        /* 171:   "onehalf"           */
     0x00bc,        /* 172:   "onequarter"        */
     0x00a1,        /* 173:   "exclamdown"        */
     0x00ab,        /* 174:   "guillemotleft"     */
     0x00bb,        /* 175:   "guillemotright"    */
     0x00e3,        /* 176:   "atilde"            */
     0x00f5,        /* 177:   "otilde"            */
     0x00d8,        /* 178:   "Oslash"            */
     0x00f8,        /* 179:   "oslash"            */
     0x0153,        /* 180:   "oe"                */
     0x0152,        /* 181:   "OE"                */
     0x00c0,        /* 182:   "Agrave"            */
     0x00c3,        /* 183:   "Atilde"            */
     0x00d5,        /* 184:   "Otilde"            */
     0x00a8,        /* 185:   "dieresis"          */
     0x00b4,        /* 186:   "acute"             */
     0x2020,        /* 187:   "dagger"            */
     0x00b6,        /* 188:   "paragraph"         */
     0x00a9,        /* 189:   "copyright"         */
     0x00ae,        /* 190:   "registered"        */
     0x2122,        /* 191:   "trademark"         */
     0x00c2,        /* 192:   "Acircumflex"       */
     0x00c1,        /* 193:   "Aacute"            */
     0x00ca,        /* 194:   "Ecircumflex"       */
     0x00cb,        /* 195:   "Edieresis"         */
     0x00c8,        /* 196:   "Egrave"            */
     0x00ce,        /* 197:   "Icircumflex"       */
     0x00cf,        /* 198:   "Idieresis"         */
     0x00cc,        /* 199:   "Igrave"            */
     0x00cd,        /* 200:   "Iacute"            */
     0x00d4,        /* 201:   "Ocircumflex"       */
     0x00d2,        /* 202:   "Ograve"            */
     0x00d3,        /* 203:   "Oacute"            */
     0x00db,        /* 204:   "Ucircumflex"       */
     0x00d9,        /* 205:   "Ugrave"            */
     0x00da,        /* 206:   "Uacute"            */
     0x201e,        /* 207:   "quotedblbase"      */
     0x201c,        /* 208:   "quotedblleft"      */
     0x201d,        /* 209:   "quotedblright"     */
     0x201a,        /* 210:   "quotesinglbase"    */
     0x2018,        /* 211:   "quoteleft"         */
     0x2039,        /* 212:   "guilsinglleft"     */
     0x203a,        /* 213:   "guilsinglright"    */
     0x2013,        /* 214:   "endash"            */
     0x2014,        /* 215:   "emdash"            */
     0x2019,        /* 216:   "quoteright"        */
     0x2191,        /* 217:   "arrowup"           */
     0x2193,        /* 218:   "arrowdown"         */
     0x2192,        /* 219:   "arrowright"        */
     0x2190,        /* 220:   "arrowleft"         */
     0x00a7,        /* 221:   "section"           */
     0x2030,        /* 222:   "perthousand"       */
     0x221e,        /* 223:   "infinity"          */
     0x03b1,        /* 224:   "alpha"             */
     0x03b2,        /* 225:   "beta"              */
     0x0393,        /* 226:   "Gamma"             */
     0x03c0,        /* 227:   "pi"                */
     0x2211,        /* 228:   "summation"         */
     0x03c3,        /* 229:   "sigma"             */
     0x00b5,        /* 230:   "mu"                */
     0x03c4,        /* 231:   "tau"               */
     0x03a6,        /* 232:   "Phi"               */
     0x0398,        /* 233:   "Theta"             */
     0x2126,        /* 234:   "Omega"             */
     0x03b4,        /* 235:   "delta"             */
     0x222b,        /* 236:   "integral"          */
     0x03c6,        /* 237:   "phi"               */
     0x2208,        /* 238:   "element"           */
     0x220f,        /* 239:   "product"           */
     0x2261,        /* 240:   "equivalence"       */
     0x00b1,        /* 241:   "plusminus"         */
     0x2265,        /* 242:   "greaterequal"      */
     0x2264,        /* 243:   "lessequal"         */
     0x2320,        /* 244:   "integraltp"        */
     0x2321,        /* 245:   "integralbt"        */
     0x00f7,        /* 246:   "divide"            */
     0x2248,        /* 247:   "approxequal"       */
     0x00b0,        /* 248:   "degree"            */
     0x2022,        /* 249:   "bullet"            */
     0x00b7,        /* 250:   "periodcentered"    */
     0x221a,        /* 251:   "radical"           */
     0x207f,        /* 252:   "nsuperior"         */
     0x00b2,        /* 253:   "twosuperior"       */
     0x00b3,        /* 254:   "threesuperior"     */
     0x00af         /* 255:   "macron"            */
};

/*----------------------------------------------------------*/
/* Tabelle fuer die Umsetzung Unicode in ASCII               */
/* (ausser den Zeichen von 0x0020 bis 0x007e                 */
/*----------------------------------------------------------*/
static UWORD map_Unicode_ascii[] = 
{
     0x00a1,173,         /* 173:   "exclamdown"        */
     0x00a2,155,         /* 155:   "cent"              */
     0x00a3,156,         /* 156:   "sterling"          */
#if 0
     0x00a4,             /* 8:     "currency"          */
#endif
     0x00a5,157,         /* 157:   "yen"               */
     0x00a7,221,         /* 221:   "section"           */
     0x00a8,185,         /* 185:   "dieresis"          */
     0x00a9,189,         /* 189:   "copyright"         */
     0x00aa,166,         /* 166:   "ordfeminine"       */
     0x00ab,174,         /* 174:   "guillemotleft"     */
     0x00ac,170,         /* 170:   "logicalnot"        */
     0x00ae,190,         /* 190:   "registered"        */
     0x00af,255,         /* 255:   "macron"            */

     0x00b0,248,         /* 248:   "degree"            */
     0x00b1,241,         /* 241:   "plusminus"         */
     0x00b2,253,         /* 253:   "twosuperior"       */
     0x00b3,254,         /* 254:   "threesuperior"     */
     0x00b4,186,         /* 186:   "acute"             */
     0x00b5,230,         /* 230:   "mu"                */
     0x00b6,188,         /* 188:   "paragraph"         */
     0x00b7,250,         /* 250:   "periodcentered"    */
     0x00ba,167,         /* 167:   "ordmasculine"      */
     0x00bb,175,         /* 175:   "guillemotright"    */
     0x00bc,172,         /* 172:   "onequarter"        */
     0x00bd,171,         /* 171:   "onehalf"           */
     0x00bf,168,         /* 168:   "questiondown"      */

     0x00c0,182,         /* 182:   "Agrave"            */
     0x00c1,193,         /* 193:   "Aacute"            */
     0x00c2,192,         /* 192:   "Acircumflex"       */
     0x00c3,183,         /* 183:   "Atilde"            */
     0x00c4,142,         /* 142:   "Adieresis"         */
     0x00c5,143,         /* 143:   "Aring"             */
     0x00c6,146,         /* 146:   "AE"                */
     0x00c7,128,         /* 128:   "Ccedilla"          */
     0x00c8,196,         /* 196:   "Egrave"            */
     0x00c9,144,         /* 144:   "Eacute"            */
     0x00ca,194,         /* 194:   "Ecircumflex"       */
     0x00cb,195,         /* 195:   "Edieresis"         */
     0x00cc,199,         /* 199:   "Igrave"            */
     0x00cd,200,         /* 200:   "Iacute"            */
     0x00ce,197,         /* 197:   "Icircumflex"       */
     0x00cf,198,         /* 198:   "Idieresis"         */

     0x00d1,165,         /* 165:   "Ntilde"            */
     0x00d2,202,         /* 202:   "Ograve"            */
     0x00d3,203,         /* 203:   "Oacute"            */
     0x00d4,201,         /* 201:   "Ocircumflex"       */
     0x00d5,184,         /* 184:   "Otilde"            */
     0x00d6,153,         /* 153:   "Odieresis"         */
#if 0
     0x00d7,             /* 6:     "multiply"          */
#endif
     0x00d8,178,         /* 178:   "Oslash"            */
     0x00d9,205,         /* 205:   "Ugrave"            */
     0x00da,206,         /* 206:   "Uacute"            */
     0x00db,204,         /* 204:   "Ucircumflex"       */
     0x00dc,154,         /* 154:   "Udieresis"         */
     0x00df,158,         /* 158:   "germandbls"        */

     0x00e0,133,         /* 133:   "agrave"            */
     0x00e1,160,         /* 160:   "aacute"            */
     0x00e2,131,         /* 131:   "acircumflex"       */
     0x00e3,176,         /* 176:   "atilde"            */
     0x00e4,132,         /* 132:   "adieresis"         */
     0x00e5,134,         /* 134:   "aring"             */
     0x00e6,145,         /* 145:   "ae"                */
     0x00e7,135,         /* 135:   "ccedilla"          */
     0x00e8,138,         /* 138:   "egrave"            */
     0x00e9,130,         /* 130:   "eacute"            */
     0x00ea,136,         /* 136:   "ecircumflex"       */
     0x00eb,137,         /* 137:   "edieresis"         */
     0x00ec,141,         /* 141:   "igrave"            */
     0x00ed,161,         /* 161:   "iacute"            */
     0x00ee,140,         /* 140:   "icircumflex"       */
     0x00ef,139,         /* 139:   "idieresis"         */

     0x00f1,164,         /* 164:   "ntilde"            */
     0x00f2,149,         /* 149:   "ograve"            */
     0x00f3,162,         /* 162:   "oacute"            */
     0x00f4,147,         /* 147:   "ocircumflex"       */
     0x00f5,177,         /* 177:   "otilde"            */
     0x00f6,148,         /* 148:   "odieresis"         */
     0x00f7,246,         /* 246:   "divide"            */
     0x00f8,179,         /* 179:   "oslash"            */
     0x00f9,151,         /* 151:   "ugrave"            */
     0x00fa,163,         /* 163:   "uacute"            */
     0x00fb,150,         /* 150:   "ucircumflex"       */
     0x00fc,129,         /* 129:   "udieresis"         */
     0x00ff,152,         /* 152:   "ydieresis"         */

     0x0152,181,         /* 181:   "OE"                */
     0x0153,180,         /* 180:   "oe"                */
     0x0192,159,         /* 159:   "florin"            */

     0x0393,226,         /* 226:   "Gamma"             */
     0x0398,233,         /* 233:   "Theta"             */
     0x03a6,232,         /* 232:   "Phi"               */
     0x03b1,224,         /* 224:   "alpha"             */
     0x03b2,225,         /* 225:   "beta"              */
     0x03b4,235,         /* 235:   "delta"             */
     0x03c0,227,         /* 227:   "pi"                */
     0x03c3,229,         /* 229:   "sigma"             */
     0x03c4,231,         /* 231:   "tau"               */
     0x03c6,237,         /* 237:   "phi"               */

     0x2013,214,         /* 214:   "endash"            */
     0x2014,215,         /* 215:   "emdash"            */
     0x2018,211,         /* 211:   "quoteleft"         */
     0x2019,216,         /* 216:   "quoteright"        */
     0x201a,210,         /* 210:   "quotesinglbase"    */
     0x201c,208,         /* 208:   "quotedblleft"      */
     0x201d,209,         /* 209:   "quotedblright"     */
     0x201e,207,         /* 207:   "quotedblbase"      */
     0x2020,187,         /* 187:   "dagger"            */
     0x2022,249,         /* 249:   "bullet"            */
     0x2030,222,         /* 222:   "perthousand"       */
     0x2039,212,         /* 212:   "guilsinglleft"     */
     0x203a,213,         /* 213:   "guilsinglright"    */
     0x207f,252,         /* 252:   "nsuperior"         */

     0x2122,191,         /* 191:   "trademark"         */
     0x2126,234,         /* 234:   "Omega"             */
#if 0
     0x2190,             /* 15:    "arrowleft"         */
#endif
     0x2190,220,         /* 220:   "arrowleft"         */
#if 0
     0x2191,             /* 12:    "arrowup"           */
#endif
     0x2191,217,         /* 217:   "arrowup"           */
#if 0
     0x2192,             /* 14:    "arrowright"        */
#endif
     0x2192,219,         /* 219:   "arrowright"        */
#if 0
     0x2193,             /* 13:    "arrowdown"         */
#endif
     0x2193,218,         /* 218:   "arrowdown"         */

     0x2206,127,         /* 127:   "Delta"             */
     0x2208,238,         /* 238:   "element"           */
     0x220f,239,         /* 239:   "product"           */
     0x2211,228,         /* 228:   "summation"         */
     0x221a,251,         /* 251:   "radical"           */
#if 0
     0x221e,             /* 7:     "infinity"          */
#endif
     0x221e,223,         /* 223:   "infinity"          */
     0x222b,236,         /* 236:   "integral"          */
     0x2248,247,         /* 247:   "approxequal"       */
     0x2261,240,         /* 240:   "equivalence"       */
     0x2264,243,         /* 243:   "lessequal"         */
     0x2265,242,         /* 242:   "greaterequal"      */

     0x2310,169,         /* 169:   "revlogicalnot"     */
     0x2320,244,         /* 244:   "integraltp"        */
     0x2321,245,         /* 245:   "integralbt"        */

#if 0
     0x25b2,             /* 1:     "triagup"           */
     0x25ba,             /* 3:     "triagrt"           */
     0x25bc,             /* 2:     "triagdn"           */
     0x25c4,             /* 4:     "triaglf"           */
     0x25cf              /* 31:    "circle"            */

     0x266a,             /* 11:    "musicalnote"       */
     0x266b,             /* 10:    "musicalnotedbl"    */
#endif
};


/*******************************************************************
*
*  Wandelt Unicode (Intel) in ASCII
*
********************************************************************/

static void unic2ibm(char **ptr, unsigned char *unicode, WORD len)
{
     register char *s = *ptr;
     UWORD wchar;
     char c;
     UWORD *low,*high,*test;
     int nitems,nnitems;


     while(len)
          {
          wchar = (*unicode++) + ((*unicode++) << 8);
          if   ((wchar >= 0x20) && (wchar < 0x7f))
               {
               c = (char) wchar;
               }
          else {
               if   (!wchar || (wchar == 0xffff))
                    goto ende;

               /* binaere Suche nach <wchar> in der Tabelle  */
               /* map_Unicode_ascii[]                       */
               /* ----------------------------------------- */

               low = map_Unicode_ascii;
               nnitems = (int) sizeof(map_Unicode_ascii)/(int) sizeof(UWORD);
               high = map_Unicode_ascii+nnitems-2;
               do   {
                    nitems = nnitems;
                    test = low + ((nitems>>1)&0xfffe);
                    if   (wchar < *test)
                         {
                         high = test;
                         }
                    else
                    if   (wchar > *test)
                         {
                         low = test;
                         }
                    else {
                         c = (char) test[1];
                         goto found;
                         }
                    nnitems = (int) (high - low) + 2;
                    }
               while((low != high) && (nnitems < nitems));

               c = 0xbc;
               found:
               ;
               }

          *s++ = c;
          len--;
          }
     ende:
     *s = EOS;
     *ptr = s;
}


/*******************************************************************
*
*  Wandelt ASCII um in Unicode (Intel)
*
********************************************************************/

static void ibm2unic(char **ptr, unsigned char *unicode, WORD len)
{
     register char *s = *ptr;
     union {
          UWORD ww;
          char wc[2];
          } w;
     unsigned char c;


     do   {
          c = *s++;
          w.ww = map_ascii_Unicode[c];
          len--;
          *unicode++ = w.wc[1];
          *unicode++ = w.wc[0];
          }
     while((len > 0) && (c));
     *ptr = s;
}


/*******************************************************************
*
* Allgemeine Routine zum Durchsuchen eines Verzeichnisses.
*
* Eingabe:     fd        Verzeichnis
*              lbuf      fuer langen Namen oder NULL
*              lbuflen   Max. Laenge des langen Namens
*              shortbuf  fuer kurzen Namen oder NULL
*              fmode     Gibt an, welche Dateien gefunden werden:
*
*                   FINDDIR   nur Verzeichnisse
*                   FINDXDIR  Verzeichnisse und Symlinks
*                   FINDNDIR  keine Verzeichnisse
*                   FINDALL   alles ausser Labels
*                   FINDLABL  nur Labels.
*
* Ausgabe:     lbuf[]    langer Name bzw. kurzer, wenn es keinen
*                        langen gibt und <shortbuf> == NULL
*              startpos  Pos. des ersten DIR-Eintrags
*              <ret>     = 0  Verzeichnisende
*                        < 0  Fehlercode
*                        > 0  (DIR *)
*
********************************************************************/

static LONG _vf_readdir(MX_DOSFD *fd,
               char *lbuf, WORD lbuflen,
               char *shortbuf,
               LONG *startpos,
               WORD fmode)
{
     LONG doserr;
     DIR *dir;
     char longname[300];      /* langer Name */
     char ltmpname[14];       /* Zwischenspeicher */
     char *nxt_longname;      /* Zeiger auf freien Platz */
     char *nxt_ltmpname;
     int longcount;           /* Eintragnummer 1..15 */
     char act_chksum;         /* Checksumme fuer langen Namen */
     int reldirnr;
     char c;
     int len;


     longcount = -1;
     *startpos = -1L;

     for  (;;)
          {

          /* Einen Eintrag lesen */
          /* ------------------- */

          doserr = p_fread(fd, sizeof(DIR), NULL);
          if   (doserr <= E_OK)         /* Fehler oder Verz.ende */
               return(doserr);
          dir = (DIR *) doserr;

          c = dir->name[0];
          if   (!c)                     /* Verzeichnisende */
               return(E_OK);
          if   (c == '\xe5')            /* geloeschte Datei */
               continue;                /* ueberlesen */

          if   (dir->attr == 0x0f)      /* lange Namen! */
               {
               reldirnr = (c & 0x1f);

               if   (c & 0x40)     /* letzter Eintrag, d.h. phys. erster */
                    {
                    nxt_longname = longname+299;
                    *nxt_longname = EOS;
                    longcount = reldirnr;
                    *startpos = fd->fd_fpos - sizeof(DIR);
                    act_chksum = ((LDIR *) dir)->chksum;
                    }
               else {
                    if   (longcount <= 0)
                         goto fehler;             /* Fehler */
     
                    if   ((reldirnr != longcount) ||
                          (act_chksum != ((LDIR *) dir)->chksum))
                         {
                         fehler:
                         longcount = -1;
                         *startpos = -1L;
                         continue;           /* Fehler */
                         }
                    }

               /* Stueckweise UNICODE-Brocken => String */
               /* ------------------------------------ */

               nxt_ltmpname = ltmpname;
               unic2ibm(&nxt_ltmpname, ((LDIR *) dir)->name1, 5);
               unic2ibm(&nxt_ltmpname, ((LDIR *) dir)->name2, 6);
               unic2ibm(&nxt_ltmpname, ((LDIR *) dir)->name3, 2);
               len = (int) strlen(ltmpname);

               /* Ueberlauf testen */
               /* --------------- */

               if   (nxt_longname - len < longname)
                    return(EINTRN);     /* ??? */

               /* Rueckwaerts reinkopieren */
               /* ---------------------- */

               vmemcpy(nxt_longname - len, ltmpname, len);
               nxt_longname -= len;
               longcount--;
               }
          else
               {
               if   (longcount >= 0)    /* vorher war ein langer Name */
                    {
                    if   (vf_chksum(dir->name) != act_chksum)
                         {
                         longcount = -1;     /* Checksumme stimmt nicht */
                         *startpos = -1L;
                         }
                    }
               c = (dir->attr & FA_VOLUME);
               switch(fmode)
                    {

                    case FINDLABL:
                    if   ((c) && (!(dir->attr & FA_SUBDIR)))
                         goto fertig;
                    break;

                    case FINDDIR:
                    if   (dir->attr & FA_SUBDIR)
                         goto fertig;
                    break;

                    case FINDXDIR:
                    if   (dir->attr & (FA_SUBDIR+FA_SYMLINK))
                         goto fertig;
                    break;

                    case FINDNDIR:
                    if   (c)
                         break;
                    if   (dir->attr & FA_SUBDIR)
                         break;
                    goto fertig;

                    case FINDALL:
                    if   (c)
                         break;
                    goto fertig;

                    }
               }
          }


     fertig:

     if   (lbuf)         /* will lange Namen */
          {
          if   (longcount >= 0)    /* habe auch langen Namen */
               {
               len = (int) (strlen(nxt_longname)) + 1;
               if   (len > lbuflen)
                    return(ERANGE);
               vstrcpy(lbuf, nxt_longname);
               }
          else {         /* habe keinen langen Namen */
               if   (!shortbuf)    /* will keinen kurzen */
                    {
                    if   (13 > lbuflen)      /* Radikalabfrage */
                         return(ERANGE);
                    ext_8_3(lbuf, dir->name);
                    }
               else *lbuf = EOS;   /* will kurzen extra haben */
               }
          }

     if   (shortbuf)
          ext_8_3(shortbuf, dir->name);

     return((LONG) dir);
}


/*******************************************************************
*
* Durchsucht ein Verzeichnis nach einem Dateinamen.
* <fd> ist bereits geoeffnet.
*
* Verwendet fuer
*
*    Fopen
*    Fdelete
*    Fxattr
*    Fattrib
*
* -> d0 = DIR *
* -> long spos           zeigt auf Haupt-DIR-Eintrag
*    long lpos           Anfang des langen Namens, ggf. -1
*
********************************************************************/

LONG vf_dirsrch( MX_DOSFD *fd, char *fname, WORD fmode,
               LONG *spos, LONG *lpos )
{
     LONG ret;
     char longname[300];
     char shortname[14];
     register char *s;


     if   (!*fname)
          return(EFILNF);

     for  (;;)
          {
          ret = _vf_readdir( fd, longname, 300,
                              shortname, lpos,
                              fmode);

          if   (ret <= 0L)
               break;

          if   ((!stricmp(longname, fname)) ||
                (!stricmp(shortname, fname)) ||
                (fmode == FINDLABL))
               {
               found:
               *spos = fd->fd_fpos-sizeof(DIR);
               break;
               }

          /* Hier brauchen wir den Sonderfall, der in u:\proc    */
          /* eine Datei des Typs <pgmname.nnn> loescht.           */
          /* --------------------------------------------------- */

          if   ((*fname == '*') && (fname[1] == '.'))
               {
               s = shortname;
               while(*s)
                    {
                    if   (*s == '.')
                         {
                         if   (!stricmp(s+1, fname+2))
                              goto found;
                         }
                    s++;
                    }
               }
          }

     if   (!ret)
          ret = EFILNF;

     return(ret);
}


/*******************************************************************
*
* Durchsucht ein Verzeichnis nach einem Disknamen.
* <fd> ist bereits geoeffnet.
*
* Verwendet fuer
*
*    Dreadlabel
*
* -> d0 = DIR *
* -> long spos           zeigt auf Haupt-DIR-Eintrag
*    long lpos           Anfang des langen Namens, ggf. -1
*
********************************************************************/

LONG vf_rlabel( MX_DOSFD *fd, char *buf, WORD buflen )
{
     LONG lpos;
     LONG ret;


     ret = _vf_readdir( fd, buf, buflen,
                              NULL, &lpos,
                              FINDLABL);
     if   (!ret)
          ret = EFILNF;
     else
     if   (ret > 0)
          ret = E_OK;

     return(ret);
}


/*******************************************************************
*
* long dxfs_dreaddir( a0 = FD *d, d0 = int len, a1 = char *buf,
*                     d1 = XATTR *xattr, d2 = long *xr )
*
* FUer Dreaddir (xattr = NULL) und Dxreaddir
*
********************************************************************/

LONG vf_readdir(MX_DOSFD *fd, WORD buflen, char *buf,
               LONG p_xattr, LONG p_xr)
{
     LONG doserr;
     LONG dummy;
     DIR *dir;
     int unixmode;
     char *longbuf,*shortbuf;


     unixmode = (fd->fd_dirch & 2) ? 0 : 4;
     buflen -= unixmode;
     buf += unixmode;

     longbuf = shortbuf = NULL;
     if   (unixmode)
          longbuf = buf;
     else shortbuf = buf;

     doserr = _vf_readdir( fd, longbuf, buflen, shortbuf, &dummy,
                         FINDALL);
     if   (doserr < E_OK)
          return(doserr);     /* Fehler */
     if   (!doserr)
          return(ENMFIL);     /* Ende */

     dir = (DIR *) doserr;

     if   (unixmode)          /* Inode-Nummer */
          vf_d2i( fd, dir, buf-4);

     if   (p_xattr)
          *(LONG *)p_xr = _xattr(fd, dir, p_xattr, 1);

     return(E_OK);
}


/*******************************************************************
*
* Oeffnet ein Unterverzeichnis.
*
* <len> ist die Laenge des untersuchten Pfadelements
*
* Geht einen Verzeichnislevel weiter.
* verwendet in <path2DD>.
*
* Gibt einen Fehlercode, ELINK, oder einen DD_FD zurueck.
*
********************************************************************/

LONG vf_path2DD( MX_DOSFD *fd, char *path, WORD len, void **link )
{
     MX_DOSFD  *f;
     register char *s;
     char shortname[14];
     char pathelem[66];       /* 64 Zeichen + EOS */
     char longname[MAXFOLDERNAME+1];
     LONG ret;
     LONG lpos;
     DIR *dir;


     /* Pfadelement umkopieren und durch EOS abschliessen */
     /* ------------------------------------------------ */

     if   (len > 64)
          return(EPTHNF);
     for  (s = pathelem; len; len--)
          *s++ = *path++;
     *s = '\0';

     /* Erst die Liste der geoeffneten Verzeichnisse durchsuchen */
     /* ------------------------------------------------------- */

     f = fd->fd_children;
     while(f)
          {
          if   ((f->fd_longname) &&
                (!stricmp(pathelem, f->fd_longname)))
               goto found;

          ext_8_3(shortname, f->fd_name);

          if   (!stricmp(pathelem, shortname))
               {
               found:
               ret = (((f->fd_owner) && (f->fd_mode & OM_RDENY)) ?
                         EACCDN : (LONG) f);
               goto err;
               }
          f = f->fd_next;
          }

     /* Jetzt brauchen wir doch Plattenzugriffe */
     /* --------------------------------------- */

     ret = reopen_FD(fd, OM_RPERM);
     if   (ret < E_OK)
          goto err;

     fd = (MX_DOSFD *) ret;        /* Verzeichnis geoeffnet! */

     for  (;;)
          {
          ret = _vf_readdir( fd,
                         longname, MAXFOLDERNAME+1,
                         shortname, &lpos, FINDXDIR);

          if   (ret <= 0L)
               break;

          dir = (DIR *) ret;

          if   ((!stricmp(longname, pathelem)) ||
                (!stricmp(shortname, pathelem)))
               {
               ret = get_DD( fd, dir, fd->fd_fpos-sizeof(DIR),
                         (*longname) ? longname : ((char *) 0), link);
               break;
               }
          }


     if   (!ret)
          ret = EPTHNF;

     if   ((ret != E_CHNG) && (ret != EDRIVE))
          close_DD(fd);

err:
     return(ret);
}


/*******************************************************************
*
* (Langen) Dateinamen an aktueller Position des Dateizeigers
* schreiben.
*
********************************************************************/

LONG vf_crnam( MX_DOSFD *fd, DIR *newdir, char *longname )
{
     LDIR ldir;
     int len, ndirs;
     char *nxts,*nxt_ltmpname;
     register unsigned char *s;
     LONG doserr;
     register int i;


     if   ((fd->fd_fpos) & 0x1fL)
          return(EINTRN);               /* Abfrage fuer Ben */

     /* Langen Namen schreiben */
     /* ---------------------- */

     if   (longname)
          {
          ldir.attr = 0xf;
          ldir.unused = 0;
          ldir.chksum = vf_chksum( newdir->name );
          ldir.stcl = 0;
          for  (s = ldir.name1,i=0; i < 10; i++)
               *s++ = 0xff;
          for  (s = ldir.name2,i=0; i < 12; i++)
               *s++ = 0xff;
          for  (s = ldir.name3,i=0; i < 4; i++)
               *s++ = 0xff;

          len = (int) strlen(longname);

/*   wird schon bei vf_ffree() getestet:

          if   (len > MAXFOLDERNAME)
               return(ERANGE);
*/
          ndirs = (len+12)/13;     /* soviele LDIRs */
          nxts = longname+((ndirs-1)*13);
          ldir.head = 0x40+ndirs;
          len++;                   /* EOS mit abspeichern! */
          for  (; ndirs > 0; ndirs--)
               {
               nxt_ltmpname = nxts;
               i = (int) ((longname+len)-nxts);        /* verbleibende Zeichen */
               ibm2unic(&nxt_ltmpname, ldir.name1, 5);
               i -= 5;
               if   (i > 0)
                    {
                    ibm2unic(&nxt_ltmpname, ldir.name2, 6);
                    i -= 6;
                    if   (i > 0)
                         ibm2unic(&nxt_ltmpname, ldir.name3, 2);
                    }
               doserr = p_fwrite(fd, sizeof(DIR), &ldir);
               if   (doserr < E_OK)
                    return(doserr);
               ldir.head = ndirs-1;
               nxts -= 13;
               }
          }

     /* Haupteintrag schreiben */
     /* ---------------------- */

     return(p_fwrite(fd, sizeof(DIR), newdir));
}


/*******************************************************************
*
* Leeren Eintrag im Verzeichnis suchen. Es muss genuegend Platz
* fuer den Namen <name> vorhanden sein.
* Ggf. wird das Verzeichnis auch erweitert.
*
* Falls <specialpos> >= 0 ist, ist der an dieser Stelle befindliche
* Haupteintrag als geloescht zu betrachten (fuer Frename im selben
* Verzeichnis). Bzw. falls <specialfirstpos> >= 0 ist, sind alle
* Eintraege zwischen diesem und dem Haupteintrag als geloescht zu
* betrachten, d.h. nur dann, wenn die Anzahl der DIR-Eintraege mit
* den neu benoetigten identisch ist.
* Die letzte Klausel kann jetzt entfallen, nachdem die
* xfs_rename() ueberlappende Bereiche beruecksichtigt.
* In jedem Fall ist der alte Haupteintrag bei der Berechnung des
* Alias zu ignorieren.
*
* Wenn lange Namen im DMD zugelassen sind, wird eine komplizierte
* Strategie verfolgt:
*
* Dabei wird der Name <newdir->name> ggf. modifiziert, damit ein
* eindeutiger Kurzname (MS-Jargon: "Alias") gefunden wird. Dazu muss
* das Verzeichnis in jedem Fall bis zum Ende durchsucht werden.
*
* Gibt eine freie Position oder einen Fehlercode zurueck.
*
********************************************************************/

LONG vf_ffree( LONG specialpos, LONG specialfirstpos,
               MX_DOSFD *fd, char *name, DIR *newdir,
               char **longname, LONG *firstdirpos )
{
     LONG doserr;
     LONG gap_pos;            /* Anf.pos einer Luecke */
     LONG actpos;
     int  gap_len;            /* Laenge einer Luecke in #(DIR) */
     DIR *dir;
     char shortname[14];      /* Zwischenspeicher */
     char c;
     int len;
     int ndirs;
     register char *s,*t,*u;
     int found = FALSE;
     int number;
     char used[200];          /* Flags */


     /* Dateizeiger an den Verzeichnisanfang! */
     /* ------------------------------------- */

     doserr = p_fseek( fd, 0L );
     if   (doserr < E_OK)
          return(doserr);          /* Fehler */

     /* Erst muessen wir den Platzbedarf des neuen */
     /* Dateinamens ermitteln.                    */
     /* ----------------------------------------- */

     if   (!fd->fd_dmd->d_flags)
          {
          *longname = NULL;             /* ja! */
          ndirs = 1;
          }
     else {
          ext_8_3(shortname, newdir->name);  /* wieder expandieren */
          if   (!strcmp(shortname, name))    /* darstellbar ? */
               {
               *longname = NULL;             /* ja! */
               ndirs = 1;
               }
          else {
               *longname = name;             /* nein! */
               len = (int) strlen(*longname);
               if   (len > MAXFOLDERNAME)
                    return(ERANGE);          /* Dateiname zu lang */
               ndirs = (len+12)/13 + 1;      /* soviele DIRs */
               fast_clrmem(used, used+200);
               if   (stricmp(shortname, name))    /* 8+3 ? */
                    used[0] |= 1;       /* nein, Ur-Name belegt */
               }
          }

     /* Berechne bei Frename die alte Anzahl von benoetigten Eintraegen */
     /* ------------------------------------------------------------- */

     if   (specialpos >= 0)
          {
          if   (specialfirstpos < 0)
               specialfirstpos = specialpos;
          if   (ndirs != (((specialpos - specialfirstpos) >> 5L) + 1))
               specialfirstpos = 0x7fffffffL;     /* leeres Intervall erzeugen */
          }

     gap_pos = -1L;

     for  (;;)
          {

          /* Einen Eintrag lesen */
          /* ------------------- */

          actpos = fd->fd_fpos;
          doserr = p_fread(fd, sizeof(DIR), NULL);
          if   (doserr < E_OK)
               return(doserr);          /* Fehler */

          /* 1. Fall: Dateiende. Datei erweitern */
          /* ----------------------------------- */

          if   (!doserr)                /* Dateiende! */
               {
               if   (found)
                    break;
               if   (gap_pos < 0)
                    gap_pos = actpos;
               doserr = p_extfd(fd);    /* Verz. erweitern */
               if   (doserr < E_OK)
                    return(doserr);     /* Fehler beim Erweitern */
               break;                   /* OK! */
               }

          dir = (DIR *) doserr;
          c = dir->name[0];

          /* 2. Fall: Verzeichnis-Endmarke.       */
          /*          Schaffe genuegend Platz.     */
          /* ------------------------------------ */

          if   (!c)                     /* Verzeichnisende */
               {
               if   (found)
                    break;
               if   (gap_pos < 0)
                    {
                    gap_pos = actpos;
                    gap_len = 1;
                    }
               else gap_len++;

               for  (len = gap_len; len < ndirs; len++)
                    {
                    doserr = p_fseek(fd, (gap_pos + (len << 5)) + 1L); /* (* sizeof(DIR)) */
                    if   (doserr == ERANGE)
                         doserr = p_extfd(fd);
                    if   (doserr < E_OK)
                         return(doserr);          /* Fehler */
                    }
               break;
               }

          /* 3. Fall: Luecke, d.h. geloeschte Datei oder "special position" */
          /* ------------------------------------------------------------ */

          if   ((c == '\xe5') ||             /* geloeschte Datei */
                ((actpos <= specialpos) && (actpos >= specialfirstpos)))
               {

               if   (!*longname)
                    {
                    *firstdirpos = actpos;
                    return(actpos);
                    }

               if   (!found)
                    {
                    if   (gap_pos < 0)
                         {
                         gap_pos = actpos;
                         gap_len = 1;
                         }
                    else gap_len++;
                    if   (gap_len >= ndirs)
                         found = TRUE;  /* Genug Platz */
                    }
               }

          /* 4. Fall: DIR-Eintrag */
          /* -------------------- */

          else
          if   (*longname)
               {
               if   (!found)
                    gap_pos = -1L;      /* normaler Dateieintrag */

               /* Kurzname: Auf Kollision mit "Alias" testen */
               /* ------------------------------------------ */

               if   ((dir->attr != 0x0f) && (actpos != specialpos))
                    {
                    /* Extension (3 Zeichen) */
                    s = newdir->name+8;
                    t = dir->name+8;
                    if   (*s++ != *t++)
                         continue;
                    if   (*s++ != *t++)
                         continue;
                    if   (*s != *t)
                         continue;
                    /* Namensanfang (1 Zeichen) */
                    s = newdir->name;
                    t = dir->name;
                    if   (*s++ != *t++)
                         continue;
                    /* Teste bis zum '~' */
                    while(t < dir->name+8)
                         {
                         if   (*t == '~')
                              {
                              for  (u = t+1, /* hier beginnt die Zahl ? */
                                    len = (int) ((dir->name)+8-u),
                                    number = 0;
                                    (u < dir->name+8) && (*u != ' ');
                                    len--)
                                   {
                                   c = *u++ - '0';
                                   if   ((c < 0) ||
                                         (c > 9))
                                        goto weiter2;
                                   number *= 10;
                                   number += c;
                                   }
                              /* Zahl ist ok */
                              if   (number >= 1600)
                                   goto weiter2;  /* Ueberlauf */
                              used[number>>3] |= (1 << (number & 7));
                              goto weiter;   /* belegt */
                              }

                         weiter2:
                         if   (*s++ != *t++)
                              goto weiter;
                         }
                    /* Es ist eine Kollision aufgetreten */
                    /* Belegte "Nummer" merken */
                    used[0] |= 1;  /* Ur-Name belegt */
                    weiter:
                    ;
                    }
               }

          }

     /* Suche einen freien Alias im Muster ABCD~nnn.DEF */
     /* ----------------------------------------------- */

     if   (*longname)
          {
          for  (len = 0; len < 200; len++)
               for  (number = 0,found=1; number < 8; number++,found<<=1)
                    {
                    if   (!(found & used[len]))
                         goto alias_ok;
                    }
     
          /* Schon 1600 Aliase verbraten ! */
     
          return(EINTRN);
     
          alias_ok:
          number += (len<<3);
          if   (number)            /* Ur-Name ist belegt */
               {

               len = 2;
               if   (number > 9)
                    {
                    len++;
                    if   (number > 99)
                         {
                         len++;
                         if   (number > 999)
                              len++;
                         }
                    }

               s = newdir->name+7-len;
               while(*s == ' ')
                    s--;
               s += len;

               while(number)
                    {
                    *s-- = (number % 10) + '0';
                    number /= 10;
                    }
               *s = '~';
               }
          }

     *firstdirpos = gap_pos;
     if   (gap_pos < 0)
          return(gap_pos);
     else return(gap_pos + ((ndirs-1)<<5));  /* ( * sizeof(DIR)) */ 
}
