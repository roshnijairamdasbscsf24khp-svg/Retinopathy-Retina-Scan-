# RetinaScan Diagnostic Workstation - PowerShell Launcher
$ErrorActionPreference = "Stop"
$Workspace = $PSScriptRoot
Set-Location $Workspace

$env:RETINOPATHY_WORKSPACE = $Workspace
$VenvPython = Join-Path $Workspace ".venv\Scripts\python.exe"

if (-not (Test-Path $VenvPython)) {
    Write-Host "[ERROR] Virtual environment not found at: $VenvPython" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# Check if port 8000 is occupied
$portInUse = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
if ($portInUse) {
    $pidToKill = $portInUse[0].OwningProcess
    Write-Host "[NOTICE] Port 8000 is occupied by process PID: $pidToKill" -ForegroundColor Yellow
    
    # Check if healthy
    try {
        $resp = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/health" -TimeoutSec 2
        if ($resp.status -eq "online") {
            Write-Host "[INFO] RetinaScan is ALREADY running and online on http://127.0.0.1:8000/" -ForegroundColor Green
            Start-Process "http://127.0.0.1:8000/"
            $ans = Read-Host "Server is running. Restart it? [y/N]"
            if ($ans -eq "y" -or $ans -eq "Y") {
                Stop-Process -Id $pidToKill -Force
                Start-Sleep -Seconds 1
            } else {
                exit 0
            }
        }
    } catch {
        $ans = Read-Host "Terminate blocking process PID $pidToKill and continue? [Y/n]"
        if ($ans -ne "n" -and $ans -ne "N") {
            Stop-Process -Id $pidToKill -Force
            Start-Sleep -Seconds 1
        } else {
            exit 1
        }
    }
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  RetinaScan: Explainable AI Diabetic Retinopathy Workstation" -ForegroundColor Cyan
Write-Host "  Server URL: http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching web browser..." -ForegroundColor Gray

# Open browser in background after 3 seconds
Start-Job -ScriptBlock { Start-Sleep -Seconds 3; Start-Process "http://127.0.0.1:8000/" } | Out-Null

# Run Uvicorn directly
& $VenvPython -m uvicorn backend.app:app --host 127.0.0.1 --port 8000
