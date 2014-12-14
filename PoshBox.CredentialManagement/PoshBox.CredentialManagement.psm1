$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if((Get-Module PoshBox.Core -ListAvailable) -and -not (Get-Module PoshBox.Core)){
    Import-Module PoshBox.Core -Global
} else {
    Throw (New-Object System.InvalidOperationException("Dependency PoshBox.Core Module not found."))
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

[Void](Add-Type -Path $here\CredentialManagement.dll)

. $here\Get-ManagedCredential.ps1
. $here\Remove-ManagedCredential.ps1
. $here\Set-ManagedCredential.ps1

Export-ModuleMember -Function *-*