#
# crop.py
#
#  by Brian Sheldon
#
# Just a quick program to crop the original images using hand coded values.
# Used for produce the sample images on github
#

import sys
import math

from PIL import Image

crop = Image.open( 'text.4.png' )

w, h = crop.size

x = 101
y = 211

x1 = x + 768 - 1
y1 = y + 576 - 1

pad = 20

box = ( x - pad, y - pad, x1 + pad, y1 + pad )

emu = crop.crop( box )
emu.save( 'text.8300.png' )



