<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  New-BinaryReader               .NET: Extended classes    Public                16/08/2013
  New-DynamicModuleBuilder       .NET: Type builders       Public                17/08/2013
  New-Enum                       .NET: Type builders       Public                17/08/2013
  NewIndentedAutoUpdateHash      Module management         Private               07/04/2014
  Get-IndentedModule             Module management         Public                21/01/2014
  Install-IndentedModule         Module management         Public                07/04/2014
  Get-IndentedAutoUpdate         Module management         Public                07/04/2014
  Set-IndentedAutoUpdate         Module management         Public                07/04/2014
  Start-IndentedAutoUpdate       Module management         Public                15/04/2014
  New-Socket                     Socket handling           Public                25/11/2010
  Connect-Socket                 Socket handling           Public                06/01/2014
  Disconnect-Socket              Socket handling           Public                06/01/2014
  Remove-Socket                  Socket handling           Public                25/11/2010
  Receive-Bytes                  Socket handling           Public                25/11/2010
  Send-Bytes                     Socket handling           Public                25/11/2010
  Get-LdapObject                 S.DS.P                    Public                04/10/2013
  Get-WmiClass                   WMI                       Public                01/11/2013
  Get-WmiPath                    WMI                       Public                01/11/2013
  Compare-Array                  Utility                   Public                02/04/2014
  ConvertTo-Byte                 Utility                   Public                25/11/2010
  ConvertTo-String               Utility                   Public                25/11/2010
  ConvertTo-TimeSpanString       Utility                   Public                15/10/2013
  Get-DnsServerList              Utility                   Public                04/09/2012
  Get-DotNetVersion              Utility                   Public                02/04/2014
  Get-Hash                       Utility                   Public                22/04/2014
  Get-WebContent                 Utility                   Public                08/05/2013
  New-Password                   Utility                   Public                24/10/2010
  Test-AdminRoleHolder           Utility                   Public                25/11/2010
  Test-IsLocalhost               Utility                   Public                17/04/2014
#>

##############################################################################################################################################################
#                                                                 .NET: Required assemblies                                                                  #
##############################################################################################################################################################

Add-Type -Assembly System.DirectoryServices.Protocols

##############################################################################################################################################################
#                                                                   .NET: Extended classes                                                                   #
##############################################################################################################################################################

function New-BinaryReader {
  # .SYNOPSIS
  #   Create a new extended instance of a System.IO.BinaryReader class from a Byte Array.
  # .DESCRIPTION
  #   System.IO.BinaryReader reads all multi-byte values as little endian, to address this the following methods have been added to the object:
  #
  #    * ReadBEUInt16
  #    * ReadBEInt32
  #    * ReadBEUInt32
  #    * ReadBEUInt64
  #
  #   In addition to handling big endian values, the following utility methods have been implemented:
  #
  #    * PeakByte
  #    * ReadIPv4Address
  #    * ReadIPv6Address
  #    * SetPositionMarker
  #
  #  SetPositionMarker populates the PositionMarker property which is associated with the BytesFromMarker property.
  #
  # .PARAMETER ByteArray
  #   The byte array passed to this function is used to create a MemoryStream which is passed to the BinaryReader class.
  # .INPUTS
  #   System.Byte[]
  # .OUTPUTS
  #   System.IO.BinaryReader
  #
  #   The class has been extended as described above.
  # .EXAMPLE
  #   C:\PS>$ByteArray = [Byte[]](1, 2, 3, 4)
  #   C:\PS>$Reader = New-BinaryReader $ByteArray
  #   C:\PS>$Reader.PeakByte()
  #   C:\PS>$Reader.ReadIPv4Address()

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Byte[]]$ByteArray
  )

  $MemoryStream = New-Object IO.MemoryStream(,$ByteArray)
  $BinaryReader = New-Object IO.BinaryReader($MemoryStream)

  # Property: PositionMarker
  $BinaryReader | Add-Member PositionMarker -MemberType NoteProperty -Value 0
  # Property: BytesFromPositionMarker
  $BinaryReader | Add-Member BytesFromMarker -MemberType ScriptProperty -Value {
    $this.BaseStream.Position - $this.PositionMarker
  }
  
  # Method: SetPositionMarket - Set a position marker to allow simple progress tracking
  $BinaryReader | Add-Member SetPositionMarker -MemberType ScriptMethod -Value {
    $this.PositionMarker = $this.BaseStream.Position
  }
  # Method: PeekByte - Allows viewing the next byte, resetting the stream position afterwards
  $BinaryReader | Add-Member PeekByte -MemberType ScriptMethod -Value {
    if ($this.BaseStream.Capacity -ge ($this.BaseStream.Position + 1)) {
      [Byte]$Value = $this.PsBase.ReadByte()
      $this.BaseStream.Seek(-1, [IO.SeekOrigin]::Current) | Out-Null
      $Value
    }
  }
  # Method: ReadBEUInt16 - Read big endian UInt16 values
  $BinaryReader | Add-Member ReadBEUInt16 -MemberType ScriptMethod -Value {
    $Bytes = $this.ReadBytes(2)
    [Array]::Reverse($Bytes)
    [BitConverter]::ToUInt16($Bytes, 0)
  }
  # Method: ReadBEInt32 - Read big endian Int32 values
  $BinaryReader | Add-Member ReadBEInt32 -MemberType ScriptMethod -Value {
    $Bytes = $this.ReadBytes(4)
    [Array]::Reverse($Bytes)
    [BitConverter]::ToInt32($Bytes, 0)
  }
  # Method: ReadBEInt32 - Read big endian UInt32 values
  $BinaryReader | Add-Member ReadBEUInt32 -MemberType ScriptMethod -Value {
    $Bytes = $this.ReadBytes(4)
    [Array]::Reverse($Bytes)
    [BitConverter]::ToUInt32($Bytes, 0)
  }
  # Method: ReadBEInt48 - Read big endian UInt48 values (returns as UInt64)
  $BinaryReader | Add-Member ReadBEUInt48 -MemberType ScriptMethod -Value {
    $Bytes = $this.ReadBytes(6)
    $Length = $Bytes.Length
    [UInt64]$Value = 0
    for ($i = 0; $i -lt $Length; $i++) {
      $Value = $Value -bor ([UInt64]$Bytes[$i] -shl (8 * ($Length - $i - 1)))
    }
    $Value
  }
  # Method: ReadBEInt64 - Read big endian UInt64 values
  $BinaryReader | Add-Member ReadBEUInt64 -MemberType ScriptMethod -Value {
    $Bytes = $this.ReadBytes(8)
    [Array]::Reverse($Bytes)
    [BitConverter]::ToUInt64($Bytes, 0)
  }
  # Method: ReadIPv4Address - Read 4 bytes as an IPv4 address
  $BinaryReader | Add-Member ReadIPv4Address -MemberType ScriptMethod -Value {
    [IPAddress]([String]::Format("{0}.{1}.{2}.{3}",
      $this.ReadByte(),
      $this.ReadByte(),
      $this.ReadByte(),
      $this.ReadByte())
    )
  }
  # Method: ReadIPv6Address - Read 16 bytes as an IPv6 address
  $BinaryReader | Add-Member ReadIPv6Address -MemberType ScriptMethod -Value {
    [IPAddress]([String]::Format("{0:X}:{1:X}:{2:X}:{3:X}:{4:X}:{5:X}:{6:X}:{7:X}",
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16(),
      $this.ReadBEUInt16())
    )
  }
  
  return $BinaryReader
}

##############################################################################################################################################################
#                                                                    .NET: Type builders                                                                     #
##############################################################################################################################################################

function New-DynamicModuleBuilder {
  # .SYNOPSIS
  #   Creates a new assembly and a dynamic module within the current AppDomain.
  # .DESCRIPTION
  #   Prepares a System.Reflection.Emit.ModuleBuilder class to allow construction of dynamic types. The ModuleBuilder is created to allow the creation of multiple types under a single assembly.
  # .PARAMETER AssemblyName
  #   A name for the in-memory assembly.
  # .PARAMETER UseGlobalVariable
  #   By default, this function stores the requested ModuleBuilder in a global variable called Indented_ModuleBuilder. This leaves the ModuleBuilder object accessible to New-Enum without needing an explicit assignment operation.
  # .INPUTS
  #   System.Reflection.AssemblyName
  # .OUTPUTS
  #   System.Reflection.Emit.ModuleBuilder
  # .EXAMPLE
  #   New-DynamicModuleBuilder "Example.Assembly"
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Reflection.AssemblyName]$AssemblyName,
    
    [Boolean]$UseGlobalVariable = $true,
    
    [Switch]$PassThru
  )
  
  $AppDomain = [AppDomain]::CurrentDomain

  # Multiple assemblies of the same name can exist. This check aborts if the assembly name exists on the assumption
  # that this is undesirable.
  $AssemblyRegEx = "^$($AssemblyName.Name -replace '\.', '\.'),"
  if ($AppDomain.GetAssemblies() |
    Where-Object { 
      $_.IsDynamic -and $_.Fullname -match $AssemblyRegEx }) {

    Write-Error "New-DynamicModuleBuilder: Dynamic assembly $($AssemblyName.Name) already exists."
    return
  }
  
  # Create a dynamic assembly in the current AppDomain
  $AssemblyBuilder = $AppDomain.DefineDynamicAssembly(
    $AssemblyName, 
    [Reflection.Emit.AssemblyBuilderAccess]::Run
  )

  $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule($AssemblyName.Name)
  if ($UseGlobalVariable) {
    # Create a transient dynamic module within the new assembly
    New-Variable Indented_ModuleBuilder -Scope Global -Value $ModuleBuilder
    if ($PassThru) {
      $ModuleBuilder
    }
  } else {
    return $ModuleBuilder
  }
}
 
