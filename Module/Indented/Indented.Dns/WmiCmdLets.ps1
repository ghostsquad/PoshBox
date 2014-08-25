<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  Get-DnsRecord                  WMI management            Public                01/11/2013
  Get-DnsZone                    WMI management            Public                04/11/2013
  Get-DnsServer                  WMI management            Public                06/11/2013
  Clear-DnsCache                 WMI management            Public                10/01/2014
  Reset-DnsZoneType              WMI management            Public                06/11/2013
  Set-DnsZoneTransfer            WMI management            Public                02/04/2014
#>

function Get_DnsRecordTest {
  # .SYNOPSIS
  #   Get DNS records from a Microsoft DNS server using WMI.
  # .DESCRIPTION
  #   Get-DnsRecord uses the root/MicrosoftDNS WMI namespace to get information about DNS records from a Microsoft DNS server.
  # .PARAMETER Name
  #   A record name used to find a record within a zone. The record must be from a configured zone (not cache).
  #
  #   @ may be used as a value for Name to represent the Origin (zone name). This can be used to return records configured at the root of a zone (such as NS, SOA and MX records).
  # .PARAMETER RegExName
  #   A regular expression used to filter a record name within a zone. The record must be from a configured zone (not the cache).
  # .PARAMETER FQDN
  #   The FQDN value will be to search for records. The search is performed across all configured zones and includes cached entries.
  # .PARAMETER RecordType
  #   By default Get-DnsRecord will return A, CNAME, NS, PTR, SOA and SRV records. This behaviour can be changed by supplying a value for this parameter.
  #
  #   One WMI query is performed for each RecordType, this CmdLet is more efficient if the RecordTypes requested are minimised.
  #
  #   Supported record types are: A, NS, MD, MF, CNAME, SOA, MB, MG, MR, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, SIG, KEY, AAAA, NXT, SRV, ATMA, WINS and WINSR
  # .PARAMETER ZoneName
  #   The zone name to search.
  # .PARAMETER Cache
  #   Get the content of the DNS cache on the server.
  # .PARAMETER Server
  #   By default Get-DnsRecord attempts to query localhost, if the server is remote a name must be defined.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   Indented.Dns.RecordType
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord
  #
  #   ResourceRecord may be considered to be a parent class, a record type specific class is returned.
  # .EXAMPLE
  #   Get-DnsRecord
  # 
  #   Get all A, CNAME, NS, PTR, SOA and SRV records from all zones hosted on the local system.
  # .EXAMPLE
  #   Get-DnsRecord -RecordType SOA -ZoneName domain.example
  #
  #   Get the SOA record for the zone domain.example.
  # .EXAMPLE
  #   Get-DnsRecord "@" NS
  #
  #   Get all NS records configured at the root of any zone.
  # .EXAMPLE
  #   Get-DnsRecord www A -ZoneName domain.example -Server RemoteServer -Credential (Get-Credential)
  #
  #   Get the A record named www from the domain.example zone on RemoteServer and prompt for credentials.
  # .EXAMPLE
  #   Get-DnsRecord -RegExName '^[A-Z]{6}[0-9]{2}$' -RecordType A -ZoneName domain.example
  #
  #   Get all A records which match the regular expression.
  # .EXAMPLE
  #   Get-DnsRecord -FQDN indented.co.uk -RecordType A
  #
  #   Get all instances of indented.co.uk A records from the server (including cached responses).

  [CmdLetBinding(DefaultParameterSetName = 'LiteralName')]
  param(
    [Parameter(Position = 1, ParameterSetName = 'LiteralName')]
    [Alias('RecordName', 'OwnerName')]
    [String]$Name,
    
    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'RegExName')]
    [String]$RegExName,

    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'FQDN')]
    [String]$FQDN,

    [Parameter(Position = 2, ParameterSetName = 'LiteralName')]
    [Parameter(ParameterSetName = 'RegExName')]
    [Parameter(ParameterSetName = 'FQDN')]
    [Parameter(ParameterSetName = 'CacheRecords')]
    [Indented.Dns.RecordType[]]$RecordType = ("A", "NS", "CNAME", "NS", "PTR", "SOA", "SRV"), 
    
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralName')]
    [Parameter(ParameterSetName = 'RegExName')]
    [Alias('ContainerName', 'DomainName')]
    [String]$ZoneName,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'CacheRecords')]
    [Switch]$Cache,
    
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("ComputerName", "Server")]
    [String]$ServerName = "localhost",

    [PSCredential]$Credential
  )

  process {
    # Attempt to pre-empt the error WMI will throw for this parameter combination.      
    if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "User credentials cannot be used for local connections"),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Credential)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # If no RecordType filter is set the search will include all possible record types supported 
    # by the WMI interface.
    if (-not $RecordType) {
      $WmiRecordType = [Enum]::GetNames([Indented.Dns.WmiRecordType])
    } else {
      # If a RecordType filter is set, convert the values to MicrosoftDNS class names.
      $WmiRecordType = $RecordType |
        Where-Object { [Enum]::IsDefined([Indented.Dns.WmiRecordType], [UInt16]$_) } |
        ForEach-Object { [Indented.Dns.WmiRecordType][UInt16]$_ }
    }
    # Handle errors if we have no resulting record type we can query.
    if (-not $WmiRecordType) {
      $ValidRecordTypes = [Enum]::GetValues([Indented.Dns.RecordType]) |
        Where-Object { [Enum]::IsDefined([Indented.Dns.WmiRecordType], [UInt16]$_) }

      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "RecordType type must be one of $($ValidRecordTypes -join ', ')."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $RecordType)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # The default search filter excludes the ..Cache and ..RootHints folders.
    $WqlFilter = "NOT ContainerName LIKE '..%'"
    if ($Cache) {
      $WqlFilter = "ContainerName='..Cache'"
    } elseif ($FQDN) {
      # To make the behaviour of this is relatively predictable; trim off trailing periods.
      $FQDN = $FQDN.TrimEnd('.')

      # Names from the cache are suffixed with a period, authoritative names are not.
      # The use of WQL OR allows the value to be returned regardless of user input but
      # will duplicate the result.
      $WqlFilter = "NOT ContainerName='..RootHints' AND (OwnerName='$FQDN' OR OwnerName='$FQDN.')"

    } elseif ($ZoneName) {
      $WqlFilter = "ContainerName='$ZoneName'"
    }

    $ConnectionManager = NewWmiConnectionManager -ServerName $ServerName -Credential $Credential
    $WmiRecordType | ForEach-Object {
      # Prepare the query for this record type.
      $WqlFilter = "SELECT * FROM $_ WHERE $WqlFilter"

      Write-Verbose "Get-DnsRecord: Executing WMI query against $_ using the WQL filter ""$WqlFilter"""

      $ConnectionManager.Search($WqlFilter) | ForEach-Object {
        if ($Name -or $RegExName) {
          # Take the container name and make it act like a regular expression
          $ZoneName = '\.' + ($_.ContainerName -replace '\.', '\.')
          $SubjectName = $_.OwnerName -replace $ZoneName

          # Execute name based filtering (if appliable)
          if ($Name -and $Name -ne '@') {
            if ($SubjectName.ToLower() -eq $Name.ToLower()) {
              $_
            }
          } elseif ($RegExName) {
            if ($SubjectName -match $RegExName) {
              $_
            }
          } elseif ($Name -eq '@' -and $_.OwnerName -eq $_.ContainerName) {
            $_
          }
        } else {
          $_
        }
      } # | ReadWmiDnsResourceRecord
    }
  }
}

