         ttl       mc68343 fast floating point copyright notice (ffpcpyrt)
*ffpcpyrt idnt      1,1 ffp copyright notice
 
*************************************
* ffp library copyright notice stub *
*                                   *
*  this module is included by all   *
*  link edits with the ffplib.ro    *
*  library to protect motorola's    *
*  copyright status.                *
*                                   *
*  code: 68 bytes                    *
*                                   *
*  note: this module must reside    *
*  last in the library as it is     *
*  referenced by all other mc68343  *
*  modules.                         *
*************************************
 
         text
 
         xdef     ffpcpyrt
 
 
ffpcpyrt:
         dc.b     'mc68343 floating point firmware '
         dc.b     '(c) copyright 1981 by motorola inc.'
         dc.b     0

	dc.w 0x23f9
	dc.b 'ffpcpyrt'
