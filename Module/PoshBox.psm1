$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if(-not (Get-Module PSCX -ListAvailable)){
    Write-Error "Powershell Community Extensions is not installed. Please visit http://pscx.codeplex.com/downloads/get/744915"
}

Import-Module PSCX -Global

$global:PoshBoxModuleRoot = $PSScriptRoot

$null = Add-Type -Path (Join-Path $PSScriptRoot "PoshBox.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "Logging/log4net.2.0.3/log4net.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "Sql/mysql.data.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "CredentialManagement/CredentialManagement.dll")

#Import-Module $here\Indented\Indented.Common\Indented.Common.psd1 -Global
#Import-Module $here\Indented\Indented.Dns\Indented.Dns.psd1 -Global
#Import-Module $here\Indented\Indented.NetworkTools\Indented.NetworkTools.psd1 -Global

$global:PoshBoxSettings = New-Object PSObject -Property @{
    AWSAccessKey              = ""
    AWSSecretKey              = ""
    Version                   = "0.1 alpha"
}

[log4net.LogManager]::ResetConfiguration();

function GetFullExceptionDetails ($exception) {
    return (Out-String -InputObject (Format-List -InputObject (Select-Object -InputObject $exception -Property *))).Trim()
}

# setup root logger with console appender
. $here\Logging\Add-FileLogAppender.ps1
. $here\Logging\AddConsoleLogAppender.ps1

AddConsoleLogAppender

# there's a bit of a dependency tree, so let's load some of the lower level functions first
. $here\PSUsing.ps1
. $here\New-GenericObject.ps1
. $here\New-PSObject.ps1
. $here\Assert-ScriptBlockParametersEqual.ps1
. $here\Get-ScriptBlockParams.ps1

. $here\Add-TypeAccelerator.ps1
. $here\ConvertTo-Hash.ps1
. $here\Get-Delegate.ps1
. $here\Get-DelegateType.ps1
. $here\Invoke-Generic.ps1

. $here\PSObject.Easy\Attach-PSNote.ps1
. $here\PSObject.Easy\Attach-PSProperty.ps1
. $here\PSObject.Easy\Attach-PSScriptMethod.ps1
. $here\PSObject.Easy\PSCustomObjectExtensions.ps1
. $here\New-PSClass.ps1

# Misc
. $here\New-PSCredential.ps1

# Logging
. $here\Logging\Get-Logger.ps1
. $here\Logging\Log-Debug.ps1
. $here\Logging\Log-Info.ps1
. $here\Logging\Log-Warning.ps1
. $here\Logging\Log-Error.ps1
. $here\Logging\Log-Fatal.ps1

# CredentialManagement
. $here\CredentialManagement\Get-ManagedCredential.ps1
. $here\CredentialManagement\Set-ManagedCredential.ps1
. $here\CredentialManagement\Remove-ManagedCredential.ps1

# Sql
. $here\Sql\Execute-MySqlQuery.ps1
. $here\Sql\Execute-MySqlNonQuery.ps1
. $here\Sql\Execute-SqlQuery.ps1
. $here\Sql\Execute-SqlNonQuery.ps1

# Ui - Note: This is kind of broken?
. $here\Ui\New-ConsoleTable.ps1

# Development Helpers
. $here\Development\Fix-SourceFiles.ps1
. $here\Development\Remove-ExcessWhitespace.ps1
. $here\Development\Replace-TabsWithSpaces.ps1
. $here\Development\Set-EncodingUtf8NoBom.ps1

Export-ModuleMember -Function *-*
Export-ModuleMember -Function PSUsing
