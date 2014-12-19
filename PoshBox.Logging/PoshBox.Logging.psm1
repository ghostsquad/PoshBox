$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if(-not (Get-Module PoshBox.Core)){
    Import-Module "$here\..\PoshBox.Core" -Global -DisableNameChecking
}

[Void](Add-Type -Path $here\log4net.dll)

. $here\AddConsoleLogAppender.ps1
. $here\Add-FileLogAppender.ps1
. $here\Get-Logger.ps1
. $here\Log-Debug.ps1
. $here\Log-Error.ps1
. $here\Log-Fatal.ps1
. $here\Log-Info.ps1
. $here\Log-Warning.ps1

[log4net.LogManager]::ResetConfiguration();

AddConsoleLogAppender

Export-ModuleMember -Function *-*