@echo off
setlocal enabledelayedexpansion
set "PORT_PID="

for /f "tokens=5" %%a in ('netstat -a -n -o ^| findstr ":8000" ^| findstr "LISTENING"') do (
    set "PORT_PID=%%a"
)

echo Result PID: !PORT_PID!
