#!/bin/bash
set -e

# Start PulseAudio in user mode
pulseaudio --start --exit-idle-time=-1 --log-target=syslog

# Start D-Bus for XFCE
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Start virtual display
Xvfb :0 -screen 0 1920x1080x24 &

# Start XFCE desktop
startxfce4 &

# Start x11vnc server on port 5900 (no password)
x11vnc -display :0 -nopw -forever -shared &

# Start noVNC web client on port 8080
websockify --web=/usr/share/novnc/ 8080 localhost:5900 &

# Start Sunshine streaming server
/opt/sunshine/sunshine ~/.config/sunshine &

# Keep container alive
tail -f /dev/null
