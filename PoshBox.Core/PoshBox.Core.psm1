$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if(-not (Get-Module PSCX -ListAvailable)){
    Throw (New-Object System.InvalidOperationException("Powershell Community Extensions is not installed. Please visit http://pscx.codeplex.com/downloads/get/744915"))
} elseif(-not (Get-Module PSCX )) {
    Import-Module PSCX -Global
}

# Commands Provided By PSCX
# ---------------
# Add-DirectoryLength
# Add-PathVariable
# Add-ShortPath
# Clear-MSMQueue
# ConvertFrom-Base64
# ConvertTo-Base64
# ConvertTo-MacOs9LineEnding
# ConvertTo-Metric
# ConvertTo-UnixLineEnding
# ConvertTo-WindowsLineEnding
# Convert-Xml
# Disconnect-TerminalSession
# Dismount-VHD
# Edit-File
# Edit-HostProfile
# Edit-Profile
# Enable-OpenPowerShellHere
# Expand-Archive
# Export-Bitmap
# Format-Byte
# Format-Hex
# Format-Xml
# Get-ADObject
# Get-AdoConnection
# Get-AdoDataProvider
# Get-Clipboard
# Get-DhcpServer
# Get-DomainController
# Get-DriveInfo
# Get-EnvironmentBlock
# Get-ExecutionTime
# Get-FileTail
# Get-FileVersionInfo
# Get-ForegroundWindow
# Get-Hash
# Get-HttpResource
# Get-LoremIpsum
# Get-MountPoint
# Get-MSMQueue
# Get-OpticalDriveInfo
# Get-Parameter
# Get-PathVariable
# Get-PEHeader
# Get-Privilege
# Get-PSSnapinHelp
# Get-ReparsePoint
# Get-RunningObject
# Get-ScreenCss
# Get-ScreenHtml
# Get-ShortPath
# Get-TerminalSession
# Get-TypeName
# Get-Uptime
# Get-ViewDefinition
# help
# Import-Bitmap
# Import-VisualStudioVars
# Invoke-AdoCommand
# Invoke-Apartment
# Invoke-BatchFile
# Invoke-Elevated
# Invoke-GC
# Invoke-Method
# Invoke-NullCoalescing
# Invoke-Ternary
# Join-String
# less
# Mount-VHD
# New-Hardlink
# New-HashObject
# New-Junction
# New-MSMQueue
# New-Shortcut
# New-Symlink
# Out-Clipboard
# Out-Speech
# Ping-Host
# Pop-EnvironmentBlock
# Push-EnvironmentBlock
# QuoteList
# QuoteString
# Read-Archive
# Receive-MSMQueue
# Remove-MountPoint
# Remove-ReparsePoint
# Resize-Bitmap
# Resolve-ErrorRecord
# Resolve-Host
# Resolve-HResult
# Resolve-WindowsError
# Send-MSMQueue
# Send-SmtpMail
# Set-BitmapSize
# Set-Clipboard
# Set-FileTime
# Set-ForegroundWindow
# Set-LocationEx
# Set-PathVariable
# Set-Privilege
# Set-ReadOnly
# Set-VolumeLabel
# Set-Writable
# Show-Tree
# Skip-Object
# Split-String
# Start-PowerShell
# Stop-RemoteProcess
# Stop-TerminalSession
# Test-AlternateDataStream
# Test-Assembly
# Test-MSMQueue
# Test-Script
# Test-UserGroupMembership
# Test-Xml
# Write-BZip2
# Write-Clipboard
# Write-GZip
# Write-Tar
# Write-Zip

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. $here\Add-TypeAccelerator.ps1
. $here\Assert-ScriptBlockParametersEqual.ps1
. $here\Attach-PSNote.ps1
. $here\Attach-PSProperty.ps1
. $here\Attach-PSScriptMethod.ps1
. $here\ConvertTo-HashTable.ps1
. $here\Create-DirectoryIfNotExists.ps1
. $here\Get-Delegate.ps1
. $here\Get-DelegateType.ps1
. $here\Guard-ArgumentNotNull.ps1
. $here\Guard-ArgumentNotNullOrEmpty.ps1
. $here\Guard-ArgumentValid.ps1
. $here\Invoke-Generic.ps1
. $here\Invoke-Using.ps1
. $here\New-Closure.ps1
. $here\New-DynamicModuleBuilder.ps1
. $here\New-Enum.ps1
. $here\New-GenericObject.ps1
. $here\New-PSCredential.ps1
. $here\New-PSObject.ps1
. $here\PSCustomObjectExtensions.ps1

Export-ModuleMember -Function *-*