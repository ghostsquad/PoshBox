$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ErrorActionPreference = "Continue"
$DebugPreference = "Continue"
#Set-StrictMode -Version Latest
$modulePathRelative = (Join-Path $here "..\Poshbox.psm1")
$modulePathAbsolute = [System.IO.Path]::GetFullPath($modulePathRelative);
Remove-Module $modulePathAbsolute -ErrorAction SilentlyContinue
Import-Module $modulePathAbsolute -Force -DisableNameChecking