function New-Enum {
  # .SYNOPSIS
  #   Creates a new enum (System.Enum) from a hashtable using an existing dynamic module.
  # .DESCRIPTION
  #   New-Enum dynamically creates an enum with the specified name (and namespace).
  #
  #   A hashtable is used to populate the enum. All values passed in via the hashtable must be able to convert to the enum type.
  # 
  #   The enum is created, but not returned by this function.
  # .PARAMETER Members
  #   A hashtable describing the members of the enum.
  # .PARAMETER ModuleBuilder
  #   A dynamic module within a dynamic assembly, created by New-DynamicModuleBuilder. By default, the function uses the global variable Indented_ModuleBuilder, populated if New-DynamicModuleBuilder is executed with UseGlobalVariable set to true (the default value).
  # .PARAMETER Name
  #   A name for the enum, a namespace may be included.
  # .PARAMETER SetFlagsAttribute
  #   Optionally sets the System.FlagsAttribute on the enum, indicating the enum can be treated as a bit field. Note that the enum members must support this attribute.
  # .PARAMETER Type
  #   A .NET value type, by default Int32 is used. The type name is passed as a string and converted to a Type by the function.
  # .INPUTS
  #   System.Reflection.Emit.ModuleBuilder
  #   System.String
  #   System.HashTable
  #   System.Type
  # .EXAMPLE
  #   C:\PS>New-DynamicModuleBuilder "Example"
  #   C:\PS>$EnumMembers = @{cat=1;dog=2;tortoise=4;rabbit=8}
  #   C:\PS>New-Enum -Name "Example.Pets" -SetFlagsAttribute -Members $EnumMembers
  #   C:\PS>[Example.Pets]10
  #
  #   Creates a new enumeration in memory, then returns values "dog" and "rabbit".
  # .EXAMPLE
  #   C:\PS>$Builder = New-DynamicModuleBuilder "Example" -UseGlobalVariable $false
  #   C:\PS>New-Enum -ModuleBuilder $Builder -Name "Example.Byte" `
  #   >> -Type "Byte" -Members @{one=1;two=2}
  #   >>
  #   C:\PS>[Example.Byte]2
  #
  #   Uses a user-defined variable to store the created dynamic module. The example returns the value "two".
  # .EXAMPLE
  #   C:\PS>New-DynamicModuleBuilder "Example"
  #   C:\PS>New-Enum -Name "Example.NumbersLow" -Members @{One=1; Two=2}
  #   C:\PS>New-Enum -Name "Example.NumbersHigh" -Members @{OneHundred=100; TwoHundred=200}
  #   C:\PS>[UInt32][Example.NumbersLow]::One + [UInt32][Example.NumbersHigh]::OneHundred
  #
  #   Multiple Enumerations can be built within the same dynamic assembly, a module builder only needs to be created once.

  [CmdLetBinding()]
  param(
    [Reflection.Emit.ModuleBuilder]$ModuleBuilder = $Indented_ModuleBuilder,
    
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidatePattern('^(\w+\.)*\w+$')]
    [String]$Name,

    [Type]$Type = "Int32",

    [Alias('Flags')]
    [Switch]$SetFlagsAttribute,

    [Parameter(Mandatory = $true)]
    [HashTable]$Members
  )
 
  # This function cannot overwrite or append to existing types. 
  # Abort if a type of the same name is found and return a more friendly error than ValidateScript would.
  if ($Name -as [Type]) {
    Write-Error "New-Enum: Type $Name already exists"
    return
  }
 
  # Begin defining a public System.Enum 
  $EnumBuilder = $ModuleBuilder.DefineEnum(
    $Name,
    [Reflection.TypeAttributes]::Public,
    $Type)
  if ($?) {
    if ($SetFlagsAttribute) {
      $EnumBuilder.SetCustomAttribute(
        [FlagsAttribute].GetConstructor([Type]::EmptyTypes),
        @()
      )
    }
    $Members.Keys | ForEach-Object {
      $EnumBuilder.DefineLiteral($_, [Convert]::ChangeType($Members[$_], $Type)) | Out-Null
    }
    $Enum = $EnumBuilder.CreateType()
  }
}

##############################################################################################################################################################
#                                                                     Module management                                                                      #
##############################################################################################################################################################

function NewIndentedAutoUpdateHash {
  # .SYNOPSIS
  #   Creates a new hash of several fields from the autoupdate configuration file.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   A SHA1 hash is used to tentatively validate the content of the auto-configuration file.
  # .PARAMETER AutoUpdateConfiguration
  #   A object representation of the configuration generated by either Get-IndentedAutoUpdate or Set-IndentedAutoUpdate.
  # .INPUTS
  #   Indented.Common.AutoUpdateConfiguration
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   NewIndentedAutoUpdateHash $AutoUpdateConfiguration

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Common.AutoUpdateConfiguration' } )]
    $AutoUpdateConfiguration
  )

  $String = $AutoUpdateConfiguration |
    Select-Object UpdateStatus, Frequency, NextUpdate, LastModifiedBy, LastModified |
    ConvertTo-Csv |
    Select-Object -Last 1
  return (Get-Hash $String -Algorithm SHA1 -AsString)
}

function Get-IndentedModule {
  # .SYNOPSIS
  #   Get a list of available Indented.* modules from the local system.
  # .DESCRIPTION
  #   Get-IndentedModule retrieves a list of local module and compares against a list held on http://www.indented.co.uk.
  #
  #   Get-IndentedModule can be used in conjunction with Install-IndentedModule to install, update and reinstall modules.
  # .PARAMETER Name
  #   A module name beginning with "Indented.", such as Indented.Dns. This value is used to apply a simple filter to the results of the search.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Common.ModuleDescription
  # .EXAMPLE
  #   Get-IndentedModule
  #
  #   Get a list of all available Indented.* modules.
  # .EXAMPLE
  #   Get-IndentedModule Indented.Dns
  #
  #   Get a specific module by name.
  
  [CmdLetBinding()]
  param(
    [ValidatePattern('^Indented\.\w+$')]
    [String]$Name
  )

  $WhereStatementText = '$_'
  if ($Name) {
    $WhereStatementText = $WhereStatementText + ' -and $_.Name -eq $Name'
  }
  $WhereStatement = [ScriptBlock]::Create($WhereStatementText)
  
  # Grab the list of modules from the web server (if possible). Merge everything into a single authoritative list.
  $ModuleList = @()
  $ModuleList += Get-WebContent http://www.indented.co.uk/ps-modules/modulelist.csv | ConvertFrom-Csv
  # Required call to show information about loaded modules from paths other than $env:PsModulePath.
  $ModuleList += Get-Module Indented.*
  # Add information for modules available under $env:PsModulePath which are not loaded.
  $ModuleList += Get-Module Indented.* -ListAvailable | Where-Object { -not (Get-Module $_.Name) }
  $ModuleList = $ModuleList | ForEach-Object {
    $IndentedModule = New-Object PsObject -Property ([Ordered]@{
      Name          = $_.Name;
      LocalVersion  = $_.Version;
      ServerVersion = [Version]$_.ServerVersion;
      Description   = $_.Description;
      Path          = $_.Path;
    })
    $IndentedModule.PsObject.TypeNames.Add("Indented.Common.ModuleDescription")
    $IndentedModule
  }

  $ModuleList | Group-Object Name | ForEach-Object {
    # Pick out the record from the server file
    $ServerModuleCopy = $_.Group | Where-Object ServerVersion

    # Pick out locally installed versions
    $InstalledVersions = $_.Group | Where-Object LocalVersion
    if ($InstalledVersions) {
      $InstalledVersions | ForEach-Object {
        if ($ServerModuleCopy) {
          $_.ServerVersion = $ServerModuleCopy.ServerVersion
          if ($ServerModuleCopy.Description) {
            $_.Description = $ServerModuleCopy.Description
          }
        } else {
          $_.ServerVersion = "Not available"
        }

        $_
      }
    } else {
      $ServerModuleCopy.LocalVersion = "Not installed"
      $ServerModuleCopy
    }
  } | Where-Object $WhereStatement
}

function Install-IndentedModule {
  # .SYNOPSIS
  #   Installs or updates Indented.* modules.
  # .DESCRIPTION
  #   Install-IndentedModule attempts to download and install modules from http://www.indented.co.uk.
  #
  #   Install-IndentedModule may be used to download modules for the first time, to upgrade existing modules, or to re-install a module.
  # .PARAMETER Force
  #   By default Install-IndentedModule takes no action if the current version of a module is installed. Setting the Force parameter allows re-installation of modules with the same (or greater) version number.
  # .PARAMETER ModuleDescription
  #   The required ModuleDescription object is returned using Get-IndentedModule, Install-IndentedModule accepts pipeline input from Get-IndentedModule.
  # .PARAMETER ModulePath
  #   By default modules are installed into the first path in the PSModulePath environmental variable. This behaviour can be changed by supplying a value for ModulePath.
  #
  #   If a module is already installed this parameter will be ignored, an attempt will be made to update the module in its current location.
  # .PARAMETER Name
  #   A module name beginning with "Indented.", such as Indented.Dns. Using Name as a parameter causes a call-back to Get-IndentedModule.
  # .INPUTS
  #   Indented.Common.ModuleDescription
  #   System.String
  # .EXAMPLE
  #   Get-IndentedModule | Install-IndentedModule
  #
  #   Get and install all available modules.
  # .EXAMPLE
  #   Get-IndentedModule Indented.Common | Install-IndentedModule
  # 
  #   Get a named module then install or upgrade.
  # .EXAMPLE
  #   Install-IndentedModule Indented.Dns
  #
  #   Install-IndentedModule executes the search, then installs or upgrades as appropriate.
    
  [CmdLetBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'ModuleDescription')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'ModuleDescription')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Common.ModuleDescription' } )]
    $ModuleDescription,

    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Name')]
    [ValidatePattern('^Indented\.\w+$')]
    [String]$Name,
    
    [ValidateScript( { Test-Path $_ } )]
    [Alias('Path')]
    [String]$ModulePath = (($env:PsModulePath -split ';')[0]),
    
    [Switch]$Force
  )
  
  begin {
    if ($pscmdlet.ParameterSetName -eq 'Name') {
      # Call back to Get-IndentedModule to get the information we need.
      Get-IndentedModule $Name | Install-IndentedModule -ModulePath $ModulePath
    }
  }
  
  process {
    if ($ModuleDescription) {
      if ($ModuleDescription.Path) {
        $ModulePath = $ModuleDescription.Path -replace "\\$($ModuleDescription.Name)\\.+$"
      }
    
      if ($ModuleDescription.LocalVersion -eq 'Not installed') {
        $Install = $true
      } elseif ($ModuleDescription.ServerVersion -gt $ModuleDescription.LocalVersion -or $Force) {
        $Install = $true
      }
      
      if ($Install) {  
        if ($pscmdlet.ShouldProcess("Installing $($ModuleDescription.Name) to $ModulePath")) {

          $TempFile = "$($env:Temp)\$($ModuleDescription.Name).zip"
          Get-WebContent "http://www.indented.co.uk/ps-modules/$($ModuleDescription.Name).zip" -File $TempFile
          
          if (Test-Path $TempFile) {
            # Delete the current instance of the module (files only).
            if (Test-Path "$ModulePath\$($ModuleDescription.Name)") {
              Write-Verbose "Install-IndentedModule: Removing existing version of $($ModuleDescription.Name)"
              Remove-Item "$ModulePath\$($ModuleDescription.Name)" -Recurse
            }
            
            # Attempt to avoid using COM objects to extract the zip file (at least .NET 4 is needed for this).
            if (Test-Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full") {
              Add-Type -AssemblyName "System.IO.Compression.FileSystem, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
            }
            try { $Test = [IO.Compression.ZipFile]::ExtractToDirectory } catch { }
            if ($?) {
              [IO.Compression.ZipFile]::ExtractToDirectory("$($env:Temp)\$($ModuleDescription.Name).zip", $ModulePath)
            } else {
              $Shell = New-Object -ComObject Shell.Application
              $Source = $Shell.Namespace("$($env:Temp)\$($ModuleDescription.Name).zip")
              $Destination = $Shell.Namespace($ModulePath)
              $Destination.CopyHere($Source.Items())
            }

            # Cleanup temp files
            Remove-Item $TempFile
          
            if (Get-Module $ModuleDescription.Name -ListAvailable) {
              Write-Host "Install-IndentedModule: Module $($ModuleDescription.Name) installed successfully." -ForegroundColor Green
            }
          } else {
            Write-Error "Install-IndentedModule: Failed to download module file $($ModuleDescription.Name)." -Category ResourceUnavailable
          }
        }
      } else {
        Write-Verbose "Install-IndentedModule: Module $($ModuleDescription.Name) is up to date."
      }
    }
  }
}

