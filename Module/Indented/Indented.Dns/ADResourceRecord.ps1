<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  ReadADDnsDomainName            dnsRecord parser          Private               31/10/2013
  ReadADDnsCharacterString       dnsRecord parser          Private               31/10/2013
  ReadADDnsResourceRecord        dnsRecord parser          Private               31/10/2013
  ReadADDnsUnknownRecord         dnsRecord parser          Private               31/10/2013
  ReadADDnsARecord               dnsRecord parser          Private               31/10/2013
  ReadADDnsNSRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsMDRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsMFRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsCNAMERecord           dnsRecord parser          Private               31/10/2013
  ReadADDnsSOARecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsMBRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsMGRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsMRRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsWKSRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsPTRRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsHINFORecord           dnsRecord parser          Private               31/10/2013
  ReadADDnsMINFORecord           dnsRecord parser          Private               31/10/2013
  ReadADDnsMXRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsTXTRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsRPRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsAFSDBRecord           dnsRecord parser          Private               31/10/2013
  ReadADDnsX25Record             dnsRecord parser          Private               31/10/2013
  ReadADDnsISDNRecord            dnsRecord parser          Private               31/10/2013
  ReadADDnsRTRecord              dnsRecord parser          Private               31/10/2013
  ReadADDnsSIGRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsKEYRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsAAAARecord            dnsRecord parser          Private               31/10/2013
  ReadADDnsNXTRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsSRVRecord             dnsRecord parser          Private               31/10/2013
  ReadADDnsATMARecord            dnsRecord parser          Private               31/10/2013
  ReadADDnsWINSRecord            dnsRecord parser          Private               31/10/2013
  ReadADDnsWINSRRecord           dnsRecord parser          Private               31/10/2013
#>

function ReadADDnsDomainName {
  # .SYNOPSIS
  #   Reads a domain-name from dnsRecord.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Domain name values are held in the following format:
  #
  #                                  1  1  1  1  1  1
  #    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |         LENGTH        |   NUMBER OF LABELS    |
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |      LABEL LENGTH     |                       |
  #  |--+--+--+--+--+--+--+--+                       |
  #  /                     DATA                      /
  #  /                                               /
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   System.String
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )

  $Length = $BinaryReader.ReadByte()
  $NumberOfLabels = $BinaryReader.ReadByte()
  
  $DomainName = @()
  
  for ($i = 0; $i -lt $NumberOfLabels; $i++) {
    $LabelLength = $BinaryReader.ReadByte()
    $DomainName += New-Object String (,$BinaryReader.ReadChars($LabelLength))
  }
  
  # Drop the terminating byte
  $BinaryReader.ReadByte() | Out-Null
    
  return ([String]::Join('.', $DomainName) + '.')
}

function ReadADDnsCharacterString {
  # .SYNOPSIS
  #   Reads a character-string from a DNS message.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Character string values are held in the following format:
  #
  #                                  1  1  1  1  1  1
  #    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  |         LENGTH        |                       |
  #  |--+--+--+--+--+--+--+--+                       |
  #  /                     DATA                      /
  #  /                                               /
  #  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #  
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   System.String

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )
  
  $Length = $BinaryReader.ReadByte()
  $CharacterString = New-Object String (,$BinaryReader.ReadChars($Length))
  
  return $CharacterString
}

