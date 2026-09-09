#!/bin/bash

wpFile=`find ${HOME}/Pictures/wallpapers -type f | shuf -n 1`
feh --bg-fill ${wpFile}