function Get-IndentedAutoUpdate {
  # .SYNOPSIS
  #   Get the auto-update configuration for Indented modules.
  # .DESCRIPTION
  #   Indented.Common can manage updates for all Indented modules. The update process is started by this module when it loads using the Start-IndentedAutoUpdate command.
  #
  #   Update options are held in a configuration file in the module directory named AutoUpdateConfiguration.csv.
  # .OUTPUTS
  #   Indented.Common.AutoUpdateConfiguration
  # .EXAMPLE
  #   Get-IndentedAutoUpdate
  
  [CmdLetBinding()]
  param( )
  
  if (-not (Test-Path $AutoUpdateConfigurationFile)) {
    # Initialise the auto-update file.
    Set-IndentedAutoUpdate
  }

  $AutoUpdateConfiguration = Import-Csv $AutoUpdateConfigurationFile
  $AutoUpdateConfiguration.PsObject.TypeNames.Add("Indented.Common.AutoUpdateConfiguration")

  if (([Array]$AutoUpdateConfiguration).Count -ne 1) {
    Write-Warning "Get-IndentedAutoUpdate: Auto-update configuration file contains too many elements."
    return
  }
  
  # Property: EnableAutoUpdate
  $AutoUpdateConfiguration.EnableAutoUpdate = $(
    if ($AutoUpdateConfiguration.EnableAutoUpdate -eq "True") {
      $true
    } else { 
      $false
    })
  # Property: Frequency
  $AutoUpdateConfiguration.Frequency = [TimeSpan]$AutoUpdateConfiguration.Frequency
  
  # Property: NextUpdateLocal
  $AutoUpdateConfiguration | Add-Member NextUpdateLocal -MemberType ScriptProperty -Value {
    return (Get-Date $this.NextUpdate) 
  }
  # Property: LastModifiedLocal
  $AutoUpdateConfiguration | Add-Member LastModifiedLocal -MemberType ScriptProperty -Value {
    return (Get-Date $this.LastModified)
  }
  # Property: IsHashValid
  $AutoUpdateConfiguration | Add-Member IsHashValid -MemberType NoteProperty -Value $(
    $AutoUpdateConfiguration.Hash -eq (NewIndentedAutoUpdateHash $AutoUpdateConfiguration)
  )

  return $AutoUpdateConfiguration
}

function Set-IndentedAutoUpdate {
  # .SYNOPSIS
  #   Set auto-update configuration for Indented modules.
  # .DESCRIPTION
  #   Indented.Common can manage updates for all Indented modules. The update process is started by this module when it loads using the Start-IndentedAutoUpdate command.
  #
  #   Update options are held in a configuration file in the module directory named AutoUpdateConfiguration.csv, the file content should be modified using this CmdLet.
  # .PARAMETER EnableAutoUpdate
  #   Auto-update is disabled by default. Setting EnableAutoUpdate to true enables updating.
  # .PARAMETER Force
  #   Force recreation of the configuration file.
  # .PARAMETER Frequency
  #   By default, Start-IndentedAutoUpdate will check for updates no more than once per day. The frequency can be adjusted using a TimeSpan.
  #
  #   Note: Updates only occur when this module loads regardless of the frequency value set here.
  # .PARAMETER NextUpdate
  #   NextUpdate may be set to an arbitrary date, this parameter is used by Start-IndentedAutoUpdate to record the next anticipated update time.
  # .PARAMETER PassThru
  #   The settings object will be returned when updating settings.
  # .INPUTS
  #   System.Boolean
  #   System.TimeSpan
  #   System.DateTime
  # .OUTPUTS
  #   Indented.Common.AutoUpdateConfiguration
  # .EXAMPLE
  #   Set-IndentedAutoUpdate -EnableAutoUpdate $true
  #
  #   Set-up and enable auto-update with the default frequency value (1 day).
  # .EXAMPLE
  #   Set-IndentedAutoUpdate -EnableAutoUpdate $false
  #
  #   Disable auto-update.
  # .EXAMPLE
  #   Set-IndentedAutoUpdate -Frequency "2.00:00:00"
  #
  #   Set the auto-update frequency to a minimum of 2 days.
  
  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Boolean]$EnableAutoUpdate = $false,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [TimeSpan]$Frequency = "1.00:00:00",
    
    [String]$NextUpdate = (Get-Date).ToString(),

    [Switch]$Force,

    [Switch]$PassThru
  )
  
  $New = $false
  if (-not (Test-Path $AutoUpdateConfigurationFile)) {
    $New = $true
  } else {
    $AutoUpdateConfiguration = Get-IndentedAutoUpdate
    if (-not $AutoUpdateConfiguration -or -not $AutoUpdateConfiguration.IsHashValid) {
      $New = $true
    }
  }

  if ($Force) {
    $New = $true 
  }

  if ($New) {
    # Generate a new auto-update configuration block.
    $AutoUpdateConfiguration = New-Object PsObject -Property ([Ordered]@{
      EnableAutoUpdate = $EnableAutoUpdate;
      Frequency        = $Frequency;
      NextUpdate       = (Get-Date $NextUpdate).ToUniversalTime().ToString("u");
      LastModifiedBy   = $null;
      LastModified     = $null;
      Hash             = $null;
    })
    $AutoUpdateConfiguration.PsObject.TypeNames.Add("Indented.Common.AutoUpdateConfiguration")
    
    $Updated = $true
  } else {
    if ($myinvocation.BoundParameters.ContainsKey("EnableAutoUpdate") -and $AutoUpdateConfiguration.EnableAutoUpdate -ne $EnableAutoUpdate) {
      $AutoUpdateConfiguration.EnableAutoUpdate = $EnableAutoUpdate
      $Updated = $true
      
    }
    if ($myinvocation.BoundParameters.ContainsKey("Frequency") -and $AutoUpdateConfiguration.Frequency -ne $Frequency) {
      $AutoUpdateConfiguration.Frequency = $Frequency.ToString()
      $Updated = $true
    }
    if ($myinvocation.BoundParameters.ContainsKey("NextUpdate") -and (Get-Date $AutoUpdateConfiguration.NextUpdate) -ne $NextUpdate) {
      $AutoUpdateConfiguration.NextUpdate = (Get-Date $NextUpdate).ToUniversalTime().ToString("u")
      $Updated = $true
    }
  }
  
  if ($Updated) {
    # Update the change record
    $AutoUpdateConfiguration.LastModifiedBy = "$($env:UserDomain)\$($env:Username)"
    $AutoUpdateConfiguration.LastModified = (Get-Date).ToUniversalTime().ToString("u")
    $AutoUpdateConfiguration.Hash = NewIndentedAutoUpdateHash $AutoUpdateConfiguration
    
    # Export the modified configuration.
    $AutoUpdateConfiguration | 
      Select-Object EnableAutoUpdate, Frequency, NextUpdate, LastModifiedBy, LastModified, Hash |
      Export-Csv $AutoUpdateConfigurationFile -NoTypeInformation
  } else {
    Write-Warning "Set-IndentedAutoUpdate: No auto-update settings were changed."
  }
  
  if ($PassThru) {
    Get-IndentedAutoUpdate
  }
}

function Start-IndentedAutoUpdate {
  # .SYNOPSIS
  #   Start an update process for all installed Indented.* modules.
  # .DESCRIPTION
  #   Start-IndentedAutoUpdate attempts to update all installed Indented.* modules from www.indented.co.uk.
  # .EXAMPLE
  #   Start-IndentedAutoUpdate
  
  [CmdLetBinding()]
  param( )
  
  # Get the settings file
  $AutoUpdateConfiguration = Get-IndentedAutoUpdate
  if (-not $AutoUpdateConfiguration.IsHashValid) {
    Write-Verbose "Start-IndentedAutoUpdate: Invalid configuration file. Please re-run Set-IndentedAutoUpdate." 
  }
  
  if ($AutoUpdateConfiguration.EnableAutoUpdate -and (Get-Date $AutoUpdateConfiguration.NextUpdate) -lt (Get-Date)) {
    Get-IndentedModule |
      Where-Object { $_.LocalVersion -ne "Not installed" -and $_.ServerVersion -ne "Not available" } |
      ForEach-Object {
        Write-Host "Start-IndentedAutoUpdate: Starting update for $($_.Name)" -ForegroundColor Cyan
        $_ | Install-IndentedModule
      }
 
    $AutoUpdateConfiguration | Set-IndentedAutoUpdate -NextUpdate (((Get-Date) + $AutoUpdateConfiguration.Frequency).ToString())
  } elseif (-not $AutoUpdateConfiguration.EnableAutoUpdate) {
    Write-Verbose "Start-IndentedAutoUpdate: Updates are not enabled" 
  } elseif ((Get-Date $AutoUpdateConfiguration.NextUpdate) -lt (Get-Date)) {
    Write-Verbose "Start-IndentedAutoUpdate: NextUpdate is in the future, aborting." 
  }
}

