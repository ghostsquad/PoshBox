param(
    [switch]$debug
)
$ErrorActionPreference = "Stop"
Import-Module Pester
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
if($debug){
    try {
        Set-Variable -Name "DebugPreference" -Scope 1 -Value "Continue"
    }
    catch [Exception] {
        Set-Variable -Name "DebugPreference" -Scope 0 -Value "Continue"
    }
}
#Set-StrictMode -Version "Latest"
Invoke-Pester