function Get_DnsRecord {
  # .SYNOPSIS
  #   Get DNS records from a Microsoft DNS server using WMI.
  # .DESCRIPTION
  #   Get-DnsRecord uses the root/MicrosoftDNS WMI namespace to get information about DNS records from a Microsoft DNS server.
  # .PARAMETER Name
  #   A record name used to find a record within a zone. The record must be from a configured zone (not cache).
  #
  #   @ may be used as a value for Name to represent the Origin (zone name). This can be used to return records configured at the root of a zone (such as NS, SOA and MX records).
  # .PARAMETER RegExName
  #   A regular expression used to filter a record name within a zone. The record must be from a configured zone (not the cache).
  # .PARAMETER FQDN
  #   The FQDN value will be to search for records. The search is performed across all configured zones and includes cached entries.
  # .PARAMETER RecordType
  #   By default Get-DnsRecord will return A, CNAME, NS, PTR, SOA and SRV records. This behaviour can be changed by supplying a value for this parameter.
  #
  #   One WMI query is performed for each RecordType, this CmdLet is more efficient if the RecordTypes requested are minimised.
  #
  #   Supported record types are: A, NS, MD, MF, CNAME, SOA, MB, MG, MR, WKS, PTR, HINFO, MINFO, MX, TXT, RP, AFSDB, X25, ISDN, RT, SIG, KEY, AAAA, NXT, SRV, ATMA, WINS and WINSR
  # .PARAMETER ZoneName
  #   The zone name to search.
  # .PARAMETER Cache
  #   Get the content of the DNS cache on the server.
  # .PARAMETER Server
  #   By default Get-DnsRecord attempts to query localhost, if the server is remote a name must be defined.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   Indented.Dns.RecordType
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord
  #
  #   ResourceRecord may be considered to be a parent class, a record type specific class is returned.
  # .EXAMPLE
  #   Get-DnsRecord
  # 
  #   Get all A, CNAME, NS, PTR, SOA and SRV records from all zones hosted on the local system.
  # .EXAMPLE
  #   Get-DnsRecord -RecordType SOA -ZoneName domain.example
  #
  #   Get the SOA record for the zone domain.example.
  # .EXAMPLE
  #   Get-DnsRecord "@" NS
  #
  #   Get all NS records configured at the root of any zone.
  # .EXAMPLE
  #   Get-DnsRecord www A -ZoneName domain.example -Server RemoteServer -Credential (Get-Credential)
  #
  #   Get the A record named www from the domain.example zone on RemoteServer and prompt for credentials.
  # .EXAMPLE
  #   Get-DnsRecord -RegExName '^[A-Z]{6}[0-9]{2}$' -RecordType A -ZoneName domain.example
  #
  #   Get all A records which match the regular expression.
  # .EXAMPLE
  #   Get-DnsRecord -FQDN indented.co.uk -RecordType A
  #
  #   Get all instances of indented.co.uk A records from the server (including cached responses).

  [CmdLetBinding(DefaultParameterSetName = 'LiteralName')]
  param(
    [Parameter(Position = 1, ParameterSetName = 'LiteralName')]
    [Alias('RecordName', 'OwnerName')]
    [String]$Name,
    
    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'RegExName')]
    [String]$RegExName,

    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'FQDN')]
    [String]$FQDN,

    [Parameter(Position = 2, ParameterSetName = 'LiteralName')]
    [Parameter(ParameterSetName = 'RegExName')]
    [Parameter(ParameterSetName = 'FQDN')]
    [Parameter(ParameterSetName = 'CacheRecords')]
    [Indented.Dns.RecordType[]]$RecordType = ("A", "NS", "CNAME", "NS", "PTR", "SOA", "SRV"), 
    
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralName')]
    [Parameter(ParameterSetName = 'RegExName')]
    [Alias('ContainerName', 'DomainName')]
    [String]$ZoneName,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'CacheRecords')]
    [Switch]$Cache,
    
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("ComputerName", "Server")]
    [String]$ServerName = "localhost",

    [PSCredential]$Credential
  )

  process {
    # Attempt to pre-empt the error Get-WmiObject will throw for this parameter combination.      
    if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "User credentials cannot be used for local connections"),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Credential)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # If no RecordType filter is set the search will include all possible record types supported 
    # by the WMI interface.
    if (-not $RecordType) {
      $WmiRecordType = [Enum]::GetNames([Indented.Dns.WmiRecordType])
    } else {
      # If a RecordType filter is set, convert the values to MicrosoftDNS class names.
      $WmiRecordType = $RecordType |
        Where-Object { [Enum]::IsDefined([Indented.Dns.WmiRecordType], [UInt16]$_) } |
        ForEach-Object { [Indented.Dns.WmiRecordType][UInt16]$_ }
    }
    # Handle errors if we have no resulting record type we can query.
    if (-not $WmiRecordType) {
      $ValidRecordTypes = [Enum]::GetValues([Indented.Dns.RecordType]) |
        Where-Object { [Enum]::IsDefined([Indented.Dns.WmiRecordType], [UInt16]$_) }

      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "RecordType type must be one of $($ValidRecordTypes -join ', ')."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $RecordType)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # Define the parameters to pass to Get-WmiObject.
    $Params = @{}    
    if ($Credential) {
      $Params.Add("Credential", $Credential)
    }
    $Params.Add("ComputerName", $ServerName)
    $Params.Add("Namespace", "root\microsoftDNS")
    # Class is set later.
    $Params.Add("Class", "")

    # The default search filter excludes the ..Cache and ..RootHints folders.
    $WmiFilter = "NOT ContainerName LIKE '..%'"
    if ($Cache) {
      $WmiFilter = "ContainerName='..Cache'"
    } elseif ($FQDN) {
      # To make the behaviour of this is relatively predictable; trim off trailing periods.
      $FQDN = $FQDN.TrimEnd('.')

      # Names from the cache are suffixed with a period, authoritative names are not.
      # The use of WQL OR allows the value to be returned regardless of user input but
      # will duplicate the result.
      $WmiFilter = "NOT ContainerName='..RootHints' AND (OwnerName='$FQDN' OR OwnerName='$FQDN.')"

    } elseif ($ZoneName) {
      $WmiFilter = "ContainerName='$ZoneName'"
    }
    $Params.Add("Filter", $WmiFilter)

    $WmiRecordType | ForEach-Object {
      # Execute the query for this record type.

      Write-Verbose "Get-DnsRecord: Executing WMI query against $_ using the WQL filter ""$WmiFilter"""

      $Params.Class = $_

      $WmiError = $null
      # Get-WmiObject does not gracefully handle Access Denied exceptions (ErrorAction / ErrorVariable are ineffective).
      try {

        Get-WmiObject @Params -ErrorAction SilentlyContinue -ErrorVariable WmiError | ForEach-Object {

          if ($Name -or $RegExName) {
            # Take the container name and make it act like a regular expression
            $ZoneName = '\.' + ($_.ContainerName -replace '\.', '\.')
            $SubjectName = $_.OwnerName -replace $ZoneName

            # Execute name based filtering (if appliable)
            if ($Name -and $Name -ne '@') {
              if ($SubjectName.ToLower() -eq $Name.ToLower()) {
                $_
              }
            } elseif ($RegExName) {
              if ($SubjectName -match $RegExName) {
                $_
              }
            } elseif ($Name -eq '@' -and $_.OwnerName -eq $_.ContainerName) {
              $_
            }
          } else {
            $_
          }
        } | ReadWmiDnsResourceRecord

        # Error handling
        if ($WmiError) {
          switch -RegEx ($WmiError.Exception) {
            'Generic failure' {
              # Submitting a non-existent zone name will cause Get-WmiObject to throw a generic failure error message.
              if ($ZoneName) {
                $ErrorRecord = New-Object Management.Automation.ErrorRecord(
                  (New-Object ArgumentException "Query for records using WMI class $_ failed; Specified zone may not exist on server. Check zone name: $ZoneName."),
                  "ArgumentException",
                  [Management.Automation.ErrorCategory]::InvalidArgument,
                  $ZoneName)
                $pscmdlet.ThrowTerminatingError($ErrorRecord)
              }
              # If this does not capture the error it will fall down through to the default switch action.
            }
            'Invalid namespace' {
              $ErrorRecord = New-Object Management.Automation.ErrorRecord(
                (New-Object InvalidOperationException "Unable to access DNS information using WMI; DNS WMI components not available."),
                "InvalidOperation",
                [Management.Automation.ErrorCategory]::InvalidOperation,
                $ServerName)
              $pscmdlet.ThrowTerminatingError($ErrorRecord)
            }
            default {
              # Exceptions which are already reasonably well defined.
              #
              # Modify the error record to show a record in the context of this CmdLet then throw
              # the ErrorRecord as a terminating error.
              $ErrorRecord = New-Object Management.Automation.ErrorRecord(
                $WmiError.Exception,
                $WmiError.Exception.GetType().Name,
                $WmiError.CategoryInfo.Category,
                [Management.Automation.PsCmdLet]
              )
              $pscmdlet.ThrowTerminatingError($ErrorRecord)
            }
          }
        }

      } catch [UnauthorizedAccessException] {
        $ErrorRecord = New-Object Management.Automation.ErrorRecord(
          (New-Object UnauthorizedAccessException "Access is denied"),
          "UnauthorizedAccessException",
          [Management.Automation.ErrorCategory]::PermissionDenied,
          [Management.Automation.PsCmdLet]
        )
        $pscmdlet.ThrowTerminatingError($ErrorRecord)
      }

    }
  }
}

