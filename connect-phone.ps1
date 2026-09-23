<#
.SYNOPSIS
    Quick-connect Android phone for Flutter debugging over Wi-Fi (< 10 seconds).
    Created for Nova Mobile / NIVEX Flutter.
.DESCRIPTION
    1. Tries direct connection to port 5555.
    2. If port 5555 is not open, sweeps dynamic ports (35000-45000) or uses provided port.
    3. Promotes session to fixed port 5555 via 'adb tcpip 5555' so future connects are instant.
    4. Verifies with 'flutter devices'.
#>

param(
    [string]$IP = "192.168.1.11",
    [int]$Port = 0
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Nova Mobile - Fast Wireless ADB Connect (< 10s) " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Target IP: $IP" -ForegroundColor Yellow

$adb = "D:\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
    $adbCmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbCmd) { $adb = $adbCmd.Source } else {
        Write-Host "Error: adb.exe not found on PATH or D:\Android\Sdk\platform-tools\adb.exe" -ForegroundColor Red
        exit 1
    }
}

# 1. Try port 5555 first (Default standard ADB port)
Write-Host "Checking if port 5555 is active on $IP..." -ForegroundColor Gray
$connected = $false
try {
    $c = New-Object System.Net.Sockets.TcpClient
    $iar = $c.BeginConnect($IP, 5555, $null, $null)
    if ($iar.AsyncWaitHandle.WaitOne(800)) {
        $c.EndConnect($iar)
        $connected = $true
        $c.Close()
    }
} catch {}

if ($connected) {
    Write-Host "Port 5555 is open! Connecting via ADB..." -ForegroundColor Green
    & $adb connect "$IP`:5555"
} else {
    if ($Port -gt 0) {
        Write-Host "Connecting using specified port $Port..." -ForegroundColor Yellow
        & $adb connect "$IP`:$Port"
        # Pin to port 5555
        & $adb -s "$IP`:$Port" tcpip 5555
        Start-Sleep -Seconds 1
        & $adb connect "$IP`:5555"
    } else {
        Write-Host "Port 5555 not listening. Searching for Android 11+ Dynamic Wireless Debugging port..." -ForegroundColor Yellow
        $foundPort = 0
        
        # Check ports around typical Xiaomi/HyperOS range: 35000-45000
        # Common buckets: 37000-43000
        $buckets = @(37000..43000)
        
        # Test in rapid batches of 50
        $batchSize = 100
        for ($i = 0; $i -lt $buckets.Count; $i += $batchSize) {
            $end = [Math]::Min($i + $batchSize - 1, $buckets.Count - 1)
            $slice = $buckets[$i..$end]
            
            $tasks = foreach ($p in $slice) {
                [PSCustomObject]@{
                    Port = $p
                    Client = (New-Object System.Net.Sockets.TcpClient)
                    IAR = $null
                }
            }
            
            foreach ($t in $tasks) {
                try {
                    $t.IAR = $t.Client.BeginConnect($IP, $t.Port, $null, $null)
                } catch {}
            }
            
            Start-Sleep -Milliseconds 120
            
            foreach ($t in $tasks) {
                if ($t.IAR -and $t.IAR.AsyncWaitHandle.WaitOne(10)) {
                    try {
                        $t.Client.EndConnect($t.IAR)
                        $foundPort = $t.Port
                        $t.Client.Close()
                        break
                    } catch {}
                }
                try { $t.Client.Close() } catch {}
            }
            
            if ($foundPort -gt 0) { break }
        }
        
        if ($foundPort -gt 0) {
            Write-Host "Found active Wireless Debugging port: $foundPort!" -ForegroundColor Green
            & $adb connect "$IP`:$foundPort"
            Write-Host "Promoting connection to standard port 5555 for permanent future use..." -ForegroundColor Cyan
            & $adb -s "$IP`:$foundPort" tcpip 5555
            Start-Sleep -Seconds 1
            & $adb connect "$IP`:5555"
            & $adb disconnect "$IP`:$foundPort" 2>$null
        } else {
            Write-Host "`nCould not auto-detect dynamic port on $IP." -ForegroundColor Red
            Write-Host "Hint: Open Settings -> Developer Options -> Wireless Debugging on your phone." -ForegroundColor Yellow
            Write-Host "Check the port under 'IP address & Port' (e.g. $IP:XXXXX) and run:" -ForegroundColor Yellow
            Write-Host "  .\connect-phone.ps1 $IP <PORT>" -ForegroundColor White
            exit 1
        }
    }
}

Write-Host "`nChecking connected devices in Flutter..." -ForegroundColor Cyan
flutter devices

Write-Host "`nReady! To run app on your phone, execute:" -ForegroundColor Green
Write-Host "  flutter run -d $IP`:5555" -ForegroundColor White
