<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  NewWmiConnectionManager        WMI management            Private               11/02/2014
  ReadWmiDnsServer               WMI management            Public                18/12/2013
  ReadWmiDnsZone                 WMI management            Public                05/11/2013
#>

function NewWmiConnectionManager {
  # .SYNOPSIS
  #   Creates a new WMI connection wrapper which includes error handling specific to the DNS namespace.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   A wrapper for WMI connections, abstracts the interface and allows a variety of returns through a single interface.
    
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [String]$ServerName,
    
    [PsCredential]$Credential
  )
  
  $WmiConnectionManager = New-Object PsObject -Property ([Ordered]@{
    ManagementScope = New-Object Management.ManagementScope("\\$ServerName\root\MicrosoftDns");
    State = "No Error";
    RegistryConnected = $false;
    RegistryClass = $null
  })

  # Update credentials
  if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
    $WmiConnectionManager.State = "User credentials cannot be used for local connections"
  } elseif ($Credential) {
    $WmiConnectionManager.ManagementScope.Options.Username = $Credential.Username
    $WmiConnectionManager.ManagementScope.Options.SecurePassword = $Credential.Password
  }
   
  # Method: Search
  $WmiConnectionManager | Add-Member Search -MemberType ScriptMethod -Value {
    param(
      [Parameter(Mandatory = $true)]
      [ValidatePattern('^SELECT (\*|\w+(, \w+)+) FROM \w+( WHERE .+)?$')]
      [String]$Filter
    )
  
    if ($this.State -eq 'No Error') {
      $ObjectQuery = New-Object Management.ObjectQuery($Filter)
      $Searcher = New-Object Management.ManagementObjectSearcher($this.ManagementScope, $ObjectQuery)

      # Catch any exceptions which should be modified and return all others.
      try {
        $Searcher.Get()
      } catch [Management.ManagementException] {
        if ($_.Exception.Message -match 'Invalid namespace') {
          $this.State = "DNS WMI namespace not available."
        } else {
          $this.State = $_.Exception.Message
        }
      } catch [Exception] {
        $_
        $this.State = $_.Exception.Message
        return
      }
    }
  }
  
  # Method: GetObject - Get a WMI object from a management path.
  $WmiConnectionManager | Add-Member GetObject -MemberType ScriptMethod -Value {
    param(
      [Parameter(Mandatory = $true)]
      [Management.ManagementPath]$Path
    )
  
    return New-Object Management.ManagementObject(
      $this.ManagementScope,
      $Path,
      (New-Object Management.ObjectGetOptions)
    )
  }

  # Method: GetClass - Get a WMI class from a management path.
  $WmiConnectionManager | Add-Member GetClass -MemberType ScriptMethod -Value {
    param(
      [Parameter(Mandatory = $true)]
      [Management.ManagementPath]$Path
    )
  
    return New-Object Management.ManagementClass(
      $this.ManagementScope,
      $Path,
      (New-Object Management.ObjectGetOptions)
    )
  }

  # Method: ConnectRegistry
  $WmiConnectionManager | Add-Member ConnectRegistry -MemberType ScriptMethod -Value {
    $this.RegistryConnected = $true
    $this.RegistryClass = New-Object Management.ManagementClass(
      (New-Object Management.ManagementScope("//$($this.ManagementScope.Path.Server)/root/default", $this.ManagementScope.Options)),
      [Management.ManagementPath]"StdRegProv",
      (New-Object Management.ObjectGetOptions)
    )
  }

  # Method: GetRegistryValue
  $WmiConnectionManager | Add-Member GetRegistryValue -MemberType ScriptMethod -Value {
    param(
      $Method,
      $Hive,
      $Key,
      $ValueName
    )
  
    $InParams = $this.RegistryClass.GetMethodParameters($Method)
    $InParams["hDefKey"] = $Hive
    $InParams["sSubKeyName"] = $Key
    $InParams["sValueName"] = $ValueName

    return this.RegistryClass.InvokeMethod($Method, $InParams, $null);
  }
  
  # Method: GetRegistryDWordValue 
  $WmiConnectionManager | Add-Member GetRegistryDWordValue -MemberType ScriptMethod -Value {
    param(
      [Parameter(Mandatory = $true)]
      [String]$Key,

      [Parameter(Mandatory = $true)]
      [String]$ValueName,
      
      [Indented.Dns.RegistryHive]$Hive = [Indented.Dns.RegistryHive]::HKLM
    )
    
    $OutParams = $this.GetRegistryValue("GetDWORDValue", $Key, $ValueName, $Hive)
    if ($OutParams["uValue"] -eq $null) {
      return [UInt32]::MaxValue
    }
    return [UInt32]$OutParams["uValue"]
  }

  # Method: GetRegistryMultiStringValue
  $WmiConnectionManager | Add-Member GetRegistryDWordValue -MemberType ScriptMethod -Value {
    param(
      [Parameter(Mandatory = $true)]
      [String]$Key,

      [Parameter(Mandatory = $true)]
      [String]$ValueName,
      
      [Indented.Dns.RegistryHive]$Hive = [Indented.Dns.RegistryHive]::HKLM
    )
    
    $OutParams = $this.GetRegistryValue("GetMultiStringValue", $Key, $ValueName, $Hive)
    if ($OutParams["sValue"] -eq $null) {
      return [String]::Empty
    }
    return $OutParams["sValue"]
  }
  
  return $WmiConnectionManager
}

