param (
    [switch]$debug
)
$ErrorActionPreference = "Stop"
if($debug){
    $DebugPreference = "Continue"
}

$cmd = 'Set-Location ''{0}''; Import-Module Pester; Invoke-Pester -EnableExit' -f (Split-Path -Parent $MyInvocation.MyCommand.Path)
powershell.exe -noprofile -command $cmd