function ReadADDnsResourceRecord {
  # .SYNOPSIS
  #   Reads common DNS resource record fields from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Reads a byte array in the following format:
  #
  #                                     1  1  1  1  1  1
  #       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                 RDATA LENGTH                  |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                      TYPE                     |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |        VERSION        |         RANK          |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                     FLAGS                     |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                 UPDATEDATSERIAL               |
  #     |                                               |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                      TTL                      |
  #     |                                               |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                    RESERVED                   |
  #     |                                               |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #     |                   TIMESTAMP                   |
  #     |                                               |
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
  #     /                     RDATA                     /
  #     /                                               /
  #     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER SearchResultEntry
  #   A SearchResultEntry passed from Get-ADDnsRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #   System.DirectoryServices.Protocols.SearchResultEntry
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [DirectoryServices.Protocols.SearchResultEntry]$SearchResultEntry
  )
  
  $ResourceRecord = New-Object PsObject -Property ([Ordered]@{
    Name             = ($SearchResultEntry.Attributes['name'].Item(0));
    TTL              = [UInt32]0;
    RecordClass      = [Indented.Dns.RecordClass]::IN;
    RecordType       = [Indented.Dns.RecordType]::Empty;
    RecordDataLength = 0;
    RecordData       = "";
    DN               = $SearchResultEntry.DistinguishedName;
    ZoneName         = "";
    objectGUID       = ([GUID]$SearchResultEntry.Attributes['objectguid'].Item(0));
    Rank             = $null;
    TimeStamp        = $null;
    UpdatedAtSerial  = $null;
    WhenCreated      = ([DateTime]::ParseExact(($SearchResultEntry.Attributes['whencreated'].Item(0)), "yyyyMMddHHmmss.0Z", [Globalization.CultureInfo]::CurrentCulture));
    DnsTombstone     = $false;
  })
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord")

  # Property: ZoneName
  $ResourceRecord.ZoneName = $ResourceRecord.DN -replace '^DC=[^,]+,DC=|,.+$'
  # Property: Name - rebuild the name; concatenate with the zone name
  if ($ResourceRecord.Name -eq '@') {
    $ResourceRecord.Name = "$($ResourceRecord.ZoneName)."
  } else {
    $ResourceRecord.Name = [String]::Format("{0}.{1}.",
      $ResourceRecord.Name,
      $ResourceRecord.ZoneName)
  }
  # Property: RecordDataLength
  $ResourceRecord.RecordDataLength = $BinaryReader.ReadUInt16()
  # Property: RecordType
  $ResourceRecord.RecordType = [Indented.Dns.RecordType]($BinaryReader.ReadUInt16())
  # Property: Version
  $BinaryReader.ReadByte() | Out-Null
  # Property: Rank
  $ResourceRecord.Rank = [Indented.Dns.Rank]$BinaryReader.ReadByte()
  # Property: Flags
  $BinaryReader.ReadUInt16() | Out-Null
  # Property: UpdatedAtSerial
  $ResourceRecord.UpdatedAtSerial = $BinaryReader.ReadUInt32()
  # Property: TTL
  $ResourceRecord.TTL = $BinaryReader.ReadBEUInt32()
  # Property: Reserved
  $BinaryReader.ReadUInt32() | Out-Null
  # Property: TimeStamp
  $TimeStamp = $BinaryReader.ReadUInt32()
  if ($TimeStamp -gt 0) {
    $ResourceRecord.TimeStamp = (Get-Date '01/01/1601').AddHours($TimeStamp)
  }
  # Property: DnsTombstone
  if ($SearchResultEntry.Attributes['dnstombstoned']) {
    [Boolean]$ResourceRecord.DnsTombstone = $SearchResultEntry.Attributes['dnstombstoned'].Item(0)
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
  
  # Mark the beginning of the RecordData
  $BinaryReader.SetPositionMarker()
  
  $Params = @{BinaryReader = $BinaryReader; ResourceRecord = $ResourceRecord}
  
  # Create appropriate properties for each record type
  switch ($ResourceRecord.RecordType) {
    ([Indented.Dns.RecordType]::A)           { $ResourceRecord = ReadADDnsARecord @Params; break }
    ([Indented.Dns.RecordType]::NS)          { $ResourceRecord = ReadADDnsNSRecord @Params; break }
    ([Indented.Dns.RecordType]::MD)          { $ResourceRecord = ReadADDnsMDRecord @Params; break }
    ([Indented.Dns.RecordType]::MF)          { $ResourceRecord = ReadADDnsMFRecord @Params; break }
    ([Indented.Dns.RecordType]::CNAME)       { $ResourceRecord = ReadADDnsCNAMERecord @Params; break }
    ([Indented.Dns.RecordType]::SOA)         { $ResourceRecord = ReadADDnsSOARecord @Params; break }
    ([Indented.Dns.RecordType]::MB)          { $ResourceRecord = ReadADDnsMBRecord @Params; break }
    ([Indented.Dns.RecordType]::MG)          { $ResourceRecord = ReadADDnsMGRecord @Params; break }
    ([Indented.Dns.RecordType]::MR)          { $ResourceRecord = ReadADDnsMRRecord @Params; break }
    ([Indented.Dns.RecordType]::WKS)         { $ResourceRecord = ReadADDnsWKSRecord @Params; break }
    ([Indented.Dns.RecordType]::PTR)         { $ResourceRecord = ReadADDnsPTRRecord @Params; break }
    ([Indented.Dns.RecordType]::HINFO)       { $ResourceRecord = ReadADDnsHINFORecord @Params; break }
    ([Indented.Dns.RecordType]::MINFO)       { $ResourceRecord = ReadADDnsMINFORecord @Params; break }
    ([Indented.Dns.RecordType]::MX)          { $ResourceRecord = ReadADDnsMXRecord @Params; break }
    ([Indented.Dns.RecordType]::TXT)         { $ResourceRecord = ReadADDnsTXTRecord @Params; break }
    ([Indented.Dns.RecordType]::RP)          { $ResourceRecord = ReadADDnsRPRecord @Params; break }
    ([Indented.Dns.RecordType]::AFSDB)       { $ResourceRecord = ReadADDnsAFSDBRecord @Params; break }
    ([Indented.Dns.RecordType]::X25)         { $ResourceRecord = ReadADDnsX25Record @Params; break }
    ([Indented.Dns.RecordType]::ISDN)        { $ResourceRecord = ReadADDnsISDNRecord @Params; break }
    ([Indented.Dns.RecordType]::RT)          { $ResourceRecord = ReadADDnsRTRecord @Params; break }
    ([Indented.Dns.RecordType]::SIG)         { $ResourceRecord = ReadADDnsSIGRecord @Params; break }
    ([Indented.Dns.RecordType]::KEY)         { $ResourceRecord = ReadADDnsKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::AAAA)        { $ResourceRecord = ReadADDnsAAAARecord @Params; break }
    ([Indented.Dns.RecordType]::NXT)         { $ResourceRecord = ReadADDnsNXTRecord @Params; break }
    ([Indented.Dns.RecordType]::SRV)         { $ResourceRecord = ReadADDnsSRVRecord @Params; break }
    ([Indented.Dns.RecordType]::ATMA)        { $ResourceRecord = ReadADDnsATMARecord @Params; break }
    ([Indented.Dns.RecordType]::WINS)        { $ResourceRecord = ReadADDnsWINSRecord @Params; break }
    ([Indented.Dns.RecordType]::WINSR)       { $ResourceRecord = ReadADDnsWINSRRecord @Params; break }
    default                                  { ReadADDnsUnknownRecord @Params }
  }
  
  return $ResourceRecord
}