function ReadWmiDnsServer {
  # .SYNOPSIS
  #   Reads DNS server information from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding zone information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.Server

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Management.ManagementObject]$ManagementObject
  )

  process {
    $WmiDnsServer = New-Object PsObject -Property ([Ordered]@{
      ServerName                 = $ManagementObject.Name;                                                        # General sever information
      Version                    = $null;                                                                         #
      BootMethod                 = [Indented.Dns.NameCheckFlag][UInt32]$ManagementObject.NameCheckFlag;           #
      AddressAnswerLimit         = [UInt32]$ManagementObject.AddressAnswerLimit;                                  #
      RecursionRetry             = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.RecursionRetry));            #
      RecursionTimeout           = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.RecursionTimeout));          #
      MaxCacheTTL                = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.MaxCacheTTL));               #
      MaxNegativeCacheTTL        = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.MaxNegativeCacheTTL));       #
      StrictFileParsing          = [Boolean]$ManagementObject.StrictFileParsing;                                  #
      LooseWildcarding           = [Boolean]$ManagementObject.LooseWildcarding;                                   #
      BindSecondaries            = [Boolean]$ManagementObject.BindSecondaries;                                    #
      DisableAutoReverseZones    = [Boolean]$ManagementObject.DisableAutoReverseZones;                            #
      AutoCacheUpdate            = [Boolean]$ManagementObject.AutoCacheUpdate;                                    #
      NoRecursion                = [Boolean]$ManagementObject.NoRecursion;                                        # 
      RoundRobin                 = [Boolean]$ManagementObject.RoundRobin;                                         #
      LocalNetPriority           = [Boolean]$ManagementObject.LocalNetPriority;                                   #
      WriteAuthorityNS           = [Boolean]$ManagementObject.WriteAuthorityNS;                                   #
      ForwardDelegations         = $false;                                                                        #
      SecureResponses            = [Boolean]$ManagementObject.SecureResponses;                                    #
      AutoConfigFileZones        = [Indented.Dns.AutoConfigZones][UInt32]$ManagementObject.AutoConfigFileZones;   #
      AllowCNAMEatNS             = $null;                                                                         #
      CacheLockingPercent        = $null;                                                                         #
      XfrConnectTimeout          = [UInt32]$ManagementObject.XfrConnectTimeout;                                   # Zone transfer
      Forwarders                 = [IPAddress[]]$ManagementObject.Forwarders;                                 # Global forwarders
      ForwardingTimeout          = (New-TimeSpan -Secnods ([UInt32]$ManagementObject.ForwardingTimeout));         #
      UseRecursion               = (-not [Boolean]$ManagementObject.IsSlave);                                     #
      ScavengingInterval         = (New-TimeSpan -Hours ([UInt32]$ManagementObject.ScavengingInterval));          # Aging and Scavenging
      DefaultAgingState          = [Boolean]$ManagementObject.DefaultAgingState;                                  #
      DefaultNoRefreshInterval   = (New-TimeSpan -Hours ([UInt32]$ManagementObject.DefaultNoRefreshInterval));    #
      DefaultRefreshInterval     = (New-TimeSpan -Hours ([UInt32]$ManagementObject.DefaultRefreshInterval));      #
      AllowServerUpdate          = [Boolean]$ManagementObject.AllowUpdate;                                        # Server-level auto-update controls (NS / SOA)
      ServerUpdateOptions        = [Indented.Dns.ServerDynamicUpdate][UInt32]$ManagementObject.UpdateOptions;     #
      EnableDirectoryPartitions  = [Boolean]$ManagementObject.EnableDirectoryPartitions;                          # DS Integration
      DsAvailable                = [Boolean]$ManagementObject.DsAvailable;                                        #
      DsPollingInterval          = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.DsPollingInterval));         #
      DsTombstoneInterval        = (New-TimeSpan -Seconds ([UInt32]$ManagementObject.DsTombstoneInterval));       #
      EventLogLevel              = [Indented.Dns.EventLogLevel]$ManagementObject.EventLogLevel;                   # Logging
      LogLevel                   = [Indented.Dns.LogLevel]$ManagementObject.LogLevel;                             #
      LogFilePath                = [String]$ManagementObject.LogFilePath;                                         #
      LogFileMaxSize             = [UInt32]$ManagementObject.LogFileMaxSize;                                      #
      LogIPFilterList            = [String[]]$ManagementObject.LogIPFilterList;                                   #  * Value is not reliably available using MicrosoftDNS_Server
      ServerAddresses            = [IPAddress[]]$ManagementObject.ServerAddresses;                            # Server bindings
      ListenAddresses            = [IPAddress[]]$ManagementObject.ListenAddresses;                            #
      SendPort                   = [UInt32]$ManagementObject.SendPort;                                            #
      EnableGlobalQueryBlockList = $null;                                                                         # Global query block list
      GlobalQueryBlockList       = $null;                                                                         #
      EnableEDnsProbes           = [Boolean]$ManagementObject.EnableEDnsProbes;                                   # EDNS
      EDnsCacheTimeout           = [UInt32]$ManagementObject.EDnsCacheTimeout;                                    # DNSSEC
      EnableDnsSec               = [Indented.Dns.DnsSecMode][UInt32]$ManagementObject.EnableDnsSec;               # RPC
      RpcProtocol                = [Indented.Dns.RpcProtocol][Uint32]$ManagementObject.RpcProtocol; 
      ManagementObject           = $ManagementObject;
    })
    $WmiDnsServer.PsObject.TypeNames.Add("Indented.Dns.Wmi.Server")

    $ManagementObject.Version = [Version][String]::Format("{0}.{1}.{2}",
      ([Byte](([UInt32]$ManagementObject.Version -band [UInt32][UInt16]::MaxValue) -band [Byte]::MaxValue)),
      ([Byte](([UInt32]$ManagementObject.Version -band [UInt32][UInt16]::MaxValue) -shr 8)),
      ([UInt16]([UInt32]$ManagementObject.Version -shr 16))
    )
    if ([UInt32]$ManagementObject.ForwardDelegations -ne 0) {
      $WmiDnsServer.ForwardDelegations = $true
    }
    if (!$WmiDnsServer.ListenAddresses) {
      $WmiDnsServer.ListenAddresses = $WmiDnsServer.ServerAddresses
    }

    # TO-DO: UpdateOptions == 783 when not set on the server?

    return $WmiDnsServer
  }
}

