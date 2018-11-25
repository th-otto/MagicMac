#ifndef __MAC_PIXMAP_H__
#define __MAC_PIXMAP_H__

#ifndef __Fixed_defined
#define __Fixed_defined
typedef int32_t Fixed;			/* 16.16 */
#endif
typedef void **CTabHandle;		/* Zeiger auf ColorTable */

#ifndef __Rect_defined
#define __Rect_defined 1
typedef struct
{
	unsigned short	top;			/* topmost line */
	unsigned short	left;			/* leftmost columm */
	unsigned short	bottom;			/* bottommost line */
	unsigned short	right;			/* rightmost column */
} Rect;		
#endif

/* Mac Carbon PixMap */
typedef struct
{
	uint8_t		*baseAddr;		/* pointer to pixels */
	uint16_t	rowBytes;		/* offset to next line */
	Rect		bounds;			/* encloses bitmap */
	uint16_t	pmVersion;		/* pixMap version number */
	uint16_t	packType;		/* defines packing format */
	uint32_t	packSize;		/* length of pixel data */
	Fixed		hRes;			/* horiz. resolution (ppi) */
	Fixed		vRes;			/* vert. resolution (ppi) */
	uint16_t	pixelType;		/* defines pixel type */
	uint16_t	pixelSize;		/* # bits in pixel */
	uint16_t	cmpCount;		/* # components in pixel */
	uint16_t	cmpSize;		/* # bits per component */
	uint32_t	planeBytes;		/* offset to next plane */
	CTabHandle	pmTable;		/* color map for this pixMap (definiert CtabHandle) */
	uint32_t	pmReserved;		/* for future use. MUST BE 0 */
} MXVDI_PIXMAP;

/*

Pixel Maps

Just as the original QuickDraw does all of its drawing in a bit map, Color QuickDraw
uses an extended data structure called a pixel map (pixMap). In addition to the
dimensions and contents of a pixel image, the pixel map also includes information on
the image's storage format, depth, resolution, and color usage

...

Field descriptions

baseAddr      The baseAddr field contains a pointer to first byte of the
              pixel image, the same as in a bitMap. For optimal performance
              this should be a multiple of four.

rowBytes      The rowBytes field contains the offset in bytes from one row of
              the image to the next, the same as in a bitMap. As before,
              rowBytes must be even. The high three bits of rowBytes are used
              as flags. If bit 15 = 1, the data structure is a pixMap;
              otherwise it is a bitMap. Bits 14 and 13 are not used and must
              be 0.

bounds        The bounds field is the boundary rectangle, which defines the
              coordinate system and extent of the pixel map; it's similar to
              a bitMap. This rectangle is in pixels, so depth has no effect
              on its values.

pmVersion     The pmVersion is the version number of Color QuickDraw that
              created this pixel map, which is provided for future
              compatibility. (Initial release is version 0.)

packType      The packType field identifies the packing algorithm used to
              compress image data. Color QuickDraw currently supports only
              packType = 0, which means no packing.

packSize      The packSize field contains the size of the packed image in
              bytes. When packType = 0, this field should be set to 0.

hRes          The hRes is the horizontal resolution of pixMap data in pixels
              per inch.

vRes          The vRes is the vertical resolution of pixMap data in pixels
              per inch. By default, hRes = vRes = 72 pixels per inch.

pixelType     The pixelType field specifies the storage format for a pixel
              image. 0 = chunky, 1 = chunky/planar, 2 = planar. Only chunky
              is used in the Macintosh II.

pixelSize     The pixelSize is the physical bits per pixel; it's always a
              power of 2.

cmpCount      The cmpCount is the number of color components per pixel. For
              chunky pixel images, this is always 1.

cmpSize       The cmpSize field contains the logical bits per RGBColor
              component. Note that (cmpCount*cmpSize) doesn't necessarily
              equal pixelSize. For chunky pixel images, cmpSize = pixelSize.

planeBytes    The planeBytes field is the offset in bytes from one plane to
              the next. If only one plane is used, as is the case with chunky
              pixel images, this field is set to 0.

pmTable       The pmTable field is a handle to table of colors used in the
              pixMap. This may be a device color table or an image color table.

pmReserved    The pmReserved field is reserved for future expansion; it must
              be set to 0 for future compatibility.

The data in a pixel image can be organized several ways, depending on the characteristics
of the device or image. The pixMap data structure supports three pixel image formats:
chunky, planar, and chunky/planar.

In a chunky pixel image, all of a pixel's bits are stored consecutively in memory,
all of a row's pixels are stored consecutively, and rowBytes indicates the offset in
memory from one row to the next. This is the only one of the three formats that's
supported by this implementation of Color QuickDraw. The pixel depths that are currently
supported are 1, 2, 4, and 8 bits per pixel. In a chunky pixMap cmpCount = 1 and
cmpSize = pixelSize. Figure 5 shows a chunky pixel image for a system with screen
depth set to eight.

A planar pixel image is a pixel image separated into distinct bit images in memory,
one for each color plane. Within the bit image, rowBytes indicates the offset in
memory from one row to the next. PlaneBytes indicates the offset in memory from one
plane to the next. The planar format isn't supported by this implementation of Color
QuickDraw.

A chunky/planar pixel image is separated into distinct pixel images in memory, typically
one for each color component. Within the pixel image, rowBytes indicates the offset
in memory from one row to the next. PlaneBytes indicates the offset in memory from
one plane to the next. The chunky/planar format isn't supported by this implementation
of Color QuickDraw.

*/

#endif /* __MAC_PIXMAP_H__ */
