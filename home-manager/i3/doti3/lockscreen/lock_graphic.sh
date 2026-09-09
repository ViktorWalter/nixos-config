#!/bin/bash
rand=$[ $RANDOM % "6" ]
# rand=4

rm /tmp/s.png
rm /tmp/s.jpg

# IFS=, #so that sub-command sequences in variables get parsed
logo=(\( ~/.i3/lockscreen/ohhellno_shadow.png -resize 700x700 -geometry -400+0 \))
tinttcolor=(-fill "#00bffa")
case $rand in
  0)
  scrot /tmp/s.png && convert -gravity center $tintcolor /tmp/s.png -brightness-contrast -10x0 -tint 80 -blur 0x2 -paint 3 "${logo[@]}"  -composite /tmp/s.png
  ;;
  1)
scrot /tmp/s.png && convert -gravity center $tintcolor /tmp/s.png -brightness-contrast -10x0 -tint 80 -blur 0x8 "${logo[@]}"  -composite /tmp/s.png
  ;;
  2)
  scrot /tmp/s.png && convert -gravity center $tintcolor /tmp/s.png -brightness-contrast -10x0 -tint 80 -scale 10% -scale 1000% "${logo[@]}"  -composite /tmp/s.png
  ;;
  3)
  scrot /tmp/s.png && convert -gravity center $tintcolor /tmp/s.png -brightness-contrast -10x0 -tint 80 -scale 2% -scale 5000% "${logo[@]}"  -composite /tmp/s.png
  ;;
  4)
    pre_swirl=(-tint 80 -blur 0x5)
    swirl=(-implode 1 -swirl 360)
    scrot /tmp/s.png && convert -background Black -gravity center $tintcolor \( /tmp/s.png "${pre_swirl[@]}" \) \( /tmp/s.png "${pre_swirl[@]}" -extent 1:1^ "${swirl[@]}" \) -composite  "${logo[@]}"  -composite /tmp/s.png
  ;;
  *)
  scrot -q 40 /tmp/s.jpg && \
    convert /tmp/s.jpg -quality 1  /tmp/s.jpg && \
    convert -gravity center $tintcolor /tmp/s.jpg -brightness-contrast -0x-40 -tint 10 "${logo[@]}"  -composite /tmp/s.png
      ;;
esac