function ReadADDnsUnknownRecord {
  # .SYNOPSIS
  #   Reads properties for an unknown record type from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  <anything>                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #   Indented.Dns.AD.ResourceRecord
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.Unknown
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  # Create the basic Resource Record
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.Unknown")
  
  # Property: BinaryData
  $ResourceRecord | Add-Member BinaryData -MemberType NoteProperty -Value ($BinaryReader.ReadBytes($ResourceRecord.RecordDataLength))
 
  return $ResourceRecord
}

function ReadADDnsARecord {
  # .SYNOPSIS
  #   Reads properties for an A record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ADDRESS                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.A
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.A")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv4Address()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }
  
  return $ResourceRecord
}

function ReadADDnsNSRecord {
  # .SYNOPSIS
  #   Reads properties for an NS record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   NSDNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.NS
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.NS")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsMDRecord {
  # .SYNOPSIS
  #   Reads properties for an MD record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Present for legacy support; the MD record is marked as obsolete in favour of MX.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MADNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MD
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MD")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsMFRecord {
  # .SYNOPSIS
  #   Reads properties for an MF record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Present for legacy support; the MF record is marked as obsolete in favour of MX.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MADNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MF
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MF")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsCNAMERecord {
  # .SYNOPSIS
  #   Reads properties for an CNAME record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     CNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.CNAME
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.CNAME")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsSOARecord {
  # .SYNOPSIS
  #   Reads properties for an SOA record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     SERIAL                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    REFRESH                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     RETRY                     |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    EXPIRE                     |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  MINIMUM TTL                  |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     DATA                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /               RESPONSIBLE PERSON              /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.SOA
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.SOA")

  # Property: Serial
  $ResourceRecord | Add-Member Serial -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Refresh
  $ResourceRecord | Add-Member Refresh -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Retry
  $ResourceRecord | Add-Member Retry -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Expire
  $ResourceRecord | Add-Member Expire -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: MinimumTTL
  $ResourceRecord | Add-Member MinimumTTL -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: NameServer
  $ResourceRecord | Add-Member NameServer -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
  # Property: ResponsiblePerson
  $ResourceRecord | Add-Member ResponsiblePerson -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
  
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
 
  return $ResourceRecord
}