function ReadWmiDnsServerRegistry {
  # .SYNOPSIS
  #   Reads DNS server information from the registery using the WMI provider. Properties are added to an existing Indented.Dns.Wmi.Server object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   An Indented.Dns.Wmi.Server object created using ReadWmiDnsServer.
  # .INPUTS
  #   Indented.Dns.Wmi.Server
  # .OUTPUTS
  #   Indented.Dns.Wmi.Server
  #
  #   Properties are added to the existing object before it is returned.

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.Server' } )]
    [Management.ManagementObject]$WmiDnsServer,

    [HashTable]$Params = @{}
  )

  process {
    $WmiRegistry = Get-WmiClass @Params

    # Property: AllowCNAMEAtNS
    $


  }


  # Global Query Block List

                        # UInt32 EnableGlobalQueryBlockList = this.GetDWordValue(
                        #     RegKey,
                        #     "EnableGlobalQueryBlockList");
                        # if (EnableGlobalQueryBlockList == 1)
                        # {
                        #     ServerObject.EnableGlobalQueryBlockList = true;
                        # }

                        # // GlobalQueryBlockList

                        # ServerObject.GlobalQueryBlockList = this.GetMultiStringValue(
                        #     RegKey,
                        #     "GlobalQueryBlockList");#

  # Global Names


                        # UInt32 EnableGlobalNamesSupport = this.GetDWordValue(
                        #     RegKey,
                        #     "EnableGlobalNamesSupport");
                        # if (EnableGlobalNamesSupport == 1)
                        # {
                        #     ServerObject.EnableGlobalNamesSupport = true;
                        # }

                        # // GlobalNamesQueryOrder

                        # UInt32 GlobalNamesQueryOrder = this.GetDWordValue(
                        #     RegKey,
                        #     "GlobalNamesQueryOrder");
                        # if (GlobalNamesQueryOrder == 1)
                        # {
                        #     ServerObject.GlobalNamesQueryOrder = true;
                        # }

                        # // GlobalNamesBlockUpdates

                        # UInt32 GlobalNamesBlockUpdates = this.GetDWordValue(
                        #     RegKey,
                        #     "GlobalNamesBlockUpdates");
                        # if (GlobalNamesBlockUpdates == 1)
                        # {
                        #     ServerObject.GlobalNamesBlockUpdates = true;
                        # }

        # Attempt to add the values we can't get using WMI.

                        #         // AllowCNAMEAtNS

                        # UInt32 AllowCNAMEAtNS = this.GetDWordValue(
                        #     RegKey,
                        #     "AllowCNAMEAtNS");
                        # if (AllowCNAMEAtNS == 1)
                        # {
                        #     ServerObject.AllowCNAMEAtNS = true;
                        # }

                        # // CacheLockingPercent

                        # ServerObject.CacheLockingPercent = this.GetDWordValue(
                        #     RegKey,
                        #     "CacheLockingPercent");
                        # if (ServerObject.CacheLockingPercent == UInt32.MaxValue)
                        # {
                        #     ServerObject.CacheLockingPercent = 100;
                        # }







                        # // SocketPoolSize

                        # ServerObject.SocketPoolSize = this.GetDWordValue(
                        #     RegKey,
                        #     "SocketPoolSize");
                        # if (ServerObject.SocketPoolSize == UInt32.MaxValue | ServerObject.SocketPoolSize == 0)
                        # {
                        #     // Default value for SocketPoolSize
                        #     ServerObject.SocketPoolSize = 2500;
                        # }
                        
                        # // SocketPoolExcludedPortRanges

                        # ServerObject.SocketPoolExcludedPortRanges = this.GetMultiStringValue(
                        #     RegKey,
                        #     "SocketPoolExcludedPortRanges");


}
        
