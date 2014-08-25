<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  Get-ADDnsPartition             AD Management             Public                03/10/2013
  Get-ADDnsRecord                AD Management             Public                07/10/2013
  Get-ADDnsZone                  AD Management             Public                04/10/2013
#>

function Get-ADDnsPartition {
  # .SYNOPSIS
  #   Get all partitions which are likely to contain DNS zones and records from Active Directory.
  # .DESCRIPTION
  #   Get-ADDnsPartition executes a search against the configuration subtree to locate partitions which may hold DNS information.
  # .PARAMETER Server
  #   By default, Get-ADDnsPartition will use serverless binding to locate a suitable directory server. If the query must be targetted, or run against a non-local forest domain, a server must be specified.
  # .PARAMETER Credential
  #   Specifies a user account that has permittion to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.AD.Partition
  # .EXAMPLE
  #   Get-ADDnsPartition
  # .EXAMPLE
  #   Get-ADDnsPartition -Credential (Get-Credential)
  # .EXAMPLE
  #   Get-ADDnsPartition -Server "remoteserver.testdomain.com" -Credential (Get-Credential)

  [CmdLetBinding()]
  param(
    [String]$Server = "",
  
    [Parameter(ParameterSetName = "")]
    [PSCredential]$Credential
  )

  $Params = @{}
  if ($Credential) {
    $Params.Add("Credential", $Credential)
  }
  $Params.Add("Server", "$Server")
  
  # Find the configuration NC
  $RootDSE = Get-LdapObject @Params -SearchScope Base
  $ConfigurationNamingContext = $RootDSE.Attributes['configurationnamingcontext'].Item(0)

  $LdapFilter = "(&(objectCategory=crossRef)(!name=Enterprise Configuration)(!name=Enterprise Schema))"
  $Properties = "name", "whenCreated", "objectGUID", "msDS-NC-Replica-Locations", "nCName", "nETBIOSName"

  Get-LdapObject @Params -SearchRoot $ConfigurationNamingContext -LdapFilter $LdapFilter -Properties $Properties | ForEach-Object {
  
    $DN = [String]$_.Attributes['ncname'].Item(0)
    if ($_.Attributes.AttributeNames -contains 'netbiosname') {
      $DN = "CN=MicrosoftDNS,CN=System,$DN"
      $PartitionType = "Legacy"
    }
    if ($DN -match '^dc=DomainDnsZones') {
      $PartitionType = "Domain"
    } elseif ($DN -match '^dc=ForestDnsZones') {
      $PartitionType = "Forest"
    } elseif (!$PartitionType) {
      $PartitionType = "Custom"
    }

    $ReplicaLocations = @()
    if ($_.Attributes.AttributeNames -contains 'msds-nc-replica-locations') {
      $Count = $_.Attributes['msds-nc-replica-locations'].Count
      for ($i = 0; $i -lt $Count; $i++) {
        $ReplicaLocations += $_.Attributes['msds-nc-replica-locations'].Item($i) -replace '^[^,]+,CN=|,.+$'
      }
    }

    $ADDnsPartition = New-Object PsObject -Property ([Ordered]@{
      DN               = $DN;
      PartitionType    = $PartitionType;
      ReplicaLocations = $ReplicaLocations;
      objectGUID       = ([GUID]$_.Attributes['objectguid'].Item(0));
      WhenCreated      = ([DateTime]::ParseExact(($_.Attributes['whencreated'].Item(0)), "yyyyMMddHHmmss.0Z", [Globalization.CultureInfo]::CurrentCulture))
    })
    $ADDnsPartition.PsObject.TypeNames.Add("Indented.Dns.AD.Partition")
  
    $ADDnsPartition
  }
}

