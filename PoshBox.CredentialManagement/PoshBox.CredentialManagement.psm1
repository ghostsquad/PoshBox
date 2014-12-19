$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if(-not (Get-Module PoshBox.Core)){
    Import-Module "$here\..\PoshBox.Core" -Global -DisableNameChecking
}

[Void](Add-Type -Path $here\CredentialManagement.dll)

. $here\Get-ManagedCredential.ps1
. $here\Remove-ManagedCredential.ps1
. $here\Set-ManagedCredential.ps1

Export-ModuleMember -Function *-*