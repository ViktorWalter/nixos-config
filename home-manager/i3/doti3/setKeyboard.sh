setxkbmap -I$HOME/.xkb -symbols "custom(basic)" -print > /tmp/keymap.xkb
xkbcomp -w 10 -I$HOME/.xkb /tmp/keymap.xkb $DISPLAY
