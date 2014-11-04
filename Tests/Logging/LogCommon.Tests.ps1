$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\TestCommon.ps1"

Describe "LogCommon" {
    Context "GetDefaultLogThreshold" {
        It "uses debug preference if set" {
            $script:VerbosePreference = "SilentlyContinue"
            $script:DebugPreference = "Continue"
            $log = Get-Logger ([Guid]::NewGuid())
            $log.Logger.IsEnabledFor([log4net.Core.Level]::Debug) | Should Be $true
        }

        It "uses verbose preference if set" {
            $script:VerbosePreference = "Continue"
            $script:DebugPreference = "SilentlyContinue"
            $log = Get-Logger ([Guid]::NewGuid())
            $log.Logger.IsEnabledFor([log4net.Core.Level]::Debug) | Should Be $true
        }

        It "log level info used if verbose & debug preference at silentlycontinue" {
            $script:VerbosePreference = "SilentlyContinue"
            $script:DebugPreference = "SilentlyContinue"
            $log = Get-Logger ([Guid]::NewGuid())
            $log.Logger.IsEnabledFor([log4net.Core.Level]::Debug) | Should Be $false
            $log.Logger.IsEnabledFor([log4net.Core.Level]::Info) | Should Be $true
        }
    }
}