##############################################################################################################################################################
#                                                                       Socket handling                                                                      #
##############################################################################################################################################################

function New-Socket {
  # .SYNOPSIS
  #   Creates a new network socket to use to send and receive packets over a network.
  # .DESCRIPTION
  #   New-Socket creates an instance of System.Net.Sockets.Socket for use with Send-Bytes and Receive-Bytes.
  # .PARAMETER EnableBroadcast
  #   Allows a UDP socket to send and receive datagrams from the directed or undirected broadcast IP address.
  # .PARAMETER LocalIPAddress
  #   If configuring a server port (to listen for requests) an IP address may be defined. By default the Socket is created to listen on all available addresses.
  # .PARAMETER LocalPort
  #   If configuring a server port (to listen for requests) the local port number must be defined.
  # .PARAMETER NoTimeout
  #   By default, send and receive timeout values are set for all operations. These values can be overridden to allow configuration of a socket which will never stop either attempting to send or attempting to receive.
  # .PARAMETER ProtocolType
  #   ProtocolType must be either TCP or UDP. This parameter also sets the SocketType to Stream for TCP and Datagram for UDP.
  # .PARAMETER ReceiveTimeout
  #   A timeout for individual Receive operations performed with this socket. The default value is 5 seconds; this CmdLet allows the value to be set between 1 and 30 seconds.
  # .PARAMETER SendTimeout
  #   A timeout for individual Send operations performed with this socket. The default value is 5 seconds; this CmdLet allows the value to be set between 1 and 30 seconds.
  # .INPUTS
  #   System.Net.Sockets.ProtocolType
  #   System.Net.IPAddress
  #   System.UInt16
  #   System.Int32
  # .OUTPUTS
  #   System.Net.Sockets.Socket
  # .EXAMPLE
  #   New-Socket -LocalPort 25
  #
  #   Configure a socket to listen using TCP/25 (as a network server) on all locally configured IP addresses.
  # .EXAMPLE
  #   New-Socket -ProtocolType Udp
  #
  #   Configure a socket for sending UDP datagrams (as a network client).
  # .EXAMPLE
  #   New-Socket -LocalPort 23 -LocalIPAddress 10.0.0.1
  #
  #   Configure a socket to listen using TCP/23 (as a network server) on the IP address 10.0.0.1 (the IP address must exist and be bound to an interface).

  [CmdLetBinding(DefaultParameterSetName = 'ClientSocket')]
  param(
    [ValidateSet("Tcp", "Udp")]
    [Net.Sockets.ProtocolType]$ProtocolType = "Tcp",
    
    [Parameter(ParameterSetName = 'ServerSocket')]
    [IPAddress]$LocalIPAddress = [IPAddress]::Any,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ServerSocket')]
    [UInt16]$LocalPort,

    [Parameter(ParameterSetName = 'ClientSocket')]
    [Switch]$EnableBroadcast,
   
    [Switch]$IPv6,
   
    [Switch]$NoTimeout,
    
    [ValidateRange(1, 30)]
    [Int32]$ReceiveTimeOut = 5,
    
    [ValidateRange(1, 30)]
    [Int32]$SendTimeOut = 5
  )
  
  switch ($ProtocolType) {
    ([Net.Sockets.ProtocolType]::Tcp) { $SocketType = [Net.Sockets.SocketType]::Stream; break }
    ([Net.Sockets.ProtocolType]::Udp) { $SocketType = [Net.Sockets.SocketType]::Dgram; break } 
  }

  $AddressFamily = [Net.Sockets.AddressFamily]::InterNetwork

  if ($IPv6) {
    $AddressFamily = [Net.Sockets.AddressFamily]::Internetworkv6
    # If LocalIPAddress has not been explicitly defined, and IPv6 is expected, change to all IPv6 addresses.
    if ($LocalIPAddress -eq [IPAddress]::Any) {
      $LocalIPAddress = [IPAddress]::IPv6Any
    }
  }

  $Socket = New-Object Net.Sockets.Socket(
    $AddressFamily,
    $SocketType,
    $ProtocolType
  )

  if ($EnableBroadcast) {
    if ($ProtocolType -eq [Net.Sockets.ProtocolType]::Udp) {
      $Socket.EnableBroadcast = $true
    } else {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "EnableBroadcast cannot be set for TCP sockets."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
  }

  # Bind a local end-point to listen for inbound requests.
  if ($pscmdlet.ParameterSetName -eq 'ServerSocket') {
    $LocalEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($LocalIPAddress, $LocalPort))
    $Socket.Bind($LocalEndPoint)
  }

  # Set timeout values if applicable.
  if (-not $NoTimeout) {
    $Socket.SendTimeOut = $SendTimeOut * 1000
    $Socket.ReceiveTimeOut = $ReceiveTimeOut * 1000
  }

  return $Socket
}

function Connect-Socket {
  # .SYNOPSIS
  #   Connect a TCP socket to a remote IP address and port.
  # .DESCRIPTION
  #   If a TCP socket is being used as a network client it must first connect to a server before Send-Bytes and Receive-Bytes can be used.
  # .PARAMETER RemoteIPAddress
  #   The remote IP address to connect to.
  # .PARAMETER RemotePort
  #   The remote port to connect to.
  # .PARAMETER Socket
  #   A socket created using New-Socket.
  # .INPUTS
  #   System.Net.IPAddress
  #   System.Net.Sockets.Socket
  #   System.UInt16
  # .OUTPUTS
  #   None
  #
  #   Connect-Socket performs an operation on an existing socket created using New-Socket.
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,
    
    [Parameter(Mandatory = $true)]
    [Alias('IPAddress')]
    [IPAddress]$RemoteIPAddress,

    [Parameter(Mandatory = $true)]
    [Alias('Port')]
    [UInt16]$RemotePort
  )

  process {
    if ($Socket.ProtocolType -ne [Net.Sockets.ProtocolType]::Tcp) {
      Write-Error "Connect-Socket: The protocol type must be TCP to use Connect-Socket." -Category InvalidOperation
      return
    }

    $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($RemoteIPAddress, $RemotePort))

    if ($Socket.Connected) {
      Write-Warning "Connect-Socket: The socket is connected to $($Socket.RemoteEndPoint). No action taken."
    } else {
      $Socket.Connect($RemoteEndPoint)
    }
  }
}

function Disconnect-Socket {
  # .SYNOPSIS
  #   Disconnect a connected TCP socket.
  # .DESCRIPTION
  #   A TCP socket which has been connected using Connect-Socket may be disconnected using this CmdLet.
  # .PARAMETER Shutdown
  #   By default, Disconnect-Socket attempts to shutdown the connection before disconnecting. This behaviour can be overridden by setting this parameter to False.
  # .PARAMETER Socket
  #   A socket created using New-Socket and connected using Connect-Socket.
  # .INPUTS
  #   System.Net.Sockets.Socket
  # .OUTPUTS
  #   None
  #
  #   Disconnect-Socket performs an operation on an existing socket created using New-Socket.
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>$Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
  #   C:\PS>$Socket | Disconnect-Socket

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,

    [Boolean]$Shutdown = $true
  )

  process {
    if ($Socket.ProtocolType -ne [Net.Sockets.ProtocolType]::Tcp) {
      Write-Error "Disconnect-Socket: The protocol type must be TCP to use Disconnect-Socket." -Category InvalidOperation
      return
    }

    if (-not $Socket.Connected) {
      Write-Warning "Disconnect-Socket: The socket is not connected. No action taken."
    } else {
      Write-Verbose "Disconnect-Socket: Disconnected socket from $($Socket.RemoteEndPoint)."

      if ($Shutdown) {
        $Socket.Shutdown([Net.Sockets.SocketShutdown]::Both)
      }

      # Disconnect the socket and allow reuse.
      $Socket.Disconnect($true)
    }
  }
}

function Remove-Socket {
  # .SYNOPSIS
  #   Removes a socket, releasing all resources.
  # .DESCRIPTION
  #   A socket may be removed using Remove-Socket if it is no longer required.
  # .PARAMETER Socket
  #   A socket created using New-Socket.
  # .INPUTS
  #   System.Net.Sockets.Socket
  # .OUTPUTS
  #   None
  #
  #   Remove-Socket performs an operation on an existing socket created using New-Socket.
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>$Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
  #   C:\PS>$Socket | Disconnect-Socket
  #   C:\PS>$Socket | Remove-Socket

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket
  )

  process {
    # Close the socket
    $Socket.Close()
  }
}

function Receive-Bytes {
  # .SYNOPSIS
  #   Receive bytes using a TCP or UDP socket.
  # .DESCRIPTION
  #   Receive-Bytes is used to accept inbound TCP or UDP packets as a client exepcting a response from a server, or as a server waiting for incoming connections.
  #
  #   Receive-Bytes will listen for bytes sent to broadcast addresses provided the socket has been created using EnableBroadcast.
  # .PARAMETER BufferSize
  #   The maximum buffer size used for each receive operation.
  # .PARAMETER Socket
  #   A socket created using New-Socket. If the ProtocolType is TCP the socket must be connected first.
  # .INPUTS
  #   System.Net.Sockets.Socket
  #   System.UInt32
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.1 -RemotePort 25
  #   C:\PS>$Bytes = Receive-Bytes $Socket
  #   C:\PS>$Bytes | ConvertTo-String
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket -ProtocolType Udp -EnableBroadcast
  #   C:\PS>$Socket | Receive-Bytes

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,
    
    [UInt32]$BufferSize = 1024
  )

  $Buffer = New-Object Byte[] $BufferSize 

  switch ($Socket.ProtocolType) {
    ([Net.Sockets.ProtocolType]::Tcp) {
      $BytesReceived = $null; $BytesReceived = $Socket.Receive($Buffer)
      Write-Verbose "Receive-Bytes: Received $BytesReceived from $($Socket.RemoteEndPoint): Connection State: $($Socket.Connected)"

      $Response = New-Object PsObject -Property ([Ordered]@{
        BytesReceived  = $BytesReceived;
        Data           = $Buffer[0..$($BytesReceived - 1)];
        RemoteEndPoint = $Socket.RemoteEndPoint | Select-Object *;
      })
      break
    }
    ([Net.Sockets.ProtocolType]::Udp) {
      # Create an IPEndPoint to use as a reference object
      if ($Socket.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork) {
        $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint([IPAddress]::Any, 0))
      } elseif ($Socket.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkv6) {
        $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint([IPAddress]::IPv6Any, 0))
      }
      
      $BytesReceived = $null; $BytesReceived = $Socket.ReceiveFrom($Buffer, [Ref]$RemoteEndPoint)
      Write-Verbose "Receive-Bytes: Received $BytesReceived from $($RemoteEndPoint.Address.IPAddressToString)"

      $Response = New-Object PsObject -Property ([Ordered]@{
        BytesReceived  = $BytesReceived;
        Data           = $Buffer[0..$($BytesReceived - 1)];
        RemoteEndPoint = $RemoteEndPoint | Select-Object *;
      })
      break
    }
  }
  if ($Response) {
    $Response.PsObject.TypeNames.Add("Indented.Common.SocketResponse")
    return $Response
  }
}

