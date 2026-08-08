# ==============================================================================
# Phase 4: Formatting Helper Function
# ==============================================================================
function Write-Header ($title) {
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

# ==============================================================================
# Phase 1 & 2: Querying Memory (CIM Class: Win32_OperatingSystem)
# ==============================================================================
function Get-MemoryStats {
    Write-Header "1. MEMORY UTILIZATION"
    
    # Query the OS CIM object
    $os = Get-CimInstance Win32_OperatingSystem
    
    # Phase 3: Unit Conversions & Math (Windows reports memory in KB)
    $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 2)
    $freeMB  = [math]::Round($os.FreePhysicalMemory / 1KB, 2)
    $usedMB  = [math]::Round($totalMB - $freeMB, 2)
    
    $usedPct = [math]::Round(($usedMB / $totalMB) * 100, 2)
    $freePct = [math]::Round(($freeMB / $totalMB) * 100, 2)
    
    # Output formatted string
    Write-Host ("Total Memory : {0} MB" -f $totalMB)
    Write-Host ("Used Memory  : {0} MB ({1}%)" -f $usedMB, $usedPct)
    Write-Host ("Free Memory  : {0} MB ({1}%)" -f $freeMB, $freePct)
}

# ==============================================================================
# Phase 1 & 2: Querying CPU (CIM Class: Win32_Processor)
# ==============================================================================
function Get-CpuStats {
    Write-Header "2. CPU UTILIZATION"
    
    # Query CPU load percentage
    $cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    Write-Host ("Total CPU Usage: {0:N2}%" -f $cpuLoad)
}

# ==============================================================================
# Phase 1 & 2: Querying Processes (Cmdlet: Get-Process)
# ==============================================================================
function Get-TopProcesses {
    Write-Header "3. TOP 5 PROCESSES BY CPU"
    
    # Pipeline: Get All Processes -> Sort Descending by CPU -> Select Top 5 -> Create Custom Columns
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 `
        @{N='Process Name'; E={$_.Name}}, `
        @{N='PID';          E={$_.Id}}, `
        @{N='CPU Time (s)'; E={[math]::Round($_.CPU, 2)}}, `
        @{N='RAM (MB)';     E={[math]::Round($_.WorkingSet64 / 1MB, 2)}} | Format-Table -AutoSize

    Write-Header "4. TOP 5 PROCESSES BY MEMORY USAGE"
    
    Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 `
        @{N='Process Name'; E={$_.Name}}, `
        @{N='PID';          E={$_.Id}}, `
        @{N='RAM (MB)';     E={[math]::Round($_.WorkingSet64 / 1MB, 2)}}, `
        @{N='CPU Time (s)'; E={[math]::Round($_.CPU, 2)}} | Format-Table -AutoSize
}

# ==============================================================================
# Main Execution Pipeline
# ==============================================================================
Clear-Host
Write-Header "SYSTEM PERFORMANCE REPORT (WINDOWS)"
Get-MemoryStats
Write-Host ""
Get-CpuStats
Write-Host ""
Get-TopProcesses