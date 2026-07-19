#!/bin/bash
scr=($( xrandr -q | awk '/ connected/ {print $1}' ))
active=($( xrandr | grep -E " connected (primary )?[1-9]+" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/" ))
echo $active | grep LVDS
if [ $? -eq 0 ]; then
  xrandr --output DisplayPort-1 --auto --primary
  xrandr --output DisplayPort-3 --off
else
  xrandr --output DisplayPort-3 --auto --primary
  xrandr --output DisplayPort-1 --off
fi
~/.i3/setWallpaper.sh
