# One-click launcher: starts MediaMTX + hosts DJI live page
# Run:  powershell -ExecutionPolicy Bypass -File serve.ps1
# Then open http://<this-ip>:8080/ on any device on the same LAN

$ErrorActionPreference = "Stop"

# ---------- 1. Ensure MediaMTX is running (RTMP in :1935) ----------
$mtxDir = Join-Path $PSScriptRoot "mediamtx_v1.20.1_windows_amd64"
$mtxExe = Join-Path $mtxDir "mediamtx.exe"

if (Get-Process -Name "mediamtx" -ErrorAction SilentlyContinue) {
    Write-Host "[1/2] MediaMTX already running" -ForegroundColor Green
} else {
    Write-Host "[1/2] Starting MediaMTX..." -ForegroundColor Yellow
    Start-Process -FilePath $mtxExe -WorkingDirectory $mtxDir
    $ready = $false
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Milliseconds 500
        if (Get-NetTCPConnection -LocalPort 1935 -State Listen -ErrorAction SilentlyContinue) {
            $ready = $true
            break
        }
    }
    if (-not $ready) {
        Write-Host "MediaMTX failed to start (port 1935 not listening)" -ForegroundColor Red
        exit 1
    }
    Write-Host "      MediaMTX is up (RTMP :1935, WebRTC :8889, HLS :8888)" -ForegroundColor Green
}

# ---------- 2. Host the live page ----------
$port = 8080
$file = Join-Path $PSScriptRoot "index.html"
$body = [System.IO.File]::ReadAllBytes($file)

function Show-Steps {
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "  DJI LIVE IS READY" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  STEP 1  WATCH - open any url below on a device" -ForegroundColor White
    Write-Host "          in the SAME network as this PC:" -ForegroundColor White
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254*" } | ForEach-Object {
        $alias = if ($_.InterfaceAlias) { $_.InterfaceAlias } else { "?" }
        Write-Host ("    WATCH:  http://{0}:{1}/   [ {2} ]" -f $_.IPAddress, $port, $alias) -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "  STEP 2  PUSH - in DJI Fly, the SERVER address and" -ForegroundColor White
    Write-Host "          the STREAM KEY are SEPARATE fields. No port" -ForegroundColor White
    Write-Host "          needed in SERVER - defaults to 1935. Pick the" -ForegroundColor White
    Write-Host "          one whose [ network ] your controller uses:" -ForegroundColor White
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254*" } | ForEach-Object {
        $alias = if ($_.InterfaceAlias) { $_.InterfaceAlias } else { "?" }
        Write-Host ("    SERVER:  rtmp://{0}/   [ {1} ]" -f $_.IPAddress, $alias) -ForegroundColor Cyan
    }
    Write-Host "    STREAM KEY:  livedji" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  STEP 3  Start pushing in DJI Fly, then check the" -ForegroundColor White
    Write-Host "          WATCH page - stream appears within ~5s." -ForegroundColor White
    Write-Host ""
    Write-Host "  Tip: also open the WATCH page on this PC:" -ForegroundColor Yellow
    Write-Host "    http://127.0.0.1:8080/" -ForegroundColor Cyan
    Write-Host ""
}

if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
    Write-Host "[2/2] Web server already running on port $port (skip)" -ForegroundColor Yellow
    Show-Steps
    Write-Host "  Note: server keeps running; Ctrl+C only closes this window." -ForegroundColor Yellow
    Write-Host ""
    while ($true) { Start-Sleep -Seconds 3600 }
}

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$listener.Start()

Write-Host "[2/2] Live page ready" -ForegroundColor Green
Show-Steps
Write-Host "Ctrl+C stops web server (MediaMTX keeps running)" -ForegroundColor Yellow

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream)
    $requestLine = $reader.ReadLine()
    if ($null -ne $requestLine) {
        $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
        $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
        $stream.Write($headerBytes, 0, $headerBytes.Length)
        $stream.Write($body, 0, $body.Length)
    }
    $client.Close()
}
