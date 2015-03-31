#!/bin/bash

# Load resources

xrdb -merge .Xresources

xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'

# Set up an icon tray

trayer --edge top --align right --SetDockType true --SetPartialStrut true \
 --expand true --width 11 --transparent true --alpha 0 --tint 0x000000 --height 14 &

nm-applet --sm-disable &
gnome-power-manager &
gnome-sound-applet &
~/.dropbox-dist/dropboxd &

~/.cabal/bin/xmonad
#xterm
#firefox
