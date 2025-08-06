#
# capture.mod.py
#
#  by Brian Sheldon
#
# An extremely crude script to convert the output of the scan in text
# format into binary and save it to a file.  Enough said.
#

beg = '8000'
end = 'ffff'
fn = 'capture.' + str( beg ) + '.' + str( end ) + '.txt'

curaddr = 0x8000
binarr = bytearray()

def error( s ):
    print( s )

def getword( pos, line ):
    end = pos + 4
    s = line[ pos:end ]
    v = int( s, 16 )
    return ( s, v )

def data( line ):
    global curaddr
    saddr, addr = getword( 0, line )
    if addr != curaddr:
        error( 'Data address: ' + saddr + ' not aligned with: ' + hex( curaddr ) )
    for w in range( 8 ):
        pos = 6 + w * 5
        sword, word = getword( pos, line )
        high = word >> 8
        low = word & 0xff
        binarr.append( high )
        binarr.append( low )
    curaddr += 16

def status( line ):
    pass

with open( fn, 'r' ) as fs:
    lines = fs.readlines()
    for i, line in enumerate( lines ):
        blki = i % 17
        if blki == 16:
            status( line )
        else:
            data( line )

with open( 'capture.bin', 'wb' ) as fout:
    fout.write( binarr[ 0x0000:0x4000 ] )