function Get-ADDnsRecord {
  # .SYNOPSIS
  #   Get all DNS records from Active Directory.
  # .DESCRIPTION
  #   Get-ADDnsRecord executes a search against a partition holding DNS data to locate dnsNode objects.
  #
  #   Each dnsNode object contains one or more dnsRecord values.
  #
  #   Get-ADDnsRecord can return records which have been deleteed, where DNS tombstoned is set to True. As record type identifiers are stripped from deleted records the record data is returned as a simple byte array (BinaryData).
  # .PARAMETER Name
  #   A name is used to define an LDAP filter for a specific record. The name value supports standard LDAP wildcard characters.
  # .PARAMETER RecordType
  #   RecordType filtering is offered within this CmdLet as a convenience, it offers no operational benefit.
  # .PARAMETER SearchRoot
  #   An LDAP distinguished named defining the starting point for this query.
  # .PARAMETER Tombstone
  #   Return dnsTombstoned records.
  # .PARAMETER ChaseLdapReferrals
  #   By default, Get-ADDnsRecord does not follow referrals returned by an LDAP query. RefErr messages may be returned when executing a search. This behaviour may be changed using this parameter. The search will be modified to follow all referrals.
  # .PARAMETER Server
  #   By default, Get-ADDnsRecord will use serverless binding to locate a suitable directory server. If the query must be targetted, or run against a non-local forest domain, a server must be specified.
  # .PARAMETER Credential
  #   Specifies a user account that has permittion to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord
  #
  #   ResourceRecord may be considered to be a parent class, a record type specific class is returned.
  # .EXAMPLE
  #   Get-ADDnsRecord
  #
  #   All records under DomainDnsZones partition (the default search root) for the current domain.
  # .EXAMPLE
  #   Get-ADDnsZone domain.example | Get-ADDnsRecord
  #
  #   All records within the zone domain.example. The distinguishedName for the zone will be passed as the search root.
  # .EXAMPLE
  #   Get-ADDnsRecord AComputer
  # 
  #   Get a record with a specific named.
  # .EXAMPLE
  #   Get-ADDnsRecord -RecordType A
  #
  #   Filter the records to A only.
  # .EXAMPLE
  #   Get-ADDnsZone domain.example | Get-ADDnsRecord "@" SOA
  #
  #   The SOA record for domain.example. @ represents the zone name and is used as a literal character in AD.
  #
  #   The @ character is rewritten by Get-ADDnsRecord and is replaced with the zone name (parent container name in AD).

  [CmdLetBinding(DefaultParameterSetName = 'ActiveRecords')]
  param(
    [Parameter(Position = 1, ParameterSetName = 'ActiveRecords')]
    [String]$Name = "",

    [Parameter(Position = 2, ParameterSetName = 'ActiveRecords')]
    [Indented.Dns.RecordType[]]$RecordType,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'TombstonedRecords')]    
    [Switch]$Tombstone,
	
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("DN")]
    [String]$SearchRoot = "DC=DomainDnsZones,DC=$($env:UserDnsDomain -replace '\.', ',DC=')",
    
    [Switch]$ChaseLdapReferrals,
    
    [String]$Server = "",
  
    [PSCredential]$Credential
  )

  begin {
    $Params = @{}
    if ($Credential) {
      $Params.Add("Credential", $Credential)
    }
    if ($ChaseLdapReferrals) {
      $Params.Add("ReferralChasingOptions", [DirectoryServices.Protocols.ReferralChasingOptions]::All)
    }
    $Params.Add("Server", "$Server")

    $LdapFilter = "(&(objectCategory=dnsNode)(!dnsTombStoned=TRUE))"
    if ($Name) {
      $LdapFilter = [String]::Format("(&(objectCategory=dnsNode)(name={0}))", $Name)
    }
    if ($Tombstone) {
      $LdapFilter = "(&(objectCategory=dnsNode)(dnsTombStoned=TRUE))"
    }
    $Properties = "name", "distinguishedName", "whenCreated", "objectGuid", "dnsRecord", "dnsTombstoned"
  }
  
  process {
    Get-LdapObject @Params -SearchRoot $SearchRoot -LdapFilter $LdapFilter -Properties $Properties | ForEach-Object {
    
      $Count = $_.Attributes['dnsrecord'].Count
      for ($i = 0; $i -lt $Count; $i++) {
        $DnsRecord = $_.Attributes['dnsrecord'].GetValues([Byte[]])[$i]
        $BinaryReader = New-BinaryReader -ByteArray $DnsRecord
        
        $ResourceRecord = ReadADDnsResourceRecord -BinaryReader $BinaryReader -SearchResultEntry $_
        
        # Filter the return values by record type (but only if a filter is defined)
        if ($RecordType) {
          if ($RecordType -contains $ResourceRecord.RecordType) {
            $ResourceRecord
          }
        } else {
          $ResourceRecord
        }
      }
    }
  }
}