function Send-Bytes {
  # .SYNOPSIS
  #   Sends bytes using a TCP or UDP socket.
  # .DESCRIPTION
  #   Send-Bytes is used to send outbound TCP or UDP packets as a server responding to a cilent, or as a client sending to a server.
  # .PARAMETER Broadcast
  #   Sets the RemoteIPAddress to the undirected broadcast address.
  # .PARAMETER RemoteIPAddress
  #   If the Protocol Type is UDP a remote IP address must be defined. Directed or undirected broadcast addresses may be used if EnableBroadcast has been set on the socket.
  # .PARAMETER Socket
  #   A socket created using New-Socket. If the ProtocolType is TCP the socket must be connected first.
  # .INPUTS
  #   System.Net.Sockets.Socket
  #   System.UInt32
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket
  #   C:\PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.1 -RemotePort 25
  #   C:\PS>Send-Bytes $Socket -Data 0
  # .EXAMPLE
  #   C:\PS>$Socket = New-Socket -ProtocolType Udp -EnableBroadcast
  #   C:\PS>Send-Bytes $Socket -Data 0

  [CmdLetBinding(DefaultParameterSetName = 'DirectedTcpSend')]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Net.Sockets.Socket]$Socket,

    [Parameter(Mandatory = $true, ParameterSetName = 'DirectedUdpSend')]
    [IPAddress]$RemoteIPAddress,

    [Parameter(Mandatory = $true, ParameterSetName = 'BroadcastUdpSend')]
    [Switch]$Broadcast,
    
    [Parameter(Mandatory = $true, ParameterSetname = 'DirectedUdpSend')]
    [Parameter(Mandatory = $true, ParameterSetName = 'BroadcastUdpSend')]
    [UInt16]$RemotePort,
   
    [Parameter(Mandatory = $true)]
    [Byte[]]$Data
  )
  
  # Broadcast parameter set checking
  if ($pscmdlet.ParameterSetName -eq 'BroadcastUdpSend') {
    # IPv6 error checking
    if ($Socket.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkv6) {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "EnableBroadcast cannot be set for IPv6 sockets."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
    
    # TCP socket error checking
    if (-not $Socket.ProtocolType) {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "EnableBroadcast cannot be set for TCP sockets."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
    
    # Broadcast flag checking
    if (-not $Socket.EnableBroadcast) {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object InvalidOperationException "EnableBroadcast is not set on the socket."),
        "InvalidOperation",
        [Management.Automation.ErrorCategory]::InvalidOperation,
        $Socket)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    $RemoteIPAddress = [IPAddress]::Broadcast
  }

  switch ($Socket.ProtocolType) {
    ([Net.Sockets.ProtocolType]::Tcp) {
    
      $Socket.Send($Data) | Out-Null

      break
    }
    ([Net.Sockets.ProtocolType]::Udp) {
      $RemoteEndPoint = [Net.EndPoint](New-Object Net.IPEndPoint($RemoteIPAddress, $RemotePort))
      
      $Socket.SendTo($Data, $RemoteEndPoint) | Out-Null

      break
    }
  }
}  

##############################################################################################################################################################
#                                                              System.DirectoryServices.Protocols                                                            #
##############################################################################################################################################################

function Get-LdapObject {
  # .SYNOPSIS
  #   Get objects from an LDAP directory using System.DirectoryServices.Protocols.
  # .DESCRIPTION
  #   Get-LdapObject uses System.DirectoryServices.Protocols to execute searches against an LDAP directory. 
  #
  #   Values returned by this CmdLet are raw and comparatively complex to work with. This function is written for speed and flexibility over ease of use.
  #      
  #   Get-LdapObject has only been tested against Active Directory.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .PARAMETER LdapFilter
  #   An LDAP filter to use with the search. The filter (objectClass=*) is used by default.
  # .PARAMETER Properties
  #   An optional array of LDAP property names to return in the search result. 
  # .PARAMETER SearchRoot
  #   The search root must be specified as a distinguishedName. The default value (blank) will allow Get-LdapObject to return values from RootDSE with a SearchScope to set to Base.
  # .PARAMETER SearchScope
  #   The search scope is either Base, OneLevel or Subtree. Subtree is the default value.
  # .PARAMETER Server
  #   An optional server to use for this query. If server is not populated Get-LdapObject uses serverless binding, passing off server selection to the site-aware DC locator process. Server is mandatory when executing a query against a remote domain.
  # .INPUTS
  #   System.Management.Automation.PSCredential
  #   System.DirectoryServices.Protocols.SearchScope
  #   System.String
  #   System.String[]
  # .OUTPUTS
  #   System.DirectoryServices.Protocols.SearchResultEntry[]
  # .EXAMPLE
  #   C:\PS>$RootDSE = Get-LdapObject -SearchScope Base
  #   C:\PS>$RootDSE.Attributes.AttributeNames | ForEach-Object {
  #   >>  Write-Host ""
  #   >>  Write-Host "Attribute Name: $_" -ForegroundColor Green
  #   >>  Write-Host ""
  #   >>  $Count = $RootDSE.Attributes[$_].Count
  #   >>  for ($i = 0; $i -lt $Count; $i++) {
  #   >>    $RootDSE.Attributes[$_].Item($_)
  #   >>  }
  #   >>}     
  #
  #   Gets the content of RootDSE.
  # .EXAMPLE
  #   C:\PS>Get-LdapObject -LdapFilter "(sAMAccountName=cdent)" -SearchRoot "DC=indented,DC=co,DC=uk"
  #
  #   Gets the user with sAMAccountName cdent from the LDAP directory indented.co.uk.
  
  [CmdLetBinding()]
  param(
    [String]$LdapFilter = "(objectClass=*)",
    
    [String]$SearchRoot,
    
    [DirectoryServices.Protocols.SearchScope]$SearchScope = "Subtree",
    
    [String[]]$Properties,
    
    [DirectoryServices.Protocols.ReferralChasingOptions]$ReferralChasingOptions = [DirectoryServices.Protocols.ReferralChasingOptions]::None,

    [String]$Server,
    
    [PSCredential]$Credential
  )

  # Force a value for SearchScope if the SearchRoot is blank.
  if (-not $SearchRoot) {
    $SearchScope = "Base"
  }

  # Bind to the LDAP server. If $Server is $null serverless binding is used.
  if ($Credential) {
    $NetworkCredential = $Credential.GetNetworkCredential()
    $LdapConnection = New-Object DirectoryServices.Protocols.LdapConnection("$Server", $NetworkCredential)
  } else {
    $LdapConnection = New-Object DirectoryServices.Protocols.LdapConnection("$Server")
  }
  # Set the LDAP version to 3.
  $LdapConnection.SessionOptions.ProtocolVersion = 3
  # Set referral chasing options
  $LdapConnection.SessionOptions.ReferralChasing = $ReferralChasingOptions
  
  $SearchRequest = New-Object DirectoryServices.Protocols.SearchRequest
  $SearchRequest.DistinguishedName = $SearchRoot
  $SearchRequest.Filter = $LdapFilter 
  $SearchRequest.Scope = $SearchScope
  
  if ($Properties) {
    $SearchRequest.Attributes.AddRange($Properties)
  }

  $PageRequest = New-Object DirectoryServices.Protocols.PageResultRequestControl 1000
  $SearchRequest.Controls.Add($PageRequest) | Out-Null
  # $SearchRequest.Controls.Add((New-Object DirectoryServices.Protocols.SearchOptionsControl "DomainScope")) | Out-Null

  while ($true) {
    $SearchResponse = $null
    try {
      $SearchResponse = $LdapConnection.SendRequest($SearchRequest)
    } catch [Exception] {
      $pscmdlet.ThrowTerminatingError($_)
    }
    if ($SearchResponse.ResultCode -ne [DirectoryServices.Protocols.ResultCode]::Success) {
      Write-Error $SearchResponse.ErrorMessage -Category OperationStopped
      return
    }
    if ($SearchResponse) {
      # Leave the result entries in the output pipeline
      $SearchResponse.Entries

      # Exit after the first page if paging is not supported.
      if ($SearchResponse.Controls.Length -ne 1 -or -not $SearchResponse.Controls[0] -is [DirectoryServices.Protocols.DirectoryControl]) {
        return
      }
      
      # Check the cookie size
      $PageResponse = [DirectoryServices.Protocols.PageResultResponseControl]$SearchResponse.Controls[0]
      if ($PageResponse.Cookie.Length -eq 0) {
        return
      }
      
      # Update the search cookie
      $SearchRequest.Controls[0].Cookie = $PageResponse.Cookie
    }
  }
}

##############################################################################################################################################################
#                                                                            WMI                                                                             #
##############################################################################################################################################################

