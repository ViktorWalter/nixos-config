#!/bin/bash
let -a scr
let -a res
# let -a rot
# let -a wid
wid=0
scr=($( xrandr -q | awk '/ connected/ {print $1}' ))
res=($( xrandr -q | awk '/ connected/ {getline; print $1}' ))
# rot=($( xrandr -q --verbose | awk '/ connected/ {print $5}' ))
active=($( xrandr | grep -E " connected (primary )?[1-9]+" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/" ))
if [ -z "$scr" ]; then
  i3-nagbar -m 'No screen defined' -t warning;
else
  for i in "${!scr[@]}"; do
    if [[ "${scr[$i]}" == *LVDS* ]]; then
      previousMonitor=${scr[$i]}
      xrandr --output ${scr[$i]} --auto --primary --pos 0x0 --rotate normal 
      wid=$((wid + $( echo ${res[$i]} | awk -F'x' '{print $1}' )));
    fi
  done;
  if [ "${#active[@]}" -eq "${#scr[@]}" ]; then
    for i in "${!scr[@]}"; do
      if [[ "${scr[$i]}" != *LVDS* ]]; then
        xrandr --output ${scr[$i]} --off
      fi;
    done;
    # pacmd set-default-sink `pactl list short sinks | grep 1b | tr '\t' ' ' | cut -d' ' -f2`
  else
    for i in "${!scr[@]}"; do
      if [[ "${scr[$i]}" != *LVDS* ]]; then
        xrandr --output ${scr[$i]} --auto --right-of $previousMonitor
        previousMonitor=${scr[$i]}
      fi;
    done;
    pacmd set-default-sink `pactl list short sinks | grep hdmi | tr '\t' ' ' | cut -d' ' -f2`
  fi
fi
xrandr --dpi 100

~/.i3/setWallpaper.sh
sleep 2
~/.i3/conky_start
