@echo off
title DJI Live Server
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0server\serve.ps1"
pause
