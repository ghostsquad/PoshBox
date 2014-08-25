$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if(-not (Get-Module PSCX -ListAvailable)){
    Write-Error "Powershell Community Extensions is not installed. Please visit http://pscx.codeplex.com/downloads/get/744915"
}

Import-Module PSCX -Global

$global:PoshBoxModuleRoot = $PSScriptRoot

$null = Add-Type -Path (Join-Path $PSScriptRoot "PoshBox.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "logging/log4net.2.0.3/log4net.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "sql/mysql.data.dll")

Import-Module $here\Indented\Indented.Common\Indented.Common.psd1 -Global
Import-Module $here\Indented\Indented.Dns\Indented.Dns.psd1 -Global
Import-Module $here\Indented\Indented.NetworkTools\Indented.NetworkTools.psd1 -Global

$global:PoshBoxSettings = New-Object PSObject -Property @{
    AWSAccessKey              = ""
    AWSSecretKey              = ""
    Version                   = "0.1 alpha"
}

# setup root logger with console appender
[log4net.LogManager]::ResetConfiguration();

. $here\Logging\Add-FileLogAppender.ps1

AddConsoleLogAppender

. $here\PSUsing.ps1
. $here\Extensions\PSCustomObjectExtensions.ps1

Export-ModuleMember -Function PSUSing

# Logging
. $here\Logging\Get-Logger.ps1
. $here\Logging\Log-Debug.ps1
. $here\Logging\Log-Info.ps1
. $here\Logging\Log-Warning.ps1
. $here\Logging\Log-Error.ps1
. $here\Logging\Log-Fatal.ps1

. $here\Get-Delegate.ps1
. $here\ConvertTo-Hash.ps1

. $here\Invoke-Generic.ps1
. $here\New-PSCredential.ps1
. $here\New-Interface.ps1

. $here\Sql\Execute-MySqlQuery.ps1
. $here\Sql\Execute-MySqlNonQuery.ps1
. $here\Sql\Execute-SqlQuery.ps1
. $here\Sql\Execute-SqlNonQuery.ps1

. $here\Ui\New-ConsoleTable.ps1

. $here\Development\Fix-SourceFiles.ps1
. $here\Development\Remove-ExcessWhitespace.ps1
. $here\Development\Replace-TabsWithSpaces.ps1
. $here\Development\Set-EncodingUtf8NoBom.ps1

Export-ModuleMember -Function *-*
