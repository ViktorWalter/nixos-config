#!/bin/bash
sinks=`pactl list short sinks | cut -f1-2`
if [ "$#" == "0" ]; then
  selected=`echo "$sinks" | rofi -dmenu`
else
  selected=`echo "$sinks" | grep $1`
fi
pactl set-card-profile "alsa_card.pci-0000_03_00.1"  output:hdmi-stereo-extra4
selNum=`echo "$selected" | cut -f1`
pactl set-default-sink $selNum
outputs=`pactl list short sink-inputs | cut -f1`
for output in $outputs; do
  pactl move-sink-input $output $selNum
done



