#!/usr/bin/env sh

#graphical progs load their envvars
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

#for nyxt browser on highdpi display
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5

#start dwm script + dbus session
dbus-launch /home/panos/.local/bin/startdwm.sh
