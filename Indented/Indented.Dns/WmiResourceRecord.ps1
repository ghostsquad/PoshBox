<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  ReadWmiDnsResourceRecord       ManagementObject          Private               01/11/2013
  ReadWmiDnsARecord              ManagementObject          Private               01/11/2013
  ReadWmiDnsNSRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsMDRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsMFRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsCNAMERecord          ManagementObject          Private               01/11/2013
  ReadWmiDnsSOARecord            ManagementObject          Private               01/11/2013
  ReadWmiDnsMBRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsMGRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsMRRecord             ManagementObject          Private               01/11/2013
  ReadWmiDnsWKSRecord            ManagementObject          Private               01/11/2013
  ReadWmiDnsPTRRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsHINFORecord          ManagementObject          Private               04/11/2013
  ReadWmiDnsMINFORecord          ManagementObject          Private               04/11/2013
  ReadWmiDnsMXRecord             ManagementObject          Private               04/11/2013
  ReadWmiDnsTXTRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsRPRecord             ManagementObject          Private               04/11/2013
  ReadWmiDnsAFSDBRecord          ManagementObject          Private               04/11/2013
  ReadWmiDnsX25Record            ManagementObject          Private               04/11/2013
  ReadWmiDnsISDNRecord           ManagementObject          Private               04/11/2013
  ReadWmiDnsRTRecord             ManagementObject          Private               04/11/2013
  ReadWmiDnsSIGRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsKEYRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsAAAARecord           ManagementObject          Private               04/11/2013
  ReadWmiDnsNXTRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsSRVRecord            ManagementObject          Private               04/11/2013
  ReadWmiDnsATMARecord           ManagementObject          Private               04/11/2013
  ReadWmiDnsWINSRecord           ManagementObject          Private               04/11/2013
  ReadWmiDnsWINSRRecord          ManagementObject          Private               04/11/2013
#>