function Get_DnsZone {
  # .SYNOPSIS
  #   Get DNS zones from a Microsoft DNS server using WMI.
  # .DESCRIPTION
  #   Get-DnsZone uses the root/MicrosoftDNS WMI namespace to get information about DNS records from a Microsoft DNS server.
  # .PARAMETER Name
  #   The name of a lookup zone (forward or reverse) on the DNS server.
  #
  #   Name supports the use of standard wild card characters (* and ?).
  # .PARAMETER ZoneType
  #   Filter the list of zones to those of a specific type, valid types are Primary, Secondary, Stub and Conditional Forwarder.
  # .PARAMETER Forward
  #   Get Forward Lookup Zones only.
  # .PARAMETER Reverse
  #   Get Reverse Lookup Zones only.
  # .PARAMETER Server
  #   By default Get-DnsZone attempts to query localhost, if the server is remote a name must be defined.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Wmi.Zone
  # .EXAMPLE
  #   Get-DnsZone
  # 
  #   Get all zones configured on the local system.

  [CmdLetBinding(DefaultParameterSetName = 'AllLookupZones')]
  param(
    [Parameter(Position = 1)]
    [Alias('ZoneName', 'ContainerName', 'DomainName')]
    [String]$Name,

    [Parameter(Position = 2)]
    [Alias('Type')]
    [Indented.Dns.ZoneType]$ZoneType,

    [Parameter(Mandatory = $true, ParameterSetName = 'ForwardLookupZones')]
    [Switch]$Forward,

    [Parameter(Mandatory = $true, ParameterSetName = 'ReverseLookupZones')]
    [Switch]$Reverse,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("ComputerName", "Server")]
    [String]$ServerName = "localhost",

    [PSCredential]$Credential
  )

  process {
    # Attempt to pre-empt the error Get-WmiObject will throw for this parameter combination.      
    if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "User credentials cannot be used for local connections"),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Credential)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # Define the parameters to pass to Get-WmiObject.
    $Params = @{}    
    if ($Credential) {
      $Params.Add("Credential", $Credential)
    }
    $Params.Add("ComputerName", $ServerName)
    $Params.Add("Namespace", "root\microsoftDNS")
    $Params.Add("Class", "MicrosoftDNS_Zone")

    $WmiFilter = @()
    if ($Name -match '\*|\?') {
      # Swap wildcard characters for WQL wildcard characters.
      $Name = ($Name -replace '\*', '%') -replace '\?', '_'
      $WmiFilter += "ContainerName LIKE '$Name'"
    } else {
      $WmiFilter += "ContainerName='$Name'"
    }
    if ($ZoneType) {
      $WmiFilter += "ZoneType='$([UInt32]$ZoneType)'"
    }
    if ($Forward) {
      $WmiFilter += "Reverse=FALSE"
    } elseif ($Reverse) {
      $WmiFilter += "Reverse=TRUE"
    }
    $WmiFilter = [String]::Join(" AND ", $WmiFilter)
    if ($WmiFilter) {
      $Params.Add("Filter", $WmiFilter)
    }
 
    $WmiError = $null
    # Get-WmiObject does not gracefully handle Access Denied exceptions (ErrorAction / ErrorVariable are ineffective).
    try {

      Get-WmiObject @Params -ErrorAction SilentlyContinue -ErrorVariable WmiError | ReadWmiDnsZone

      # Error handling
      if ($WmiError) {
        switch -RegEx ($WmiError.Exception) {
          'Invalid namespace' {
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              (New-Object InvalidOperationException "Unable to access DNS information using WMI; DNS WMI components not available."),
              "InvalidOperation",
              [Management.Automation.ErrorCategory]::InvalidOperation,
              $ServerName)
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
          default {
            # Exceptions which are already reasonably well defined.
            #
            # Modify the error record to show a record in the context of this CmdLet then throw
            # the ErrorRecord as a terminating error.
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              $WmiError.Exception,
              $WmiError.Exception.GetType().Name,
              $WmiError.CategoryInfo.Category,
              [Management.Automation.PsCmdLet]
            )
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
        }
      }

    } catch [UnauthorizedAccessException] {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object UnauthorizedAccessException "Access is denied"),
        "UnauthorizedAccessException",
        [Management.Automation.ErrorCategory]::PermissionDenied,
        [Management.Automation.PsCmdLet]
      )
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
  }
}

