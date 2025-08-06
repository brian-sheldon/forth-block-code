#!/usr/bin/bash

#
# xdo.words.sh
# 
#   by Brian Sheldon
#
# load forth-block-code.fs words to the online Forth system
#

winname="My TRS-80"
winid=$( xdotool search --name "$winname" )

function xdoinit {
  if [[ -z "$winid" ]]; then
    echo "Window: '$winname' not found, exiting ..."
  else
    echo "Window: '$winname' id: $winid"
    xdotool windowactivate $winid
    sleep 1
  fi
}

function hex2 {
  echo "Define hex2 ..."
  xdotool type --window $winid ": hex2"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup   \$10 < if \$30 emit then"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    hex u. ;"
  xdotool key  --window $winid Return
}
function hex4 {
  echo "Define hex4 ..."
  xdotool type --window $winid ": hex4"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup \$1000 < if \$30 emit then"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup  \$100 < if \$30 emit then"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup   \$10 < if \$30 emit then"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    hex u. ;"
  xdotool key  --window $winid Return
}
function endianswap {
  echo "Define endianswap ..."
  xdotool type --window $winid ": endianswap dup 8>> swap 8<< + ;"
  xdotool key  --window $winid Return
}
function hexline {
  echo "Define hexline ..."
  xdotool type --window $winid ": hexline"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup hex4 \$20 emit \$20 emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    8 0 do"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      dup @ endianswap hex4"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      \$20 emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      2 +"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    loop"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    cr ;"
  xdotool key  --window $winid Return
}
function hexblock {
  echo "Define hexblock ..."
  xdotool type --window $winid ": hexblock"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    8 0 do"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      hexline"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    loop ;"
  xdotool key  --window $winid Return
}

function font {
  echo "Define font ..."
  xdotool type --window $winid ": font cls 192 0 do i 32 < if  \$20 emit else i emit then loop cr ;"
  xdotool key  --window $winid Return
}
function gsync {
  echo "Define gsync ..."
  xdotool type --window $winid ": gsync \$bf emit 3 0 do \$20 emit \$bf emit loop ;"
  xdotool key  --window $winid Return
}
function gmap {
  echo "Define gmap ..."
  xdotool type --window $winid ": gmap 16 0 do i u. i \$81 + emit loop ;"
  xdotool key  --window $winid Return
}
function gsp {
  echo "Define gsp ..."
  xdotool type --window $winid ": gsp 0 do \$20 emit loop ;"
  xdotool key  --window $winid Return
}
function ghead {
  echo "Define ghead ..."
  xdotool type --window $winid ": ghead cls gsync 9 gsp gmap 9 gsp gsync ;"
  xdotool key  --window $winid Return
}
function gword {
  echo "Define gword ..."
  xdotool type --window $winid ": gword"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup 8>> \$f0 and \$10 / \$81 + emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup 8>> \$0f and \$81 + emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup \$f0 and \$10 / \$81 + emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    \$0f and \$81 + emit ;"
  xdotool key  --window $winid Return
}
# chksum addr -> chksum addr value -> addr chksum swap
function gline {
  echo "Define gline ..."
  xdotool type --window $winid ": gline"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    16 0 do"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      dup @ endianswap dup gword"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      rot + swap"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      2 +"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      loop ;"
  xdotool key  --window $winid Return
}
function gblock {
  echo "Define gblock ..."
  xdotool type --window $winid ": gblock"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    8 0 do"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      gline"
  xdotool key  --window $winid Return
  xdotool type --window $winid "      loop ;"
  xdotool key  --window $winid Return
}
function gfoot {
  echo "Define gfoot ..."
  xdotool type --window $winid ": gfoot"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    gsync 10 gsp"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup \$100 - dup gword \$20 emit hex4 \$20 emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    dup 1 - dup gword \$20 emit hex4 \$20 emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    swap dup gword \$20 emit hex4 \$20 emit"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    10 gsp gsync ;"
  xdotool key  --window $winid Return
}
function gbody {
  echo "Define gbody ..."
  xdotool type --window $winid ": gbody"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    0 swap"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    ghead"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    gblock"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    gfoot cr ;"
  xdotool key  --window $winid Return
}
function gstart {
  echo "Define gstart ..."
  xdotool type --window $winid ": gstart"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    hex"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    \$8000"
  xdotool key  --window $winid Return
  xdotool type --window $winid "    gbody ;"
  xdotool key  --window $winid Return
}

function forthinit {
  hex2
  hex4
  endianswap
  hexline
  hexblock
  font
  gsync
  gmap
  gsp
  ghead
  gword
  gline
  gblock
  gfoot
  gbody
  gstart
}

xdoinit
forthinit

