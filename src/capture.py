#
# capture.py
#
#  by Brian Sheldon
#
# Scans an image looking for the sync block to determine the
# location of the block code.  It uses the sync blocks to
# determine the bounds of the data block and can then use
# this to precisely locate the individual characters used
# to encode the data.  The 2x3 block character is then scanned
# to determine the 6 bits that represent the character code.
# The code is used as an index to convert to the hex characters
# that can then be saved to a file.  This file can then be used
# to extract whatever data is neeeded.
#

import sys
import math

from PIL import Image

class TrsScan:
    def __init__( self ):
        self.filename( 'capture.png' )
    @property
    def threshold( self ):
        return self._threshold
    @threshold.setter
    def threshold( self, level ):
        self._threshold = level
    def scanRow( self, y, show = False ):
        lastx = 0
        trans = []
        sync = []
        for x in range( self.width ):
            pixel = self.img.getpixel( ( x, y ) )
            r, g, b, a = pixel
            avg = math.floor( ( r + g + b ) / 3 )
            s = ' '
            v = 0
            if avg > self.threshold:
                s = '*'
                v = 1
            if show:
                sys.stdout.write( s )
            if x == 0:
                current = v
            if v != current:
                tlen = x - lastx
                lastx = x
                trans.append( ( x, v, tlen ) )
                current = v
        count = 0
        xstartofsync = 0
        xendofsync = 0
        for transition in trans:
            x, v, tlen = transition
            prevx = x - tlen
            if tlen > 9 and tlen < 15:
                if count == 0:
                    xstartofsync = prevx
                count += 1
                if count == 7:
                    xendofsync = x - 1
                    sync.append( ( y, xstartofsync, xendofsync ) )
                    #print( len( self.sync ) )
                    #print( 'Sync Block found, row: ' + str( y ) + ' start of sync: ' + str( xstartofsync ) + ' end of sync: ' + str( xendofsync ) )
                    count = 0
            else:
                 count = 0
        if len( sync ) > 0:
            if len( sync ) != 2:
                 pass
                #print( 'Sync Error .....' )
            else:
                y, xs0, xe0 = sync[ 0 ]
                y, xs1, xe1 = sync[ 1 ]
                self.sync.append( ( y, xs0, xe0, xs1, xe1 ) )
    def scanRows( self ):
        self.sync = []
        for y in range( self.height ):
            self.scanRow( y )
        #print( len( self.sync ) )
        xs0 = 0
        xe0 = 0
        xs1 = 0
        xe1 = 0
        ys0 = 0
        ye0 = 0
        ys1 = 0
        ye1 = 0
        ynext = 0
        count = 0
        for found in self.sync:
            y, xs0, xe0, xs1,xe1 = found
            if count == 0:
                ys0 = y
                ynext = y + 1
            else:
                if y != ynext:
                    ye0 = ynext - 1
                    ys1 = y
                else:
                    ye1 = y
                ynext = y + 1
            #print( 'Sync Block found, row: ' + str( y ), xs0, xe0, xs1, xe1 )
            count += 1
        tx = xs0
        ty = ys0
        tw = xe1 - tx + 1
        th = ye1 - ty + 1
        self.config( tx, ty, tw, th )
        screen = ( tx, ty, tw, th )
        return screen
    def config( self, x, y, w, h ):
        self.tx = x
        self.ty = y
        self.tw = w
        self.th = h
        self.chw = w / 64
        self.chh = h / 10
    def filename( self, fn ):
        self.filename = fn
        self.img = Image.open( fn )
        w, h = self.img.size
        self.width = w
        self.height = h
    def decodeBlock( self, c, r ):
        pixels = [
            [ 0x01, 0x04, 0x10 ],
            [ 0x02, 0x08, 0x20 ]
        ]
        tx = self.tx
        ty = self.ty
        tw = self.tw
        th = self.th
        chw = self.chw
        chh = self.chh
        x = tx + c * chw
        y = ty + r * chh
        #print( tx, ty )
        #print( chw,chh )
        #print( x, y )
        value = 0
        for px in range( 2 ):
            testx = x + px * (chw / 2 ) + ( chw / 4 )
            for py in range( 3 ):
                testy = y + py * (chh / 3 ) + ( chh / 6 )
                pixel = self.img.getpixel( ( int( testx ), int( testy ) ) )
                r, g, b, a = pixel
                avg = math.floor( ( r + g + b ) / 3 )
                if avg > self.threshold:
                    value += pixels[ px ][ py ]
                    #print( value )
                #print( px, py, testx, testy, avg )
        value = value - 1
        #print( value )
        return value
    def decoder( self ):
        hch = [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ]
        words = []
        data = ''
        word = 0
        chksum = 0
        addr = self.addrbeg
        for r in range( 8 ):
            for c in range( 16 ):
                if ( c % 8 ) == 0:
                    data += f"{addr:04X}" + '  '
                    addr += 16
                word = self.decodeWord( c * 4, r + 1 )
                words.append( word )
                chksum += word
                chksum = chksum & 0xffff
                if ( c % 8 ) != 0:
                    data += ' '
                data += f"{word:04X}"
                if ( c % 8 ) == 7:
                    data += '\n'
        if chksum == self.chksum:
            data += 'Chksum: ' + f"{chksum:04X}" + ' is a match of: ' + f"{self.chksum:04X}" + '\n'
            #print( 'Chksum: ' + f"{chksum:04X}" + ' is a match of: ' + f"{self.chksum:04X}" )
        else:
            data += 'Chksum: ' + f"{chksum:04X}" + ' does not match: ' + f"{self.chksum:04X}" + '\n'
            #print( 'Chksum: ' + f"{chksum:04X}" + ' does not match: ' + f"{self.chksum:04X}" )
        sys.stdout.write( data )
        return words
    def decodeWord( self, c, r ):
        word = 0
        for x in range( 4 ):
            value = self.decodeBlock( c + x, r )
            word = word << 4
            word = word + value
        return word
    def decodeFooter( self ):
        self.addrbeg = self.decodeWord( 17, 9 )
        self.addrend = self.decodeWord( 27, 9 )
        self.chksum = self.decodeWord( 37, 9 )
        #print( hex( addrbeg ) )
        #print( hex( addrend ) )
        #print( hex( chksum ) )


plen = len( sys.argv )
if plen > 1:
    filename = 'capture.png'
    scan = TrsScan()
    threshold = 150
    if sys.argv[1] == 'scan':
        if plen > 2:
            threshold = int( sys.argv[2] )
        scan.threshold = threshold
        screen = scan.scanRows()
        x, y, w, h = screen
        print( f"threshold={threshold:0d}" )
        print( f"x={x:0d}" )
        print( f"y={y:0d}" )
        print( f"w={w:0d}" )
        print( f"h={h:0d}" )
    if sys.argv[1] == 'decode':
        if plen > 6:
            threshold = int( sys.argv[2] )
            scan.threshold = threshold
            x = int( sys.argv[3] )
            y = int( sys.argv[4] )
            w = int( sys.argv[5] )
            h = int( sys.argv[6] )
            scan.config( x, y, w, h )
            scan.decodeFooter()
            scan.decoder()