function ReadWmiDnsZone {
  # .SYNOPSIS
  #   Reads DNS zone information from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding zone information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.Zone

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Management.ManagementObject]$ManagementObject
  )

  process {
    $WmiDnsZone = New-Object PsObject -Property ([Ordered]@{
      ZoneName                   = $ManagementObject.Name;
      AutoCreated                = [Boolean]$ManagementObject.AutoCreated;
      ZoneType                   = [Indented.Dns.ZoneType]$ManagementObject.ZoneType;
      Reverse                    = [Boolean]$ManagementObject.Reverse;
      DataFile                   = $ManagementObject.DataFile;
      ADIntegrated               = [Boolean]$ManagementObject.DsIntegrated;
      DynamicUpdate              = [Indented.Dns.DynamicUpdate]$ManagementObject.AllowUpdate;
      Aging                      = $ManagementObject.Aging;
      AvailableForScavenging     = $null;
      NoRefreshInterval          = $null;
      RefrehsInterval            = $null;
      ScavengeServers            = $ManagementObject.ScavengeServers;
      ZoneTransfer               = [Indented.Dns.ZoneTransfer][UInt32]$ManagementObject.SecureSecondaries;
      SecondaryServers           = $ManagementObject.SecondaryServers;
      Notify                     = [Indented.Dns.Notify][UInt32]$ManagementObject.Notify;
      NotifyServers              = $ManagementObject.NotifyServers;
      MasterServers              = $ManagementObject.MasterServers;
      LocalMasterServers         = $ManagementObject.LocalMasterServers;
      LastSuccessfulSOACheck     = $null;
      LastSuccessfulTransfer     = $null;
      ForwarderUseRecursion      = [Boolean]$ManagementObject.ForwarderSlave;
      ForwarderTimeOut           = $ManagementObject.ForwarderTimeOut;
      UseWINSLookup              = [Boolean]$ManagementObject.UseWins;
      WINSReplicationEnabled     = $true;
      Paused                     = [Boolean]$ManagementObject.Paused;
      Shutdown                   = [Boolean]$ManagementObject.Shutdown;
      ServerName                 = $ManagementObject.DnsServerName;
      ManagementObject           = $ManagementObject;
    })
    $WmiDnsZone.PsObject.TypeNames.Add("Indented.Dns.Wmi.Zone")

    if ([UInt32]$ManagementObject.AvailForScavengeTime -gt 0) {
      $WmiDnsZone.AvailableForScavenging = (Get-Date '01/01/1601').AddHours([UInt32]$ManagementObject.AvailForScavengeTime -gt 0)
    }
    if ([UInt32]$ManagementObject.NoRefreshInterval -gt 0) {
      $WmiDnsZone.NoRefreshInterval = New-TimeSpan -Hours ([UInt32]$ManagementObject.NoRefreshInterval)
    } 
    if ([UInt32]$ManagementObject.RefreshInterval -gt 0) {
      $WmiDnsZone.RefreshInterval = New-TimeSpan -Hours ([UInt32]$ManagementObject.RefreshInterval)
    }
    if ([UInt32]$ManagementObject.LastSuccessfulSOACheck -gt 0) {
      $WmiDnsZone.LastSuccessfulSOACheck = (Get-Date '01/01/1970').AddSeconds([UInt32]$ManagementObject.LastSuccessfulSoaCheck)
    }
    if ([UInt32]$ManagementObject.LastSuccessfulTransfer -gt 0) {
      $WmiDnsZone.LastSuccessfulTransfer = (Get-Date '01/01/1970').AddSeconds([UInt32]$ManagementObject.LastSuccessfulXfr)
    }
    if ($ManagementObject.DisableWINSRecordReplication) {
      # Get rid of the double negative, this is enabled for all records and has no effect if UseWINS is false.
      $WmiDnsZone.WINSReplicationEnabled = $false
    }

    return $WmiDnsZone
  }
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFvaW42mPHugdE1szUpF/mSYQ
# i0mgggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFLxy
# 6FzQb9mYNq/6PlhwjHzf9KpXMA0GCSqGSIb3DQEBAQUABIIBADgv8i9nrInAfIbG
# hwVVhhHKXcCLzq3BGWL/k7e5RuRI1AkZXdzruuXJehVmxubXtkK4+TGgSOEJwwPd
# hfl3UMLXcYrqmE0/8FwU3wAnlQ20LvkNSYMLr108oCZnXfe5onOuTSXjtWgl0bS6
# BB83aWe0hXm+iopWHoGcIi/J/F3crW1riC48JakEc/TKlkFSQwdfeopVw+BY4cG7
# rWEbaIWTKoS7wapNRhCDCQQScUB2Kzh0s/d2weUoU6QEvo8wjJpECTFq14YvCIZn
# hedVSJ/fRI57k0Vq/fmtPfzqmxJyoP0dB6NdSePS1Ns2t7WEAblw0pKnryMsy2hA
# lPAW7z0=
# SIG # End signature block