function Get_DnsServer {
  # .SYNOPSIS
  #   Get DNS server settings from a Microsoft DNS server using WMI.
  # .DESCRIPTION
  #   Get-DnsServer uses the root/MicrosoftDNS WMI namespace and the registry to get settings from a Microsoft DNS server.
  # .PARAMETER Server
  #   By default Get-DnsServer attempts to query localhost, if the server is remote a name must be defined.
  # .PARAMETER Credential
  #   Specifies a user account that has permission to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Wmi.Server
  # .EXAMPLE
  #   Get-DnsServer
  # 
  #   Get all zones configured on the local system.
  
  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("ComputerName", "Server")]
    [String]$ServerName = "localhost",

    [PSCredential]$Credential
  )

  process {
    # Attempt to pre-empt the error Get-WmiObject will throw for this parameter combination.      
    if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "User credentials cannot be used for local connections"),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Credential)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # Define the parameters to pass to Get-WmiObject.
    $Params = @{}; $RegParams = @{}
    if ($Credential) {
      $Params.Add("Credential", $Credential)
      $RegParams.Add("Credential", $Credential)
    }
    $Params.Add("ComputerName", $ServerName)
    $Params.Add("Namespace", "root\microsoftDNS")
    $Params.Add("Class", "MicrosoftDNS_Server")

    $RegParams.Add("ComputerName", $ServerName)
    $RegParams.Add("Namespace", "root\default")
    $RegParams.Add("Class", "StdRegProv")

    $WmiError = $null
    # Get-WmiObject does not gracefully handle Access Denied exceptions (ErrorAction / ErrorVariable are ineffective).
    try {

      # Registry parameters need wiring properly.
      Get-WmiObject @Params -ErrorAction SilentlyContinue -ErrorVariable WmiError | ReadWmiDnsServer | ReadWmiDnsServerRegistry -Params $RegParams

      # Error handling
      if ($WmiError) {
        switch -RegEx ($WmiError.Exception) {
          'Invalid namespace' {
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              (New-Object InvalidOperationException "Unable to access DNS information using WMI; DNS WMI components not available."),
              "InvalidOperation",
              [Management.Automation.ErrorCategory]::InvalidOperation,
              $ServerName)
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
          default {
            # Exceptions which are already reasonably well defined.
            #
            # Modify the error record to show a record in the context of this CmdLet then throw
            # the ErrorRecord as a terminating error.
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              $WmiError.Exception,
              $WmiError.Exception.GetType().Name,
              $WmiError.CategoryInfo.Category,
              [Management.Automation.PsCmdLet]
            )
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
        }
      }
    } catch [UnauthorizedAccessException] {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object UnauthorizedAccessException "Access is denied"),
        "UnauthorizedAccessException",
        [Management.Automation.ErrorCategory]::PermissionDenied,
        [Management.Automation.PsCmdLet]
      )
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
  }
}

