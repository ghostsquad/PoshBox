$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if(-not (Get-Module PoshBox.Core)){
    Import-Module ..\PoshBox.Core -Global
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

[Void](Add-Type -Path $here\CredentialManagement.dll)

. $here\Get-ManagedCredential.ps1
. $here\Remove-ManagedCredential.ps1
. $here\Set-ManagedCredential.ps1

Export-ModuleMember -Function *-*