#!/bin/sh

# background color
xsetroot -solid gray10 &

# applet tray
#trayer --edge top --align right --width 150 --widthtype pixel --height 18 --tint 0 --alpha 255 --transparent true &

# applets
nm-applet --sm-disable &
mate-power-manager &
pipewire & # required for pnmixer?
pnmixer &

# start background kitty daemon
# (for faster startup times)
kitty --single-instance --instance-group=main --detach

# keyboard layouts
setxkbmap -layout us,es -variant , -option 'grp:alt_shift_toggle' 
xbdd

# disable keyboard backlight
(sleep 1 && dbus-send --system --type=method_call  --dest="org.freedesktop.UPower" "/org/freedesktop/UPower/KbdBacklight" "org.freedesktop.UPower.KbdBacklight.SetBrightness" int32:0) &

# start xmonad
exec xmonad "$@"

