#!/bin/bash
PIPE="/tmp/zoom-pipe"
[ -p "$PIPE" ] || mkfifo "$PIPE"

# Trik 'sleep infinity' menjaga pipa tetap terbuka agar wl-mirror tidak exit
(sleep infinity > "$PIPE" &)

# Jalankan wl-mirror membaca dari pipa
wl-mirror -b screencopy -S eDP-1 < "$PIPE" &

# Tunggu jendela muncul, lalu lempar ke proyektor
sleep 1
echo "--no-region" > "$PIPE"
niri msg action move-column-to-monitor-right
sleep 1
niri msg action toggle-windowed-fullscreen
