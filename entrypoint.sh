#!/bin/bash
set -e

pulseaudio --start --exit-idle-time=-1 --log-target=syslog

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

Xvfb :0 -screen 0 1920x1080x24 &
export DISPLAY=:0

/opt/sunshine/sunshine ~/.config/sunshine &

tail -f /dev/null
