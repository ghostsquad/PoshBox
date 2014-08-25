<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  Get-Dns                        DNS resolver              Public                28/04/2014
  Send-DnsDynamicUpdate          DNS resolver              Public                09/01/2014
  Initialize-InternalDnsCache    DNS cache                 Public                08/01/2014
  Get-InternalDnsCacheRecord     DNS cache                 Public                08/01/2014
  Add-InternalDnsCacheRecord     DNS cache                 Public                08/01/2014
  Remove-InternalDnsCacheRecord  DNS cache                 Public                28/04/2014
#>

function Get-Dns {
  # .SYNOPSIS
  #   Get a DNS resource record from a DNS server.
  # .DESCRIPTION
  #   Get-Dns is a debugging resolver tool similar to dig and nslookup.
  # .PARAMETER DnsDebug
  #   Forces Get-Dns to output intermediate requests which would normally be hidden, such as NXDomain replies when using a SearchList.
  # .PARAMETER DnsSec
  #   Advertise support for DNSSEC when executing a query.
  # .PARAMETER EDnsBufferSize
  #   By default the EDns buffer size is set to 4096 bytes. If NoEDns is used this value is ignored.
  # .PARAMETER IPv6
  #   Force the use of IPv6 for queries, if this parameter is set and the Server is set to a name (e.g. ns1.domain.example), Get-Dns will attempt to locate an AAAA record for the server.
  # .PARAMETER Iterative
  #   Perform a full iterative search for a name starting with the root servers. Intermediate queries are resolved using the locally configured name server to reduce the work-load as Get-Dns does not implement response caching.
  # .PARAMETER Name
  #   A resource name to query, by default Get-Dns will use '.' as the name. IP addresses (IPv4 and IPv6) are automatically converted into an appropriate format to aid PTR queries.
  # .PARAMETER NoEDns
  #   Disable EDNS support, suppresses OPT RR advertising client support in DNS question.
  # .PARAMETER NoRecursion
  #   Remove the Recursion Desired (RD) flag from a query. Recursion is requested by default.
  # .PARAMETER NoSearchList
  #   The use of a SearchList can be explicitly suppressed using the NoSearchList parameter.
  #
  #   SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
  # .PARAMETER NoTcpFallback
  #   Disable the use of TCP if a truncated response (TC flag) is seen when using UDP.
  # .PARAMETER NSSearch
  #   Locate the authoritative servers for a zone (using Server as a starting point), then execute a the query against each authoritative server. Aids the testing of replication failure between authoritative servers.
  # .PARAMETER Port
  #   By default, DNS uses TCP or UDP port 53. The port used to send queries may be changed if a server is listening on a different port.
  # .PARAMETER RecordClass
  #   By default the class is IN. CH (Chaos) may be used to query for name server information. HS (Hesoid) may be used if the name server supports it.
  # .PARAMETER RecordType
  #   Any resource record type, by default a query for ANY will be sent.
  # .PARAMETER SearchList
  #   If a name is not root terminated (does not end with '.') a SearchList will be used for recursive queries. If this parameter is not defined Get-Dns will attempt to retrieve a SearchList from the hosts network configuration.
  #
  #   SearchLists are explicitly dropped for Iterative, NSSearch, Zone Transfer and Version queries.
  # .PARAMETER SerialNumber
  #   The SerialNumber is used only if the RecordType is set to IXFR (either directly, or by using the ZoneTransfer parameter).
  # .PARAMETER Server
  #   A server name or IP address to execute a query against. If an IPv6 address is used Get-Dns will attempt the query using IPv6 (enables the IPv6 parameter). 
  #
  #   If a name is used another lookup will be required to resolve the name to an IP. Get-Dns caches responses for queries performed involving the Server parameter. The cache may be viewed and maintained using the *-InternalDnsCache CmdLets.
  #
  #   If no server name is defined, the Get-DnsServerList CmdLet is used to discover locally configured DNS servers.
  # .PARAMETER Tcp
  #   Recursive, or version, queries can be forced to use TCP by setting the TCP switch parameter.
  # .PARAMETER Timeout
  #   By default, queries will timeout after 5 seconds. The default value can be changed using the Timeout parameter. The value may be set between 1 and 30 seconds.
  # .PARAMETER Version
  #   Generates and sends a query for version.bind. using TXT as the RecordType and CH (Chaos) as the RecordClass.
  # .PARAMETER ZoneTransfer
  #   Constructs and executes a zone transfer request. If SerialNumber is also set an IXFR request will be generated using the algorithm discussed in draft-ietf-dnsind-ixfr-01. If SerialNumber is not set an AXFR request will be sent.
  #
  #   The use of TCP or UDP for zone transfer requests is fixed, AXFR will always use TCP. IXFR will attempt UDP and switch to TCP if a stub response is returned.
  # .OUTPUTS
  #   Indented.Dns.Message
  # .EXAMPLE
  #   Get-Dns hostname
  #
  #   Attempt to resolve hostname using the system-configured search list.
  # .EXAMPLE
  #   Get-Dns www.domain.example
  #
  #   The system-configured search list will be appended to this query before it is executed.
  # .EXAMPLE
  #   Get-Dns www.domain.example.
  #
  #   The name is fully-qualified (or root terminated), no additional suffixes will be appended.
  # .EXAMPLE
  #   Get-Dns www.domain.example -NoSearchList
  #
  #   No additional suffixes will be appended.
  # .EXAMPLE
  #   Get-Dns www.domain.example -Iterative
  #
  #   Attempt to perform an iterative lookup of www.domain.example, starting from the root hints.
  # .EXAMPLE
  #   Get-Dns www.domain.example CNAME -NSSearch
  #
  #   Attempt to return the CNAME record for www.domain.example from all authoritative servers for the parent zone.
  # .EXAMPLE
  #   Get-Dns -Version -Server 10.0.0.1
  #
  #   Request a version string from the server 10.0.0.1.
  # .EXAMPLE
  #   Get-Dns domain.example -ZoneTransfer -Server 10.0.0.1
  #
  #   Request a zone transfer, using AXFR, for domain.example from the server 10.0.0.1.
  # .EXAMPLE
  #   Get-Dns domain.example -ZoneTransfer -SerialNumber 2 -Server 10.0.0.1
  #
  #   Request a zone transfer, using IXFR and the serial number 2, for domain.example from the server 10.0.0.1.
  # .EXAMPLE
  #   Get-Dns example. -DnsSec
  #
  #   Request ANY record for the co.uk domain, advertising DNSSEC support.
  # .LINK
  #   http://www.ietf.org/rfc/rfc1034.txt
  #   http://www.ietf.org/rfc/rfc1035.txt
  #   http://tools.ietf.org/html/draft-ietf-dnsind-ixfr-01

  [CmdLetBinding(DefaultParameterSetname = 'RecursiveQuery')]
  param(
    [Parameter(Position = 1, ParameterSetName = 'RecursiveQuery')]
    [Parameter(Position = 1, ParameterSetName = 'IterativeQuery')]
    [Parameter(Position = 1, ParameterSetName = 'NSSearch')]
    [Parameter(Position = 1, ParameterSetName = 'ZoneTransfer')]
    [String]$Name = ".",

    [Parameter(Position = 2, ParameterSetname = 'RecursiveQuery')]
    [Parameter(Position = 2, ParameterSetname = 'IterativeQuery')]
    [Parameter(Position = 2, ParameterSetName = 'NSSearch')]
    [Alias('Type')]
    [Indented.Dns.RecordType]$RecordType = [Indented.Dns.RecordType]::ANY,

    [Parameter(Mandatory = $true, ParameterSetName = 'IterativeQuery')]
    [Alias('Trace')]
    [Switch]$Iterative,

    [Parameter(Mandatory = $true, ParameterSetName = 'NSSearch')]
    [Switch]$NSSearch,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'Version')]
    [Switch]$Version,

    [Parameter(Mandatory = $true, ParameterSetName = 'ZoneTransfer')]
    [Alias('Transfer')]
    [Switch]$ZoneTransfer,
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'IterativeQuery')]
    [Indented.Dns.RecordClass]$RecordClass = [Indented.Dns.RecordClass]::IN,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Alias('NoRecurse')]
    [Switch]$NoRecursion,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'IterativeQuery')]
    [Parameter(ParameterSetName = 'NSSearch')]
    [Switch]$DnsSec,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'IterativeQuery')]
    [Parameter(ParameterSetName = 'NSSearch')]
    [Switch]$NoEDns,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'IterativeQuery')]
    [Parameter(ParameterSetName = 'NSSearch')]
    [UInt16]$EDnsBufferSize = 4096,
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'IterativeQuery')]
    [Parameter(ParameterSetName = 'NSSearch')]
    [Switch]$NoTcpFallback,    
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [String[]]$SearchList,
  
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Switch]$NoSearchList,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'ZoneTransfer')]
    [UInt32]$SerialNumber,

    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'Version')]
    [Parameter(ParameterSetName = 'ZoneTransfer')]
    [Alias('ComputerName')]
    [String]$Server,
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'Version')]
    [Switch]$Tcp,
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'Version')]
    [UInt16]$Port = 53,
    
    [ValidateRange(1, 30)]
    [Byte]$Timeout = 5,
    
    [Parameter(ParameterSetName = 'RecursiveQuery')]
    [Parameter(ParameterSetName = 'Version')]
    [Parameter(ParameterSetName = 'ZoneTransfer')]
    [Switch]$IPv6,
    
    [Switch]$DnsDebug
  )

  #
  # Cache maintenance
  #
  
  Remove-InternalDnsCacheRecord -AllExpired

  #
  # Reset global control flags
  #

  $Script:IndentedDnsTCEndFound = $false
  
  #
  # Global query options
  #
  
  $GlobalOptions = @{}
  if ($NoEDns -and $DnsSec) {
    Write-Warning "Get-Dns: EDNS support is mandatory for DNSSEC. Enabling EDNS for this request."
    $NoDns = $false
  }
  if ($NoEDns) {
    $GlobalOptions.Add("NoEDns", $true) 
  } else {
    $GlobalOptions.Add("EDnsBufferSize", $EDnsBufferSize)     
  }
  if ($DnsSec) {
    $GlobalOptions.Add("DnsSec", $true)
  }
  if ($NoTcpFallback) {
    $GlobalOptions.Add("NoTcpFallback", $true) 
  }

  #
  # Name
  #

  $IsValidName = $false
  # Test and correct the input value, if an IP address is entered it will be converted to an appropriate format and in-addr.arpa will be appended.
  $IPAddress = [IPAddress]0
  if ([IPAddress]::TryParse($Name, [Ref]$IPAddress)) {
    # Convert IPv4 addresses into in-addr.arpa format.
    $IPAddressBytes = $IPAddress.GetAddressBytes()
    if ($IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork) {
      [Array]::Reverse($IPAddressBytes)
      $Name = ($IPAddressBytes -join '.') + '.in-addr.arpa.'
    } elseif ($IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkv6) {
      # Convert IPv6 addresses into ip6.arpa format.     
      $IPAddressString = ConvertTo-String $IPAddressBytes -Hexadecimal        
      $Name = ((($IPAddressString.Length - 1)..0 | ForEach-Object { $IPAddressString[$_] }) -join '.') + '.ip6.arpa.'
    }
    $IsValidName = $true
  }
  if (-not $IsValidName -and $Name -eq '.') {
    $IsValidName = $true
  }
  if (-not $IsValidname -and $Name -match '^([A-Z0-9]|_[A-Z])(([\w\-]{0,61})[^_\-])?(\.([A-Z0-9]|_[A-Z])(([\w\-]{0,61})[^_\-])?)*$|^\.$') {
    $IsValidName = $true
  }
  if (-not $IsValidName) {
    # SerialNumber is required, throw an error and abandon this.
    $ErrorRecord = New-Object Management.Automation.ErrorRecord(
      (New-Object ArgumentException "The value for Name ($Name) is not a valid format."),
      "ArgumentException",
      [Management.Automation.ErrorCategory]::InvalidArgument,
      $Name)
    $pscmdlet.ThrowTerminatingError($ErrorRecord)
  }

  #
  # Server
  #

  if (-not ($myinvocation.BoundParameters.ContainsKey("Server"))) {
    if ($IPv6) {
      $Server = (Get-DnsServerList -IPv6 | Select-Object -ExpandProperty IPAddressToString | Select-Object -First 1)
    } else {
      $Server = (Get-DnsServerList | Select-Object -ExpandProperty IPAddressToString | Select-Object -First 1)
    }
  }
  if (-not $Server) {
    # Failed to resolve name. Return an error.
    $ErrorRecord = New-Object Management.Automation.ErrorRecord(
      (New-Object ArgumentException "No name servers available."),
      "ArgumentException",
      [Management.Automation.ErrorCategory]::InvalidArgument,
      $Server)
    $pscmdlet.ThrowTerminatingError($ErrorRecord)
  }
 
  if ($IPv6) {
    $ServerRecordType = [Indented.Dns.RecordType]::AAAA
  } else {
    $ServerRecordType = [Indented.Dns.RecordType]::A
  }
 
  # Recursive call to find the IP address associated with a server name (if a name is supplied instead of an IP)
  $IPAddress = New-Object IPAddress 0
  if ([IPAddress]::TryParse($Server, [Ref]$IPAddress)) {
    # Forcefully switch to IPv6 mode if an IPv6 server address is supplied.
    if ($IPAddress.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetworkv6) {
      Write-Verbose "Get-Dns: Server: IPv6 Server value used. Switching to IPv6 transport."
      $IPv6 = $true
    }
  } else {
    # Unable to parse the server as an IP address. Attempt to resolve it.

    # Attempt a cache lookup - Note: This will not catch servers names which resolve because suffixes have been added.
    $CachedServer = Get-InternalDnsCacheRecord $Server $ServerRecordType
    if ($CachedServer) {
      Write-Verbose "Get-Dns: Cache: Using Server ($Server) from cache."
      $IPAddress = $CachedServer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress
    } else {
      # If the cache lookup fails, execute a full lookup
      Write-Verbose "Get-Dns: Server: Attempting to lookup $Server $ServerRecordType"
      $DnsResponse = Get-Dns $Server -RecordType $ServerRecordType
      
      if ($DnsResponse.Answer) {
        # Addresses will be returned using round-robin ordering. Honour that and use the first address.
        $IPAddress = $DnsResponse.Answer | Select-Object -First 1 | Select-Object -ExpandProperty IPAddress

        # Add the response to the cache.
        Write-Verbose "Get-Dns: Cache: Adding Server ($Server) to cache."
        $DnsResponse.Answer | ForEach-Object {
          Add-InternalDnsCacheRecord -ResourceRecord $_
        }
      }
    }
    if ($IPAddress) {
      $Server = $IPAddress
    } else {
      # Failed to resolve name. Return an error.
      $ErrorRecord = New-Object Management.Automation.ErrorRecord(
        (New-Object ArgumentException "Unable to find an IP address for the specified name server ($Server)."),
        "ArgumentException",
        [Management.Automation.ErrorCategory]::InvalidArgument,
        $Server)
      $pscmdlet.ThrowTerminatingError($ErrorRecord)
    }
  }
  
  #
  # Suffix search list
  #

  # Used if:
  #
  # 1. The name does not end with '.' (root terminated).
  # 2. A search list has not been defined.
  #
  # Skipped if:
  #
  # 1. An Iterative query is being performed.
  # 2. A zone transfer is not being performed (AXFR or IXFR).
  # 3. NoSearchList has been set.
  #
  # Applies to both single-label and multi-label names.
  if ($NoSearchList -or $NSSearch -or $Iterative -or $ZoneTransfer -or $Name.EndsWith('.')) {
    $SearchList = ""
  } else {
    if (-not $SearchList) {
      # If a search list has not been passed using the SearchList parameter attempt to discover one.
      $SearchList = Get-WmiObject Win32_NetworkAdapterConfiguration |
        Where-Object DNSDomainSuffixSearchOrder |
        Select-Object -ExpandProperty DNSDomainSuffixSearchOrder |
        ForEach-Object { "$_." }
      Write-Verbose "Get-Dns: SearchList: Automatically retrieved and set to $SearchList"
    }
    # If the name is multi-label allow it to be sent without a suffix.
    if ($Name -match '[^.]+\.[^.]+') {
      # Add an empty (root) SearchList item
      $SearchList += ""
    }
  }
  # For consistent operation now the search list has been set.
  if (-not $Name.EndsWith('.')) {
    $Name = "$Name."
  }
  
  #
  # Advanced queries and queries requiring recursive calls.
  #
  
  #
  # Version requests
  #
  
  if ($Version) {
    # RFC 4892 (http://www.ietf.org/rfc/rfc4892.txt)
    $Name = "version.bind."
    $RecordType = [Indented.Dns.RecordType]::TXT
    $RecordClass = [Indented.Dns.RecordClass]::CH
  }
  
  #
  # Iterative searches
  #

  if ($Iterative) {
    # Pick a random(ish) server from Root Hints
    $HintRecordSet = Get-InternalDnsCacheRecord -RecordType A -ResourceType Hint
    $Server = $HintRecordSet[(Get-Random -Minimum 0 -Maximum ($HintRecordSet.Count - 1))] | Select-Object -ExpandProperty IPAddress
    
    $NoError = $true; $NoAnswer = $true
    while ($NoError -and $NoAnswer) {

      $DnsResponse = Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -NoRecursion -Server $Server @GlobalOptions
      
      if ($DnsResponse.Header.RCode -ne [Indented.Dns.RCode]::NoError)  {
        $NoError = $false
      } else {
        if ($DnsResponse.Header.ANCount -gt 0) {
          $NoAnswer = $false
        } elseif ($DnsResponse.Header.NSCount -gt 0) {
          $Authority = $DnsResponse.Authority | Select-Object -First 1

          # Attempt to match between Authority and Additional. No need to execute another lookup if we have the information.
          $Server = $DnsResponse.Additional |
            Where-Object { $_.Name -eq $Authority.Hostname -and $_.RecordType -eq [Indented.Dns.RecordType]::A } |
            Select-Object -ExpandProperty IPAddress |
            Select-Object -First 1
          if ($Server) {
            Write-Verbose "Get-Dns: Iterative query: Next name server IP: $Server"
          } else {
            $Server = $Authority[0].Hostname
            Write-Verbose "Get-Dns: Iterative query: Next name server Name: $Server"
          }
        }
      }
      
      # Return the response to the output pipeline
      $DnsResponse
    }
  }

  #
  # Name server searches
  #
  
  if ($NSSearch) {
    # Get the zone name from the SOA record
    Write-Verbose "Get-Dns: NSSearch: Finding start of authority."
    $DnsResponse = Get-Dns $Name -RecordType SOA -Server $Server -NoSearchList
    if ($DnsDebug) {
      $DnsResponse
    }
    if ($DnsResponse.Header.RCode -eq [Indented.Dns.RCode]::NoError -and $DnsResponse.Header.ANCount -gt 0) {
      $ZoneName = $DnsResponse.Answer | Where-Object RecordType -eq ([Indented.Dns.RecordType]::SOA) | Select-Object -ExpandProperty Name
    } elseif ($DnsResponse.Header.RCode -eq [Indented.Dns.RCode]::NoError -and $DnsResponse.Header.NSCount -gt 0) {
      $ZoneName = $DnsResponse.Authority | Where-Object RecordType -eq ([Indented.Dns.RecordType]::SOA) | Select-Object -ExpandProperty Name
    }
    
    # Get the name servers for the zone
    Write-Verbose "Get-Dns: NSSearch: Finding name servers for zone ($ZoneName)."
    $DnsResponse = Get-Dns $ZoneName -RecordType NS -Server $Server -NoSearchList
    if ($DnsDebug) {
      $DnsDebug
    }
    $AuthoritativeServerList = $DnsResponse.Answer | Where-Object RecordType -eq ([Indented.Dns.RecordType]::NS) | ForEach-Object {
      $NameServer = $_
      $NameServerIP = $DnsResponse.Additional |
        Where-Object { $_.Name -eq $NameServer.Hostname -and ($_.RecordType -eq [Indented.Dns.RecordType]::A -or $_.RecordType -eq [Indented.Dns.RecordType]::AAAA) } |
        Select-Object -ExpandProperty IPAddress 
      if ($NameServerIP) {
        $NameServerIP.ToString()
      } else {
        $_.Hostname
      }
    }
 
    # Query each authoritative server
    Write-Verbose "Get-Dns: NSSearch: Testing responses from each authoritative servers"
    $AuthoritativeServerList | ForEach-Object {
      Get-Dns $Name -RecordType $RecordType -RecordClass $RecordClass -Server $_ -NoSearchList @GlobalOptions
    }
  }
  
  #
  # Zone Transfer
  #
  
  if ($RecordType -eq [Indented.Dns.RecordType]::IXFR -and -not $SerialNumber) {
    # SerialNumber is required, throw an error and abandon this.
    $ErrorRecord = New-Object Management.Automation.ErrorRecord(
      (New-Object ArgumentException "A value for SerialNumber must be supplied to execute an IXFR."),
      "ArgumentException",
      [Management.Automation.ErrorCategory]::InvalidArgument,
      $RecordType)
    $pscmdlet.ThrowTerminatingError($ErrorRecord)
  }
  if ($ZoneTransfer -and $myinvocation.BoundParameters.ContainsKey("SerialNumber")) {
    #
    # IXFR
    #
  
    $RecordType = [Indented.Dns.RecordType]::IXFR
    $DnsResponse = Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -NoSearchList
    
    if ($DnsResponse.Header.RCode -eq [Indented.Dns.RCode]::NoError) {
      if ($DnsResponse.Answer[0].Serial -le $SerialNumber) {
        # Complete, the zone is already up to date.
        Write-Verbose "Get-Dns: IXFR: Transfer complete, zone is up to date."
        $DnsResponse
      } else {
        if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [Indented.Dns.RecordType]::SOA) {
          # The message was a UDP overflow response, restart using TCP
          Write-Verbose "Get-Dns: IXFR: UDP overflow response. Attempting TCP."
          Get-Dns $Name -RecordType $RecordType -Server $Server -SerialNumber $SerialNumber -Tcp -NoSearchList
        }
      }
    } else {
      # Allow an error message return.
      $DnsResponse
    }
  } elseif ($ZoneTransfer) {
    #
    # AXFR
    #
  
    $RecordType = [Indented.Dns.RecordType]::AXFR
    $Tcp = $true
    
    # Clear the zone transfer parameter, allow normal message processing from here.
    $ZoneTransfer = $false
  }
  
  #
  # Execute a query
  #
  
  if (-not $Iterative -and -not $NSSearch -and -not $ZoneTransfer) {
    $SearchStatus = [Indented.Dns.RCode]::NXDomain; $i = 0
    
    # SearchList loop
    do {
    
      $Suffix = $SearchList[$i]
      if ($Suffix) {
        $FullName = "$Name$Suffix"
      } else {
        $FullName = $Name
      }

      Write-Verbose "Get-Dns: Query: $FullName $RecordClass $RecordType :: Server: $Server Protocol: $(if ($Tcp) { 'TCP' } else { 'UDP' }) AddressFamily: $(if ($IPv6) { 'IPv6' } else { 'IPv4' })"

      # Construct a message
      if ($RecordType -eq [Indented.Dns.RecordType]::IXFR -and $SerialNumber) {
        $DnsQuery = NewDnsMessage -Name $FullName -RecordType $RecordType -RecordClass $RecordClass -SerialNumber $SerialNumber
      } else {
        $DnsQuery = NewDnsMessage -Name $FullName -RecordType $RecordType -RecordClass $RecordClass
      }
      if (-not $NoEDns -and -not ($RecordType -in ([Indented.Dns.RecordType]::AXFR), ([Indented.Dns.RecordType]::IXFR))) {
        $DnsQuery.SetEDnsBufferSize($EDnsBufferSize) 
      }
      if ($DnsSec -and -not ($RecordType -in ([Indented.Dns.RecordType]::AXFR), ([Indented.Dns.RecordType]::IXFR))) {
        $DnsQuery.SetAcceptDnsSec()
      }
      
      if ($NoRecursion) {
        # Recursion is set by default, toggle the flag.
        $DnsQuery.Header.Flags = [Indented.Dns.Flags]([UInt16]$DnsQuery.Header.Flags -bxor [UInt16][Indented.Dns.Flags]::RD)
      }

      $Start = Get-Date

      # Construct a socket and send the request.
      if ($Tcp -and $IPv6) {
      
        # Create an IPv6 TCP socket, connect and send the message using IPv6
        $Socket = New-Socket -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6
        try {
          Connect-Socket $Socket -RemoteIPAddress $Server -RemotePort $Port
        } catch [Net.Sockets.SocketException] {
          $ErrorRecord = New-Object Management.Automation.ErrorRecord(
            (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
            "IPv6 TCP connection to Server ($Server/$Port) failed",
            [Management.Automation.ErrorCategory]::ConnectionError,
            $Socket)
          $pscmdlet.ThrowTerminatingError($ErrorRecord)
        }
        Send-Bytes $Socket -Data ($DnsQuery.ToByte([Net.Sockets.ProtocolType]::Tcp))
      
      } elseif ($Tcp) {
      
        # Create a TCP socket, connect and send the message.
        $Socket = New-Socket -SendTimeout $Timeout -ReceiveTimeout $Timeout
        try {
          Connect-Socket $Socket -RemoteIPAddress $Server -RemotePort $Port
        } catch [Net.Sockets.SocketException] {
          $ErrorRecord = New-Object Management.Automation.ErrorRecord(
            (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
            "TCP connection to Server ($Server/$Port) failed",
            [Management.Automation.ErrorCategory]::ConnectionError,
            $Socket)
          $pscmdlet.ThrowTerminatingError($ErrorRecord)
        }
        Send-Bytes $Socket -Data ($DnsQuery.ToByte([Net.Sockets.ProtocolType]::Tcp))

      } elseif ($IPv6) {
      
        # Create a UDP socket and send the message using IPv6.
        $Socket = New-Socket -ProtocolType Udp -SendTimeout $Timeout -ReceiveTimeout $Timeout -IPv6
        Send-Bytes $Socket -RemoteIPAddress $Server -RemotePort $Port -Data ($DnsQuery.ToByte())
      
      } else {
      
        # Create a UDP socket and send the message.
        $Socket = New-Socket -ProtocolType Udp -SendTimeout $Timeout -ReceiveTimeout $Timeout
        Send-Bytes $Socket -RemoteIPAddress $Server -RemotePort $Port -Data ($DnsQuery.ToByte())

      }

      $MessageComplete = $false
      # A buffer used to reassemble responses using TCP
      $MessageBuffer = [Byte[]]@()
      # An SOA record counter used as exit criteria for AXFR responses and a place-holder for a serial number of IXFR
      $SOAResouceRecordCount = 0; $ActiveSerialNumber = $null
      
      # Support for multi-packet responses.
      do {
        try {
          $DnsResponseData = Receive-Bytes $Socket -BufferSize 4096
        } catch [Net.Sockets.SocketException] {
          $ErrorRecord = New-Object Management.Automation.ErrorRecord(
            (New-Object Net.Sockets.SocketException ($_.Exception.InnerException.NativeErrorCode)),
            "Timeout waiting for data from remote host ($Server/$Port)",
            [Management.Automation.ErrorCategory]::ConnectionError,
            $Socket)
          $pscmdlet.ThrowTerminatingError($ErrorRecord)
        }
        
        if ($Tcp) {
          $MessageBuffer += $DnsResponseData.Data
        
          if ($MessageBuffer.Count -ge 2) {
            $MessageLength = [BitConverter]::ToUInt16(($MessageBuffer[1..0]), 0)
   
            # If the message buffer holds more data than the recorded message length a response can be read off.
            while ($MessageBuffer.Count -ge ($MessageLength + 2)) {
              # Copy bytes from message buffer into the partial copy
              $MessageBytes = New-Object Byte[] $MessageLength
              [Array]::Copy($MessageBuffer, 2, $MessageBytes, 0, $MessageLength)
              $DnsResponseData.Data = $MessageBytes
              
              # Remove the bytes which have been read from the buffer and update the number of available bytes.
              $TempMessageBuffer = New-Object Byte[] ($MessageBuffer.Count - 2 - $MessageLength)
              [Array]::Copy($MessageBuffer, (2 + $MessageLength), $TempMessageBuffer, 0, $TempMessageBuffer.Count)
              $MessageBuffer = $TempMessageBuffer
              $TempMessageBuffer = $null
              
              # Process the response message
              $DnsResponse = ReadDnsMessage $DnsResponseData
              
              # Anything other than NoError in a Header denotes message completion.
              if ($DnsResponse.Header.RCode -ne [Indented.Dns.RCode]::NoError) {
                $MessageComplete = $true
              }
              
              # IXFR completion tests
              if ($RecordType -eq [Indented.Dns.RecordType]::IXFR -and -not $MessageComplete) {
                if ($ActiveSerialNumber -eq $null) {
                  # A truncated return.
                  if ($DnsResponse.Header.ANCount -eq 1 -and $DnsResponse.Answer[0].RecordType -eq [Indented.Dns.RecordType]::SOA) {
                    $MessageComplete = $true
                    Write-Verbose "Get-Dns: IXFR: Terminated, no more answers available."
                  }
                  if ($DnsResponse.Header.ANCount -ge 2) {
                    if ($DnsResponse.Answer[1].RecordType -ne [Indented.Dns.RecordType]::SOA) {
                      # If a second record is present, and it is not an SOA record ,an AXFR response is being returned.
                      # Change the RecordType value, subjecting the response to the tests for AXFR responses.
                      $RecordType = [Indented.Dns.RecordType]::AXFR
                      Write-Verbose "Get-Dns: IXFR: AXFR mode response detected."
                    } else {
                      $ActiveSerialNumber = $DnsResponse.Answer[0].Serial
                      Write-Verbose "Get-Dns: IXFR: Latest serial number available is $ActiveSerialNumber"
                    }
                  }
                }
                
                if ($ActiveSerialNumber) {
                  $SOAResouceRecordCount += $DnsResponse.Answer |
                    Where-Object { $_.RecordType -eq [Indented.Dns.RecordType]::SOA -and $_.Serial -eq $ActiveSerialNumber } |
                    Measure-Object |
                    Select-Object -ExpandProperty Count
               
                  if ($SOAResouceRecordCount -ge 3) {
                    $MessageComplete = $true
                    Write-Verbose "Get-Dns: IXFR: Transfer is complete."
                  }
                }
              }
              
              # AXFR completion tests
              if ($RecordType -eq [Indented.Dns.RecordType]::AXFR -and -not $MessageComplete) {
                $SOAResouceRecordCount += $DnsResponse.Answer |
                  Where-Object RecordType -eq ([Indented.Dns.RecordType]::SOA) |
                  Measure-Object |
                  Select-Object -ExpandProperty Count

                # An complete AXFR starts and ends with an SOA record.
                if ($SOAResouceRecordCount -ge 2) {
                  $MessageComplete = $true
                  Write-Verbose "Get-Dns: AXFR: Transfer is complete."
                }
              } else {
                # If this is not a zone transfer the process can be marked as complete.
                $MessageComplete = $true
                Write-Verbose "Get-Dns: Query: Complete."
              }
            }
          }
        } else {
          $DnsResponse = ReadDnsMessage $DnsResponseData
          # If this is not TCP the response must be contained in a single packet.          
          $MessageComplete = $true
        }

        # If a complete response is present (no TCP loop).
        if ($DnsResponse) {
          $DnsResponse.TimeTaken = New-TimeSpan $Start (Get-Date)
          
          # Update the SearchList loop exit criteria
          $SearchStatus = $DnsResponse.Header.RCode
          
          # Return the response
          if ($SearchStatus -ne [Indented.Dns.RCode]::NXDomain -or $DnsDebug) {
            if ($IndentedDnsCacheReverse.Contains($DnsResponse.Server)) {
              $DnsResponse.Server = "$($DnsResponse.Server) ($($IndentedDnsCacheReverse[$DnsResponse.Server]))"
            }
       
            if ($DnsResponse.Header.Flags -band [Indented.Dns.Flags]::TC) {
              if ($NoTcpFallback) {
                $DnsResponse
              } else {
                # Make $DnsResponse null
                $DnsResponse = $null
                # Resend using TCP
                $BoundParameters = $MyInvocation.BoundParameters
                Get-Dns @BoundParameters -Tcp
              }
            } else {
              $DnsResponse
            }
          }
        }
        
        if ($SearchStatus -eq [Indented.Dns.RCode]::NXDomain -and $i -eq ($SearchList.Count - 1)) {
          if ($RecordType -in ([Indented.Dns.RecordType]::AXFR), ([Indented.Dns.RecordType]::IXFR)) {
            Write-Warning "Get-Dns: Transfer refused. Server ($Server) is not authoritative for $Name."
          } else {
            Write-Warning "Get-Dns: Name ($Name) does not exist."
          }
        }
      } until ($MessageComplete)
      
      if ($Tcp) {
        # Disconnect a TCP socket.
        Disconnect-Socket $Socket
      }
      # Close down the socket and free resources.
      Remove-Socket $Socket

      # Track the position in the suffixes search list
      $i++

    } while ($SearchStatus -eq [Indented.Dns.RCode]::NXDomain -and $i -lt $SearchList.Count)
  }
}

function Send_DnsDynamicUpdate {
  # .SYNOPSIS
  #   Send a DNS update message.
  # .DESCRIPTION
  #
  # DNS update header:
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      ID                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |QR|   Opcode  |          Z         |   RCODE   |  <-- Set OPCODE to Update
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ZOCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    PRCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    UPCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ADCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #  UPDATE uses this section to denote the zone of the records being
  # updated.  All records to be updated must be in the same zone, and
  # therefore the Zone Section is allowed to contain exactly one record.
  # The ZNAME is the zone name, the ZTYPE must be SOA, and the ZCLASS is
  # the zone's class.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                                               |
  #    /                     ZNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ZTYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ZCLASS                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # 
  # .INPUTS
  # .OUTPUTS
  # .EXAMPLE
  # .LINK
  #   http://www.ietf.org/rfc/rfc2078.txt
  #   http://www.ietf.org/rfc/rfc2136.txt
  #   http://www.ietf.org/rfc/rfc2845.txt

  [CmdLetBinding()]
  param(
    [String]$Name,
    
    [Indented.Dns.RecordType]$RecordType,
    
    [String]$RecordData
  )

  # Allow name validation through Get-Dns
  
  # Discover the ZoneName  
  $DnsResponse = Get-Dns $Name -RecordType SOA
  if ($DnsResponse.Header.RCode -eq [Indented.Dns.RCode]::NoError -and $DnsResponse.Header.ANCount -gt 0) {
    $ZoneName = $DnsResponse.Answer | Where-Object RecordType -eq ([Indented.Dns.RecordType]::SOA) | Select-Object -ExpandProperty Name
  } elseif ($DnsResponse.Header.RCode -eq [Indented.Dns.RCode]::NoError -and $DnsResponse.Header.NSCount -gt 0) {
    $ZoneName = $DnsResponse.Authority | Where-Object RecordType -eq ([Indented.Dns.RecordType]::SOA) | Select-Object -ExpandProperty Name
  }
  
  # Construct the update message
 
  
  # Attempt a non-secure update

}

function Update-InternalRootHints {
  # .SYNOPSIS
  #   Updates the root hints file from InterNIC then re-initializes the internal cache.
  # .DESCRIPTION
  #   The root hints file is used as the basis of an internal DNS cache. The content of the root hints file is used during iterative name resolution.
  # .PARAMETER Source
  #   Update-InternalRootHints attempts to download a named.root file from InterNIC by default. An alternative root hints source may be specified here.
  # .INPUTS
  #   System.String
  # .EXAMPLE
  #   Update-InternalRootHints
  
  [CmdLetBinding()]
  param(
    $Source = "http://www.internic.net/domain/named.root"
  )
  
  Get-WebContent $Source -File $psscriptroot\named.root
  Initialize-InternalDnsCache
}

function Initialize-InternalDnsCache {
  # .SYNOPSIS
  #   Initializes a basic DNS cache for use by Get-Dns.
  # .DESCRIPTION
  #   Get-Dns maintains a limited DNS cache, capturing A and AAAA records, to assist name server resolution (for values passed using the Server parameter).
  #
  #   The cache may be manipulated using *-InternalDnsCacheRecord CmdLets.
  # .EXAMPLE
  #   Initialize-InternalDnsCache
  
  [CmdLetBinding()]
  param( )
  
  # These two variables are consumed by all other -InternalDnsCacheRecord CmdLets.
  
  # The primary cache variable stores a stub resource record
  if (Get-Variable IndentedDnsCache -Scope Script -ErrorAction SilentlyContinue) {
    Remove-Variable IndentedDnsCache -Scope Script
  }
  New-Variable IndentedDnsCache -Scope Script -Value @{}

  # Allows quick, if limited, reverse lookups against the cache.
  if (Get-Variable IndentedDnsCacheReverse -Scope Script -ErrorAction SilentlyContinue) {
    Remove-Variable IndentedDnsCacheReverse -Scope Script
  }
  New-Variable IndentedDnsCacheReverse -Scope Script -Value @{}
  
  if (Test-Path $psscriptroot\named.root) {
    Get-Content $psscriptroot\named.root | 
      Where-Object { $_ -match '(?<Name>\S+)\s+(?<TTL>\d+)\s+(IN\s+)?(?<RecordType>A\s+|AAAA\s+)(?<IPAddress>\S+)' } |
      ForEach-Object {
        $CacheRecord = New-Object PsObject -Property ([Ordered]@{
          Name       = $matches.Name;
          TTL        = [UInt32]$matches.TTL;
          RecordType = [Indented.Dns.RecordType]$matches.RecordType;
          IPAddress  = [IPAddress]$matches.IPAddress;
        })
        $CacheRecord.PsObject.TypeNames.Add('Indented.Dns.Message.CacheRecord')
        $CacheRecord
      } |
      Add-InternalDnsCacheRecord -Permanent -ResourceType Hint
  }
}

function Get-InternalDnsCacheRecord {
  # .SYNOPSIS
  #   Get the content of the internal DNS cache used by Get-Dns.
  # .DESCRIPTION
  #   Get-InternalDnsCacheRecord displays records held in the cache.
  # .INPUTS
  #   Indented.Dns.RecordType
  #   System.Net.IPAddress
  #   System.String
  # .OUTPUTS
  #   Indented.Dns.Message.CacheRecord
  # .EXAMPLE
  #   Get-InternalDnsCacheRecord
  # .EXAMPLE
  #   Get-InternalDnsCacheRecord a.root-servers.net A
  
  [CmdLetBinding()]
  param(
    [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
    [String]$Name,
    
    [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
    [Indented.Dns.RecordType]$RecordType,
    
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [IPAddress]$IPAddress,

    [ValidateSet("Address", "Hint")]
    [String]$ResourceType
  )
  
  process {
    $WhereStatementText = '$_'
    if ($ResourceType) {
      $WhereStatementText = $WhereStatementText + ' -and $_.ResourceType -eq $ResourceType'
    }
    if ($RecordType) {
      $WhereStatementText = $WhereStatementText + ' -and $_.RecordType -eq $RecordType'
    }
    if ($IPAddress) {
      $WhereStatementText = $WhereStatementText + ' -and $_.IPAddress -eq $IPAddress'
    }
    # Create a ScriptBlock using the statements above.
    $WhereStatement = [ScriptBlock]::Create($WhereStatementText)
    
    if ($Name) {
      if (-not $Name.EndsWith('.')) {
        $Name = "$Name."
      }
      if ($IndentedDnsCache.Contains($Name)) {
        $IndentedDnsCache[$Name] | Where-Object $WhereStatement
      }
    } else {
      # Each key may contain multiple values. Forcing a pass through ForEach-Object will
      # remove the multi-dimensional aspect of the return value.
      $IndentedDnsCache.Values | ForEach-Object { $_ } | Where-Object $WhereStatement
    }
  }
}

function Add-InternalDnsCacheRecord {
  # .SYNOPSIS
  #   Add a new CacheRecord to the DNS cache object.
  # .DESCRIPTION
  #   Cache records must expose the following property members:
  #
  #    - Name
  #    - TTL
  #    - RecordType
  #    - IPAddress
  #
  # .PARAMETER CacheRecord
  #   A record to add to the cache.
  # .PARAMETER Permanent
  #   A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
  # .INPUTS
  #   Indented.Dns.Message.CacheRecord
  # .EXAMPLE
  #   $CacheRecord | Add-InternalDnsCacheRecord

  [CmdLetBinding(DefaultParameterSetName = 'CacheRecord')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CacheRecord')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.CacheRecord' } )]
    $CacheRecord,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ResourceRecord')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord,
    
    [ValidateSet("Address", "Hint")]
    [String]$ResourceType = "Address",
    
    [Switch]$Permanent
  )

  begin {
    if (-not $Permanent) {
      $Time = Get-Date
    }
  }

  process {
    if ($ResourceRecord) {
      $TempObject = $ResourceRecord | Select-Object Name, TTL, RecordType, IPAddress
      $TempObject.PsObject.TypeNames.Add('Indented.Dns.Message.CacheRecord')
      $CacheRecord = $TempObject
    }
  
    $CacheRecord | Add-Member ResourceType -MemberType NoteProperty -Value $ResourceType
    $CacheRecord | Add-Member Time -MemberType NoteProperty -Value $Time
    $CacheRecord | Add-Member Status -MemberType ScriptProperty -Value {
      if ($this.Time) {
        if ($this.Time.AddSeconds($this.TTL) -lt (Get-Date)) {
          "Expired"
        } else {
          "Active"
        }
      } else {
        "Permanent"
      }
    }
  
    if ($IndentedDnsCache.Contains($CacheRecord.Name)) {
      # Add the record to the cache if it doesn't already exist.
      if (-not ($CacheRecord | Get-InternalDnsCacheRecord)) {
        $IndentedDnsCache[$CacheRecord.Name] += $CacheRecord
      }
    } else {
      $IndentedDnsCache.Add($CacheRecord.Name, @($CacheRecord))
      if (-not ($IndentedDnsCacheReverse.Contains($CacheRecord.IPAddress))) {
        $IndentedDnsCacheReverse.Add($CacheRecord.IPAddress, $CacheRecord.Name)
      }
    }
  }      
}

