@echo off
title DJI Live Stopper
powershell -ExecutionPolicy Bypass -File "%~dp0server\stop.ps1"
pause
