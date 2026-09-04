#!/bin/bash
# One-click stopper for macOS: stops MediaMTX + the DJI watch page
# Double-click this file (or: chmod +x stop_macos.command && ./stop_macos.command)
# Everything keeps running until you run this (or reboot).

cd "$(dirname "$0")"

echo ""
echo "=============================================="
echo "  Stopping DJI Live services ..."
echo "=============================================="

stop_port() {
  # $1 = port, $2 = label
  local pids
  pids=$(lsof -tiTCP:"$1" -sTCP:LISTEN 2>/dev/null)
  if [ -n "$pids" ]; then
    echo "$pids" | xargs kill 2>/dev/null
    echo "  stopped       $2  (port $1)"
  else
    echo "  not running   $2  (port $1)"
  fi
}

stop_port 1935 "MediaMTX"
stop_port 8080 "Watch page"

echo ""
echo "  Done. Double-click start_macos.command to restart."
read -n 1 -s -r -p "Press any key to close this window"