function ReadWmiDnsResourceRecord {
  # .SYNOPSIS
  #   Reads common DNS resource record fields from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Management.ManagementObject]$ManagementObject
  )

  process {

    $ResourceRecord = New-Object PsObject -Property ([Ordered]@{
      Name             = $ManagementObject.OwnerName;
      TTL              = $ManagementObject.TTL;
      RecordClass      = [Indented.Dns.RecordClass]::IN;
      RecordType       = [Indented.Dns.RecordType]($ManagementObject.RecordClass);
      RecordData       = "";
      ZoneName         = $ManagementObject.ContainerName;
      TimeStamp        = $null;
      ServerName       = $ManagementObject.DnsServerName;
      ManagementObject = $ManagementObject;
    })
    $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord")

    # Property: Name
    if (-not $ResourceRecord.Name.EndsWith('.')) {
      $ResourceRecord.Name = "$($ResourceRecord.Name)."
    }
    # Property: ZoneName
    if (-not $ResourceRecord.ZoneName.EndsWith('.')) {
      $ResourceRecord.ZoneName = "$($ResourceRecord.ZoneName)."
    }
    # Property: TimeStamp
    if ($ManagementObject.TimeStamp -gt 0) {
      $ResourceRecord.TimeStamp = (Get-Date '01/01/1601').AddHours($ManagementObject.TimeStamp)
    }

    # Method: ToString
    $ResourceRecord | Add-Member ToString -MemberType ScriptMethod -Force -Value {
      return [String]::Format("{0} {1} {2} {3} {4}",
        $this.Name.PadRight(19, ' '),
        $this.TTL.ToString().PadRight(5, ' '),
        $this.RecordClass.ToString().PadRight(5, ' '),
        $this.RecordType.ToString().PadRight(5, ' '),
        $this.RecordData)
    }

    $Params = @{}
    $Params.Add("ManagementObject", $ManagementObject)
    $Params.Add("ResourceRecord", $ResourceRecord)

    # Create appropriate properties for each record type
    switch ($ResourceRecord.RecordType) {
      ([Indented.Dns.RecordType]::A)           { $ResourceRecord = ReadWmiDnsARecord @Params; break }
      ([Indented.Dns.RecordType]::NS)          { $ResourceRecord = ReadWmiDnsNSRecord @Params; break }
      ([Indented.Dns.RecordType]::MD)          { $ResourceRecord = ReadWmiDnsMDRecord @Params; break }
      ([Indented.Dns.RecordType]::MF)          { $ResourceRecord = ReadWmiDnsMFRecord @Params; break }
      ([Indented.Dns.RecordType]::CNAME)       { $ResourceRecord = ReadWmiDnsCNAMERecord @Params; break }
      ([Indented.Dns.RecordType]::SOA)         { $ResourceRecord = ReadWmiDnsSOARecord @Params; break }
      ([Indented.Dns.RecordType]::MB)          { $ResourceRecord = ReadWmiDnsMBRecord @Params; break }
      ([Indented.Dns.RecordType]::MG)          { $ResourceRecord = ReadWmiDnsMGRecord @Params; break }
      ([Indented.Dns.RecordType]::MR)          { $ResourceRecord = ReadWmiDnsMRRecord @Params; break }
      ([Indented.Dns.RecordType]::WKS)         { $ResourceRecord = ReadWmiDnsWKSRecord @Params; break }
      ([Indented.Dns.RecordType]::PTR)         { $ResourceRecord = ReadWmiDnsPTRRecord @Params; break }
      ([Indented.Dns.RecordType]::HINFO)       { $ResourceRecord = ReadWmiDnsHINFORecord @Params; break }
      ([Indented.Dns.RecordType]::MINFO)       { $ResourceRecord = ReadWmiDnsMINFORecord @Params; break }
      ([Indented.Dns.RecordType]::MX)          { $ResourceRecord = ReadWmiDnsMXRecord @Params; break }
      ([Indented.Dns.RecordType]::TXT)         { $ResourceRecord = ReadWmiDnsTXTRecord @Params; break }
      ([Indented.Dns.RecordType]::RP)          { $ResourceRecord = ReadWmiDnsRPRecord @Params; break }
      ([Indented.Dns.RecordType]::AFSDB)       { $ResourceRecord = ReadWmiDnsAFSDBRecord @Params; break }
      ([Indented.Dns.RecordType]::X25)         { $ResourceRecord = ReadWmiDnsX25Record @Params; break }
      ([Indented.Dns.RecordType]::ISDN)        { $ResourceRecord = ReadWmiDnsISDNRecord @Params; break }
      ([Indented.Dns.RecordType]::RT)          { $ResourceRecord = ReadWmiDnsRTRecord @Params; break }
      ([Indented.Dns.RecordType]::SIG)         { $ResourceRecord = ReadWmiDnsSIGRecord @Params; break }
      ([Indented.Dns.RecordType]::KEY)         { $ResourceRecord = ReadWmiDnsKEYRecord @Params; break }
      ([Indented.Dns.RecordType]::AAAA)        { $ResourceRecord = ReadWmiDnsAAAARecord @Params; break }
      ([Indented.Dns.RecordType]::NXT)         { $ResourceRecord = ReadWmiDnsNXTRecord @Params; break }
      ([Indented.Dns.RecordType]::SRV)         { $ResourceRecord = ReadWmiDnsSRVRecord @Params; break }
      ([Indented.Dns.RecordType]::ATMA)        { $ResourceRecord = ReadWmiDnsATMARecord @Params; break }
      ([Indented.Dns.RecordType]::WINS)        { $ResourceRecord = ReadWmiDnsWINSRecord @Params; break }
      ([Indented.Dns.RecordType]::WINSR)       { $ResourceRecord = ReadWmiDnsWINSRRecord @Params; break }
    }
    
    return $ResourceRecord
  }
}

