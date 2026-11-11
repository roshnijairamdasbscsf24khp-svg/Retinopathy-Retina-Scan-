@echo off
setlocal enabledelayedexpansion
title Stop RetinaScan Server

echo ====================================================================
echo   Stopping RetinaScan Workstation Server...
echo ====================================================================
echo.

set "PORT_PID="
for /f "tokens=5" %%a in ('netstat -a -n -o ^| findstr ":8000" ^| findstr "LISTENING"') do (
    set "PORT_PID=%%a"
)

if defined PORT_PID (
    echo [INFO] Found RetinaScan process [PID !PORT_PID!] listening on port 8000.
    echo Stopping process...
    taskkill /F /PID !PORT_PID! >nul 2>&1
    if !errorlevel! equ 0 (
        echo [+] RetinaScan server stopped successfully.
    ) else (
        echo [!] Failed to stop process [PID !PORT_PID!]. You may need administrator rights.
    )
) else (
    echo [+] No active server found listening on port 8000.
)

echo.
echo Closing...
ping 127.0.0.1 -n 3 >nul
