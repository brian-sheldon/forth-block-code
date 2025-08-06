#!/usr/bin/bash

#
# snap.sh
#
#  by Brian Sheldon
#
# Not used for the block code processing, just useful for taking additional
# snapshots if needed.
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

function do_snap {
  echo 'Screenshot happens now ...'
  gnome-screenshot -w -f text.4.png
  sleep 2
}

do_snap