function ReadADDnsMBRecord {
  # .SYNOPSIS
  #   Reads properties for an MB record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   The MB record is marked as experimental.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MADNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MB
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MB")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsMGRecord {
  # .SYNOPSIS
  #   Reads properties for an MG record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   The MG record is marked as experimental.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MGMNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MG

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MG")

  # Property: MailboxName
  $ResourceRecord | Add-Member Mailbox -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.MailboxName
  }
  
  return $ResourceRecord
}

function ReadADDnsMRRecord {
  # .SYNOPSIS
  #   Reads properties for an MR record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   The MR record is marked as experimental.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   NEWNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MR
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MR")

  # Property: MailboxName
  $ResourceRecord | Add-Member MailboxName -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.MailboxName
  }
  
  return $ResourceRecord
}

function ReadADDnsWKSRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an WKS record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ADDRESS                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       PROTOCOL        |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                                               /
  #    /                   <BIT MAP>                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.WKS
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.WKS")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv4Address()
  # Property: IPProtocolNumber
  $ResourceRecord | Add-Member IPProtocolNumber -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: IPProtocolType
  $ResourceRecord | Add-Member IPProtocolType -MemberType ScriptProperty -Value {
    [Net.Sockets.ProtocolType]$this.IPProtocolNumber
  }
  
  # BitMap length in bytes, discounting the first five bytes (IPAddress and ProtocolType).
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 5)
  $BinaryString = ,$Bytes | ConvertTo-String -Binary
  
  # Property: BitMap
  $ResourceRecord | Add-Member BitMap -MemberType NoteProperty -Value $BinaryString
  # Property: Ports (numeric)
  $ResourceRecord | Add-Member Ports -MemberType ScriptProperty -Value {
    $Length = $BinaryString.Length; $Ports = @()
    for ([UInt16]$i = 0; $i -lt $Length; $i++) {
      if ($BinaryString[$i] -eq 1) {
        $Ports += $i
      }
    }
    $Ports
  }

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} ( {2} )",
      $this.IPAddress,
      $this.IPProtocolType,
      "$($this.Ports)")
  }
  
  return $ResourceRecord
}

function ReadADDnsPTRRecord {
  # .SYNOPSIS
  #   Reads properties for an PTR record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   PTRDNAME                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.PTR
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.PTR")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadADDnsHINFORecord {
  # .SYNOPSIS
  #   Reads properties for an HINFO record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      CPU                      /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                       OS                      /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.HINFO
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.HINFO")

  # Property: CPU
  $ResourceRecord | Add-Member CPU -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)

  # Property: OS
  $ResourceRecord | Add-Member OS -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.CPU,
      $this.OS)
  }
  
  return $ResourceRecord
}

function ReadADDnsMINFORecord {
  # .SYNOPSIS
  #   Reads properties for an MINFO record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    RMAILBX                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    EMAILBX                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MINFO

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MINFO")
  
  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
  # Property: ErrorMailbox
  $ResourceRecord | Add-Member ErrorMailbox -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.ResponsibleMailbox,
      $this.ErrorMailbox)
  }
  
  return $ResourceRecord
}

function ReadADDnsMXRecord {
  # .SYNOPSIS
  #   Reads properties for an MX record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  PREFERENCE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   EXCHANGE                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.MX
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.MX")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadUInt16()
  # Property: Exchange
  $ResourceRecord | Add-Member Exchange -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.Exchange)
  }
  
  return $ResourceRecord
}