function Clear_DnsCache {
  # .SYNOPSIS
  #   Clear the DNS cache on the specified Microsoft DNS server using WMI.
  # .DESCRIPTION
  #   Clear-DnsCache uses the root/MicrosoftDNS WMI namespace to get clear cached responses from a Microsoft DNS server.
  # .PARAMETER Server
  #   By default Clear-DnsCache attempts to query localhost, if the server is remote a name must be defined.
  # .PARAMETER Credential
  #   Specifies a user account that has permittion to perform this action. The default is the current user. Get-Credential can be used to create a PSCredential object for this parameter.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Wmi.Server
  # .EXAMPLE
  #   Get-DnsServer
  # 
  #   Get all zones configured on the local system.
  
  [CmdLetBinding()]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias("ComputerName", "Server")]
    [String]$ServerName = "localhost",

    [PSCredential]$Credential
  )
  
  process {
    # Attempt to pre-empt the error Get-WmiObject will throw for this parameter combination.      
    if ($Credential -and $ServerName -match "^(?:$(hostname)|localhost|\.)$") {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "User credentials cannot be used for local connections"),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Credential)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }

    # Define the parameters to pass to Get-WmiObject.
    $Params = @{}
    if ($Credential) {
      $Params.Add("Credential", $Credential)
    }
    $Params.Add("ComputerName", $ServerName)
    $Params.Add("Namespace", "root\microsoftDNS")
    $Params.Add("Class", "MicrosoftDNS_Cache")

    $WmiError = $null
    # Get-WmiObject does not gracefully handle Access Denied exceptions (ErrorAction / ErrorVariable are ineffective).
    try {

      # Registry parameters need wiring properly.
      $Cache = Get-WmiObject @Params -ErrorAction SilentlyContinue -ErrorVariable WmiError

      # Error handling
      if ($WmiError) {
        switch -RegEx ($WmiError.Exception) {
          'Invalid namespace' {
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              (New-Object InvalidOperationException "Unable to access DNS information using WMI; DNS WMI components not available."),
              "InvalidOperation",
              [Management.Automation.ErrorCategory]::InvalidOperation,
              $ServerName)
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
          default {
            # Exceptions which are already reasonably well defined.
            #
            # Modify the error record to show a record in the context of this CmdLet then throw
            # the ErrorRecord as a terminating error.
            $ErrorRecord = New-Object Management.Automation.ErrorRecord(
              $WmiError.Exception,
              $WmiError.Exception.GetType().Name,
              $WmiError.CategoryInfo.Category,
              [Management.Automation.PsCmdLet]
            )
            $pscmdlet.ThrowTerminatingError($ErrorRecord)
          }
        }
      }
    } catch [UnauthorizedAccessException] {
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object UnauthorizedAccessException "Access is denied"),
        "UnauthorizedAccessException",
        [Management.Automation.ErrorCategory]::PermissionDenied,
        [Management.Automation.PsCmdLet]
      )
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
    
    if ($Cache) {
      $Cache | ForEach-Object {
        $_.ClearCache()
      }
    }
  }
}


