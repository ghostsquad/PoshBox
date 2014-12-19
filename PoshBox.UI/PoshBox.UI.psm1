$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if(-not (Get-Module PoshBox.Core)){
    Import-Module "$here\..\PoshBox.Core" -Global -DisableNameChecking
}

. $here\New-ConsoleTable.ps1

Export-ModuleMember -Function *-*