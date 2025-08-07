\
\ forth-block-code.fs words
\
\   by Brian Sheldon
\


\ Define hex2 ...

: hex2
    dup   $10 < if $30 emit then
    hex u. ;

\ Define hex4 ...

: hex4
    dup $1000 < if $30 emit then
    dup  $100 < if $30 emit then
    dup   $10 < if $30 emit then
    hex u. ;

\ Define endianswap ...

: endianswap
    dup 8>>
    swap 8<<
    + ;


\ Define hexline ...

: hexline
    dup hex4 $20 emit $20 emit
    8 0 do
        dup @ endianswap hex4
        $20 emit
        2 +
    loop
    cr ;"

\ Define hexblock ...

: hexblock
    8 0 do
        hexline
    loop ;


\ Define font ...

: font
    cls
    192 0 do
        i 32 < if
            $20 emit
        else
            i emit
        then
    loop
    cr ;

\ Define gsync ...

: gsync
    $bf emit
    3 0 do
        $20 emit
        $bf emit
    loop ;

\ Define gmap ...

: gmap
    16 0 do
        i u.
        i $81 + emit
    loop ;

\ Define gsp ...

: gsp
    0 do
        $20 emit
    loop ;

\ Define ghead ...

: ghead
    cls
    gsync
    9 gsp
    gmap
    9 gsp
    gsync ;

\ Define gword ...

: gword
    dup 8>> $f0 and $10 / $81 + emit
    dup 8>> $0f and $81 + emit
    dup $f0 and $10 / $81 + emit
    $0f and $81 + emit ;

\ Define gline ...

: gline
    16 0 do
        dup @ endianswap dup gword
        rot + swap
        2 +
    loop ;

\ Define gblock ...

: gblock
    8 0 do
        gline
    loop ;

\ Define gfoot ...

: gfoot
    gsync 10 gsp
    dup $100 - dup gword $20 emit hex4 $20 emit
    dup 1 - dup gword $20 emit hex4 $20 emit
    swap dup gword $20 emit hex4 $20 emit
    10 gsp gsync ;

\ Define gblock ...

: gbody
    0 swap
    ghead
    gblock
    gfoot cr ;

\ Define gstart ...

: gstart
    hex
    $8000
    gbody ;


