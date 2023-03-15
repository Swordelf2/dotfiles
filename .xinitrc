# This is just a sh file

# Load ~/.Xresources
xrdb -merge ~/.Xresources

# Change key repeat delay and interval
xset r rate 200 30

# Disable the annoying bell
xset -b

# Sync primary and clipboard selections
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

# Two layouts us,ru. Hold Alt to enable ru
# setxkbmap -layout us,ru -option grp:switch -option grp_led:caps
setxkbmap -layout us,ru -option grp:switch -option grp:alt_shift_toggle
# Use this instead if you want Alt+shift to switch language as well
#setxkbmap -layout us,ru -option grp:switch -option grp:alt_shift_toggle

# Default stuff
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Run window manager
exec i3
