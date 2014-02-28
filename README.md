Depixelate
==========

Implementation of various scaling/depixelating techbologies.

This is very rough software that I threw together for my own amusement.
Feel free to modify it and make it better.

Currently it makes use of NSImage, so it only runs on Mac. It shouldn't be too hard to modify it to use jpeg and png libs directly, thus making it portable to other systems.


Usage
-----

Usage: depixelate <algorithm> <scale> <srcfile> <dstfile>
- Where scale is between 2 and 5 (certain algorithms do not support certain scales)
- Where algorithm is one of "xbrz", "hqx", "scale2x".
- srcfile and dstfile determine their types by the filename extension.

Scale support:
- XBRZ:    2x - 5x
- HQX:     2x - 4x
- Scale2X: 2x - 4x


License
-------

- Scale2X is released under GNU General Public License version 2
- HQX is released under GNU Lesser General Public License version 2.1
- XBRZ is releaed under GNU General Public License version 3
- All the glue logic is released under MIT.
