#!/bin/bash
# One-click launcher for macOS: starts MediaMTX + hosts the DJI live page
# Double-click this file (or: chmod +x start.command && ./start.command)
# Servers keep running in the background after this window closes.

set -e
cd "$(dirname "$0")"

# ---------- locate macOS MediaMTX (auto-detect chip) ----------
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  MTX_DIR="server/mediamtx_v1.20.1_darwin_arm64"
else
  MTX_DIR="server/mediamtx_v1.20.1_darwin_amd64"
fi
MTX_EXE="$MTX_DIR/mediamtx"

if [ ! -x "$MTX_EXE" ]; then
  echo "==============================================================="
  echo "  ERROR: MediaMTX not found at $MTX_EXE"
  echo ""
  echo "  Download the macOS build from:"
  echo "    https://github.com/bluenviron/mediamtx/releases"
  echo "    (v1.20.1  darwin_arm64  for Apple Silicon,"
  echo "               darwin_amd64  for Intel)"
  echo "  Unzip and place 'mediamtx' into:  $MTX_DIR"
  echo "==============================================================="
  read -n 1 -s -r -p "Press any key to close"
  exit 1
fi

# ---------- 1. start MediaMTX if not running (RTMP :1935) ----------
echo "[1/2] MediaMTX ..."
if lsof -iTCP:1935 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "      already running"
else
  chmod +x "$MTX_EXE"
  (cd "$MTX_DIR" && nohup ./mediamtx >/dev/null 2>&1 &)
  for i in $(seq 1 20); do
    sleep 0.5
    lsof -iTCP:1935 -sTCP:LISTEN >/dev/null 2>&1 && break
  done
  if ! lsof -iTCP:1935 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "ERROR: MediaMTX failed to start (port 1935 not listening)"
    read -n 1 -s -r -p "Press any key to close"
    exit 1
  fi
  echo "      MediaMTX is up (RTMP :1935, WebRTC :8889, HLS :8888)"
fi

# ---------- 2. host the live page (python3, bundled with macOS) ----------
PORT=8080
if lsof -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "[2/2] Web server already running on port $PORT"
else
  echo "[2/2] Starting web server ..."
  nohup python3 "$PWD/server/serve.py" "$PWD/server" $PORT >/dev/null 2>&1 &
  sleep 1
fi

# ---------- print addresses (with interface names) ----------
list_ip() {
  for iface in $(ifconfig -l); do
    case "$iface" in
      lo0|utun*|awdl0|llw0|anpi*|gif*|stf*|ap1) continue ;;
    esac
    ip=$(ifconfig "$iface" 2>/dev/null | awk '/inet /{print $2; exit}')
    if [ -n "$ip" ]; then
      echo "    $1:  $2$ip$3   [ $iface ]"
    fi
  done
}

echo ""
echo "=============================================="
echo "  DJI LIVE IS READY"
echo "=============================================="
echo ""
echo "  STEP 1  WATCH - open any url below on a device"
echo "          in the SAME network as this Mac:"
list_ip "WATCH" "http://" ":$PORT/"
echo ""
echo "  STEP 2  PUSH - in DJI Fly, fill SEPARATE fields:"
list_ip "SERVER" "rtmp://" "/"
echo "    STREAM KEY:  livedji"
echo ""
echo "  STEP 3  Start pushing in DJI Fly, then check the"
echo "          WATCH page - stream appears within ~5s."
echo ""
echo "  Tip: also open on this Mac:  http://127.0.0.1:$PORT/"
echo ""
echo "  Servers keep running in the background."
read -n 1 -s -r -p "Press any key to close this window"
