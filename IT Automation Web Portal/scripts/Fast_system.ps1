# Run as Administrator
Write-Host "Starting Windows Optimization Script..." -ForegroundColor Cyan

# 1. Disable Unused Services
$servicesToDisable = @(
    "Fax",
    "XblGameSave",
    "XboxGipSvc",
    "WMPNetworkSvc",
    # "PrintSpooler"   # Remove comment only if printers are not used
)

foreach ($svc in $servicesToDisable) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -ne 'Stopped') {
            Stop-Service $svc -Force -ErrorAction SilentlyContinue
        }
        Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Disabled service: $svc"
    }
}

# 2. Clean Temp & Prefetch
$pathsToClean = @(
    "$env:TEMP",
    "$env:WINDIR\Temp",
    "$env:SystemRoot\Prefetch",
    "$env:USERPROFILE\AppData\Local\Temp"
)

foreach ($path in $pathsToClean) {
    if (Test-Path $path) {
        Write-Host "Cleaning: $path"
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# 3. Windows Update (Optional - slow)
try {
    Write-Host "Checking for Windows Updates..."
    Install-Module PSWindowsUpdate -Force -Confirm:$false
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot
}
catch {
    Write-Host "Windows Update module skipped or failed."
}

# 4. Disk Cleanup (silent)
Write-Host "Running Cleanmgr..."
cleanmgr /sagerun:1

# 5. Disable Startup Apps
$startupApps = @("OneDrive", "Teams")
foreach ($app in $startupApps) {
    Write-Host "Disabling startup app: $app"
    Get-CimInstance Win32_StartupCommand |
    Where-Object { $_.Name -like "*$app*" } |
    ForEach-Object {
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
        -Name $_.Name -ErrorAction SilentlyContinue
    }
}

# 6. Optimize Boot Settings
bcdedit /set {current} quietboot on
bcdedit /timeout 5

Write-Host "`nSystem optimization complete. Please reboot if required." -ForegroundColor Green
