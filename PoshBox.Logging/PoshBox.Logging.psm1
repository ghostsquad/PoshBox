$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if((Get-Module PoshBox.Core -ListAvailable) -and -not (Get-Module PoshBox.Core)){
    Import-Module PoshBox.Core -Global
} else {
    Throw (New-Object System.InvalidOperationException("Dependency PoshBox.Core Module not found."))
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

[Void](Add-Type -Path $here\log4net.dll)

. $here\AddConsoleLogAppender.ps1
. $here\Add-FileLogAppender.ps1
. $here\Get-Logger.ps1
. $here\Log-Debug.ps1
. $here\Log-Error.ps1
. $here\Log-Fatal.ps1
. $here\Log-Info.ps1
. $here\Log-Warning.ps1

Export-ModuleMember -Function *-*