# One-click stopper: stops MediaMTX + DJI watch page (Windows)
# Run:  powershell -ExecutionPolicy Bypass -File stop.ps1
# Everything keeps running until you run this (or reboot).

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  Stopping DJI Live services ..." -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# 1. MediaMTX (RTMP :1935)
if (Get-Process -Name "mediamtx" -ErrorAction SilentlyContinue) {
    Get-Process -Name "mediamtx" | Stop-Process -Force
    Write-Host "  stopped       MediaMTX  (RTMP :1935)" -ForegroundColor Green
} else {
    Write-Host "  not running   MediaMTX  (RTMP :1935)" -ForegroundColor Yellow
}

# 2. Watch page (HTTP :8080) - served by a PowerShell window
$conn = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($conn) {
    Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    Write-Host "  stopped       Watch page  (HTTP :8080)" -ForegroundColor Green
} else {
    Write-Host "  not running   Watch page  (HTTP :8080)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Done. Double-click start_windows.bat to restart." -ForegroundColor Green
