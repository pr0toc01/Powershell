[CmdletBinding()]
Param (
    [parameter(Mandatory=$true)] [string] $Purpose,
    
    [parameter(Mandatory=$false)] [int] $years=0,
    [parameter(Mandatory=$false)] [int] $months=0,
    [parameter(Mandatory=$false)] [int] $days=0,

    [parameter(Mandatory=$true)] [string[]] $Path
)

Register-EngineEvent PowerShell.Exiting –Action { Stop-Transcript }

$LogPath = $PSScriptRoot + '\Logs'

if (-not(Test-Path -Path $LogPah)) {
    ### Create log directory
    New-Item -Path LogPath -ItemType "directory"
}

### Create Log
$fileDate = get-date -Format "yyyy-MM-dd"
$LogFile = $logPath+'\'+$fileDate+' Purge Log '+$purpose+'.txt'

Start-Transcript -path $LogFile


### Ensure a time offset is entered.
if (($years -eq 0) -and ($months -eq 0) -and ($days -eq 0)) {
    throw "No time offset entered. Aborting Execution"
}

$Locations = @()

### Ensure the location(s) provided are valid
foreach ($loc in $Path) {
    if (Test-Path -Path $loc) {
        $Locations += $loc
    }
    else {
        write-warning "Provided Path [ $loc ] is NOT valid"
    }
}

$Locations += $LogPath

$CurrentTime = (Get-Date)

$Edge = Get-Date -Year ($CurrentTime.Year - $Years) -Month ($CurrentTime.Month - $Months) -Day ($CurrentTime.Day - $Days) -Hour 0 -Minute 0 -Second 0

foreach ($directory in $Locations) {
    Write-Host "CURRENT TARGET DIRECTORY: $directory"
    Get-ChildItem $directory -Attributes !Directory -recurse | Where-Object { $_.CreationTime -lt $Edge } | Remove-Item -Verbose
}

Stop-Transcript