Param(
    [Parameter(Mandatory)]
    [string] $Path,

    [Parameter(Mandatory, ParameterSetName="Years")]
    [int] $Years,

    [Parameter(Mandatory, ParameterSetName="Months")]
    [int] $Months,

    [Parameter(Mandatory, ParameterSetName="Weeks")]
    [int] $Weeks,

    [Parameter(Mandatory, ParameterSetName="Days")]
    [int] $Days,

    [Parameter(Mandatory, ParameterSetName="Hours")]
    [int] $Hours,

    [Parameter(Mandatory, ParameterSetName="Minutes")]
    [int] $Minutes,

    [Parameter(Mandatory, ParameterSetName="Seconds")]
    [int] $Seconds,

    [string] $LogDir='c:\temp\logs',

    [switch] $Recurse,

    [switch] $whatif
)
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$ScriptName = ($MyInvocation.MyCommand) -replace '.ps1',''

$title = ($Path.Split('\'))[-1]

### Check if Log PATH is valid
if (-not (Test-Path -Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-null
}

### Create LOG file
$now = Get-Date
$LogName = ($now.toString("yyyyMMdd_HHmmss"))+'_'+$ScriptName+' '+$title+'.log'

$LogFile = Join-Path $LogDir $LogName

$initialLog  = "Script: $PSCommandPath `n"
$initialLog += "Executing Computer: "+$env:COMPUTERNAME+" `n"
$initialLog += "Executing User: "+$env:USERNAME+" `n"
$initialLog += "Time of execution: $now `n"
$initialLog += "====================================================================`n"
$initialLog += "                            Starting Log`n"
$initialLog += "====================================================================`n"

if (-not (Test-Path $LogFile)) {
    New-Item -Path $LogDir -Name $LogName -ItemType File | Out-Null
    Set-Content -Path $LogFile -Value $initialLog
}

Function Write-Log {
    Param (
        [Parameter(Mandatory, Position=0)]
        [Alias("m")]
        [string]$Message,

        [Parameter(Position=1)]
        [ValidateSet("I","W","E","D")]
        [Alias("t")]
        [string]$Type = "I"
    )

    $LogFile = $SCRIPT:LogFile
    $ts = (Get-Date).ToString("MM/dd/yyyy | HH:mm:ss.fffff")

    Switch ($Type) {
        'I' { $mType = 'INFO ' }
        'W' { $mType = 'WARN ' }
        'E' { $mType = 'ERROR' }
        'D' { $mType = 'DEBUG' }
    }

    $logMessage = $ts+' | '+$mType+' | '+$Message

    Add-Content -Path $LogFile -Value $logMessage    
}

$valid = $false  ### Safegaurd
$pSet = $PSCmdlet.ParameterSetName
#$now = Get-Date
$boundry = $false

Switch ($pSet) {
    "Years" {
        $qty = $Years
        $boundry = $now.AddYears($Years*-1)
    }

    "Months" {
        $qty = $Months
        $boundry = $now.AddMonths($Months*-1)
    }

    "Weeks" {
        $qty = $Weeks
        $boundry = $now.AddDays((7*$Weeks)*-1)
    }

    "Days" {
        $qty = $Days
        $boundry = $now.AddDays($Days*-1)
    }

    "Hours" {
        $qty = $Hours
        $boundry = $now.AddHours($Hours*-1)
    }

    "Minutes" {
        $qty = $Minutes
        $boundry = $now.AddMinutes($Minutes*-1)
    }

    "Seconds" {
        $qty = $Seconds
        $boundry = $now.AddSeconds($Seconds*-1)
    }

    default { 
        ### This should never happen. HOWEVER since this function is meant to delete files we want to fail SAFE
        throw {
            "Conditions out of bouns. ParameterSet selected did not match any of the expected values"
        }
    }
}

Write-Log "Removing all files older than: $qty $pset"
Write-Log "File Deletion Boundry: $boundry"

Write-Log "Selected Directory: $Path"

### Is selected Directory Valid?
if (Test-Path -Path $Path) {
    $Valid = $true
    Write-Log "Directory Valid: True"
}
else {
    ### Directory is NOT valid, Log error and terminate execution
    Write-Log "Directory Valid: False" -Type E
    Write-Log "Directory selected is invalid, Execution Terminated" -Type E
    exit
}

if ($Recurse) {
    $FilesToDelete = Get-ChildItem -Path $Path -Recurse | Sort-Object -Property CreationTime | Where-Object {$_.CreationTime -lt $boundry}
    Write-Log "Recurse is set to TRUE"
}
else {
    $FilesToDelete = Get-ChildItem -Path $Path | Sort-Object -Property CreationTime | Where-Object {$_.CreationTime -lt $boundry}
    Write-Log "Recurse is set to FALSE"
}

$numFiles = $FilesToDelete.count

Write-Log "There are $NumFiles objects that will be effected"

if ($Valid) {

    Write-Log "------------------- BEGINING OPERATION -------------------------"

    $FilesToDelete | ForEach-Object {
        $removalError = $false
        $thisFile = $_
        if ($whatif) {
            Write-Log "WHAT-IF - File would be deleted : $($ThisFile.fullname)"
        }
        else {
            Remove-Item $thisFile.FullName -ErrorVariable removalError

            if ($removalError) {
                Write-Log "Unable to delete : $($ThisFile.fullname)" -Type W
            }
            else {
                Write-Log "Deleted : $($ThisFile.fullname)"
            }
        }
    }
}
else { ### THIS SHOULD NEVER EXECUTE. Invalid directory should cause script to exit, but just in case
    Write-Log "Targeted Directory is INVALID. Script should have aborted before now but reached the DELETE stage anyway. No action taken" -Type E
}

$stopwatch.stop()
$time = $stopwatch.Elapsed
Write-Log "Execution completed in $time"