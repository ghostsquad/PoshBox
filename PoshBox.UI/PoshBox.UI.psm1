$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if(-not (Get-Module PoshBox.Core)){
    Import-Module ..\PoshBox.Core -Global
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\New-ConsoleTable.ps1

Export-ModuleMember -Function *-*