function Remove-InternalDnsCacheRecord {
  # .SYNOPSIS
  #   Remove an entry from the DNS cache object.
  # .DESCRIPTION
  #   Remove-InternalDnsCacheRecord allows the removal of individual records from the cache, or removal of all records which expired.
  # .PARAMETER CacheRecord
  #   A record to add to the cache.
  # .PARAMETER Permanent
  #   A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
  # .INPUTS
  #   Indented.Dns.RecordType
  #   System.Net.IPAddress
  #   System.String
  # .EXAMPLE
  #   Get-InternalDnsCacheRecord a.root-servers.net | Remove-InternalDnsCacheRecord
  # .EXAMPLE
  #   Remove-InternalDnsCacheRecord -AllExpired

  [CmdLetBinding(DefaultParameterSetName = 'CacheRecord')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CacheRecord')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.CacheRecord' } )]
    $CacheRecord,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'AllExpired')]
    [Switch]$AllExpired
  )
  
  begin {
    if ($AllExpired) {
      $ExpiredRecords = Get-InternalDnsCacheRecord | Where-Object { $_.Status -eq 'Expired' }
      $ExpiredRecords | Remove-InternalDnsCacheRecord
    }
  }
  
  process {
    if (-not $AllExpired) {
      if ($IndentedDnsCacheReverse.Contains($CacheRecord.IPAddress)) {
        $IndentedDnsCacheReverse.Remove($CacheRecord.IPAddress)
      }
      if ($IndentedDnsCache.Contains($CacheRecord.Name)) {
        $IndentedDnsCache[$CacheRecord.Name] = $IndentedDnsCache[$CacheRecord.Name] | Where-Object { $_.IPAddress -ne $CacheRecord.IPAddress -and $_.RecordType -ne $CacheRecord.RecordType }
        if ($IndentedDnsCache[$CacheRecord.Name].Count -eq 0) {
          $IndentedDnsCache.Remove($CacheRecord.Name)
        }
      }
    }
  }
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH3xVzCeUmvCteOc/JcTrRYVG
# UV6gggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFLua
# GlA6UOfixZHmvEvN8FsevhjNMA0GCSqGSIb3DQEBAQUABIIBACI6iWjlJjgLocCI
# V9Ym5lyUDiMRi+rr+9/2JVRvUTqmPpzvGk9eylGo4uARZWLQqS5EbdBqIsWAqvcc
# EE2ysAFibRdYy+eKwcgc8YSbyedhZ9RGtfyhFzYmNXHQQ1J06WfTmSersK4HI3B6
# 8GEnWBK9dQN7zYNjbkv0ZiKue0aSidUjFM/DIonYDATFvGmBvbrLEXlsVUvepuU9
# 98ptL+EPliFTPjRCE2kTyPPgZps8qcRembcBFkHv4Z8CylxFJKWk6xzhJGpYYhxH
# 5Oy0f2V1T8//ffCxRwnS17ahluHc12nx6DyI+EipEmKwpNYI16Itg8CRHKYPLgCM
# HvdURnk=
# SIG # End signature block
