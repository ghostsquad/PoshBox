$ErrorActionPreference = "Stop"
Import-Module Pester
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)
Invoke-Pester