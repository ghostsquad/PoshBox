$null = Add-Type -Path (Join-Path $PSScriptRoot "logging/log4net.2.0.3/log4net.dll")							
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$global:PoshBoxSettings = New-Object PSObject -Property @{
    AWSAccessKey    		  = ""
	AWSSecretKey			  = ""
	Version					  = "0.1 alpha"
}

# setup root logger with console appender
[log4net.LogManager]::ResetConfiguration();

. $here\Logging\Add-FileLogAppender.ps1

AddConsoleLogAppender

. $here\PSUsing.ps1

Export-ModuleMember -Function PSUSing

# Logging
. $here\Logging\Get-Logger.ps1
. $here\Logging\Log-Debug.ps1
. $here\Logging\Log-Info.ps1
. $here\Logging\Log-Warning.ps1
. $here\Logging\Log-Error.ps1
. $here\Logging\Log-Fatal.ps1

. $here\Get-Delegate.ps1

. $here\Invoke-Generic.ps1
. $here\Get-IniContent.ps1
. $here\Out-IniFile.ps1

Export-ModuleMember -Function *-*