$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ModuleName = [System.IO.Path]::GetFileName((Split-Path $MyInvocation.ScriptName -Parent)) -Replace '.Test',''
$private:modulePathRelative = (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "$ModuleName\$ModuleName.psd1")
$private:modulePathAbsolute = [System.IO.Path]::GetFullPath($modulePathRelative);
Import-Module $private:modulePathAbsolute -Force -DisableNameChecking