function Get-WmiClass {
  # .SYNOPSIS
  #   Get an instance of a ManagementClass.
  # .DESCRIPTION
  #   Get-WmiClass is equivalent to [WMIClass] with an additional option to authenticate the connection.
  # .PARAMETER Class
  #   The WMI Class name.
  # .PARAMETER ComputerName
  #   A computer name to execute this function against.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .PARAMETER Namespace
  #   The WMI Namespace. By default the root\cimv2 namespace is used.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Management.ManagementClass
  # .EXAMPLE
  #

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [String]$Class,

    [String]$Namespace = "root\cimv2",

    [String]$ComputerName = ".",

    [Management.Automation.PSCredential]$Credential
  )

  $ConnectionOptions = New-Object Management.ConnectionOptions
  if ($Credential) {
    $ConnectionOptions.Username = $Credential.UserName
    $ConnectionOptions.SecurePassword = $Credential.Password
  }

  $WmiScope = New-Object Management.ManagementScope("\\$ComputerName\$Namespace", $ConnectionOptions)
  $WmiPath = New-Object Management.ManagementPath($Class)
  $WmiClass = New-Object Management.ManagementClass($WmiScope, $WmiPath, (New-Object Management.ObjectGetOptions))

  return $WmiClass
}

function Get-WmiPath {
  # .SYNOPSIS
  #   Get an instance of a ManagementObject using a specific management path.
  # .DESCRIPTION
  #   Get-WmiPath is equivalent to [WMI] with an additional option to authenticate the connection.
  # .PARAMETER ComputerName
  #   A computer name to execute this function against.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .PARAMETER Path
  #   A WMI ManagementPath.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Management.ManagementObject
  # .EXAMPLE
  #   C:\PS>[WMI]"Win32_SID.SID='S-1-5-32-545'" | Select-Object AccountName, ReferencedDomainName
  #   C:\PS>Get-WmiPath -Path "Win32_SID.SID='S-1-5-32-545'" | Select-Object AccountName, ReferencedDomainName
  # .EXAMPLE
  #   Get-WmiPath -Path "Win32_Processor.DeviceID='CPU0'" -Computer "Server01" -Credential (Get-Credential)
  #
  #   Get-WmiPath can be used to bind to a remote ManagementObject with or without specific credentials.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [String]$Path,

    [String]$ComputerName = ".",

    [Management.Automation.PSCredential]$Credential
  )

  $ConnectionOptions = New-Object Management.ConnectionOptions
  if ($Credential) {
    $ConnectionOptions.Username = $Credential.UserName
    $ConnectionOptions.SecurePassword = $Credential.Password
  }

  $WmiScope = New-Object Management.ManagementScope("\\$ComputerName\$Namespace", $ConnectionOptions)
  $WmiPath = New-Object Management.ManagementPath($Path)
  $WmiObject = New-Object Management.ManagementObject($WmiScope, $WmiPath, (New-Object Management.ObjectGetOptions))

  return $WmiObject
}

##############################################################################################################################################################
#                                                                      Utility functions                                                                     #
##############################################################################################################################################################

function Compare-Array {
  # .SYNOPSIS
  #   Compares two arrays to determine equality.
  # .DESCRIPTION
  #   This function presents two methods of comparing arrays.
  #
  #     1. A manual loop comparison method, exiting at the first opportunity. 
  #     2. A wrapper around the .NET 4 IStructuralEquatable interface.
  #
  #   Arrays must be exactly equal for the function to return true. That is, arrays must meet the following criteria:
  #
  #     * Must use simple values (primitive types).
  #     * Must be of equal length.
  #     * Must be ordered in the same way unless using the Sort parameter.
  #     * When comparing strings, case is important.
  #     * .NET Type must be equal (UInt32 is not the same as Int32).
  #
  # .PARAMETER Object
  #   The object array to test against.
  # .PARAMETER Sort
  #   For an array to be considered equal it must also be ordered in the same way. Comparison of unordered arrays can be forced by setting this parameter.
  # .PARAMETER Subject
  #   The object array to test.
  # .INPUTS
  #   System.Array
  #   System.Object[]
  # .OUTPUTS
  #   System.Boolean
  # .EXAMPLE
  #   C:\PS>Compare-Array -Subject 1, 2, 3 -Object 1, 2, 3
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS>$a = [Byte[]](1, 2, 3)
  #   C:\PS>$b = [Byte[]](3, 2, 1)
  #   C:\PS>Compare-Array -Subject $a -Object $b
  #
  #   Returns false, elements are not ordered in the same way and types are equal.
  # .EXAMPLE
  #   C:\PS>$a = [Byte[]](1, 2, 3)
  #   C:\PS>$a = [UInt32[]](1, 2, 3)
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns false, element Types are not equal.
  # .EXAMPLE
  #   C:\PS>$a = "one", "two"
  #   C:\PS>$b = "one", "two"
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS>$a = "ONE", "TWO"
  #   C:\PS>$b = "one", "two"
  #   C:\PS>Compare-Array $a $b
  #
  #   Returns false.
  # .EXAMPLE
  #   C:\PS>$a = 1..10000
  #   C:\PS>$b = 1..10000
  #   C:\PS>Compare-Array $a $b -ManualLoop
  #
  #   Returns true.
  # .EXAMPLE
  #   C:\PS> Compare-Array @("1.2.3.4", "2.3.4.5") @("2.3.4.5", "1.2.3.4") -Sort
  #
  #   Returns true.
  
  param(
    [Parameter(Mandatory = $true)]
    [Object[]]$Subject,

    [Parameter(Mandatory = $true)]
    [Object[]]$Object,
    
    [Switch]$ManualLoop,
    
    [Switch]$Sort
  )

  if ($ManualLoop) {
    # If the arrays are not the same length they cannot be equal.
    if ($Subject.Length -ne $Object.Length) {
      return $false
    }
    
    # If Sort is set and the arrays are of equal length ensure both arrays are similarly ordered.
    if ($Sort) {
      $Subject = $Subject | Sort-Object
      $Object = $Object | Sort-Object
    }
    
    $Length = $Subject.Length
    $Equal = $true
    for ($i = 0; $i -lt $Length; $i++) {
      # Exit when the first match fails.
      if ($Subject[$i] -ne $Object[$i]) {
        return $false
      }
    }
    return $true
  } else {
    # If Sort is set and the arrays are of equal length ensure both arrays are similarly ordered.
    if ($Sort) {
      $Subject = $Subject | Sort-Object
      $Object = $Object | Sort-Object
    }

    ([Collections.IStructuralEquatable]$Subject).Equals(
      $Object,
      [Collections.StructuralComparisons]::StructuralEqualityComparer
    )
  }
}

function ConvertTo-Byte {
  # .SYNOPSIS
  #   Converts a value to a byte array.
  # .DESCRIPTION
  #   ConvertTo-Byte acts as a wrapper for a number of .NET methods which return byte arrays.
  # .PARAMETER BigEndian
  #   If a multi-byte value is being returned this parameter can be used to reverse the byte order. By default, the least significant byte is returned first.
  #
  #   The BigEndian parameter is only effective when a numeric value is passsed as the Value.
  # .PARAMETER Value
  #   The value to convert. If a string value is passed it is treated as ASCII text and converted. If a numeric value is entered the type is tested an BitConverter.GetBytes is used.
  # .INPUTS
  #   System.Object
  # .OUTPUTS
  #   System.Byte[]
  # .EXAMPLE
  #   "The cow jumped over the moon" | ConvertTo-Byte
  # .EXAMPLE
  #   123456 | ConvertTo-Byte
  # .EXAMPLE
  #   [UInt16]60000 | ConvertTo-Byte -BigEndian

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Value,

    [Switch]$BigEndian
  )
  
  process {
    switch -Regex ($Value.GetType().Name) {
      'Byte|U?Int(16|32|64)' { 
        $Bytes = [BitConverter]::GetBytes($Value)
        if ($BigEndian) {
            [Array]::Reverse($Bytes)
        }
        return $Bytes
      }
      default { return [Text.Encoding]::ASCII.GetBytes([String]$Value) }
    }
  }
}

function ConvertTo-String {
  # .SYNOPSIS
  #   Converts a byte array to a string value.
  # .DESCRIPTION
  #   ConvertTo-String supports a number of different binary encodings including ASCII, Base16 (Hexadecimal), Base64, Binary and Unicode.
  # .PARAMETER ASCII
  #   The byte array is an ASCII string.
  # .PARAMETER Base64
  #   The byte array is Base64 encoded string.
  # .PARAMETER Binary
  #   The byte array is a binary string.
  # .PARAMETER Hexadecimal
  #   The byte array is a hexadecimal string.
  # .PARAMETER Unicode
  #   The byte array is a Unicode string.
  # .INPUTS
  #   System.Byte[]
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   ConvertTo-String (72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100)
  #
  #   Converts the byte array to an ASCII string.
  # .EXAMPLE
  #   ConvertTo-String (1, 2, 3, 4) -Base64
  #
  #   Converts the byte array to a Base64 string.
  # .EXAMPLE
  #   ConvertTo-String (1, 2, 3, 4) -Binary
  # 
  #   Converts the byte array to a binary string.
  # .EXAMPLE
  #   ConvertTo-String (1, 2, 3, 4) -Hexadecimal
  # 
  #   Converts the byte array to a hexadecimal string.
  # .EXAMPLE
  #   ConvertTo-String (72, 0, 101, 0, 108, 0, 108, 0, 111, 0, 32, 0, 119, 0, 111, 0, 114, 0, 108, 0, 100, 0) -Unicode
  #
  #   Converts the byte array to a unicode string.
  
  [CmdLetBinding(DefaultParameterSetName = 'ToASCII')]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Byte[]]$Data,

    [Parameter(Mandatory = $true, ParameterSetName = 'ToBase64')]
    [Alias('ToBase64')]
    [Switch]$Base64,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ToBinary')]
    [Alias('ToBinary')]
    [Switch]$Binary,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ToHex')]
    [Alias('Hex', 'ToHex', 'Base16', 'ToBase16')]
    [Switch]$Hexadecimal,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ToUnicode')]
    [Alias('ToUnicode')]
    [Switch]$Unicode
  )

  process {
    switch ($pscmdlet.ParameterSetName) {
      'ToASCII' { 
        return [Text.Encoding]::ASCII.GetString($Data)
      }
      'ToBase64' {
        return [Convert]::ToBase64String($Data)
      }
      'ToBinary' {
        return (($Data | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join '')
      }
      'ToHex'   {
        $HexAlphabet = [Char[]]('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f')

        $Length = $Data.Length
        $ResultCharacters = New-Object Char[] ($Length * 2)
        for ($i = 0; $i -lt $Length; $i++) {
          [Byte]$Byte = $Data[$i]
          $j = $i * 2
          # Shift right to drop the last 4 bits. Allows conversion of the first of two characters.
          $ResultCharacters[$j] = $HexAlphabet[$Byte -shr 4]
          # Mask the last last 4 bits  with 00001111 (15 / 0x0F). Allows conversion of the second of two characters.
          $ResultCharacters[$j + 1] = $HexAlphabet[$Byte -band [Byte]0xF]
        }
        
        return New-Object String(,$ResultCharacters)
      }
      'ToUnicode' {
        return [Text.Encoding]::Unicode.GetString($Data)
      }
    }
  }
}

