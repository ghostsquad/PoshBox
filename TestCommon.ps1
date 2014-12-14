$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$global:modulePathRelative = (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "..\Module\Poshbox.psd1")
$global:modulePathAbsolute = [System.IO.Path]::GetFullPath($modulePathRelative);
Remove-Module $global:modulePathAbsolute -ErrorAction Ignore
Import-Module $global:modulePathAbsolute -Force -DisableNameChecking
