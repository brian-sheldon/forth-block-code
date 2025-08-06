#!/usr/bin/bash

#
# xdo.sh
#
#  by Brian Sheldon
#
# Automates the process of running generating the block code image
# on the online Forth system, taking a screenshot and decoding the
# image using the Python decoder, capture.py
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

xdoinit

function do_gstart {
  echo 'Sending gstart command ...'
  xdotool type --window $winid "gstart"
  xdotool key  --window $winid Return
  sleep 5
}

function do_gbody {
  echo 'Sending gbody command ...'
  xdotool type --window $winid "gbody"
  xdotool key  --window $winid Return
  sleep 3
}

function do_snap {
  echo 'Screenshot happens now ...'
  gnome-screenshot -w -f capture.png
  sleep 2
}

# required only once if graphics block is same size and location in image
function do_init {
  screen=$(python capture.py scan)
  
  threshold=$(echo "$screen" | grep "threshold=" | cut -d'=' -f2)
  x=$(echo "$screen" | grep "x=" | cut -d'=' -f2)
  y=$(echo "$screen" | grep "y=" | cut -d'=' -f2)
  w=$(echo "$screen" | grep "w=" | cut -d'=' -f2)
  h=$(echo "$screen" | grep "h=" | cut -d'=' -f2)
  
  echo $threshold
  echo $x
  echo $y
  echo $w
  echo $h
}

# uses the image locaton and size from first scan
function do_capture {
  echo 'Capture happens now ...'
  python capture.py decode $threshold $x $y $w $h >> data/capture.txt
}

function capture_first {
  do_gstart
  do_gbody
  do_snap
  do_init
  do_capture
}

function capture {
  do_gbody
  do_snap
  do_init
  do_capture
}

# required to set the start address of data, leaves next address on stack
capture_first

function many {
  for i in $(seq 1 127 );
  do
    capture
  done
}

many