function ConvertTo-TimeSpanString {
  # .SYNOPSIS
  #   Converts a number of seconds to a string.
  # .DESCRIPTION
  #   ConvertTo-TimeSpanString accepts values in seconds then uses integer division to represent that time as a string.
  #
  #   ConvertTo-TimeSpanString accepts UInt32 values, overcoming the Int32 type limitation built into New-TimeSpan.
  #
  #   The format below is used, omitting any values of 0:
  #
  #   # weeks # days # hours # minutes # seconds
  #
  # .PARAMETER Seconds
  #   A number of seconds as an unsigned 32-bit integer. The maximum value is 4294967295 ([UInt32]::MaxValue).
  # .INPUTS
  #   System.UInt32
  # .OUTPUTS
  #   System.String  
  # .EXAMPLE
  #   ConvertTo-TimeSpanString 28800
  # .EXAMPLE
  #   [UInt32]::MaxValue | ConvertTo-TimeSpanString
  # .EXAMPLE
  #   86400, 700210 | ConvertTo-TimeSpanString

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeLine = $true)]
    [UInt32]$Seconds
  )

  begin {
    # Time periods described in seconds
    $Formats = [Ordered]@{
      week = 604800;
      day = 86400;
      hour = 3600;
      minute = 60;
      second = 1;
    }
  }
  
  process {
    $Values = $Formats.Keys | ForEach-Object {
      $Key = $_

      # Calculate the remainder prior to integer division
      $Remainder = $Seconds % $Formats[$Key]
      $Value = ($Seconds - $Remainder) / $Formats[$Key]
      # Decrement the original value
      $Seconds = $Remainder
      
      if ($Value) {
        # if the value is greater than 1, make the key name plural
        if ($Value -gt 1) { $Key = "$($Key)s" }
        
        "$Value $Key"
      }
    }
    return "$Values"
  }
}

function Get-DnsServerList {
  # .SYNOPSIS
  #   Gets a list of network interfaces and attempts to return a list of DNS server IP addresses.
  # .DESCRIPTION
  #   Get-DnsServerList uses System.Net.NetworkInformation to return a list of operational ethernet or wireless interfaces. IP properties are returned, and an attempt to return a list of DNS server addresses is made. If successful, the DNS server list is returned.
  # .OUTPUTS
  #   System.Net.IPAddress[]
  # .EXAMPLE
  #   Get-DnsServerList
  # .EXAMPLE
  #   Get-DnsServerList -IPv6

  [CmdLetBinding()]
  param(
    [Switch]$IPv6
  )

  if ($IPv6) {
    $AddressFamily = [Net.Sockets.AddressFamily]::InterNetworkv6
  } else {
    $AddressFamily = [Net.Sockets.AddressFamily]::InterNetwork
  }
  
  if ([Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()) {
    [Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
      Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -match 'Ethernet|Wireless' } |
      ForEach-Object { $_.GetIPProperties() } |
      Select-Object -ExpandProperty DnsAddresses -Unique |
      Where-Object AddressFamily -eq $AddressFamily
  }
}

function Get-DotNetVersion {
  # .SYNOPSIS
  #   Get all versions of .NET available on the local machine.
  # .DESCRIPTION
  #   Gets the installed versions of .NET from the registry on the local machine.
  # .OUTPUTS
  #   System.Management.Automation.PSCustomObject
  # .EXAMPLE
  #   Get-DotNetVersion
  # .LINK
  #   http://msdn.microsoft.com/en-us/library/hh925568%28v=vs.110%29.aspx

  [CmdLetBinding()]
  param( )
  
  $InstalledVersions = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -Recurse |
    Where-Object { $_.GetValue("Install", "") -eq 1 -and $_.GetValue("Version", "") -ne "" } |
    ForEach-Object {
      $_.Name -match '(v[^\\]+)' | Out-Null
      New-Object PsObject -Property ([Ordered]@{
          FrameworkVersion = $matches[1];
          Version          = $_.GetValue("Version");
          ServicePack      = $_.GetValue("SP");
      })
    }
  $InstalledVersions | Group-Object Version | ForEach-Object {
    $_.Group[0]
  }
}

function Get-Hash {
  # .SYNOPSIS
  #   Get a hash for the requested object.
  # .DESCRIPTION
  #   Generate a hash using .NET cryptographic service providers from the passed string, file or byte array.
  # .PARAMETER Algorithm
  #   The hashing algorithm to be used. By default, Get-Hash generates an MD5 hash.
  #
  #   Available algorithms are MD5, SHA1, SHA256, SHA384 and SHA512.
  # .PARAMETER ByteArray
  #   Generate a hash from the byte array.
  # .PARAMETER FileName
  #   Generate a hash of the file.
  # .PARAMETER String
  #   Generate a hash from the specified string.
  # .INPUTS
  #   System.Byte[]
  #   System.String
  # .OUTPUTS
  #   System.Byte[]
  #   System.String
  # .EXAMPLES
  #   Get-ChildItem C:\WindowsGet-Hash

  [CmdLetBinding(DefaultParameterSetName = 'String')]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ParameterSetName = 'String')]
    [String]$String,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'FileName')]
    [ValidateScript( { Test-Path $_ -PathType Leaf } )]
    [Alias('FullName')]
    [String]$FileName,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByteArray')]
    [Byte[]]$ByteArray,

    [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
    [String]$Algorithm = "MD5",
    
    [Switch]$AsString
  )

  begin {
    $CryptoServiceProvider = switch ($Algorithm) {
      "MD5"    { New-Object Security.Cryptography.MD5CryptoServiceProvider; break }
      "SHA1"   { New-Object Security.Cryptography.SHA1CryptoServiceProvider; break }
      "SHA256" { New-Object Security.Cryptography.SHA256CryptoServiceProvider; break }
      "SHA384" { New-Object Security.Cryptography.SHA384CryptoServiceProvider; break }
      "SHA512" { New-Object Security.Cryptography.SHA512CryptoServiceProvider; break }
    }
  }

  process {
    if ($pscmdlet.ParameterSetName -eq 'String') {
      $ByteArray = ConvertTo-Byte $String
    } elseif ($pscmdlet.ParameterSetName -eq 'FileName') {
      # Ensure the full path to the file is available
      $FullName = Get-Item $FileName | Select-Object -ExpandProperty FullName
      
      $FileStream = New-Object IO.FileStream($FullName, "Open", "Read", "Read")
      $ByteArray = New-Object Byte[] $FileStream.Length
      $FileStream.Read($ByteArray, 0, $FileStream.Length) | Out-Null
    }
    
    $HashValue = $CryptoServiceProvider.ComputeHash($ByteArray)
    
    if ($AsString) {
      ConvertTo-String $HashValue -Hexadecimal
    } else {
      $HashValue
    }
  }
  
  end {
    $CryptoServiceProvider.Dispose()
  }
}

function Get-WebContent {
  # .SYNOPSIS
  #   A function to simulate wget style calls.
  # .DESCRIPTION
  #   Get-WebContent uses System.Net.WebClient. Settings, such as proxy servers, are inherited from the computers Internet Settings. As such, Get-WebContent does not support a manually defined proxy.
  # .PARAMETER URL
  #   A remote resource URL.
  # .PARAMETER File
  #   Download the content at the URL to a file instead of standard out.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.String
  # .EXAMPLE
  #   Get-WebContent www.example.com
  # .EXAMPLE
  #   Get-WebContent www.example.com -File c:\example.htm
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]$URL,
    
    [String]$File
  )

  $WebClient = New-Object Net.WebClient
 
  if ($File) {
    # A full output file path to the file is required if one has not been supplied.
    if (-not (Split-Path $File)) {
      $File = "$($PWD.Path)\$File"
    }
    $WebClient.DownloadFile($URL, $File)
  } else {
    $WebClient.DownloadString($URL) -split '\r?\n'
  }
}

function New-Password {
  # .SYNOPSIS
  #   Creates a new complex password.
  # .DESCRIPTION
  #   Creates a new complex password.
  # .PARAMETER Length
  #   The minimum password length. The default value is 8.
  # .PARAMETER MustIncludeSets
  #   The number of character sets which must be included in the password. The default is 3 (of 4).
  # .INPUTS
  #   System.UInt32
  # .OUTPUTS
  #   System.String  
  # .EXAMPLE
  #   New-Password
  # .EXAMPLE
  #   New-Password -Length 30

  [CmdLetBinding()]
  param(
    [Int32]$Length = 8,
    [Int32]$MustIncludeSets = 3
  )

  $CharacterSets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                   "abcdefghijklmnopqrstuvwzyz",
                   "0123456789",
                   "!$%^&*-=_+#?"

  $Random = New-Object Random

  $Password = ""
  $IncludedSets = ""
  $IsNotComplex = $true
  while ($IsNotComplex -or $Password.Length -lt $Length) {
    $Set = $Random.Next(0, 4)

    if (-not ($IsNotComplex -and $IncludedSets -match "$Set" -And $Password.Length -lt ($Length - $IncludedSets.Length))) {
      if ($IncludedSets -notmatch "$Set") { $IncludedSets = "$IncludedSets$Set" }
      if ($IncludedSets.Length -ge $MustIncludeSets) { $IsNotcomplex = $false }

      $Password = "$Password$($CharacterSets[$Set].SubString($Random.Next(0, $CharacterSets[$Set].Length), 1))"
    }
  }
  return $Password
}