function Get-ADDnsZone {
  # .SYNOPSIS
  #   Get all dnsZone objects from an Active Directory partition.
  # .DESCRIPTION
  #   Get-ADDnsZone executes a search against a partition holding DNS information to locate dnsZone objects.
  #
  #   Each dnsZone object contains a dnsProperty attribute. The dnsProperty attribute is a multi-value field describing several properties, each of which is decoded by this CmdLet.
  # .PARAMETER Name
  #   A name is used to define an LDAP filter for a specific zone. The name value supports standard LDAP wildcard characters (* and ?).
  # .PARAMETER SearchRoot
  #   An LDAP distinguished named defining the starting point for this query.
  # .PARAMETER ChaseLdapReferrals
  #   By default, Get-ADDnsZone does not follow referrals returned by an LDAP query. RefErr messages may be returned when executing a search. This behaviour may be changed using this parameter. The search will be modified to follow all referrals.
  # .PARAMETER Server
  #   By default, Get-ADDnsZone will use serverless binding to locate a suitable directory server. If the query must be targetted, or run against a non-local forest domain, a server must be specified.
  # .PARAMETER Credential
  #   Specifies a user account that has permittion to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.AD.Zone  
  # .EXAMPLE
  #   Get-ADDnsZone
  #
  #   Get DNS zones from the DomainDnsZones partition in the current domain.
  # .EXAMPLE
  #   Get-ADDnsPartition | Get-ADDnsZone
  #
  #   Get DNS zones from all partitions in the current forest.
  # .EXAMPLE
  #   Get-ADDnsPartition | Get-ADDnsZone indented.co.uk
  #
  #   Get all instances of the indented.co.uk zone from all partitions in the forest.
  # .EXAMPLE
  #   Get-ADDnsZone -Credential (Get-Credential)
  # .EXAMPLE
  #   Get-ADDnsZone -Server "remoteserver.testdomain.com" -Credential (Get-Credential)

  [CmdLetBinding()]
  param(
    [String]$Name = "",

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("DN")]
    [String]$SearchRoot = "DC=DomainDnsZones,DC=$($env:UserDnsDomain -replace '\.', ',DC=')",

    [Switch]$ChaseLdapReferrals,
    
    [String]$Server = "",
  
    [Parameter(ParameterSetName = "")]
    [PSCredential]$Credential
  )

  begin {
    $Params = @{}
    if ($Credential) {
      $Params.Add("Credential", $Credential)
    }
    if ($ChaseLdapReferrals) {
      $Params.Add("ReferralChasingOptions", [DirectoryServices.Protocols.ReferralChasingOptions]::All)
    }
    $Params.Add("Server", "$Server")
    
    $LdapFilter = "(&(objectCategory=dnsZone))"
    if ($Name) {
      $LdapFilter = [String]::Format("(&(objectCategory=dnsZone)(name={0}))", $Name)
    }
    $Properties = "name", "distinguishedName", "whenCreated", "objectGuid", "dnsProperty"
  }
  
  process {
    Get-LdapObject @Params -SearchRoot $SearchRoot -LdapFilter $LdapFilter -Properties $Properties | ForEach-Object {
    
      $ADDnsZone = New-Object PsObject -Property ([Ordered]@{
        ZoneName                   = ($_.Attributes['name'].Item(0));
        DN                         = $_.DistinguishedName;
        objectGUID                 = ([GUID]$_.Attributes['objectguid'].Item(0));
        WhenCreated                = ([DateTime]::ParseExact(($_.Attributes['whencreated'].Item(0)), "yyyyMMddHHmmss.0Z", [Globalization.CultureInfo]::CurrentCulture))
        Aging                      = $false;
        AgingEnabledDate           = $Null;
        AllowNSRecordsAutoCreation = [IPAddress[]]@();
        DataFile                   = "";
        DeletedFromHostname        = "";
        DynamicUpdate              = [Indented.Dns.DynamicUpdate]"None";
        ForwarderUseRecursion      = $false;
        MasterServers              = [IPAddress[]]@();
        NoRefreshInterval          = $Null;
        RefreshInterval            = $Null;
        ScavengeServers            = [IPAddress[]]@();
        SecureTime                 = $Null;
        ZoneType                   = [Indented.Dns.ZoneType]::Primary;
      })
      $ADDnsZone.PsObject.TypeNames.Add("Indented.Dns.AD.Zone")
        
      # Decode the dnsProperty field
      $Count = $_.Attributes['dnsproperty'].Count
      for ($i = 0; $i -lt $Count; $i++) {
        $DnsProperty = $_.Attributes['dnsproperty'].GetValues([Byte[]])[$i]
        
        $BinaryReader = New-BinaryReader -ByteArray $DnsProperty
        
        $DataLength = $BinaryReader.ReadUInt32()
        $NameLength = $BinaryReader.ReadUInt32()
        $Flag = $BinaryReader.ReadUInt32()
        $Version = $BinaryReader.ReadUInt32()
        $ZonePropertyID = [Indented.Dns.ZonePropertyID]($BinaryReader.ReadUInt32())
        
        switch ($ZonePropertyID) {
          ([Indented.Dns.ZonePropertyID]::AgingEnabledTime) {
            $AgingEnabledHours = $BinaryReader.ReadUInt32()
            if ($AgingEnabledHours -gt 0) {
              # Property: AgingEnabledDate
              $ADDnsZone.AgingEnabledDate = (Get-Date "01/01/1601").AddHours($AgingEnabledHours)
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::AgingState) {
            if ($BinaryReader.ReadUInt32() -eq 1) {
              # Property: Aging
              $ADDnsZone.Aging = $true
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::AllowUpdate) {
            # Property: DynamicUpdate
            $ADDnsZone.DynamicUpdate = [Indented.Dns.DynamicUpdate]($BinaryReader.ReadByte())
            break
          }
          ([Indented.Dns.ZonePropertyID]::AutoNSServers) {
            if ($DataLength -ge 4) {
              $NumberOfServers = $BinaryReader.ReadUInt32()
              for ($j = 0; $j -lt $NumberOfServers; $j++) {
                # Property: AllowNSRecordsAutoCreation
                $ADDnsZone.AllowNSRecordsAutoCreation += $BinaryReader.ReadIPv4Address()
              }
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::AutoNSServersDA) {
            # Ignore this value
            break
          }
          ([Indented.Dns.ZonePropertyID]::DCPromoConvert) {
            # Hide this property
            break
          }
          ([Indented.Dns.ZonePropertyID]::DeletedFromHostname) {
            # Property: DeletedFromHostname
            $ADDnsZone.DeletedFromHostname = ConvertTo-String ($BinaryReader.ReadBytes($DataLength)) -Unicode
            break
          }
          ([Indented.Dns.ZonePropertyID]::MasterServers) {
            # Ignore this value
            break
          }
          ([Indented.Dns.ZonePropertyID]::MasterServersDA) {
            $MaxCount = $BinaryReader.ReadUInt32()
            $AddressCount = $BinaryReader.ReadUInt32()
            
            # Drop padding / reserved bytes
            $BinaryReader.ReadBytes(24) | Out-Null
            
            for ($j = 0; $j -lt $AddressCount; $j++) {
              # Each address is in a specific format across a number of fields
              $AddressFamily = [Net.Sockets.AddressFamily]($BinaryReader.ReadUInt16())
              # Probably need to reverse the endian order here if it's used.
              $Port = $BinaryReader.ReadUInt16()
              
              # The format includes sequential fields for both IPv4 and IPv6 addressing
              $IPv4 = $BinaryReader.ReadIPv4Address()
              $IPv6 = $BinaryReader.ReadIPv6Address()

              if ($AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork) {
                # Property: MasterServers
                $ADDnsZone.MasterServers += $IPv4
              } elseif ($AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkV6) {
                # Property: MasterServers
                $ADDnsZone.MasterServers += $IPv6
              }
              # Read off and discard the trailing data
              $BinaryReader.ReadBytes(8) | Out-Null
              # The SALen field (dnscmd returns this, ignoring it here beyond this comment)
              $BinaryReader.ReadUInt32() | Out-Null
              # Read off and discard the trailing data
              $BinaryReader.ReadBytes(28) | Out-Null
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::NodeDBFlags) {
            # Ignore this value
            break
          }
          ([Indented.Dns.ZonePropertyID]::NoRefreshInterval) {
            # Property: NoRefreshInterval
            $ADDnsZone.NoRefreshInterval = New-TimeSpan -Hours $BinaryReader.ReadUInt32()
            break
          }
          ([Indented.Dns.ZonePropertyID]::RefreshInterval) {
            # Property: RefreshInterval
            $ADDnsZone.RefreshInterval = New-TimeSpan -Hours $BinaryReader.ReadUInt32()
            break
          }
          ([Indented.Dns.ZonePropertyID]::ScavengingServers) {
            if ($DataLength -ge 4) {
              $NumberOfServers = $BinaryReader.ReadUInt32()
              for ($j = 0; $j -lt $NumberOfServers; $j++) {
                # Property: ScavengeServers
                $ADDnsZone.ScavengeServers += $BinaryReader.ReadIPv4Address()
              }
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::ScavengingServersDA) {
            # Ignore this value
            break
          }
          ([Indented.Dns.ZonePropertyID]::SecureTime) {
            $SecureTimeSeconds = $BinaryReader.ReadUInt64()
            if ($SecureTimeSeconds -gt 0) {
              # Property: SecureTime
              $ADDnsZone.SecureTime = (Get-Date "01/01/1601").AddSeconds($SecuretimeSeconds)
            }
            break
          }
          ([Indented.Dns.ZonePropertyID]::Type) {
            # Property: ZoneType
            $ADDnsZone.ZoneType = [Indented.Dns.ZoneType]$BinaryReader.ReadUInt32()
            break
          }
        }
      }
      $ADDnsZone
    }
  }
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcB4/KwntfM8P45CtzzJhn2/Y
# RB2gggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJmy
# E3c5nCJDDd9ozKclbb2QtkLQMA0GCSqGSIb3DQEBAQUABIIBAIi8KrLHVFaIGpU8
# +0QIsyxpcG58sJCZo5IdPs3RtcbIb6Ok3lUhvn2sMbGKntIMwcLny4zAgoujg2hy
# LlvrDyiJ8cQn/VmkJNlGvTcDR94yWGM6tOx8wPnYn6kF7/b2HJewVEmlhLzD7cXh
# b5RsKjnpg0NpEzH7f4KcxLPrSat1alRwulJE+9tb3ejB6xrYjiVdQI+G6bhDuyad
# vSA7y8P21/H8AzxT5maIgeOIMGly6p36HRz1kVxkABbq1O9CELmCvvk70jORX33T
# y/gxmLYKy/rzRPsh7J46Mta9G8hBfs9mS/isWap6I9W4uzfCRlXIrm+KosqBriJ9
# IT95lSU=
# SIG # End signature block