function ReadADDnsTXTRecord {
  # .SYNOPSIS
  #   Reads properties for an TXT record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   TXT-DATA                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.TXT
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.TXT")
 
  # Property: Text
  $ResourceRecord | Add-Member Text -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Text
  }
  
  return $ResourceRecord
}

function ReadADDnsRPRecord {
  # .SYNOPSIS
  #   Reads properties for an RP record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    RMAILBX                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    EMAILBX                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.RP
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.RP")
  
  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
  # Property: TXTDomainName
  $ResourceRecord | Add-Member TXTDomainName -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.ResponsibleMailbox,
      $this.TXTDomainName)
  }
  
  return $ResourceRecord
}

function ReadADDnsAFSDBRecord {
  # .SYNOPSIS
  #   Reads properties for an AFSDB record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    SUBTYPE                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    HOSTNAME                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.AFSDB
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.AFSDB")
  
  $SubType = $BinaryReader.ReadUInt16()
  if ([Enum]::IsDefined([Idented.Dns.AFSDBSubType], $SubType)) {
    $SubType = [Indented.Dns.AFSDBSubType]$SubType
  }

  # Property: SubType
  $ResourceRecord | Add-Member SubType -MemberType NoteProperty -Value $SubType
  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.SubType,
      $this.Hostname)
  }
  
  return $ResourceRecord
}

function ReadADDnsX25Record {
  # .SYNOPSIS
  #   Reads properties for an X25 record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                PSDNADDRESS                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.X25
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.X25")
  
  # Property: PSDNAddress
  $ResourceRecord | Add-Member PSDNAddress -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.PSDNAddress
  }
  
  return $ResourceRecord
}

function ReadADDnsISDNRecord {
  # .SYNOPSIS
  #   Reads properties for an ISDN record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                ISDNADDRESS                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                 SUBADDRESS                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.ISDN
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.ISDN")
  
  # Property: ISDNAddress
  $ResourceRecord | Add-Member ISDNAddress -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)
  # Property: SubAddress
  $ResourceRecord | Add-Member SubAddress -MemberType NoteProperty -Value (ReadADDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.ISDNAddress,
      $this.SubAddress)
  }
  
  return $ResourceRecord
}

function ReadADDnsRTRecord {
  # .SYNOPSIS
  #   Reads properties for an RT record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  PREFERENCE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   EXCHANGE                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.RT
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.RT")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadUInt16()
  # Property: IntermediateHost
  $ResourceRecord | Add-Member IntermediateHost -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.IntermediateHost)
  }
  
  return $ResourceRecord
}

function ReadADDnsSIGRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an SIG record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 TYPE COVERED                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |         LABELS        |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 ORIGINAL TTL                  |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |             SIGNATURE EXPIRATION              |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |              SIGNATURE INCEPTION              |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEY TAG                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                 SIGNER'S NAME                 /
  #    /                                               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   SIGNATURE                   /
  #    /                                               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.SIG
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.SIG")

  # Property: TypeCovered
  $ResourceRecord | Add-Member TypeCovered -MemberType NoteProperty -Value ([Indented.Dns.RecordType]$BinaryReader.ReadUIn16())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: Labels
  $ResourceRecord | Add-Member Labels -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: OriginalTTL
  $ResourceRecord | Add-Member OriginalTTL -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: SignatureExpiration
  $ResourceRecord | Add-Member SignatureExpiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32()))
  # Property: SignatureInception
  $ResourceRecord | Add-Member SignatureInception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadUInt32()))
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadUInt16()
  # Property: SignersName
  $ResourceRecord | Add-Member SignersName -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
  # Property: Signature
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ,$Bytes | ConvertTo-String -Base64
  $ResourceRecord | Add-Member Signature -MemberType NoteProperty -Value $Base64String
    
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
  
  return $ResourceRecord
} 

function ReadADDnsKEYRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an KEY record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     FLAGS                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        PROTOCOL       |       ALGORITHM       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  PUBLIC KEY                   /
  #    /                                               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   The flags field takes the following format, discussed in RFC 2535 3.1.2:
  #
  #      0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5
  #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  #    |  A/C  | Z | XT| Z | Z | NAMTYP| Z | Z | Z | Z |      SIG      |
  #    +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.KEY
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.KEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ($BinaryReader.ReadUInt16())
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
  $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([Indented.Dns.KEYProtocol]$BinaryReader.ReadByte())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  
  if ($ResourceRecord.AuthenticationConfidentiality -ne [Indented.Dns.KEYAC]::NoKey) {
    # Property: PublicKey
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
    $Base64String = ,$Bytes | ConvertTo-String -Base64
    $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String
  }

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} ( {3} )",
      $this.Flags,
      ([Byte]$this.Protocol).ToString(),
      ([Byte]$this.Algorithm).ToString(),
      $this.PublicKey)
  }
  
  return $ResourceRecord
} 

function ReadADDnsAAAARecord {
  # .SYNOPSIS
  #   Reads properties for an AAAA record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ADDRESS                    |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.AAAA
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.AAAA")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv6Address()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }
  
  return $Record
}

function ReadADDnsNXTRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an NXT record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   DOMAINNAME                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   <BIT MAP>                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.NXT
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc3755.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.NXT")
  
  # Property: DomainName
  $ResourceRecord | Add-Member DomainName -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)
    
  # Property: RRTypeBitMap
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $BinaryString = ,$Bytes | ConvertTo-String -Binary
  $ResourceRecord | Add-Member RRTypeBitMap -MemberType NoteProperty -Value $BinaryString
  # Property: RRTypes
  $ResourceRecord | Add-Member RRTypes -MemberType ScriptProperty -Value {
    $RRTypes = @()
    [Enum]::GetNames([Indented.Dns.RecordType]) |
      Where-Object { [UInt16][Indented.Dns.RecordType]::$_ -lt $BinaryString.Length -and 
        $BinaryString[([UInt16][Indented.Dns.RecordType]::$_)] -eq '1' } |
      ForEach-Object {
        $RRTypes += [Indented.Dns.RecordType]::$_
      }
    $RRTypes
  }

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {2}",
      $this.DomainName,
      "$($this.RRTypes)")
  }
  
  return $ResourceRecord
}

function ReadADDnsSRVRecord {
  # .SYNOPSIS
  #   Reads properties for an SRV record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   PRIORITY                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    WEIGHT                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     PORT                      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    TARGET                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.SRV
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.SRV")
  
  # Property: Priority
  $ResourceRecord | Add-Member Priority -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Weight
  $ResourceRecord | Add-Member Weight -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Port
  $ResourceRecord | Add-Member Port -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ReadADDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.Priority,
      $this.Weight,
      $this.Port,
      $this.Hostname)
  }
  
  return $ResourceRecord
}

function ReadADDnsATMARecord {
  # .SYNOPSIS
  #   Reads properties for an ATMA record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |         FORMAT        |                       |
  #    +--+--+--+--+--+--+--+--+                       |
  #    /                   ATMADDRESS                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.ATMA
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.ATMA")
  
  # Format
  $Format = [Indented.Dns.ATMAFormat]$BinaryReader.ReadByte()
  
  # ATMAAddress length, discounting the first byte (Format)
  $Length = $RecorceRecord.RecordDataLength - 1
  $ATMAAddress = New-Object Text.StringBuilder
  
  switch ($Format) {
    ([Indented.Dns.ATMAFormat]::AESA) { 
      for ($i = 0; $i -lt $Length; $i++) {
        $ATMAAddress.Append($BinaryReader.ReadChar()) | Out-Null
      }
      break
    }
    ([Indented.Dns.ATMAFormat]::E164) {
      for ($i = 0; $i -lt $Length; $i++) {
        if ((3, 6) -contains $i) { $ATMAAddress.Append(".") | Out-Null }
        $ATMAAddress.Append($BinaryReader.ReadChar()) | Out-Null
      }
      break
    }
    ([Indented.Dns.ATMAFormat]::NSAP) {
      for ($i = 0; $i -lt $Length; $i++) {
        if ((1, 3, 13, 19) -contains $i) { $ATMAAddress.Append(".") | Out-Null }
        $ATMAAddress.Append(('{0:X2}' -f $BinaryReader.ReadByte())) | Out-Null
      }
      break
    }
  }

  # Property: Format
  $ResourceRecord | Add-Member Format -MemberType NoteProperty -Value $Format
  # Property: ATMAAddress
  $ResourceRecord | Add-Member ATMAAddress -MemberType NoteProperty -Value $ATMAAddress.ToString()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.ATMAAddress
  }
  
  return $ResourceRecord
}

