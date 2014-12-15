$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if(-not (Get-Module PoshBox.Core)){
    Import-Module ..\PoshBox.Core -Global
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\Fix-SourceFiles.ps1
. $here\Remove-ExcessWhitespace.ps1
. $here\Replace-TabsWithSpaces.ps1
. $here\Set-EncodingUtf8NoBom.ps1

Export-ModuleMember -Function *-*