function Reset_DnsZoneType {
  # .SYNOPSIS
  #   Reset the type of an existing zone using WMI.
  # .DESCRIPTION
  #
  # .PARAMETER WmiDnsZone
  # 
  # .PARAMETER NewZoneType
  #
  # .PARAMETER MasterList
  #
  # .PARAMETER ADIntegrated
  #
  # .PARAMEMTER PassThru

  [CmdLetBinding(DefaultParameterSetName = 'ToPrimary')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.Zone' } )]
    $WmiDnsZone,

    [Parameter(Mandatory = $true)]
    [Indented.Dns.ZoneType]$NewZoneType,

    [Net.IPAddress[]]$MasterList,

    [Switch]$ADIntegrated,

    [Switch]$PassThru
  )

  process {
    # Errors are non-terminating, the pipeline will be allowed to continue even if checks fail for a
    # single zone.
    $ErrorState = $false

    # No change to zone storage.
    if ($NewZoneType -eq $WmiDnsZone.ZoneType) {
      Write-Error "Reset-DnsZoneType: No zone type change."
      $ErrorState = $true
    }
    if ($NewZoneType -ne [Indented.Dns.ZoneType]::Master -and $MasterList.Count -lt 1) {
      # Attempt to use an existing list
      if ($WmiDnsZone.MasterServers) {
        $MasterList = $WmiDnsZone.MasterServers
      } elseif ($WmiDnsZone.LocalMasterServers) {
        $MasterList = $WmiDnsZone.LocalMasterServers
      } else {
        Write-Error "Reset-DnsZoneType: No master servers defined."
        $ErrorState = $true
      }
    }
    # Target type specific checks
    if ($NewZoneType -eq [Indented.Dns.ZoneType]::Master) {
      if ($WmiDnsZone.ZoneType -eq [Indented.Dns.ZoneType]::Stub -or $WmiDnsZone.ZoneType -eq [Indented.Dns.ZoneType]::Forwarder) {
        Write-Error "Reset-DnsZoneType: Cannot convert stub or forwarder to master."
        $ErrorState = $true
      }
      if ($WmiDnsZone.ZoneType -eq [Indented.Dns.ZoneType]::Slave -and $WmiDnsZone.Shutdown) {
        Write-Error "Reset-DnsZoneType: Cannot convert zones which have been shutdown."
        $ErrorState = $true
      }
    }

    if ($NewZoneType -eq [Indented.Dns.ZoneType]::Slave -or $NewZoneType -eq [Indented.Dns.ZoneType]::Stub) {
      if ($ADIntegrated) {
        Write-Warning "Reset-DnsZoneType: Only master or conditional forwarders can be AD integrated. Removing ADIntegrated flag."
      }
      $ADIntegrated = $false
    }

    if ($WmiDnsZone.DataFile) {
      $FileName = $WmiDnsZone.DataFile
    } else {
      $FileName = "$($WmiDnsZone.Name).dns"
    }

    if (-not $ErrorState) {
      $InParams = $WmiDnsZone.ManagementObject.GetMethodParameters("ChangeZoneType")

      $InParams["DataFileName"] = $FileName
      $InParams["DsIntegrated"] = $ADIntegrated
      $InParams["IpAddr"] = $ServerList
      $InParams["ZoneType"] = [UInt32]$NewZoneType - 1

      $NewWmiDnsZone = $WmiDnsZone.ManagementObject.InvokeMethod("ChangeZoneType", $inParams, $null) | ReadWmiDnsZone

      if ($PassThru) {
        $NewWmiDnsZone
      }
    }
  }
}