function ReadADDnsDHCIDRecord {
  # .SYNOPSIS
  #   Reads properties for an DHCID record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  <anything>                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.DHCID
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.DHCID")
  
  # Property: BinaryData
  $ResourceRecord | Add-Member BinaryData -MemberType NoteProperty -Value ($BinaryReader.ReadBytes($ResourceRecord.RecordDataLength))
 
  return $ResourceRecord
}

function ReadADDnsWINSRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an WINS record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  LOCAL FLAG                   |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                LOOKUP TIMEOUT                 |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 CACHE TIMEOUT                 |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |               NUMBER OF SERVERS               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                SERVER IP LIST                 /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.WINS
  # .LINK
  #   http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.WINS")

  # Property: MappingFlag
  $ResourceRecord | Add-Member MappingFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]$BinaryReader.ReadUInt32())
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: NumberOfServers
  $ResourceRecord | Add-Member NumberOfServers -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: ServerList
  $ResourceRecord | Add-Member ServerList -MemberType NoteProperty -Value @()
  
  for ($i = 0; $i -lt $ResourceRecord.NumberOfServers; $i++) {
    $ResourceRecord.ServerList += $BinaryReader.ReadIPv4Address()  
  }

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
  
  return $Record
}

function ReadADDnsWINSRRecord {
  # TO-DO
  #
  # .SYNOPSIS
  #   Reads properties for an WINSR record from a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  LOCAL FLAG                   |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                LOOKUP TIMEOUT                 |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 CACHE TIMEOUT                 |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |               NUMBER OF SERVERS               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  DOMAIN NAME                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing the dnsRecord attribute.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.AD.ResourceRecord object created by ReadADDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.AD.ResourceRecord.WINSR
  # .LINK
  #   http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.AD.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.AD.ResourceRecord.WINSR")

  # Property: LocalFlag
  $ResourceRecord | Add-Member LocalFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]$BinaryReader.ReadUInt32())
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: NumberOfDomains
  $ResourceRecord | Add-Member NumberOfDomains -MemberType NoteProperty -Value $BinaryReader.ReadUInt32()
  # Property: DomainNameList
  $ResourceRecord | Add-Member DomainNameList -MemberType NoteProperty -Value @()
  
  for ($i = 0; $i -lt $ResourceRecord.NumberOfDomains; $i++) {
    $ResourceRecord.DomainNameList += ReadADDnsDomainName $BinaryReader
  }

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
  
  return $Record
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt1Fc8lZ9mgi511uHqm4ct/iR
# TD+gggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJao
# rcPaOptQHZHAYg4nVE3sQKWUMA0GCSqGSIb3DQEBAQUABIIBAGazC9C3QC/Ll00A
# Tolk9rt9NoAlBt2ESYJ+aswDBXQyW1zzBtTQpBaSnL5cCuF/z8ej9c7UZOmTtMq6
# pE1acf6dNVCw8hCgtxcF/+KMGGHljeDA+aOl54+d1YE8tR/bygrG0bk8Y4257cJh
# 30i2h4srWH6icnOoy7JeEZYSLEbljiivlUXBVREbu3hZLA46P8VWPmTzA0bmwXUP
# afI2Xcd79xLvq4UZ9oRYUoEXeLGMmReVftT2egKndtwvxd31aJ/9KEziZ8xLWsPd
# EDhQh7Az+2yBIq8/IZUm+RyOJDCV4q0IRNcxCCHBM+CXF6kdo3UZKUh6+vWdSdc3
# zv+Mfdo=
# SIG # End signature block
