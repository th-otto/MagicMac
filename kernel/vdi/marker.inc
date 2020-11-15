/* poly marker definitions */

m_dot:            DC.W 1                  /* line count */
                  DC.W 0                  /* extra width */
                  DC.W 0                  /* hotspot-x */
                  DC.W 0                  /* hotspot-y */
                  DC.W 0,0,0,0
m_plus:           DC.W 2                  /* line count */
                  DC.W 0                  /* extra width */
                  DC.W 32767              /* hotspot-x */
                  DC.W 32767              /* hotspot-y */
                  DC.W 32767,0,32767,65535
                  DC.W 0,32767,65535,32767
m_asterisk:       DC.W 4                  /* line count */
                  DC.W 0                  /* extra width */
                  DC.W 32767              /* hotspot-x */
                  DC.W 32767              /* hotspot-y */
                  DC.W 32767,0,32767,65535
                  DC.W 6553,6553,58981,58981
                  DC.W 0,32767,65535,32767
                  DC.W 58981,6553,6553,58981
m_square:         DC.W 4                  /* line count */
                  DC.W 0                  /* extra width */
                  DC.W 32767              /* hotspot-x */
                  DC.W 32767              /* hotspot-y */
                  DC.W 0,0,65535,0
                  DC.W 0,65535,65535,65535
                  DC.W 0,0,0,65535
                  DC.W 65535,0,65535,65535
m_cross:          DC.W 2                  /* line count */
                  DC.W 0                  /* extra width */
                  DC.W 32767              /* hotspot-x */
                  DC.W 32767              /* hotspot-y */
                  DC.W 65535,0,0,65535
                  DC.W 0,0,65535,65535
m_diamond:        DC.W 4                  /* line count */
                  DC.W 39600              /* extra width */
                  DC.W 32767              /* hotspot-x */
                  DC.W 20500              /* hotspot-y */
                  DC.W 0,20500,32767,150
                  DC.W 32767,150,65535,20500
                  DC.W 65535,20500,32767,41000
                  DC.W 32767,41000,0,20500
                  