function Set_DnsZoneTransfer {
  # .SYNOPSIS
  #   Set the zone transfer and notify options for a zone using WMI.
  # .DESCRIPTION
  #   Set-DnsZoneTransfer attempts to apply changes to zone transfer settings to an existing DNS zone.
  # .PARAMETER WmiDnsZone
  #   A DNS zone object found using Get-DnsZone or any other CmdLet retuning a Indented.Dns.Wmi.Zone object.
  # .PARAMETER ZoneTransfer
  #   The zone transfer option may be set to any of Any, NS, List or None.
  # .PARAMETER SecondaryServers
  #   The specified server list will replace any existing secondary server list for the zone.
  # .PARAMETER Notify
  #   The notify option for the zone may be set to any of NS, List or None.
  # .PARAMETER NotifyServers
  #   The specified server list will replace any existing notify list for the zone.
  # .PARAMETER Append
  #   Changes the behaviour of the SecondaryServers and NotifyServers parameters. Instead of replacing the list, missing entries will be added to the end of the existing list.
  # .PARAMETER Remove
  #   Changes the behaviour of the SecondaryServers and NotifyServers parameters. Instead of replacing the list, matching entries will be removed from the existing list.

  [CmdLetBinding(DefaultParameterSetName = "Replace")]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.Zone' } )]
    $WmiDnsZone,
    
    [Indented.Dns.ZoneTransfer]$ZoneTransfer,
    
    [Parameter(ParameterSetName = "Replace")]
    [String[]]$SecondaryServers,
    
    [Indented.Dns.Notify]$Notify,
    
    [Parameter(ParameterSetName = "Replace")]
    [String[]]$NotifyServers,
    
    [Parameter(ParameterSetName = 'Append')]
    [Switch]$Append,
    
    [Parameter(ParameterSetName = 'Remove')]
    [Switch]$Remove
  )

  process {
    $InParams = $WmiDnsZone.ManagementObject.GetMethodParameters("ResetSecondaries")
    
    # Pre-populate $InParams with values from the existing zone.
    $InParams["SecureSecondaries"] = $WmiDnsZone.ZoneTransfer
    $InParams["SecondaryServers"] = $WmiDnsZone.SecondaryServers
    $InParams["Notify"] = $WmiDnsZone.Notify
    $InParams["NotifyServers"] = $WmiDnsZone.NotifyServers

    switch (pscmdlet.ParameterSetName) {
      'Append' {
        $SecondaryServers = (@($WmiDnsZone.SecondaryServers) + $SecondaryServers | Select-Object -Unique)
        $NotifyServers = (@($WmiDnsZone.NotifyServers) + $NotifyServers | Select-Object -Unique)
      }
      'Remove' {
        $SecondaryServers = $WmiDnsZone.SecondaryServers | Where-Object { $_ -notin $SecondaryServers }
        $NotifyServers = $WmiDnsZone.NotifyServers | Where-Object { $_ -notin $NotifyServers }
      }
    }

    # Set a change flag to false until a change to the current settings has been identified.
    $Change = $false
    if ($ZoneTransfer -and $ZoneTransfer -ne $WmiDnsZone.ZoneTransfer) {
      $InParams["SecureSecondaries"] = $ZoneTransfer
      $Change = $true
    }
    if ($SecondaryServers -and -not (Compare-Array $SecondaryServers $WmiDnsZone.SecondaryServers -ManualLoop -Sort)) {
      $InParams["SecondaryServers"] = $SecondaryServers
      $Change = $true
    }
    if ($Notify -and $Notify -ne $WmiDnsZone.Notify) {
      $InParams["Notify"] = $Notify
      $Change = $true
    }
    if ($NotifyServers -and -not (Compare-Array $NotifyServers $WmiDnsZone.NotifyServers -ManualLoop -Sort)) {
      $InParams["NotifyServers"] = $Notify
      $Change = $true
    }

    # Execute the change
    if ($Change) {
      $ZoneWmiObject.InvokeMethod("ResetSecondaries", $inParams, $null)
    } else {
      Write-Warning "Set-DnsZoneTransfer: Executed successfully against $($WmiDnsZone).Name but no settings were changed."
    }
  }
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnA8LvCRDGeszsCNXvvbKlxqV
# Y9agggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPFw
# PfwS9BmIp0CX/wNlCLnka1tSMA0GCSqGSIb3DQEBAQUABIIBALl0kB63/0NPPmXC
# O+OKJM6Sdmt9Ic9RxcP3Uorw05C6fpkuaM5zclEZll9bqdTxA1ofhPjOGngrKRq4
# SjKIAJqeU8zPU9mKmz0FiangJze41sZ2YASDdg8qVayqizF4JEk/yVIcqt570o4w
# +wp9E7NsdkuDupmtTyDEz6OKdf2kjnqNCpWlzUs7JOikKEbbgsL7hadb72KP8Tv/
# QrfWXucxbjR9WtmnX2EAXKJqTWuwhFxesyhoSIp62h6b2571hEwNt6JGdOFbifDc
# sRn21glZfTNVE1D56h/2cAOLCyqLnhnxFSaQ6j9VU3LpXCviBuJhJFW8igWstkKT
# fMEZJUY=
# SIG # End signature block
