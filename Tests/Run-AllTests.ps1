param (
    [switch]$Debug,
    [switch]$CurrentContext = $false
)
$ErrorActionPreference = "Stop"
if($Debug){
    $DebugPreference = "Continue"
}

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)

if($currentContext) {
    Import-Module Pester
    Invoke-Pester -Path $here
} else {
    $cmd = 'Set-Location ''{0}''; Import-Module Pester; Invoke-Pester -EnableExit;' -f $here
    powershell.exe -noprofile -command $cmd
}