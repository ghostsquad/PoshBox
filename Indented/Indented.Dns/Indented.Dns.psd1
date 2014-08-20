#
# Module manifest for module 'Indented.Dns'
#
# Generated by: Chris Dent
#
# Generated on: 28/04/2014
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Indented.Dns'

# Version number of this module.
ModuleVersion = '2.11'

# ID used to uniquely identify this module
GUID = '0ac52236-57c0-43d9-84e1-c39f1f2dc864'

# Author of this module
Author = 'Chris Dent'

# Company or vendor of this module
CompanyName = 'Chris Dent'

# Copyright statement for this module
Copyright = '(c) 2013 Chris Dent. All rights reserved.'

# Description of the functionality provided by this module
Description = 'DNS debugging and Microsoft DNS management tools.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('Indented.Common')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'Indented.Dns.Format.ps1xml'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = '*-*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = 'Indented.Dns.psd1', 'Indented.Dns.psm1', 
               'Indented.Dns.Format.ps1xml', 'Enum.ps1', 'ADCmdLets.ps1', 
               'ADResourceRecord.ps1', 'Message.ps1', 'MessageCmdLets.ps1', 
               'MessageResourceRecord.ps1', 'Wmi.ps1', 'WmiCmdLets.ps1', 
               'WmiResourceRecord.ps1'

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

