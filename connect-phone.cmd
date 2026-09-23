@echo off
set IP=%~1
if "%IP%"=="" set IP=192.168.1.11
set PORT=%~2
if "%PORT%"=="" set PORT=0

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0connect-phone.ps1" -IP %IP% -Port %PORT%
