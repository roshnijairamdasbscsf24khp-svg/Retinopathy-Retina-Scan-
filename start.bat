@echo off
setlocal enabledelayedexpansion
title RetinaScan — Diagnostic Workstation

echo ====================================================================
echo   RetinaScan: Explainable AI Retinal Analysis Workstation
echo ====================================================================
echo.

:: 1. Navigate to workspace root
cd /d "%~dp0"
set "RETINOPATHY_WORKSPACE=%CD%"

:: 2. Verify virtual environment
set "VENV_PYTHON=%~dp0.venv\Scripts\python.exe"
if not exist "%VENV_PYTHON%" (
    echo [ERROR] Python virtual environment was not found at:
    echo         %VENV_PYTHON%
    echo.
    echo Please make sure the .venv directory is present in the project folder.
    echo.
    pause
    exit /b 1
)

:: 3. Check if port 8000 is already in use
set "PORT_PID="
for /f "tokens=5" %%a in ('netstat -a -n -o ^| findstr ":8000" ^| findstr "LISTENING"') do (
    set "PORT_PID=%%a"
)

if defined PORT_PID (
    echo [NOTICE] Port 8000 is currently occupied by process [PID !PORT_PID!].
    echo Checking if an existing RetinaScan instance is running...
    
    "%VENV_PYTHON%" -c "import urllib.request; resp=urllib.request.urlopen('http://127.0.0.1:8000/api/health', timeout=2); print('ONLINE' if resp.status==200 else 'UNKNOWN')" 2>nul | findstr "ONLINE" >nul
    if !errorlevel! equ 0 (
        echo [INFO] RetinaScan is ALREADY running and healthy on http://127.0.0.1:8000/
        echo.
        echo Opening workstation in your web browser...
        start http://127.0.0.1:8000/
        echo.
        set /p "USER_CHOICE=Do you want to restart the server? [y/N]: "
        if /i "!USER_CHOICE!"=="y" (
            echo Terminating previous instance [PID !PORT_PID!]...
            taskkill /F /PID !PORT_PID! >nul 2>&1
            ping 127.0.0.1 -n 2 >nul
        ) else (
            echo Existing server kept active.
            exit /b 0
        )
    ) else (
        echo [WARNING] Port 8000 is blocked by an unresponsive process [PID !PORT_PID!].
        echo Terminating blocking process to allow fresh startup...
        taskkill /F /PID !PORT_PID! >nul 2>&1
        ping 127.0.0.1 -n 2 >nul
    )
)

echo.
echo [1/3] Virtual environment: Verified
echo [2/3] Network port 8000: Ready
echo [3/3] Starting RetinaScan server on http://127.0.0.1:8000 ...
echo.
echo The application will open in your default browser momentarily.
echo To stop the server at any time, press [Ctrl+C] in this terminal.
echo ====================================================================
echo.

:: Automatically open browser after 3 seconds in background
start "" /b cmd /c "ping 127.0.0.1 -n 4 >nul && start http://127.0.0.1:8000/"

:: Start Uvicorn directly with project virtual environment
"%VENV_PYTHON%" -m uvicorn backend.app:app --host 127.0.0.1 --port 8000

:: If server stops, preserve terminal output so errors are readable
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ====================================================================
echo   RetinaScan server has stopped [Exit code: %EXIT_CODE%].
echo   Review any log messages above.
echo ====================================================================
echo.
pause