function Test-AdminRoleHolder {
  # .SYNOPSIS
  #   Tests to see if the current user holds an admin role.
  # .DESCRIPTION
  #   Uses the IsInRole function of System.Security.Principal.WindowsPrincipal to test whether or not the current user holds an administrative role in the current context.
  # .OUTPUTS
  #   System.Boolean
  # .EXAMPLE
  #   Test-AdminRoleHolder

  [CmdLetBinding()]
  param( )

  $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object Security.Principal.WindowsPrincipal $Identity).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Test-IsLocalhost {
  # .SYNOPSIS
  #   Tests whether or not the name or IP address value is the local system.
  # .DESCRIPTION
  #   Test-IsLocalHost attempts to work out if the value which has been passed is the local machine or not.
  #
  #   Tests are ordered by increasing computational cost, returning an answer at the earliest opportunity.
  # .PARAMETER Value
  #   The value to test.
  # .INPUTS
  #   System.String
  # .OUTPUTs
  #   System.Boolean
  # .EXAMPLE
  #   Test-IsLocalhost localhost
  # .EXAMPLE
  #   Test-IsLocalhost 1.2.3.4

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]$Value
  )

  if ($Value -match '^(\.|localhost|127\.0\.0\.1|::1)$') {
    return $true
  } else {
    $MachineName = [Environment]::MachineName
    if ($Value -eq $MachineName) {
      return $true
    } else {
      $GlobalIPProperties = [Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
      $DomainName = $GlobalIPProperties.DomainName
      if ($Value -eq "$MachineName.$DomainName") {
        return $true
      } else {
        $UnicastAddresses = $GlobalIPProperties.GetUnicastAddresses()
        foreach ($Address in $UnicastAddresses) {
          if ($Value -eq $Address.Address.IPAddressToString) {
            return $true
          }
        }
      }
    }
  }
  return $false
}

##############################################################################################################################################################
#                                                                         Auto-update                                                                        #
##############################################################################################################################################################

$AutoUpdateConfigurationFile = "$psscriptroot\AutoUpdateConfiguration.csv"
Start-IndentedAutoUpdate

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2+d2+cFsYU29nm92x6upJKlx
# i56gggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
# BAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUg
# RGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBD
# bGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRlIE9iamVjdCBDQTAeFw0xNDA0MTUw
# MjM4MjBaFw0xNjA0MTQxMzM5NDhaMHsxCzAJBgNVBAYTAkdCMRYwFAYDVQQIEw1I
# ZXJ0Zm9yZHNoaXJlMRQwEgYDVQQHEwtCb3JlaGFtd29vZDEZMBcGA1UEAxMQQ2hy
# aXN0b3BoZXIgRGVudDEjMCEGCSqGSIb3DQEJARYUY2hyaXNAaW5kZW50ZWQuY28u
# dWswggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC8qgMvi3CrIaYXMuF4
# hsyqH/Az5GbHm5gAyqORwjfYeT7LNb/hQuSr8O+jt39lHem30Yhn++jPWVGGQsYk
# 7RlSqXQ1nUbbJomqNxnMiat7OqnOOmWxjGgwDCfCXDqlgT+RK3J1+RvRa9ZDOkcA
# zjO6fsg4wBJd6+F1lAz4IOTuab/kJum4TGXQAUfjO1Em7EcrmA6Xu0pdkunYtsKn
# iZGDN8Zpu7Km/hSMnHRALjblFAiT8U4b9VhJqRyiOWmPWlHJn/a/qSexwOnP667B
# 0ydYL/iraNel1sKhniwOe8wMsUM5CF1+zL7WCS1Uhw16LvykbS5+LPSaBLFGY8I0
# 9v3FAgMBAAGjggLIMIICxDAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDAuBgNV
# HSUBAf8EJDAiBggrBgEFBQcDAwYKKwYBBAGCNwIBFQYKKwYBBAGCNwoDDTAdBgNV
# HQ4EFgQUP5UsJQgs37GI2zeMv/mp8Ri6vHMwHwYDVR0jBBgwFoAU0E4PQJlsuEsZ
# bzsouODjiAc0qrcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQIDMIIB
# KjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBk
# ZjCB9wYIKwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkwAwIBARqBvlRoaXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRp
# bmcgdG8gdGhlIENsYXNzIDIgVmFsaWRhdGlvbiByZXF1aXJlbWVudHMgb2YgdGhl
# IFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25seSBmb3IgdGhlIGludGVu
# ZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBwYXJ0eSBv
# YmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNz
# bC5jb20vY3J0YzItY3JsLmNybDCBiQYIKwYBBQUHAQEEfTB7MDcGCCsGAQUFBzAB
# hitodHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMi9jb2RlL2NhMEAG
# CCsGAQUFBzAChjRodHRwOi8vYWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xh
# c3MyLmNvZGUuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wu
# Y29tLzANBgkqhkiG9w0BAQsFAAOCAQEAD7BiUmVY3C8HGt488or/G3ch85ru/iA2
# LUS6AErbJsy/ocdIa1QVLb65r9+ioarwpShqhqUCWaJjI0Cx8Afrp6/WXsL807Ud
# 1P1sdfNGkVhewoVngzaV4JARgX9V/4E4BA8G1hBuFhc0CDrzj5tuhTarF+BmpRQ/
# X6B39m1mUMVGH0VDgzJptdF9CQayjG7fd9fYy6e92hxi2vZPeFf8HdEqFCiIhiSn
# /EZBvonC9/XgFqwPtxHPWtngo2Odl8YFWw047zxF7ODVziodzHUapS1v45QQug/K
# scqsn6Im2JG29caDOBPklC92dTXj/w56Crj6/8mlMTHJ+Km/NZCxHjCCBnAwggRY
# oAMCAQICASQwDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoT
# DVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmlj
# YXRlIFNpZ25pbmcxKTAnBgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0
# aG9yaXR5MB4XDTA3MTAyNDIyMDE0NloXDTE3MTAyNDIyMDE0NlowgYwxCzAJBgNV
# BAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUg
# RGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBD
# bGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRlIE9iamVjdCBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAMojiyI1HpqgGzydSdA/DJc4Fim6+H2JW0VY
# 74Rw7X4RTekUMatD400MUYFs8BUDSiQnVOX7SqDOTeGEoyHemTWr3EmuvzHFZ4Qw
# EJvvB9x1qA9N9DVTsW44A/yIdx2ld/8/defZ578sUBHJEWX6SQdin5Omh6ltyZ0r
# 0Xvl1WUrnw1Qnv77cRkhMCgmja7C3PaW6FKGCAt6Ms1qFE2eufnNB+KWkfHPHiv5
# gvdeJgaOjdHUOddv25EnWnmPWGkKRrVv4f1vxZG0EU97AqbbS1ZSI55LmOK/fs76
# oU6D48XHw2BH/lw/FRpAKpXvAGvIUPjNahnUIwMnvDs21blDsO8CAwEAAaOCAekw
# ggHlMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBTQ
# Tg9AmWy4SxlvOyi44OOIBzSqtzAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD
# 0EGu8jA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUHMAKGIWh0dHA6Ly93d3cuc3Rh
# cnRzc2wuY29tL3Nmc2NhLmNydDBbBgNVHR8EVDBSMCegJaAjhiFodHRwOi8vd3d3
# LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwJ6AloCOGIWh0dHA6Ly9jcmwuc3RhcnRz
# c2wuY29tL3Nmc2NhLmNybDCBgAYDVR0gBHkwdzB1BgsrBgEEAYG1NwECATBmMC4G
# CCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQG
# CCsGAQUFBwIBFihodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUu
# cGRmMBEGCWCGSAGG+EIBAQQEAwIAATBQBglghkgBhvhCAQ0EQxZBU3RhcnRDb20g
# Q2xhc3MgMiBQcmltYXJ5IEludGVybWVkaWF0ZSBPYmplY3QgU2lnbmluZyBDZXJ0
# aWZpY2F0ZXMwDQYJKoZIhvcNAQEFBQADggIBAHJzCwN1WjeDiBPZeEE+ThLWcuTw
# cgYrd6B4qkKYFREKOwx0bI1w+R/yMk4r6TIpGmnkcSL/eW2kXeIaFHDMA4+CSIwt
# 1gPRaDRVd9UjJYxGWuuhvEUBAnTEkrn4Hw2LtV0PnFCsYQ9xLSxhnBRo4zC+xEL9
# iKJe+NaxLMnF8CF3K8sXojG1Nkz4u193pW8EDHOCRZSeAcvRYQc7mQdQ1drDdoqx
# lWwtxv9fktnaDw4y9QmhJcEWv09KpKtr7z8VIK8gKAqaVBSlYsOcqBmAvs9RmnrF
# loj9XhSgC9MCOyIEry81N8tVae77GGsTlQambXmxU1kR7V4wrBa60AZ4LdHd90G0
# ESOZsIMxKe1yfcbuXekVVjOEz0VLHfgw2aQR5vZrM74vYFRW9mRu6kUVwkqsrOPr
# vzSwT214v5v5VNNHDg0E5Qv3rsI5PR0LUa10P86rASUulCfnixsNajn4/h1QZf2U
# KX6C5OyKFpUUL0S9bO6IqxGqj2VCFmP4K16va+owygKdy2XSkKTzp56ILapVOH+/
# 5C4xCYa63PfJqzlplTCvwbhUQH0OaA1DJ1ZgswMyzIynxnFVv4jHsONcn4YCm8KX
# 85tywa9Wb/qRAYHIFuqJ0S0gJ91xzNHjbc/gJMR+q0X+gdpmISxBBi2qR/EdQDAK
# OAW1RTmUeZF3DAsKMYICNTCCAjECAQEwgZMwgYwxCzAJBgNVBAYTAklMMRYwFAYD
# VQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0
# aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAyIFByaW1h
# cnkgSW50ZXJtZWRpYXRlIE9iamVjdCBDQQICDfcwCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGAu
# SIIYA33MS4qglMrUR6+GIJ9FMA0GCSqGSIb3DQEBAQUABIIBAK49iC4R7ESzAvdQ
# 7N9nMJvaprYiS6HCb0BwOm5UF2utNfRWz6Igp7Fvud6BxhrG/0nflwJgfWSrMXZx
# nWL3kMfZpiLwGlKfB96o02kjWs0RrmlWlNVr8bER0Ep7tO4FHr0w8aNgzdUWj88y
# CT5vJ37VVThngFaSMhYpszbrJrdP1WAldXmYPWlJ2NL0QPnRx5qknSjmrcRZjbTG
# 8so2Ob6TFTaYjMMZ8a70RfpcgkPKzI+eirOG0ne808IbOiANW3MJYUlGYkWzZVZS
# MzUEOkq8+OEpuhs1mtS87RAEY6HcZ2TbFNdb0U4HnFY1uLSHgPZW/6lHJv9OKzt8
# uGXFV1A=
# SIG # End signature block