function ReadWmiDnsARecord {
  # .SYNOPSIS
  #   Reads properties for an A record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.A

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.A")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value ([Net.IPAddress]$ManagementObject.IPAddress)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [IPAddress]$IPAddress
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($IPAddress -and $IPAddress -ne $this.IPAddress) {
      $InParams["IPAddress"] = $IPAddress.ToString()
    }
    
    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsNSRecord {
  # .SYNOPSIS
  #   Reads properties for an NS record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.NS

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.NS")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.NSHost

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["NSHost"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMDRecord {
  # .SYNOPSIS
  #   Reads properties for an MD record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MD

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MD")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.MDHost

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["MDHost"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMFRecord {
  # .SYNOPSIS
  #   Reads properties for an MF record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MF

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MF")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.MFHost

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["MFHost"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsCNAMERecord {
  # .SYNOPSIS
  #   Reads properties for an CNAME record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.CNAME

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.CNAME")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.PrimaryName

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["PrimaryName"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsSOARecord {
  # .SYNOPSIS
  #   Reads properties for an SOA record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.SOA

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.SOA")

  # Property: Serial
  $ResourceRecord | Add-Member Serial -MemberType NoteProperty -Value [UInt32]$ManagementObject.SerialNumber
  # Property: Refresh
  $ResourceRecord | Add-Member Refresh -MemberType NoteProperty -Value [UInt32]$ManagementObject.RefreshInterval
  # Property: Retry
  $ResourceRecord | Add-Member Retry -MemberType NoteProperty -Value [UInt32]$ManagementObject.RetryDelay
  # Property: Expire
  $ResourceRecord | Add-Member Expire -MemberType NoteProperty -Value [UInt32]$ManagementObject.ExpireLimit
  # Property: MinimumTTL
  $ResourceRecord | Add-Member MinimumTTL -MemberType NoteProperty -Value [UInt32]$ManagementObject.MinimumTTL
  # Property: NameServer
  $ResourceRecord | Add-Member NameServer -MemberType NoteProperty -Value $ManagementObject.PrimaryServer
  # Property: ResponsiblePerson
  $ResourceRecord | Add-Member ResponsiblePerson -MemberType NoteProperty -Value $ManagementObject.ResponsibleParty

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} (`n" +
                     "    {2} ; serial`n" +
                     "    {3} ; refresh ({4})`n" +
                     "    {5} ; retry ({6})`n" +
                     "    {7} ; expire ({8})`n" +
                     "    {9} ; minimum ttl ({10})`n" +
                     ")",
      $this.NameServer,
      $this.ResponsiblePerson,
      $this.Serial.ToString().PadRight(10, ' '),
      $this.Refresh.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Refresh),
      $this.Retry.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Retry),
      $this.Expire.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Expire),
      $this.MinimumTTL.ToString().PadRight(10, ' '),
      (ConvertTo-TimeSpanString -Seconds $this.Refresh))
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [UInt32]$Serial = [UInt32]::MaxValue,
      [UInt32]$Refresh = [UInt32]::MaxValue,
      [UInt32]$Retry = [UInt32]::MaxValue,
      [UInt32]$Expire = [UInt32]::MaxValue,
      [UInt32]$MinimumTTL = [UInt32]::MaxValue,
      [String]$NameServer,
      [String]$ResponsiblePerson
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Serial -ne [UInt32]::MaxValue -and $Serial -ne $this.Serial) {
      $InParams["SerialNumber"] = $Serial
    }
    if ($Refresh -ne [UInt32]::MaxValue -and $Refresh -ne $this.Refresh) {
      $InParams["RefreshInterval"] = $Refresh
    }
    if ($Retry -ne [UInt32]::MaxValue -and $Retry -ne $this.Retry) {
      $InParams["RetryDelay"] = $Retry
    }
    if ($Expire -ne [UInt32]::MaxValue -and $Expire -ne $this.Expire) {
      $InParams["ExpireLimit"] = $Expire
    }
    if ($MinimumTTL -ne [UInt32]::MaxValue -and $MinimumTTL -ne $this.MinimumTTL) {
      $InParams["MinimumTTL"] = $MinimumTTL
    }
    if ($NameServer -and $NameServer -ne $this.NameServer) {
      $InParams["PrimaryName"] = $NameServer
    }
    if ($ResponsiblePerson -and $ResponsiblePerson -ne $this.ResponsiblePerson) {
      $InParams["ResponsibleParty"] = $ResponsiblePerson
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMBRecord {
  # .SYNOPSIS
  #   Reads properties for an MB record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MB

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MB")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.MBHost

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["MBHost"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMGRecord {
  # .SYNOPSIS
  #   Reads properties for an MG record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MG

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MG")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.MGMailbox

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["MGMailbox"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}


function ReadWmiDnsMRRecord {
  # .SYNOPSIS
  #   Reads properties for an MR record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MR

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MR")

  # Property: MailboxName
  $ResourceRecord | Add-Member MailboxName -MemberType NoteProperty -Value $ManagementObject.MRMailbox

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.MailboxName
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$MailboxName
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($MailboxName -and $MailboxName -ne $this.MailboxName) {
      $InParams["MRMailbox"] = $MailboxName
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsWKSRecord {
  # .SYNOPSIS
  #   Reads properties for an WKS record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.WKS

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.WKS")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $ManagementObject.InternetAddress
  # Property: IPProtocolType
  $IPProtocolType = [Enum]::Parse([Net.Sockets.ProtocolType], $ManagementObject.IPProtocol, $true)
  $ResourceRecord | Add-Member IPProtocolType -MemberType NoteProperty -Value $IPProtocolType
  # Property: Services
  $ResourceRecord | Add-Member Services -MemberType NoteProperty -Value $ManagementObject.Services

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} ( {2} )",
      $this.IPAddress,
      $this.IPProtocolType,
      "$($this.Services)")
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Net.IPAddress]$IPAddress,
      [Net.Sockets.ProtocolType]$IPProtocolType = [Net.Sockets.ProtocolType]::Unspecified,
      [String]$Services
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($IPAddress -and $IPAddress -ne $this.IPAddress) {
      $InParams["InternetAddress"] = $IPAddress.ToString()
    }
    if ($IPProtocolType -ne [Net.Sockets.ProtocolType]::Unspecified -and $IPProtocolType -ne $this.IPProtocolType) {
      $InParams["IPProtocol"] = $IPProtocolType
    }
    if ($Services -and $Services -ne $this.Services) {
      $InParams["Services"] = $Services
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsPTRRecord {
  # .SYNOPSIS
  #   Reads properties for an PTR record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.PTR

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.PTR")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.PTRDomainName

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["PTRDomainName"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsHINFORecord {
  # .SYNOPSIS
  #   Reads properties for an HINFO record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.HINFO

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.HINFO")

  # Property: CPU
  $ResourceRecord | Add-Member CPU -MemberType NoteProperty -Value $ManagementObject.CPU
  # Property: OS
  $ResourceRecord | Add-Member OS -MemberType NoteProperty -Value $ManagementObject.OS

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.CPU,
      $this.OS)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$CPU,
      [String]$OS
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($CPU -and $CPU -ne $this.CPU) {
      $InParams["CPU"] = $CPU
    }
    if ($OS -and $OS -ne $this.OS) {
      $InParams["OS"] = $OS
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMINFORecord {
  # .SYNOPSIS
  #   Reads properties for an MINFO record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MINFO

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MINFO")

  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value $ManagementObject.ResponsibleMailbox
  # Property: ErrorMailbox
  $ResourceRecord | Add-Member ErrorMailbox -MemberType NoteProperty -Value $ManagementObject.ErrorMailbox

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.ResponsibleMailbox,
      $this.ErrorMailbox)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$ResponsibleMailbox,
      [String]$ErrorMailbox
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($ResponsibleMailbox -and $ResponsibleMailbox -ne $this.ResponsibleMailbox) {
      $InParams["ResponsibleMailbox"] = $ResponsibleMailbox
    }
    if ($ErrorMailbox -and $ErrorMailbox -ne $this.ErrorMailbox) {
      $InParams["ErrorMailbox"] = $ErrorMailbox
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsMXRecord {
  # .SYNOPSIS
  #   Reads properties for an MX record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.MX

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.MX")

  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Preference)
  # Property: Exchange
  $ResourceRecord | Add-Member Exchange -MemberType NoteProperty -Value $ManagementObject.MailExchange

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.Preference,
      $this.Exchange)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [UInt16]$Preference = [UInt16]::MaxValue,
      [String]$Exchange
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Preference -ne [UInt16]::MaxValue -and $Preference -ne $this.Preference) {
      $InParams["Preference"] = $Preference
    }
    if ($Exchange -and $Exchange -ne $this.Exchange) {
      $InParams["MailExchange"] = $Exchange
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsTXTRecord {
  # .SYNOPSIS
  #   Reads properties for an TXT record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.TXT

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.TXT")

  # Property: Text
  $ResourceRecord | Add-Member Text -MemberType NoteProperty -Value $ManagementObject.DescriptiveText

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Text
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$Text
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Text -and $Text -ne $this.Text) {
      $InParams["DescriptiveText"] = $Text
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsRPRecord {
  # .SYNOPSIS
  #   Reads properties for an RP record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.RP

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.RP")

  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value $ManagementObject.RPMailbox
  # Property: ErrorMailbox
  $ResourceRecord | Add-Member TXTDomainName -MemberType NoteProperty -Value $ManagementObject.TXTDomainName

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.ResponsibleMailbox,
      $this.TXTDomainName)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$ResponsibleMailbox,
      [String]$TXTDomainName
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($ResponsibleMailbox -and $ResponsibleMailbox -ne $this.ResponsibleMailbox) {
      $InParams["RPMailbox"] = $ResponsibleMailbox
    }
    if ($TXTDomainName -and $TXTDomainName -ne $this.TXTDomainName) {
      $InParams["TXTDomainName"] = $TXTDomainName
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsAFSDBRecord {
  # .SYNOPSIS
  #   Reads properties for an AFSDB record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.AFSDB

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.AFSDB")

  # Property: SubType
  $SubType = [UInt16]($ManagementObject.SubType)
  if ([Enum]::IsDefined([Idented.Dns.AFSDBSubType], $SubType)) {
    $SubType = [Indented.Dns.AFSDBSubType]$SubType
  }
  $ResourceRecord | Add-Member SubType -MemberType NoteProperty -Value $SubType

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.ServerName

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.SubType,
      $this.Hostname)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Indented.Dns.AFSDBSubType]$SubType,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($SubType -and $SubType -ne $this.SubType) {
      $InParams["SubType"] = [UInt16]$SubType
    }
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["ServerName"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsX25Record {
  # .SYNOPSIS
  #   Reads properties for an X25 record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.X25

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.X25")

  # Property: PSDNAddress
  $ResourceRecord | Add-Member PSDNAddress -MemberType NoteProperty -Value $ManagementObject.PSDNAddress
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.PSDNAddress
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$PSDNAddress
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($PSDNAddress -and $PSDNAddress -ne $this.PSDNAddress) {
      $InParams["PSDNAddress"] = $PSDNAddress
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsISDNRecord {
  # .SYNOPSIS
  #   Reads properties for an ISDN record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.ISDN

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.ISDN")

  # Property: ISDNAddress
  $ResourceRecord | Add-Member ISDNAddress -MemberType NoteProperty -Value $ManagementObject.ISDNNumber
  # Property: SubAddress
  $ResourceRecord | Add-Member SubAddress -MemberType NoteProperty -Value $ManagementObject.SubAddress

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.ResponsibleMailbox,
      $this.ErrorMailbox)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$ISDNAddress,
      [String]$SubAddress
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($ISDNAddress -and $ISDNAddress -ne $this.ISDNAddress) {
      $InParams["ISDNNumber"] = $ISDNAddress
    }
    if ($SubAddress -and $SubAddress -ne $this.SubAddress) {
      $InParams["SubAddress"] = $SubAddress
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsRTRecord {
  # .SYNOPSIS
  #   Reads properties for an RT record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.RT

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.RT")

  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Preference)
  # Property: IntermediateHost
  $ResourceRecord | Add-Member IntermediateHost -MemberType NoteProperty -Value $ManagementObject.IntermediateHost

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.Preference,
      $this.IntermediateHost)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [UInt16]$Preference = [UInt16]::MaxValue,
      [String]$IntermediateHost
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Preference -ne [UInt16]::MaxValue -and $Preference -ne $this.Preference) {
      $InParams["Preference"] = $Preference
    }
    if ($IntermediateHost -and $IntermediateHost -ne $this.IntermediateHost) {
      $InParams["IntermediateHost"] = $IntermediateHost
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an SIG record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.SIG

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.SIG")

  # Property: TypeCovered
  $ResourceRecord | Add-Member TypeCovered -MemberType NoteProperty -Value ([Indented.Dns.RecordType]([UInt16]$ManagementObject.TypeCovered))
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]([UInt16]$ManagementObject.Algorithm))
  # Property: Labels
  $ResourceRecord | Add-Member Labels -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Labels)
  # Property: OriginalTTL
  $ResourceRecord | Add-Member OriginalTTL -MemberType NoteProperty -Value ([UInt32]$ManagementObject.OriginalTTL)
  # Property: SignatureExpiration
  $ResourceRecord | Add-Member SignatureExpiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds([UInt32]$ManagementObject.SignatureExpiration))
  # Property: SignatureInception
  $ResourceRecord | Add-Member SignatureInception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds([UInt32]$ManagementObject.SignatureInception))
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value ([UInt16]$MangementObject.KeyTag)
  # Property: SignersName
  $ResourceRecord | Add-Member SignersName -MemberType NoteProperty -Value $ManagementObject.SignersName
  # Property: Signature
  $ResourceRecord | Add-Member Signature -MemberType NoteProperty -Value $ManagementObject.Signature

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} ( ; type-cov={0}, alg={1}, labels={2}`n" +
                     "    {3} ; Signature expiration`n" +
                     "    {4} ; Signature inception`n" +
                     "    {5} ; Key identifier`n" +
                     "    {6} ; Signer`n" +
                     "    {7} ; Signature`n" +
                     ")",
      $this.TypeCovered,
      (([Byte]$this.Algorithm).ToString()),
      ([Byte]$this.Labels.ToString()),
      $this.SignatureExpiration,
      $this.SignatureInception,
      $this.KeyTag,
      $this.SignersName,
      $this.Signature)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Indented.Dns.RecordType]$TypeCovered,
      [Indented.Dns.EncryptionAlgorithm]$EncryptionAlgorithm,
      [UInt16]$Labels = [UInt16]::MaxValue,
      [UInt16]$OriginalTTL = [UInt32]::MaxValue,
      [DateTime]$SignatureExpiration,
      [DateTime]$SignatureInception,
      [UInt16]$KeyTag = [UInt16]::MaxValue,
      [String]$SignersName,
      [String]$Signature
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($TypeCovered -and $TypeCovered -ne $this.TypeCovered) {
      $InParams["TypeCovered"] = [UInt16]$TypeCovered
    }
    if ($Algorithm -and $Algorithm -ne $this.Algorithm) {
      $InParams["Algorithm"] = [UInt16]$Algorithm
    }
    if ($Labels -ne [UInt16]::MaxValue -and $Labels -ne $this.Labels) {
      $InParams["Labels"] = $Labels 
    }
    if ($OriginalTTL -ne [UInt32]::MaxValue -and $OriginalTTL -ne $this.OriginalTTL) {
      $InParams["OriginalTTL"] = $TTL
    }
    if ($SignatureExpiration -and $SignatureExpiration -ne $this.SignatureExpiration) {
      $InParams["SignatureExpiration"] = [UInt32](New-TimeSpan '01/01/1970' $SignatureExpiration).TotalSeconds
    }
    if ($SignatureInception -and $SignatureInception -ne $this.SignatureInception) {
      $InParams["SignatureInception"] = [UInt32](New-TimeSpan '01/01/1970' $SignatureInception).TotalSeconds
    }
    if ($KeyTag -ne [UInt16]::MaxValue -and $KeyTag -ne $this.KeyTag) {
      $InParams["KeyTag"] = $KeyTag
    }
    if ($SignerName -and $SignerName -ne $this.SignerName) {
      $InParams["SignerName"] = $SignersName
    }
    if ($Signature -and $Signature -ne $this.Signature) {
      $InParams["Signature"] = $SignersName
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an KEY record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.KEY

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.KEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Flags)
  # Property: Authentication/Confidentiality (bit 0 and 1 of Flags)
  $ResourceRecord | Add-Member AuthenticationConfidentiality -MemberType ScriptProperty -Value {
    [Indented.Dns.KEYAC]([Byte]($this.Flags -shr 14))
  }
  # Property: Flags extension (bit 3)
  if (($Flags -band 0x1000) -eq 0x1000) {
    $ResourceRecord | Add-Member FlagsExtension -MemberType NoteProperty -Value $BinaryReader.ReadUInt16()
  }
  # Property: NameType (bit 6 and 7)
  $ResourceRecord | Add-Member NameType -MemberType ScriptProperty -Value {
    [Indented.Dns.KEYNameType]([Byte](($Flags -band 0x0300) -shr 9))
  }
  # Property: SignatoryField (bit 12 and 15)
  $ResourceRecord | Add-Member SignatoryField -MemberType ScriptProperty -Value {
    [Boolean]($this.Flags -band 0x000F)
  }
  # Property: Protocol
  $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([Indented.Dns.KEYProtocol]([Byte]$ManagementObject.Protocol))
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]([Byte]$ManagementObject.Algorithm))
  # Property: PublicKey
  $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $ManagementObject.PublicKey

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} ( {3} )",
      $this.Flags,
      ([Byte]$this.Protocol).ToString(),
      ([Byte]$this.Algorithm).ToString(),
      $this.PublicKey)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [UInt16]$Flags = [UInt16].MaxValue,
      [Indented.Dns.KEYProtocol]$Protocol,
      [Indented.Dns.EncryptionAlgorithm]$EncryptionAlgorithm,
      [String]$PublicKey
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Flags -ne [UInt16]::MaxValue -and $Flags -ne $this.Flags) {
      $InParams["Flags"] = $Flags 
    }
    if ($Protocol -and $Protocol -ne $this.Protocol) {
      $InParams["Protocol"] = [Byte]$Protocol
    }
    if ($Algorithm -and $Algorithm -ne $this.Algorithm) {
      $InParams["Algorithm"] = [Byte]$Algorithm
    }
    if ($PublicKey -and $PublicKey -ne $this.PublicKey) {
      $InParams["PublicKey"] = $PublicKey
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsAAAARecord {
  # .SYNOPSIS
  #   Reads properties for an AAAA record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.AAAA

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.AAAA")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value ([Net.IPAddress]$ManagementObject.IPv6Address)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [IPAddress]$IPAddress
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($IPAddress -and $IPAddress -ne $this.IPAddress) {
      $InParams["IPv6Address"] = $IPAddress.ToString()
    }
    
    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsNXTRecord {
  # .SYNOPSIS
  #   Reads properties for an NXT record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.NXT

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.NXT")

  # Property: DomainName
  $ResourceRecord | Add-Member DomainName -MemberType NoteProperty -Value $ManagementObject.NextDomainName
  # Property: RRTypes
  $ResourceRecord | Add-Member RRTypes -MemberType NoteProperty -Value $ManagementObject.Types

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {2}",
      $this.DomainName,
      $this.RRTypes)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [String]$DomainName,
      [String]$RRTypes
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($DomainName -and $DomainName -ne $this.DomainName) {
      $InParams["NextDomainName"] = $DomainName
    }
    if ($RRTypes -and $RRTypes -ne $this.RRTypes) {
      $InParams["Types"] = $RRTypes
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsSRVRecord {
  # .SYNOPSIS
  #   Reads properties for an SRV record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.SRV

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.SRV")

  # Property: Priority
  $ResourceRecord | Add-Member Priority -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Priority)
  # Property: Weight
  $ResourceRecord | Add-Member Weight -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Weight)
  # Property: Port
  $ResourceRecord | Add-Member Port -MemberType NoteProperty -Value ([UInt16]$ManagementObject.Port)
  # Property: Hostname
  # SRVDomainName is only available with 2008. DomainName was used previously but is used differently with 2008.
  # $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $ManagementObject.SRVDomainName
  $Hostname = ($ResourceRecord.ManagementObject.RecordData -split ' ')[-1]
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value $Hostname

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.Priority,
      $this.Weight,
      $this.Port,
      $this.Hostname)
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [UInt16]$Priority = [UInt16]::MaxValue,
      [UInt16]$Weight = [UInt16]::MaxValue,
      [UInt16]$Port = [UInt16]::MaxValue,
      [String]$Hostname
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Priority -ne [UInt16]::MaxValue -and $Priority -ne $this.Priority) {
      $InParams["Priority"] = $Priority
    }
    if ($Weight -ne [UInt16]::MaxValue -and $Weight -ne $this.Weight) {
      $InParams["Weight"] = $Weight
    }
    if ($Port -ne [UInt16]::MaxValue -and $Port -ne $this.Port) {
      $InParams["Port"] = $Port
    }
    # TO-DO
    if ($Hostname -and $Hostname -ne $this.Hostname) {
      $InParams["SRVDomainName"] = $Hostname
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsATMARecord {
  # .SYNOPSIS
  #   Reads properties for an ATMA record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.ATMA

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.ATMA")

  # Property: Format
  $ResourceRecord | Add-Member Format -MemberType NoteProperty -Value ([Indented.Dns.ATMAFormat][Byte]$ManagementObject.Format)
  # Property: ATMAAddress
  $ResourceRecord | Add-Member ATMAAddress -MemberType NoteProperty -Value $ManagementObject.ATMAddress

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.ATMAAddress
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Indented.Dns.ATMAFormat]$Format = [UInt16]::MaxValue,
      [String]$ATMAAddress
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($Format -and $Format -ne $this.Format) {
      $InParams["Format"] = $Format
    }
    if ($ATMAAddress -and $ATMAAddress -ne $this.ATMAAddress) {
      $InParams["ATMAAddress"] = $ATMAAddress
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsWINSRecord {
  # .SYNOPSIS
  #   Reads properties for an WINS record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.WINS

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.WINS")

  # Property: MappingFlag
  $ResourceRecord | Add-Member MappingFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]([UInt32]$ManagementObject.MappingFlag))
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value ([UInt32]$ManagementObject.LookupTimeout)
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value ([UInt32]$ManagementObject.CacheTimeout)
  # Property: ServerList
  $ResourceRecord | Add-Member ServerList -MemberType NoteProperty -Value $ManagementObject.WinsServers

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $Value = [String]::Format("L{0} C{1} ( {2} )",
      $this.LookupTimeout,
      $this.CacheTimeout,
      "$($this.ServerList)")
    if ($this.MappingFlag -eq [Indented.Dns.WINSMappingFlag]::NoReplication) {
      $Value = "LOCAL $Value"
    }
    $Value
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Indented.Dns.WINSMappingFlag]$MappingFlag,
      [UInt32]$LookupTimeout = [UInt32]::MaxValue,
      [UInt32]$CacheTimeout = [UInt32]::CacheTimeout,
      [String]$ServerList
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($MappingFlag -and $MappingFlag -ne $this.MappingFlag) {
      $InParams["MappingFlag"] = [UInt32]$MappingFlag
    }
    if ($LookupTimeout -ne [UInt32]::MaxValue -and $LookupTimeout -ne $this.LookupTimeout) {
      $InParams["LookupTimeout"] = $LookupTimeout
    }
    if ($CacheTimeout -ne [UInt32]::MaxValue -and $CacheTimeout -ne $this.CacheTimeout) {
      $InParams["CacheTimeout"] = $CacheTimeout
    }
    if ($ServerList -and $ServerList -ne $this.ServerList) {
      $InParams["WinsServers"] = $ServerList
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

function ReadWmiDnsWINSRRecord {
  # .SYNOPSIS
  #   Reads properties for an WINS record from a WMI management object.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER ManagementObject
  #   A management object holding ResourceRecord information.
  # .INPUTS
  #   System.Management.ManagementObject
  # .OUTPUTS
  #   Indented.Dns.Wmi.ResourceRecord.WINS

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [Management.ManagementObject]$ManagementObject,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Wmi.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Wmi.ResourceRecord.WINS")

  # Property: MappingFlag
  $ResourceRecord | Add-Member MappingFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]([UInt32]$ManagementObject.MappingFlag))
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value ([UInt32]$ManagementObject.LookupTimeout)
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value ([UInt32]$ManagementObject.CacheTimeout)
  # Property: DomainNameList
  $ResourceRecord | Add-Member DomainNameList -MemberType NoteProperty -Value $ManagementObject.ResultDomain

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $Value = [String]::Format("L{0} C{1} ( {2} )",
      $this.LookupTimeout,
      $this.CacheTimeout,
      "$($this.DomainNameList)")
    if ($this.LocalFlag -eq [Indented.Dns.WINSMappingFlag]::NoReplication) {
      $Value = "LOCAL $Value"
    }
    $Value
  }

  # Method: Modify
  $ResourceRecord | Add-Member Modify -MemberType ScriptMethod -Value {
    param(
      [UInt32]$TTL = [UInt32]::MaxValue,
      [Indented.Dns.WINSMappingFlag]$MappingFlag,
      [UInt32]$LookupTimeout = [UInt32]::MaxValue,
      [UInt32]$CacheTimeout = [UInt32]::CacheTimeout,
      [String]$DomainNameList
    )

    $InParams = $this.ManagementObject.GetMethodParameters("Modify")

    if ($TTL -ne [UInt32]::MaxValue -and $TTL -ne $this.TTL) {
      $InParams["TTL"] = $TTL
    }
    if ($MappingFlag -and $MappingFlag -ne $this.MappingFlag) {
      $InParams["MappingFlag"] = [UInt32]$MappingFlag
    }
    if ($LookupTimeout -ne [UInt32]::MaxValue -and $LookupTimeout -ne $this.LookupTimeout) {
      $InParams["LookupTimeout"] = $LookupTimeout
    }
    if ($CacheTimeout -ne [UInt32]::MaxValue -and $CacheTimeout -ne $this.CacheTimeout) {
      $InParams["CacheTimeout"] = $CacheTimeout
    }
    if ($DomainNameList -and $DomainNameList -ne $this.DomainNameList) {
      $InParams["ResultDomain"] = $DomainNameList
    }

    $OutParams = $this.ManagementObject.InvokeMethod("Modify", $InParams, $null)

    return $OutParams["RR"]
  }

  return $ResourceRecord
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYPNojq+Z0TjiGfFRAaIDuE66
# /r2gggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHOV
# EHcdj+JNmECOnLzq3z9oCCb9MA0GCSqGSIb3DQEBAQUABIIBAC4drMGAnIGHc/Ht
# StIRytd4rS1hFx+Nd21mR6iJuD8tAPW0Du776aToShh2XEU1lQK90WuD+gqSkq6M
# ddULlSPwuFM5ZVwQuHJ0IsXYSMfXNAvdlGV/iApxiH1vZzVXbxeNJyszPyV3AVsd
# rF+tvi8iwIgthwm5oXphntP7rVnRo0vbZPULjgxzzl3zchu62um96ioWl/9O5NJX
# RVrkebMy8Ko2JaDC3nDTdAR7MFLMqEJpS1oxFx8aXQvXJF5c4L82dwbfaokT0p7k
# ZdEzaCFvjjxxEIyZmQe8bDXOLCipEfMHyUuyBVzvWkXK5OfbRZfZr3thT3wkT+JL
# ohXW2xg=
# SIG # End signature block
