<#
  Module file content:

  CmdLet Name                    Category                  Access modifier       Updated
  -----------                    --------                  ---------------       -------
  ReadDnsResourceRecord          DNS resolver              Private               07/10/2013
  ReadDnsUnknownRecord           DNS resolver              Private               07/10/2013
  ReadDnsARecord                 DNS resolver              Private               07/10/2013
  ReadDnsNSRecord                DNS resolver              Private               07/10/2013
  ReadDnsMDRecord                DNS resolver              Private               07/10/2013
  ReadDnsMFRecord                DNS resolver              Private               07/10/2013
  ReadDnsCNAMERecord             DNS resolver              Private               07/10/2013
  ReadDnsSOARecord               DNS resolver              Private               07/10/2013
  ReadDnsMBRecord                DNS resolver              Private               07/10/2013
  ReadDnsMGRecord                DNS resolver              Private               07/10/2013
  ReadDnsMRRecord                DNS resolver              Private               07/10/2013
  ReadDnsNULLRecord              DNS resolver              Private               07/10/2013
  ReadDnsWKSRecord               DNS resolver              Private               07/10/2013
  ReadDnsPTRRecord               DNS resolver              Private               08/10/2013
  ReadDnsHINFORecord             DNS resolver              Private               08/10/2013
  ReadDnsMINFORecord             DNS resolver              Private               08/10/2013
  ReadDnsMXRecord                DNS resolver              Private               08/10/2013
  ReadDnsTXTRecord               DNS resolver              Private               08/10/2013
  ReadDnsRPRecord                DNS resolver              Private               11/10/2013
  ReadDnsAFSDBRecord             DNS resolver              Private               11/10/2013
  ReadDnsX25Record               DNS resolver              Private               11/10/2013
  ReadDnsISDNRecord              DNS resolver              Private               11/10/2013
  ReadDnsRTRecord                DNS resolver              Private               11/10/2013
  ReadDnsNSAPRecord              DNS resolver              Private               11/10/2013
  ReadDnsNSAPTRRecord            DNS resolver              Private               11/10/2013
  ReadDnsSIGRecord               DNS resolver              Private               20/12/2013
  ReadDnsKEYRecord               DNS resolver              Private               11/10/2013
  ReadDnsPXRecord                DNS resolver              Private               14/10/2013
  ReadDnsGPOSRecord              DNS resolver              Private               14/10/2013
  ReadDnsAAAARecord              DNS resolver              Private               20/12/2013
  ReadDnsLOCRecord               DNS resolver              Private               14/10/2013
  ReadDnsNXTRecord               DNS resolver              Private               14/10/2013
  ReadDnsEIDRecord               DNS resolver              Private               14/10/2013
  ReadDnsNIMLOCRecord            DNS resolver              Private               14/10/2013
  ReadDnsSRVRecord               DNS resolver              Private               14/10/2013
  ReadDnsATMARecord              DNS resolver              Private               16/10/2013
  ReadDnsNAPTRRecord             DNS resolver              Private               16/10/2013
  ReadDnsKXRecord                DNS resolver              Private               16/10/2013
  ReadDnsCERTRecord              DNS resolver              Private               16/10/2013
  ReadDnsA6Record                DNS resolver              Private               16/10/2013
  ReadDnsDNAMERecord             DNS resolver              Private               16/10/2013
  ReadDnsSINKRecord              DNS resolver              Private               16/10/2013
  ReadDnsOPTRecord               DNS resolver              Private               16/10/2013
  ReadDnsAPLRecord               DNS resolver              Private               17/10/2013
  ReadDnsDSRecord                DNS resolver              Private               17/10/2013
  ReadDnsSSHFPRecord             DNS resolver              Private               17/10/2013
  ReadDnsIPSECKEYRecord          DNS resolver              Private               17/10/2013
  ReadDnsRRSIGRecord             DNS resolver              Private               20/12/2013
  ReadDnsNSECRecord              DNS resolver              Private               17/10/2013
  ReadDnsDNSKEYRecord            DNS resolver              Private               21/10/2013
  ReadDnsDHCIDRecord             DNS resolver              Private               21/10/2013
  ReadDnsNSEC3Record             DNS resolver              Private               28/04/2014
  ReadDnsNSEC3PARAMRecord        DNS resolver              Private               21/10/2013
  ReadDnsHIPRecord               DNS resolver              Private               22/10/2013
  ReadDnsNINFORecord             DNS resolver              Private               23/10/2013
  ReadDnsRKEYRecord              DNS resolver              Private               23/10/2013
  ReadDnsSPFRecord               DNS resolver              Private               28/04/2014
  ReadDnsTKEYRecord              DNS resolver              Private               24/10/2013
  ReadDnsTSIGRecord              DNS resolver              Private               24/10/2013
  ReadDnsWINSRecord              DNS resolver              Private               24/10/2013
  ReadDnsWINSRRecord             DNS resolver              Private               24/10/2013
#>

function ReadDnsResourceRecord {
  # .SYNOPSIS
  #   Reads common DNS resource record fields from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Reads a byte array in the following format:
  #
  #                                   1  1  1  1  1  1
  #     0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      NAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      TYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     CLASS                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      TTL                      |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   RDLENGTH                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
  #    /                     RDATA                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )
  
  if ($Script:IndentedDnsTCEndFound) {
    # Return $null, cannot read past the end of a truncated packet.
    return 
  }
  
  $ResourceRecord = New-Object PsObject -Property ([Ordered]@{
    Name             = "";
    TTL              = [UInt32]0;
    RecordClass      = [Indented.Dns.RecordClass]::IN;
    RecordType       = [Indented.Dns.RecordType]::Empty;
    RecordDataLength = 0;
    RecordData       = "";
  })
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord")
  
  # Property: Name
  $ResourceRecord.Name = ConvertToDnsDomainName $BinaryReader
  
  # Test whether or not the response is complete enough to read basic fields.
  if ($BinaryReader.BaseStream.Capacity -lt ($BinaryReader.BaseStream.Position + 10)) {
    # Set a variable to globally track the state of the packet read.
    $Script:IndentedDnsTCEndFound = $true
    # Return what we know.
    return $ResourceRecord    
  }
  
  # Property: RecordType
  $ResourceRecord.RecordType = $BinaryReader.ReadBEUInt16()
  if ([Enum]::IsDefined([Indented.Dns.RecordType], $ResourceRecord.RecordType)) {
    $ResourceRecord.RecordType = [Indented.Dns.RecordType]$ResourceRecord.RecordType
  } else {
    $ResourceRecord.RecordType = "UNKNOWN ($($ResourceRecord.RecordType))"
  }
  # Property: RecordClass
  if ($ResourceRecord.RecordType -eq [Indented.Dns.RecordType]::OPT) {
    $ResourceRecord.RecordClass = $BinaryReader.ReadBEUInt16()
  } else {
    $ResourceRecord.RecordClass = [Indented.Dns.RecordClass]$BinaryReader.ReadBEUInt16()
  }
  # Property: TTL
  $ResourceRecord.TTL = $BinaryReader.ReadBEUInt32()
  # Property: RecordDataLength
  $ResourceRecord.RecordDataLength = $BinaryReader.ReadBEUInt16()
  
  # Method: ToString
  $ResourceRecord | Add-Member ToString -MemberType ScriptMethod -Force -Value {
    return [String]::Format("{0} {1} {2} {3} {4}",
      $this.Name.PadRight(29, ' '),
      $this.TTL.ToString().PadRight(10, ' '),
      $this.RecordClass.ToString().PadRight(5, ' '),
      $this.RecordType.ToString().PadRight(5, ' '),
      $this.RecordData)
  }
  
  # Mark the beginning of the RecordData
  $BinaryReader.SetPositionMarker()
  
  $Params = @{BinaryReader = $BinaryReader; ResourceRecord = $ResourceRecord}
  
  if ($BinaryReader.BaseStream.Capacity -lt ($BinaryReader.BaseStream.Position + $ResourceRecord.RecordDataLength)) {
    # Set a variable to globally track the state of the packet read.
    $Script:IndentedDnsTCEndFound = $true
    # Return what we know.
    return $ResourceRecord
  }

  # Create appropriate properties for each record type  
  switch ($ResourceRecord.RecordType) {
    ([Indented.Dns.RecordType]::A)           { $ResourceRecord = ReadDnsARecord @Params; break }
    ([Indented.Dns.RecordType]::NS)          { $ResourceRecord = ReadDnsNSRecord @Params; break }
    ([Indented.Dns.RecordType]::MD)          { $ResourceRecord = ReadDnsMDRecord @Params; break }
    ([Indented.Dns.RecordType]::MF)          { $ResourceRecord = ReadDnsMFRecord @Params; break }
    ([Indented.Dns.RecordType]::CNAME)       { $ResourceRecord = ReadDnsCNAMERecord @Params; break }
    ([Indented.Dns.RecordType]::SOA)         { $ResourceRecord = ReadDnsSOARecord @Params; break }
    ([Indented.Dns.RecordType]::MB)          { $ResourceRecord = ReadDnsMBRecord @Params; break }
    ([Indented.Dns.RecordType]::MG)          { $ResourceRecord = ReadDnsMGRecord @Params; break }
    ([Indented.Dns.RecordType]::MR)          { $ResourceRecord = ReadDnsMRRecord @Params; break }
    ([Indented.Dns.RecordType]::NULL)        { $ResourceRecord = ReadDnsNULLRecord @Params; break }
    ([Indented.Dns.RecordType]::WKS)         { $ResourceRecord = ReadDnsWKSRecord @Params; break }
    ([Indented.Dns.RecordType]::PTR)         { $ResourceRecord = ReadDnsPTRRecord @Params; break }
    ([Indented.Dns.RecordType]::HINFO)       { $ResourceRecord = ReadDnsHINFORecord @Params; break }
    ([Indented.Dns.RecordType]::MINFO)       { $ResourceRecord = ReadDnsMINFORecord @Params; break }
    ([Indented.Dns.RecordType]::MX)          { $ResourceRecord = ReadDnsMXRecord @Params; break }
    ([Indented.Dns.RecordType]::TXT)         { $ResourceRecord = ReadDnsTXTRecord @Params; break }
    ([Indented.Dns.RecordType]::RP)          { $ResourceRecord = ReadDnsRPRecord @Params; break }
    ([Indented.Dns.RecordType]::AFSDB)       { $ResourceRecord = ReadDnsAFSDBRecord @Params; break }
    ([Indented.Dns.RecordType]::X25)         { $ResourceRecord = ReadDnsX25Record @Params; break }
    ([Indented.Dns.RecordType]::ISDN)        { $ResourceRecord = ReadDnsISDNRecord @Params; break }
    ([Indented.Dns.RecordType]::RT)          { $ResourceRecord = ReadDnsRTRecord @Params; break }
    ([Indented.Dns.RecordType]::NSAP)        { $ResourceRecord = ReadDnsNSAPRecord @Params; break }
    ([Indented.Dns.RecordType]::NSAPPTR)     { $ResourceRecord = ReadDnsNSAPPTRRecord @Params; break }
    ([Indented.Dns.RecordType]::SIG)         { $ResourceRecord = ReadDnsSIGRecord @Params; break }
    ([Indented.Dns.RecordType]::KEY)         { $ResourceRecord = ReadDnsKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::PX)          { $ResourceRecord = ReadDnsPXRecord @Params; break }
    ([Indented.Dns.RecordType]::GPOS)        { $ResourceRecord = ReadDnsGPOSRecord @Params; break }
    ([Indented.Dns.RecordType]::AAAA)        { $ResourceRecord = ReadDnsAAAARecord @Params; break }
    ([Indented.Dns.RecordType]::LOC)         { $ResourceRecord = ReadDnsLOCRecord @Params; break }
    ([Indented.Dns.RecordType]::NXT)         { $ResourceRecord = ReadDnsNXTRecord @Params; break }
    ([Indented.Dns.RecordType]::EID)         { $ResourceRecord = ReadDnsEIDRecord @Params; break }
    ([Indented.Dns.RecordType]::NIMLOC)      { $ResourceRecord = ReadDnsNIMLOCRecord @Params; break }
    ([Indented.Dns.RecordType]::SRV)         { $ResourceRecord = ReadDnsSRVRecord @Params; break }
    ([Indented.Dns.RecordType]::ATMA)        { $ResourceRecord = ReadDnsATMARecord @Params; break }
    ([Indented.Dns.RecordType]::NAPTR)       { $ResourceRecord = ReadDnsNAPTRRecord @Params; break }
    ([Indented.Dns.RecordType]::KX)          { $ResourceRecord = ReadDnsKXRecord @Params; break }
    ([Indented.Dns.RecordType]::CERT)        { $ResourceRecord = ReadDnsCERTRecord @Params; break }
    ([Indented.Dns.RecordType]::A6)          { $ResourceRecord = ReadDnsA6Record @Params; break }
    ([Indented.Dns.RecordType]::DNAME)       { $ResourceRecord = ReadDnsDNAMERecord @Params; break }
    ([Indented.Dns.RecordType]::SINK)        { $ResourceRecord = ReadDnsSINKRecord @Params; break }
    ([Indented.Dns.RecordType]::OPT)         { $ResourceRecord = ReadDnsOPTRecord @Params; break }
    ([Indented.Dns.RecordType]::APL)         { $ResourceRecord = ReadDnsAPLRecord @Params; break }
    ([Indented.Dns.RecordType]::DS)          { $ResourceRecord = ReadDnsDSRecord @Params; break }
    ([Indented.Dns.RecordType]::SSHFP)       { $ResourceRecord = ReadDnsSSHFPRecord @Params; break }
    ([Indented.Dns.RecordType]::IPSECKEY)    { $ResourceRecord = ReadDnsIPSECKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::RRSIG)       { $ResourceRecord = ReadDnsRRSIGRecord @Params; break }
    ([Indented.Dns.RecordType]::NSEC)        { $ResourceRecord = ReadDnsNSECRecord @Params; break }
    ([Indented.Dns.RecordType]::DNSKEY)      { $ResourceRecord = ReadDnsDNSKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::DHCID)       { $ResourceRecord = ReadDnsDHCIDRecord @Params; break }
    ([Indented.Dns.RecordType]::NSEC3)       { $ResourceRecord = ReadDnsNSEC3Record @Params; break }
    ([Indented.Dns.RecordType]::NSEC3PARAM)  { $ResourceRecord = ReadDnsNSEC3PARAMRecord @Params; break }
    ([Indented.Dns.RecordType]::HIP)         { $ResourceRecord = ReadDnsHIPRecord @Params; break }
    ([Indented.Dns.RecordType]::NINFO)       { $ResourceRecord = ReadDnsNINFORecord @Params; break }
    ([Indented.Dns.RecordType]::RKEY)        { $ResourceRecord = ReadDnsRKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::SPF)         { $ResourceRecord = ReadDnsSPFRecord @Params; break }
    ([Indented.Dns.RecordType]::TKEY)        { $ResourceRecord = ReadDnsTKEYRecord @Params; break }
    ([Indented.Dns.RecordType]::TSIG)        { $ResourceRecord = ReadDnsTSIGRecord @Params; break }
    ([Indented.Dns.RecordType]::TA)          { $ResourceRecord = ReadDnsTARecord @Params; break }
    ([Indented.Dns.RecordType]::DLV)         { $ResourceRecord = ReadDnsDLVRecord @Params; break }
    ([Indented.Dns.RecordType]::WINS)        { $ResourceRecord = ReadDnsWINSRecord @Params; break }
    ([Indented.Dns.RecordType]::WINSR)       { $ResourceRecord = ReadDnsWINSRRecord @Params; break }
    default                                  { ReadDnsUnknownRecord @Params }
  }
  
  return $ResourceRecord
}

function ReadDnsUnknownRecord {
  # .SYNOPSIS
  #   Reads properties for an unknown record type from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #   Indented.Dns.Message.ResourceRecord
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.Unknown
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  # Create the basic Resource Record
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.Unknown")
  
  # Property: BinaryData
  $ResourceRecord | Add-Member BinaryData -MemberType NoteProperty -Value ($BinaryReader.ReadBytes($ResourceRecord.RecordDataLength))
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    if ($this.BinaryData.Length -gt 0) {
      return ,$this.BinaryData | ConvertTo-String -Hexadecimal
    }
  }

  return $ResourceRecord
}

function ReadDnsARecord {
  # .SYNOPSIS
  #   Reads properties for an A record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.A
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.A")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv4Address()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }
  
  return $ResourceRecord
}

function ReadDnsNSRecord {
  # .SYNOPSIS
  #   Reads properties for an NS record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NS
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NS")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsMDRecord {
  # .SYNOPSIS
  #   Reads properties for an MD record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MD
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MD")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsMFRecord {
  # .SYNOPSIS
  #   Reads properties for an MF record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MF
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MF")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsCNAMERecord {
  # .SYNOPSIS
  #   Reads properties for an CNAME record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.CNAME
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.CNAME")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsSOARecord {
  # .SYNOPSIS
  #   Reads properties for an SOA record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     MNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     RNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    SERIAL                     |
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
  #    |                    MINIMUM                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.SOA
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SOA")

  # Property: NameServer
  $ResourceRecord | Add-Member NameServer -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: ResponsiblePerson
  $ResourceRecord | Add-Member ResponsiblePerson -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
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

function ReadDnsMBRecord {
  # .SYNOPSIS
  #   Reads properties for an MB record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MB
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MB")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsMGRecord {
  # .SYNOPSIS
  #   Reads properties for an MG record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MG
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MG")

  # Property: MailboxName
  $ResourceRecord | Add-Member Mailbox -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.MailboxName
  }
  
  return $ResourceRecord
}

function ReadDnsMRRecord {
  # .SYNOPSIS
  #   Reads properties for an MR record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MR
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MR")

  # Property: MailboxName
  $ResourceRecord | Add-Member MailboxName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.MailboxName
  }
  
  return $ResourceRecord
}

function ReadDnsNULLRecord {
  # .SYNOPSIS
  #   Reads properties for an NULL record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NULL
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NULL")
  
  # Property: BinaryData
  $ResourceRecord | Add-Member BinaryData -MemberType NoteProperty -Value ($BinaryReader.ReadBytes($ResourceRecord.RecordDataLength))
 
  return $ResourceRecord
}

function ReadDnsWKSRecord {
  # .SYNOPSIS
  #   Reads properties for an WKS record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.WKS
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  #   http://www.ietf.org/rfc/rfc1010.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.WKS")

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
  $BinaryString = ConvertTo-String $Bytes -Binary
  
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

function ReadDnsPTRRecord {
  # .SYNOPSIS
  #   Reads properties for an PTR record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.PTR
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.PTR")

  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Hostname
  }
  
  return $ResourceRecord
}

function ReadDnsHINFORecord {
  # .SYNOPSIS
  #   Reads properties for an HINFO record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.HINFO
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.HINFO")

  # Property: CPU
  $ResourceRecord | Add-Member CPU -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: OS
  $ResourceRecord | Add-Member OS -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.CPU,
      $this.OS)
  }
  
  return $ResourceRecord
}

function ReadDnsMINFORecord {
  # .SYNOPSIS
  #   Reads properties for an MINFO record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MINFO
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MINFO")
  
  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: ErrorMailbox
  $ResourceRecord | Add-Member ErrorMailbox -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.ResponsibleMailbox,
      $this.ErrorMailbox)
  }
  
  return $ResourceRecord
}

function ReadDnsMXRecord {
  # .SYNOPSIS
  #   Reads properties for an MX record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.MX
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.MX")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Exchange
  $ResourceRecord | Add-Member Exchange -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.Exchange)
  }
  
  return $ResourceRecord
}

function ReadDnsTXTRecord {
  # .SYNOPSIS
  #   Reads properties for an TXT record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.TXT
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.TXT")
 
  # Property: Text
  $ResourceRecord | Add-Member Text -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Text
  }
  
  return $ResourceRecord
}

function ReadDnsRPRecord {
  # .SYNOPSIS
  #   Reads properties for an RP record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.RP
  # .LINK
  #   http://www.ietf.org/rfc/rfc1183.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.RP")
  
  # Property: ResponsibleMailbox
  $ResourceRecord | Add-Member ResponsibleMailbox -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: TXTDomainName
  $ResourceRecord | Add-Member TXTDomainName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.ResponsibleMailbox,
      $this.TXTDomainName)
  }
  
  return $ResourceRecord
}

function ReadDnsAFSDBRecord {
  # .SYNOPSIS
  #   Reads properties for an AFSDB record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.AFSDB
  # .LINK
  #   http://www.ietf.org/rfc/rfc1183.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.AFSDB")
  
  $SubType = $BinaryReader.ReadBEUInt16()
  if ([Enum]::IsDefined([Idented.Dns.AFSDBSubType], $SubType)) {
    $SubType = [Indented.Dns.AFSDBSubType]$SubType
  }

  # Property: SubType
  $ResourceRecord | Add-Member SubType -MemberType NoteProperty -Value $SubType
  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.SubType,
      $this.Hostname)
  }
  
  return $ResourceRecord
}

function ReadDnsX25Record {
  # .SYNOPSIS
  #   Reads properties for an X25 record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.X25
  # .LINK
  #   http://www.ietf.org/rfc/rfc1183.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.X25")
  
  # Property: PSDNAddress
  $ResourceRecord | Add-Member PSDNAddress -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.PSDNAddress
  }
  
  return $ResourceRecord
}

function ReadDnsISDNRecord {
  # .SYNOPSIS
  #   Reads properties for an ISDN record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.ISDN
  # .LINK
  #   http://www.ietf.org/rfc/rfc1183.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.ISDN")
  
  # Property: ISDNAddress
  $ResourceRecord | Add-Member ISDNAddress -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: SubAddress
  $ResourceRecord | Add-Member SubAddress -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("""{0}"" ""{1}""",
      $this.ISDNAddress,
      $this.SubAddress)
  }
  
  return $ResourceRecord
}

function ReadDnsRTRecord {
  # .SYNOPSIS
  #   Reads properties for an RT record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.RT
  # .LINK
  #   http://www.ietf.org/rfc/rfc1183.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.RT")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: IntermediateHost
  $ResourceRecord | Add-Member IntermediateHost -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.IntermediateHost)
  }
  
  return $ResourceRecord
}

function ReadDnsNSAPRecord {
  # .SYNOPSIS
  #   Reads properties for an NSAP record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      NSAP                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NSAP
  # .LINK
  #   http://www.ietf.org/rfc/rfc1706.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NSAP")

  $ResourceRecord | Add-Member NSAP -MemberType NoteProperty -Value (New-Object String (,$BinaryReader.ReadChars($ResourceRecord.RecordDataLength)))

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.NSAP
  }
  
  return $ResourceRecord
}

function ReadDnsNSAPTRRecord {
  # .SYNOPSIS
  #   Reads properties for an NSAPTR record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     OWNER                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NSAPTR
  # .LINK
  #   http://www.ietf.org/rfc/rfc1348.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NSAPTR")

  # Property: Owner
  $ResourceRecord | Add-Member Owner -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Owner
  }
  
  return $ResourceRecord
}

function ReadDnsSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an SIG record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.SIG
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc2931.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SIG")

  # Property: TypeCovered
  $TypeCovered = $BinaryReader.ReadBEUInt16()
  if ([Enum]::IsDefined([Indented.Dns.RecordType], $TypeCovered)) {
    $TypeCovered = [Indented.Dns.RecordType]$TypeCovered
  } else {
    $TypeCovered = "UNKNOWN ($TypeCovered)"
  }
  $ResourceRecord | Add-Member TypeCovered -MemberType NoteProperty -Value $TypeCovered
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: Labels
  $ResourceRecord | Add-Member Labels -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: OriginalTTL
  $ResourceRecord | Add-Member OriginalTTL -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: SignatureExpiration
  $ResourceRecord | Add-Member SignatureExpiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: SignatureInception
  $ResourceRecord | Add-Member SignatureInception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SignersName
  $ResourceRecord | Add-Member SignersName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: Signature
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
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

function ReadDnsKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an KEY record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.KEY
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc2931.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.KEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ($BinaryReader.ReadBEUInt16())
  # Property: Authentication/Confidentiality (bit 0 and 1 of Flags)
  $ResourceRecord | Add-Member AuthenticationConfidentiality -MemberType ScriptProperty -Value {
    [Indented.Dns.KEYAC]([Byte]($this.Flags -shr 14))
  }
  # Property: Flags extension (bit 3)
  if (($Flags -band 0x1000) -eq 0x1000) {
    $ResourceRecord | Add-Member FlagsExtension -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
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
    $Base64String = ConvertTo-String $Bytes -Base64
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

function ReadDnsPXRecord {
  # .SYNOPSIS
  #   Reads properties for an PX record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  PREFERENCE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MAP822                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   MAPX400                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.PX
  # .LINK
  #   http://www.ietf.org/rfc/rfc2163.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.PX")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: MAP822
  $ResourceRecord | Add-Member MAP822 -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: MAPX400
  $ResourceRecord | Add-Member MAPX400 -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.MAP822,
      $this.MAPX400)
  }
  
  return $ResourceRecord
}

function ReadDnsGPOSRecord {
  # .SYNOPSIS
  #   Reads properties for an GPOS record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   LONGITUDE                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   LATITUDE                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   ALTITUDE                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.GPOS
  # .LINK
  #   http://www.ietf.org/rfc/rfc1712.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.GPOS")
  
  # Property: Longitude
  $ResourceRecord | Add-Member Longitude -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: Latitude
  $ResourceRecord | Add-Member Latitude -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: Altitude
  $ResourceRecord | Add-Member Altitude -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2}",
      $this.Longitude,
      $this.Latitude,
      $this.Altitude)
  }
  
  return $ResourceRecord
}

function ReadDnsAAAARecord {
  # .SYNOPSIS
  #   Reads properties for an AAAA record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.AAAA
  # .LINK
  #   http://www.ietf.org/rfc/rfc3596.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )
  
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.AAAA")

  # Property: IPAddress
  $ResourceRecord | Add-Member IPAddress -MemberType NoteProperty -Value $BinaryReader.ReadIPv6Address()

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.IPAddress.ToString()
  }
  
  return $ResourceRecord
}

function ReadDnsLOCRecord {
  # .SYNOPSIS
  #   Reads properties for an LOC record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        VERSION        |         SIZE          |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       HORIZ PRE       |       VERT PRE        |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   LATITUDE                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   LONGITUDE                   |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   ALTITUDE                    |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.LOC
  # .LINK
  #   http://www.ietf.org/rfc/rfc1876.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.LOC")
 
  # Property: Version
  $ResourceRecord | Add-Member Version -MemberType NoteProperty -Value $BinaryReader.ReadByte()

  # Size handling - Default value is 1m
  $Byte = $BinaryReader.ReadByte()
  $Base = $Byte -band 0xF0 -shr 4
  $Power = $Byte -band 0x0F
  $Value = ($Base * [Math]::Pow(10, $Power)) / 100
  # Property: Size
  $ResourceRecord | Add-Member Size -MemberType NoteProperty -Value $Value

  # HorizontalPrecision handling - Default value is 10000m
  $Byte = $BinaryReader.ReadByte()
  $Base = $Byte -band 0xF0 -shr 4
  $Power = $Byte -band 0x0F
  $Value = ($Base * [Math]::Pow(10, $Power)) / 100
  # Property: HorizontalPrecision
  $ResourceRecord | Add-Member HorizontalPrecision -MemberType NoteProperty -Value $Value
  
  # VerticalPrecision handling - Default value is 10m
  $Byte = $BinaryReader.ReadByte()
  $Base = $Byte -band 0xF0 -shr 4
  $Power = $Byte -band 0x0F
  $Value = ($Base * [Math]::Pow(10, $Power)) / 100
  # Property: VerticalPrecision
  $ResourceRecord | Add-Member VerticalPrecision -MemberType NoteProperty -Value $Value
 
  # Property: LatitudeRawValue
  $ResourceRecord | Add-Member LatitudeRawValue -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Latitude
  $ResourceRecord | Add-Member Latitude -MemberType ScriptProperty -Value {
    $Equator = [Math]::Pow(2, 31)
    if ($this.LatitudeRawValue -gt $Equator) {
      $Direction = "S"
    } else {
      $Direction = "N"
    }
    # Degrees
    $Remainder = $Value % (1000 * 60 * 60)
    $Degrees = ($Value - $Remainder) / (1000 * 60 * 60)
    $Value = $Remainder
    # Minutes
    $Remainder = $Value % (1000 * 60)
    $Minutes = ($Value - $Remainder) / (1000 * 60)
    $Value = $Remainder
    # Seconds
    $Seconds = $Value / 1000
    # Return value
    "$Degrees $Minutes $Seconds $Direction"
  }
  # Property: LatitudeToString
  $ResourceRecord | Add-Member LatitudeToString -MemberType ScriptProperty -Value {
    $Values = $this.Latitude -split ' '
    [String]::Format("{0} degrees {1} minutes {2} seconds {3}",
      $Values[0],
      $Values[1],
      $Values[2],
      $Values[3])
  }
  
  # Property: LongitudeRawValue
  $ResourceRecord | Add-Member LongitudeRawValue -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: Longitude
  $ResourceRecord | Add-Member Longitude -MemberType ScriptProperty -Value {
    $PrimeMeridian = [Math]::Pow(2, 31)
    if ($this.LongitudeRawValue -gt $PrimeMeridian) {
      $Direction = "E"
    } else {
      $Direction = "W"
    }
    # Degrees
    $Remainder = $Value % (1000 * 60 * 60)
    $Degrees = ($Value - $Remainder) / (1000 * 60 * 60)
    $Value = $Remainder
    # Minutes
    $Remainder = $Value % (1000 * 60)
    $Minutes = ($Value - $Remainder) / (1000 * 60)
    $Value = $Remainder
    # Seconds
    $Seconds = $Value / 1000
    # Return value
    "$Degrees $Minutes $Seconds $Direction"
  }
  # Property: LongitudeToString
  $ResourceRecord | Add-Member LongitudeToString -MemberType ScriptProperty -Value {
    $Values = $this.Longitude -split ' '
    [String]::Format("{0} degrees {1} minutes {2} seconds {3}",
      $Values[0],
      $Values[1],
      $Values[2],
      $Values[3])
  }

  # Property: Altitude
  $ResourceRecord | Add-Member Altitude -MemberType NoteProperty -Value ($BinaryReader.ReadBEUInt32() / 100)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}m {4}m {5}m",
      $this.Latitude,
      $this.Longitude,
      $this.Altitude,
      $this.Size,
      $this.HorizontalPrecision,
      $this.VerticalPrecision
    )
  }
  
  return $ResourceRecord
}

function ReadDnsNXTRecord {
  # .SYNOPSIS
  #   Reads properties for an NXT record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NXT
  # .LINK
  #   http://www.ietf.org/rfc/rfc2535.txt
  #   http://www.ietf.org/rfc/rfc3755.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NXT")
  
  # Property: DomainName
  $ResourceRecord | Add-Member DomainName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
    
  # Property: RRTypeBitMap
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $BinaryString = ConvertTo-String $Bytes -Binary
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
    [String]::Format("{0} {1} {2}",
      $this.DomainName,
      "$($this.RRTypes)")
  }
  
  return $ResourceRecord
}

function ReadDnsEIDRecord {
  # .SYNOPSIS
  #   Reads properties for an EID record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      EID                      /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.EID
  # .LINK
  #   http://cpansearch.perl.org/src/MIKER/Net-DNS-Codes-0.11/extra_docs/draft-ietf-nimrod-dns-02.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.EID")

  # Property: EID
  $EID = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength) | ForEach-Object { '{0:X2}' -f $_ }
  $ResourceRecord | Add-Member EID -MemberType NoteProperty -Value "$EID"

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.EID
  }
  
  return $ResourceRecord
}

function ReadDnsNIMLOCRecord {
  # .SYNOPSIS
  #   Reads properties for an NIMLOC record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    NIMLOC                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NIMLOC
  # .LINK
  #   http://cpansearch.perl.org/src/MIKER/Net-DNS-Codes-0.11/extra_docs/draft-ietf-nimrod-dns-02.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NIMLOC")

  # Property: NIMLOC
  $NIMLOC = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength) | ForEach-Object { '{0:X2}' -f $_ }
  $ResourceRecord | Add-Member NIMLOC -MemberType NoteProperty -Value "$NIMLOC"

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.NIMLOC
  }
  
  return $ResourceRecord
}

function ReadDnsSRVRecord {
  # .SYNOPSIS
  #   Reads properties for an SRV record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.SRV
  # .LINK
  #   http://www.ietf.org/rfc/rfc2782.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SRV")
  
  # Property: Priority
  $ResourceRecord | Add-Member Priority -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Weight
  $ResourceRecord | Add-Member Weight -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Port
  $ResourceRecord | Add-Member Port -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Hostname
  $ResourceRecord | Add-Member Hostname -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

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

function ReadDnsATMARecord {
  # .SYNOPSIS
  #   Reads properties for an ATMA record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.ATMA
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.ATMA")
  
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

function ReadDnsNAPTRRecord {
  # .SYNOPSIS
  #   Reads properties for an NAPTR record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ORDER                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   PREFERENCE                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     FLAGS                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   SERVICES                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    REGEXP                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  REPLACEMENT                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NAPTR
  # .LINK
  #   http://www.ietf.org/rfc/rfc2915.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NAPTR")
  
  # Property: Order
  $ResourceRecord | Add-Member Order -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: Service
  $ResourceRecord | Add-Member Service -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: RegExp
  $ResourceRecord | Add-Member RegExp -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)
  # Property: Replacement
  $ResourceRecord | Add-Member RegExp -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("`n" +
                     "    ;;  order    pref  flags  service       regexp              replacement`n" +
                     "        {0} {1} {2} {3} {4} {5}",
      $this.Order.ToString().PadRight(8, ' '),
      $this.Preference.ToString().PadRight(5, ' '),
      $this.Flags.PadRight(6, ' '),
      $this.Service.PadRight(13, ' '),
      $this.RegExp.PadRight(19, ' '),
      $this.Replacement)
  }
  
  return $ResourceRecord
}

function ReadDnsKXRecord {
  # .SYNOPSIS
  #   Reads properties for an KX record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  PREFERENCE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   EXCHANGER                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.KX
  # .LINK
  #   http://www.ietf.org/rfc/rfc2230.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.KX")
  
  # Property: Preference
  $ResourceRecord | Add-Member Preference -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Exchanger
  $ResourceRecord | Add-Member Exchanger -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1}",
      $this.Preference.ToString().PadRight(5, ' '),
      $this.Exchanger)
  }
  
  return $ResourceRecord
}

function ReadDnsCERTRecord {
  # .SYNOPSIS
  #   Reads properties for an CERT record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     TYPE                      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEY TAG                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |                       |
  #    +--+--+--+--+--+--+--+--+                       |
  #    /               CERTIFICATE or CRL              /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.CERT
  # .LINK
  #   http://www.ietf.org/rfc/rfc4398.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.CERT")

  # Property: CertificateType
  $ResourceRecord | Add-Member CertificateType -MemberType NoteProperty -Value ([Indented.Dns.CertificateType]$Reader.ReadBEUInt16())
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $Reader.ReadBEUInt16()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$Reader.ReadByte())
  # Property: Certificate
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member Certificate -MemberType NoteProperty -Value $Base64String
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.CertificateType.ToString(),
      ([UInt16]$this.KeyTag).ToString(),
      ([UInt16]$this.Algorithm).ToString(),
      $this.Certificate)
  }
  
  return $ResourceRecord
}

function ReadDnsA6Record {
  # .SYNOPSIS
  #   Reads properties for an CERT record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |      PREFIX LEN       |                       |
  #    +--+--+--+--+--+--+--+--+                       |
  #    /                ADDRESS SUFFIX                 /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  PREFIX NAME                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.A6
  # .LINK
  #   http://www.ietf.org/rfc/rfc2874.txt
  #   http://www.ietf.org/rfc/rfc3226.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.A6")

  # Property: PrefixLength
  $PrefixLength = $Reader.ReadByte()
  $ResourceRecord | Add-Member PrefixLength -MemberType NoteProperty -Value $PrefixLength
  
  # Return the address suffix
  $Length = [Math]::Ceiling((128 - $PrefixLength) / 8)
  $AddressSuffixBytes = $BinaryReader.ReadBytes($Length)
  
  # Make the AddressSuffix 16 bytes long
  while ($AddressSuffixBytes.Length -lt 16) {
    $AddressSuffixBytes = @([Byte]0) + $AddressSuffixBytes
  }
  # Convert the address bytes to an IPv6 style string
  $IPv6AddressArray = @()
  for ($i = 0; $i -lt 16; $i += 2) {
    $IPv6AddressArray += [String]::Format('{0:X2}{1:X2}', $AddressSuffixBytes[$i], $AddressSuffixBytes[$i + 1])
  }
  $IPv6Address = [IPAddress]($IPv6AddressArray -join ':')
  
  # Property: AddressSuffix
  $ResourceRecord | Add-Member AddressSuffix -MemberType NoteProperty -Value $IPv6Address
  # Property: PrefixName
  $ResourceRecord | Add-Member PrefixName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2}",
      $this.PrefixLength.ToString(),
      $this.AddressSuffix.IPAddressToString,
      $this.PrefixName)
  }
  
  return $ResourceRecord
}

function ReadDnsDNAMERecord {
  # .SYNOPSIS
  #   Reads properties for an DNAME record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     TARGET                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DNAME
  # .LINK
  #   http://www.ietf.org/rfc/rfc2672.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.DNAME")

  # Property: Target
  $ResourceRecord | Add-Member Target -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.Target
  }
  
  return $ResourceRecord
}

function ReadDnsSINKRecord {
  # .SYNOPSIS
  #   Reads properties for an SINK record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        CODING         |       SUBCODING       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     DATA                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DNAME
  # .LINK
  #   http://tools.ietf.org/id/draft-eastlake-kitchen-sink-02.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SINK")

  # Property: Coding
  $ResourceRecord | Add-Member Coding -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Subcoding
  $ResourceRecord | Add-Member Subcoding -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Data
  $Length = $ResourceRecord.RecordDataLength - 2
  $ResourceRecord | Add-Member Data -MemberType NoteProperty -Value $BinaryReader.ReadBytes($Length)
  
  return $ResourceRecord
}

function ReadDnsOPTRecord {
  # .SYNOPSIS
  #   Reads properties for an OPT record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   OPT records make the following changes to standard resource record fields:
  #
  #   Field Name   Field Type     Description
  #   ----------   ----------     -----------
  #   NAME         domain name    empty (root domain)
  #   TYPE         u_int16_t      OPT
  #   CLASS        u_int16_t      sender's UDP payload size
  #   TTL          u_int32_t      extended RCODE and flags
  #   RDLEN        u_int16_t      describes RDATA
  #   RDATA        octet stream   {attribute,value} pairs
  # 
  #   The Extended RCODE (stored in the TTL) is formatted as follows:
  #  
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |    EXTENDED-RCODE     |        VERSION        |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                       Z                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   RR data structure:
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  OPTION-CODE                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 OPTION-LENGTH                 |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  OPTION-DATA                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   Processing for each option assigned by IANA has been added as described below.
  #
  #   LLQ
  #   ---
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  OPTION-CODE                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 OPTION-LENGTH                 |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    VERSION                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  LLQ-OPCODE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  ERROR-CODE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #    |                    LLQ-ID                     |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #    |                  LEASE-LIFE                   |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  # 
  #   NSID
  #   ----
  #
  #   Option data is returned as a byte array (NSIDBytes) and an ASCII string (NSIDString).
  #
  #   DUA, DHU and N3U
  #   ----------------
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  OPTION-CODE                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  LIST-LENGTH                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        ALG-CODE       |          ...          /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   EDNS-client-subnet
  #   ------------------
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  OPTION-CODE                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 OPTION-LENGTH                 |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 ADDRESSFAMILY                 |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |    SOURCE NETMASK     |     SCOPE NETMASK     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #    /                    ADDRESS                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #  
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.OPT
  # .LINK
  #   http://www.ietf.org/rfc/rfc2671.txt
  #   http://files.dns-sd.org/draft-sekar-dns-llq.txt
  #   http://files.dns-sd.org/draft-sekar-dns-ul.txt
  #   http://www.ietf.org/rfc/rfc5001.txt
  #   http://www.ietf.org/rfc/rfc6975.txt
  #   http://www.ietf.org/id/draft-vandergaast-edns-client-subnet-02.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.OPT")

  # Property: MaximumPayloadSize - A copy of the data held in Class
  $ResourceRecord | Add-Member MaximumPayloadSize -MemberType NoteProperty -Value $ResourceRecord.RecordClass
  # Property: ExtendedRCode
  $ResourceRecord | Add-Member ExtendedRCode -MemberType NoteProperty -Value ([Indented.Dns.RCode][UInt16]($ResourceRecord.TTL -shr 24))
  # Property: Version
  $ResourceRecord | Add-Member Version -MemberType NoteProperty -Value ($ResourceRecord.TTL -band 0x00FF0000)
  # Property: DNSSECOK
  $ResourceRecord | Add-Member DNSSECOK -MemberType NoteProperty -Value ([Indented.Dns.EDnsDNSSECOK]($ResourceRecord.TTL -band 0x00008000))
  # Property: Options - A container for individual options
  $ResourceRecord | Add-Member Options -MemberType NoteProperty -Value @()
  
  # RecordData handling - a counter to decrement
  $RecordDataLength = $ResourceRecord.RecordDataLength
  if ($RecordDataLength -gt 0) {
    do {
      $BinaryReader.SetMarker()
    
      $Option = New-Object PsObject -Property ([Ordered]@{
        OptionCode   = ([Indented.Dns.EDnsOptionCode]$BinaryReader.ReadBEUInt16());
        OptionLength = ($BinaryReader.ReadBEUInt16());
      })
   
      switch ($Option.OptionCode) {
        ([Indented.Dns.EDnsOptionCode]::LLQ) {
          # Property: Version
          $Option | Add-Member Version -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
          # Property: OpCode
          $Option | Add-Member OpCode -MemberType NoteProperty -Value ([Indented.Dns.LLQOpCode]$BinaryReader.ReadBEUInt16())
          # Property: ErrorCode
          $Option | Add-Member ErrorCode -MemberType NoteProperty -Value ([Indented.Dns.LLQErrorCode]$BinaryReader.ReadBEUInt16())
          # Property: ID
          $Option | Add-Member ID -MemberType NoteProprery -Value $BinaryReader.ReadBEUInt64()
          # Property: LeaseLife
          $Option | Add-Member LeaseLife -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()

          break        
        }
        ([Indented.Dns.EDnsOptionCode]::UL) {
          # Property: Lease
          $Option | Add-Member Lease -MemberType NoteProperty -Value $BinaryReader.ReadBEInt32()
        
          break
        }
        ([Indented.Dns.EDnsOptionCode]::NSID) {
          $Bytes = $BinaryReader.ReadBytes($Option.OptionLength)
        
          # Property: Bytes
          $Option | Add-Member Bytes -MemberType NoteProperty -Value $Bytes
          # Property: String
          $Option | Add-Member String -MemberType NoteProperty -Value (ConvertTo-String $Bytes)
          
          break
        }
        ([Indented.Dns.EDnsOptionCode]::DAU) {
          # Property: Algorithm
          $Option | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
          # Property: HashBytes
          $Bytes = $BinaryReader.ReadBytes($Option.OptionLength)
          $Base64String = ConvertTo-String $Bytes -Base64
          $Option | Add-Member HashBytes -MemberType NoteProperty -Value $Base64String
        
          break
        }
        ([Indented.Dns.EDnsOptionCode]::DHU) {
          # Property: Algorithm
          $Option | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
          # Property: HashBytes
          $Bytes = $BinaryReader.ReadBytes($Option.OptionLength)
          $Base64String = ConvertTo-String $Bytes -Base64
          $Option | Add-Member HashBytes -MemberType NoteProperty -Value $Base64String
        
          break
        }
        ([Indented.Dns.EDnsOptionCode]::N3U) {
          # Property: Algorithm
          $Option | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
          # Property: HashBytes
          $Bytes = $BinaryReader.ReadBytes($Option.OptionLength)
          $Base64String = ConvertTo-String $Bytes -Base64
          $Option | Add-Member HashBytes -MemberType NoteProperty -Value $Base64String
        
          break
        }
        ([Indented.Dns.EDnsOptionCode]::"EDNS-client-subnet") {
          # Property: AddressFamily
          $Option | Add-Member AddressFamily -MemberType NoteProperty -Value ([Indented.Dns.IanaAddressFamily]$BinaryReader.ReadBEUInt16())
          # Property: SourceNetMask
          $Option | Add-Member SourceNetMask -MemberType NoteProperty -Value $BinaryReader.ReadByte()
          # Property: ScopeNetMask
          $Option | Add-Member ScopeNetMask -MemberType NoteProperty -Value $BinaryReader.ReadByte()

          $AddressLength = [Math]::Ceiling($Option.SourceNetMask / 8)
          $AddressBytes = $BinaryReader.ReadBytes($AddressLength)
          
          switch ($Option.AddressFamily) {
            ([Indented.Dns.IanaAddressFamily]::IPv4) {
              while ($AddressBytes.Length -lt 4) {
                $AddressBytes = @([Byte]0) + $AddressBytes
              }
              $Address = [IPAddress]($AddressBytes -join '.')
              
              break
            }
            ([Indented.Dns.IanaAddressFamily]::IPv6) {
              while ($AddressBytes.Length -lt 16) {
                $AddressBytes = @([Byte]0) + $AddressBytes
              }
              $IPv6Address = @()
              for ($i = 0; $i -lt 16; $i += 2) {
                $IPv6Address += [String]::Format('{0:X2}{1:X2}', $AddressSuffixBytes[$i], $AddressSuffixBytes[$i + 1])
              }
              $Address = [IPAddress]($IPv6Address -join ':')
              
              break
            }
            default {
              $Address = $AddressBytes
            }
          }        
          # Property: Address
          $Option | Add-Member Address -MemberType NoteProperty -Value $Address

          break
        }
        default {
          $Option | Add-Member OptionData -MemberType NoteProperty -Value $BinaryReader.ReadBytes($Option.OptionLength)
        }
      }
      
      $ResourceRecord.Options += $Option
      
      $RecordDataLength = $RecordDataLength - $BinaryReader.BytesFromMarker
    } until ($RecordDataLength -eq 0)
  }
  
  return $ResourceRecord
}

function ReadDnsAPLRecord {
  # .SYNOPSIS
  #   Reads properties for an APL record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                 ADDRESSFAMILY                 |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |        PREFIX         | N|     AFDLENGTH      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    AFDPART                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.APL
  # .LINK
  #   http://tools.ietf.org/html/rfc3123
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.APL")

  # Property: List
  $ResourceRecord | Add-Member List -MemberType NoteProperty -Value @()
  
  # RecordData handling - a counter to decrement
  $RecordDataLength = $ResourceRecord.RecordDataLength
  if ($RecordDataLength -gt 0) {
    do {
      $BinaryReader.SetMarker()

      $ListItem = New-Object PsObject -Property ([Ordered]@{
        AddressFamily = ([Indented.Dns.IanaAddressFamily]$BinaryReader.ReadBEUInt16());
        Prefix        = $BinaryReader.ReadByte();
        Negation      = $false;
        AddressLength = 0;
        Address       = $null;
      })
      
      $NegationAndLength = $BinaryReader.ReadByte()
      # Property: Negation
      $ListItem.Negation = [Boolean]($NegationAndLength -band 0x0800)
      # Property: AddressLength
      $ListItem.AddressLength = $NegationAndLength -band 0x007F
      
      $AddressLength = [Math]::Ceiling($ResourceRecord.AddressLength / 8)
      $AddressBytes = $BinaryReader.ReadBytes($AddressLength)
            
      switch ($ListItem.AddressFamily) {
        ([Indented.Dns.IanaAddressFamily]::IPv4) {
          while ($AddressBytes.Length -lt 4) {
            $AddressBytes = @([Byte]0) + $AddressBytes
          }
          $Address = [IPAddress]($AddressBytes -join '.')
                  
          break
        }
        ([Indented.Dns.IanaAddressFamily]::IPv6) {
          while ($AddressBytes.Length -lt 16) {
            $AddressBytes = @([Byte]0) + $AddressBytes
          }
          $IPv6Address = @()
          for ($i = 0; $i -lt 16; $i += 2) {
            $IPv6Address += [String]::Format('{0:X2}{1:X2}', $AddressSuffixBytes[$i], $AddressSuffixBytes[$i + 1])
          }
          $Address = [IPAddress]($IPv6Address -join ':')

          break
        }
        default {
          $Address = $AddressBytes
        }
      }        

      # Property: Address
      $ListItem.Address = $Address
    
      $ResourceRecord.List += $ListItem
    
      $RecordDataLength = $RecordDataLength - $BinaryReader.BytesFromMarker
    } until ($RecordDataLength -eq 0)
  }
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $Values = $this.List | ForEach-Object {
      [String]::Format("{0}{1}:{2}/{3}",
        $(if ($_.Negation) { "!" } else { "" }),
        ([UInt16]$_.AddressFamily),
        $_.Address,
        $_.Prefix)
    }
    if ($Values.Count -gt 1) {
      "( $Values )"
    } else {
      "$Values"
    }
  }
 
  return $ResourceRecord
}


function ReadDnsDSRecord {
  # .SYNOPSIS
  #   Reads properties for an DS record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEYTAG                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |      DIGESTTYPE       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    DIGEST                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DS
  # .LINK
  #   http://www.ietf.org/rfc/rfc3658.txt
  #   http://www.ietf.org/rfc/rfc4034.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.DS")
  
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: DigestType
  $ResourceRecord | Add-Member DigestType -MemberType NoteProperty -Value ([Indented.Dns.DigestType]$BinaryReader.ReadByte())
  # Property: Digest
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member Digest -MemberType NoteProperty -Value $HexString

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.KeyTag.ToString(),
      ([Byte]$this.Algorithm).ToString(),
      ([Byte]$this.DigestType).ToString(),
      $this.Digest)
  }
  
  return $ResourceRecord
} 

function ReadDnsSSHFPRecord {
  # .SYNOPSIS
  #   Reads properties for an SSHFP record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |        FPTYPE         |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  FINGERPRINT                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.SSHFP
  # .LINK
  #   http://www.ietf.org/rfc/rfc4255.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SSHFP")

  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.SSHAlgorithm]$BinaryReader.ReadByte())
  # Property: FPType
  $ResourceRecord | Add-Member FPType -MemberType NoteProperty -Value ([Indented.Dns.SSHFPType]$BinaryReader.ReadByte())
  # Property: Fingerprint
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 2)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member Fingerprint -MemberType NoteProperty -Value $HexString

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2}",
      ([Byte]$this.Algorithm).ToString(),
      ([Byte]$this.FPType).ToString(),
      $this.Fingerprint)
  }
  
  return $ResourceRecord
} 

function ReadDnsIPSECKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an IPSECKEY record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |      PRECEDENCE       |      GATEWAYTYPE      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                    GATEWAY                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   PUBLICKEY                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.IPSECKEY
  # .LINK
  #   http://www.ietf.org/rfc/rfc4025.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.IPSECKEY")
  
  # Property: Precedence
  $ResourceRecord | Add-Member Precedence -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: GatewayType
  $ResourceRecord | Add-Member GatewayType -MemberType NoteProperty -Value ([Indented.Dns.IPSECGatewayType]$BinaryReader.ReadByte())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.IPSECAlgorithm]$BinaryReader.ReadByte())
  
  switch ($ResourceRecord.GatewayType) {
    ([Indented.Dns.IPSECGatewayType]::NoGateway) {
      $Gateway = ""
      
      break
    }
    ([Indented.Dns.IPSECGatewayType]::IPv4) {
      $Gateway = $BinaryReader.ReadIPv4Address()
      
      break
    }
    ([Indented.Dns.IPSECGatewayType]::IPv6) {
      $Gateway = $BinaryReader.ReadIPv6Address()
      
      break
    }
    ([Indented.Dns.IPSECGatewayType]::DomainName) {
      $Gateway = ConvertToDnsDomainName $BinaryReader
    
      break
    }
  }
  
  # Property: Gateway
  $ResourceRecord | Add-Member Gateway -MemberType NoteProperty -Value $Gateway
  # Property: PublicKey
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format(" ( {0} {1} {2}`n" +
                     "    {3}`n" +
                     "    {4} )",
      $this.Precedence.ToString(),
      ([Byte]$this.GatewayType).ToString(),
      ([Byte]$this.Algorithm).ToString(),
      $this.Gateway,
      $this.PublicKey)
  }
  
  return $ResourceRecord
} 

function ReadDnsRRSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an RRSIG record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.RRSIG
  # .LINK
  #   http://www.ietf.org/rfc/rfc3755.txt
  #   http://www.ietf.org/rfc/rfc4034.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.RRSIG")

  # Property: TypeCovered
  $TypeCovered = $BinaryReader.ReadBEUInt16()
  if ([Enum]::IsDefined([Indented.Dns.RecordType], $TypeCovered)) {
    $TypeCovered = [Indented.Dns.RecordType]$TypeCovered
  } else {
    $TypeCovered = "UNKNOWN ($TypeCovered)"
  }
  $ResourceRecord | Add-Member TypeCovered -MemberType NoteProperty -Value $TypeCovered
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: Labels
  $ResourceRecord | Add-Member Labels -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: OriginalTTL
  $ResourceRecord | Add-Member OriginalTTL -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: SignatureExpiration
  $ResourceRecord | Add-Member SignatureExpiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: SignatureInception
  $ResourceRecord | Add-Member SignatureInception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SignersName
  $ResourceRecord | Add-Member SignersName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: Signature
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
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

function ReadDnsNSECRecord {
  # .SYNOPSIS
  #   Reads properties for an NSEC record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NSEC
  # .LINK
  #   http://www.ietf.org/rfc/rfc3755.txt
  #   http://www.ietf.org/rfc/rfc4034.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NSEC")
  
  # Property: DomainName
  $ResourceRecord | Add-Member DomainName -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: RRTypeBitMap
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $BinaryString = ConvertTo-String $Bytes -Binary
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
    [String]::Format("{0} {1} {2}",
      $this.DomainName,
      "$($this.RRTypes)")
  }
  
  return $ResourceRecord
}

function ReadDnsDNSKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an DNSKEY record from a byte stream.
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
  #   The flags field takes the following format, discussed in RFC 4034 2.1.1:
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    | Z|                    | S|
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  #   Where Z represents the ZoneKey bit, and S the SecureEntryPoint bit.
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DNSKEY
  # .LINK
  #   http://www.ietf.org/rfc/rfc3755.txt
  #   http://www.ietf.org/rfc/rfc4034.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.DNSKEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ($BinaryReader.ReadBEUInt16())
  # Property: ZoneKey (bit 7 of Flags)
  $ResourceRecord | Add-Member ZoneKey -MemberType ScriptProperty -Value {
    [Boolean]($this.Flags -band 0x0100)
  }
  # Property: SecureEntryPoint (bit 15 of Flags)
  $ResourceRecord | Add-Member SecureEntryPoint -MemberType ScriptProperty -Value {
    [Boolean]($this.Flags -band 0x0001)
  }
  # Property: Protocol
  $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([Indented.Dns.KEYProtocol]$BinaryReader.ReadByte())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: PublicKey
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String
  
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

function ReadDnsDHCIDRecord {
  # .SYNOPSIS
  #   Reads properties for an DHCID record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DHCID
  # .LINK
  #   http://www.ietf.org/rfc/rfc4701.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.DHCID")
  
  # Property: BinaryData
  $ResourceRecord | Add-Member BinaryData -MemberType NoteProperty -Value ($BinaryReader.ReadBytes($ResourceRecord.RecordDataLength))
 
  return $ResourceRecord
}

function ReadDnsNSEC3Record {
  # .SYNOPSIS
  #   Reads properties for an NSEC3 record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       HASH ALG        |         FLAGS         |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   ITERATIONS                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       SALT LEN        |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                      SALT                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       HASH LEN        |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                      HASH                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                   <BIT MAP>                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+  
  #
  #   The flags field takes the following format, discussed in RFC 5155 3.2:
  #
  #      0  1  2  3  4  5  6  7 
  #    +--+--+--+--+--+--+--+--+
  #    |                    |O |
  #    +--+--+--+--+--+--+--+--+
  #
  #   Where O, bit 7, represents the Opt-Out Flag.
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NSEC3
  # .LINK
  #   http://www.ietf.org/rfc/rfc5155.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NSEC3")

  # Property: HashAlgorithm
  $ResourceRecord | Add-Member HashAlgorithm -MemberType NoteProperty -Value ([Indented.Dns.NSEC3HashAlgorithm]$BinaryReader.ReadByte())
  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: OptOut
  $ResourceRecord | Add-Member OptOut -MemberType ScriptProperty -Value {
    [Boolean]($this.Flags -band [Indented.Dns.NSEC3Flags]::OutOut)
  }
  # Property: Iterations
  $ResourceRecord | Add-Member Iterations -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SaltLength
  $ResourceRecord | Add-Member SaltLength -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Salt
  if ($ResourceRecord.SaltLength -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.SaltLength)
    $Base64String = ConvertTo-String $Bytes -Base64
  }
  $ResourceRecord | Add-Member Salt -MemberType NoteProperty -Value $Base64String
  # Property: HashLength
  $ResourceRecord | Add-Member HashLength -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Hash
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.HashLength)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member Hash -MemberType NoteProperty -Value $Base64String
  # Property: RRTypeBitMap
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $BinaryString = ConvertTo-String $Bytes -Binary
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
    [String]::Format("{0} {1} {2} {3} (`n" +
                     "{4} {5} )",
      ([Byte]$this.HashAlgorithm).ToString(),
      $this.Flags.ToString(),
      $this.Iterations.ToString(),
      $this.Salt,
      $this.Hash,
      "$($this.RRTypes)")
  }
  
  return $ResourceRecord
}

function ReadDnsNSEC3PARAMRecord {
  # .SYNOPSIS
  #   Reads properties for an NSEC3PARAM record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       HASH ALG        |         FLAGS         |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   ITERATIONS                  |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       SALT LEN        |                       /
  #    +--+--+--+--+--+--+--+--+                       /
  #    /                      SALT                     /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NSEC3PARAM
  # .LINK
  #   http://www.ietf.org/rfc/rfc5155.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NSEC3PARAM")

  # Property: HashAlgorithm
  $ResourceRecord | Add-Member HashAlgorithm -MemberType NoteProperty -Value ([Indented.Dns.NSEC3HashAlgorithm]$BinaryReader.ReadByte())
  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Iterations
  $ResourceRecord | Add-Member Iterations -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: SaltLength
  $ResourceRecord | Add-Member SaltLength -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Salt
  $HexString = ""
  if ($ResouceRecord.SaltLength -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.SaltLength)
    $HexString = ConvertTo-String $Bytes -Hexadecimal
  }
  $ResourceRecord | Add-Member Salt -MemberType NoteProperty -Value $HexString
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      ([Byte]$this.HashAlgorithm).ToString(),
      $this.Flags.ToString(),
      $this.Iterations.ToString(),
      $this.Salt)
  }
  
  return $ResourceRecord
}

function ReadDnsHIPRecord {
  # .SYNOPSIS
  #   Reads properties for an HIP record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |      HIT LENGTH       |     PK ALGORITHM      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |               PUBLIC KEY LENGTH               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      HIT                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   PUBLIC KEY                  /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /              RENDEZVOUS SERVERS               /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.HIP
  # .LINK
  #   http://www.ietf.org/rfc/rfc5205.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.HIP")

  # Property: HITLength
  $ResourceRecord | Add-Member HIPLength -MemberType NoteProperty -Value $BinaryReader.ReadByte()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.IPSECAlgorithm]$BinaryReader.ReadByte())
  # Property: PublicKeyLength
  $ResourceRecord | Add-Member PublicKeyLength -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: HIT
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.HITLength)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member HIT -MemberType NoteProperty -Value $HexString
  # Property: PublicKey
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.PublicKeyLength)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String  
  # Property: RendezvousServers - A container for individual servers
  $ResourceRecord | Add-Member RendezvousServers -MemberType NoteProperty -Value @()
  
  # RecordData handling - a counter to decrement
  $RecordDataLength = $ResourceRecord.RecordDataLength
  if ($RecordDataLength -gt 0) {
    do {
      $BinaryReader.SetMarker()

      $ResourceRecord.RendezvousServers += (ReadDnsDomainName $BinaryReader)
    
      $RecordDataLength = $RecordDataLength - $BinaryReader.BytesFromMarker
    } until ($RecordDataLength -eq 0)
  }
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("( {0} {1}`n" +
                     "    {2}`n" +
                     "    {3} )",
      ([Byte]$this.Algorithm).ToString(),
      $this.HIT,
      $this.PublicKey,
      ($this.RendezvousServers -join "`n"))
  }
  
  return $ResourceRecord
}

function ReadDnsNINFORecord {
  # .SYNOPSIS
  #   Reads properties for an NINFO record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Present for legacy support; the NINFO record is marked as obsolete in favour of MX.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    ZS-DATA                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.NINFO
  # .LINK
  #   http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
  #   http://tools.ietf.org/html/draft-reid-dnsext-zs-01
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.NINFO")

  # Property: RendezvousServers - A container for individual servers
  $ResourceRecord | Add-Member ZSData -MemberType NoteProperty -Value @()
  
  # RecordData handling - a counter to decrement
  $RecordDataLength = $ResourceRecord.RecordDataLength
  if ($RecordDataLength -gt 0) {
    do {
      $BinaryReader.SetMarker()

      $ResourceRecord.ZSData += (ReadDnsCharacterString $BinaryReader)
    
      $RecordDataLength = $RecordDataLength - $BinaryReader.BytesFromMarker
    } until ($RecordDataLength -eq 0)
  }
    
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    "$($this.ZSData)"
  }
  
  return $ResourceRecord
}

function ReadDnsRKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an RKEY record from a byte stream.
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
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.RKEY
  # .LINK
  #   http://tools.ietf.org/html/draft-reid-dnsext-rkey-00
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.RKEY")

  # Property: Flags
  $ResourceRecord | Add-Member Flags -MemberType NoteProperty -Value ($BinaryReader.ReadBEUInt16())
  # Property: Protocol
  $ResourceRecord | Add-Member Protocol -MemberType NoteProperty -Value ([Indented.Dns.KEYProtocol]$BinaryReader.ReadByte())
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  
  # Property: PublicKey
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - $BinaryReader.BytesFromMarker)
  $Base64String = ConvertTo-String $Bytes -Base64
  $ResourceRecord | Add-Member PublicKey -MemberType NoteProperty -Value $Base64String

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

function ReadDnsSPFRecord {
  # .SYNOPSIS
  #   Reads properties for an SPF record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   SPF-DATA                    /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.SPF
  # .LINK
  #   http://www.ietf.org/rfc/rfc4408.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SPF")
 
  # Property: SPF
  $ResourceRecord | Add-Member SPF -MemberType NoteProperty -Value (ReadDnsCharacterString $BinaryReader)

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    $this.SPF
  }
  
  return $ResourceRecord
}

function ReadDnsTKEYRecord {
  # .SYNOPSIS
  #   Reads properties for an TKEY record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   ALGORITHM                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   INCEPTION                   |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   EXPIRATION                  |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     MODE                      |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ERROR                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEYSIZE                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    KEYDATA                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   OTHERSIZE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   OTHERDATA                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.TKEY
  # .LINK
  #   http://www.ietf.org/rfc/rfc2930.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.TKEY")
  
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: Inception
  $ResourceRecord | Add-Member Inception -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: Expiration
  $ResourceRecord | Add-Member Expiration -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt32()))
  # Property: Mode
  $ResourceRecord | Add-Member Expiration -MemberType NoteProperty -Value ([Indented.Dns.TKEYMode]$BinaryReader.ReadBEUInt16())
  # Property: Error
  $ResourceRecord | Add-Member Expiration -MemberType NoteProperty -Value ([Indented.Dns.RCode]$BinaryReader.ReadBEUInt16())
  # Property: KeySize
  $ResourceRecord | Add-Member KeySize -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: KeyData
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.KeySize)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  
  if ($ResourceRecord.OtherSize -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.OtherSize)
    $HexString = ConvertTo-String $Bytes -Hexadecimal
  }

  # Property: OtherData
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3} {4}",
      $this.Algorithm,
      $this.Inception,
      $this.Expiration,
      $this.Mode,
      $this.KeyData)
  }
  
  return $ResourceRecord
}

function ReadDnsTSIGRecord {
  # .SYNOPSIS
  #   Reads properties for an TSIG record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   ALGORITHM                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   TIMESIGNED                  |
  #    |                                               |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     FUDGE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    MACSIZE                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                      MAC                      /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                  ORIGINALID                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     ERROR                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   OTHERSIZE                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   OTHERDATA                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.TSIG
  # .LINK
  #   http://www.ietf.org/rfc/rfc2845.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.TSIG")
  
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value (ConvertToDnsDomainName $BinaryReader)
  # Property: TimeSigned
  $ResourceRecord | Add-Member TimeSigned -MemberType NoteProperty -Value ((Get-Date "01/01/1970").AddSeconds($BinaryReader.ReadBEUInt48()))
  # Property: Fudge
  $ResourceRecord | Add-Member Fudge -MemberType NoteProperty -Value ((New-TimeSpan -Seconds ($BinaryReader.ReadBEUInt16())).TotalMinutes)
  # Property: MACSize
  $ResourceRecord | Add-Member KeySize -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: MAC
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.KeySize)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  # Property: Error
  $ResourceRecord | Add-Member Expiration -MemberType NoteProperty -Value ([Indented.Dns.RCode]$BinaryReader.ReadBEUInt16())
  # Property: OtherSize
  $ResourceRecord | Add-Member OtherSize -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()

  if ($ResourceRecord.OtherSize -gt 0) {
    $Bytes = $BinaryReader.ReadBytes($ResourceRecord.OtherSize)
    $HexString = ConvertTo-String $Bytes -Hexadecimal
  }

  # Property: OtherData
  $ResourceRecord | Add-Member KeyData -MemberType NoteProperty -Value $HexString
  
  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3} {4}",
      $this.Algorithm,
      $this.TimeSigned,
      $this.Fudge,
      $this.MAC,
      $this.OtherData)
  }
  
  return $ResourceRecord
}

 function ReadDnsTARecord {
  # .SYNOPSIS
  #   Reads properties for an DS record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEYTAG                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |      DIGESTTYPE       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    DIGEST                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.TA
  # .LINK
  #   http://tools.ietf.org/html/draft-lewis-dns-undocumented-types-01
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.TA")
  
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: DigestType
  $ResourceRecord | Add-Member DigestType -MemberType NoteProperty -Value ([Indented.Dns.DigestType]$BinaryReader.ReadByte())
  # Property: Digest
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member Digest -MemberType NoteProperty -Value $HexString

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.KeyTag.ToString(),
      ([Byte]$this.Algorithm).ToString(),
      ([Byte]$this.DigestType).ToString(),
      $this.Digest)
  }
  
  return $ResourceRecord
}

 function ReadDnsDLVRecord {
  # .SYNOPSIS
  #   Reads properties for an DLV record from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    KEYTAG                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |       ALGORITHM       |      DIGESTTYPE       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    DIGEST                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.DLV
  # .LINK
  #   http://www.ietf.org/rfc/rfc4431.txt
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.DLV")
  
  # Property: KeyTag
  $ResourceRecord | Add-Member KeyTag -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt16()
  # Property: Algorithm
  $ResourceRecord | Add-Member Algorithm -MemberType NoteProperty -Value ([Indented.Dns.EncryptionAlgorithm]$BinaryReader.ReadByte())
  # Property: DigestType
  $ResourceRecord | Add-Member DigestType -MemberType NoteProperty -Value ([Indented.Dns.DigestType]$BinaryReader.ReadByte())
  # Property: Digest
  $Bytes = $BinaryReader.ReadBytes($ResourceRecord.RecordDataLength - 4)
  $HexString = ConvertTo-String $Bytes -Hexadecimal
  $ResourceRecord | Add-Member Digest -MemberType NoteProperty -Value $HexString

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} {2} {3}",
      $this.KeyTag.ToString(),
      ([Byte]$this.Algorithm).ToString(),
      ([Byte]$this.DigestType).ToString(),
      $this.Digest)
  }
  
  return $ResourceRecord
}

function ReadDnsWINSRecord {
  # .SYNOPSIS
  #   Reads properties for an WINS record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.WINS
  # .LINK
  #   http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.WINS")

  # Property: MappingFlag
  $ResourceRecord | Add-Member MappingFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]$BinaryReader.ReadBEUInt32())
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: NumberOfServers
  $ResourceRecord | Add-Member NumberOfServers -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
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
  
  return $ResourceRecord
}

function ReadDnsWINSRRecord {
  # .SYNOPSIS
  #   Reads properties for an WINSR record from a byte stream.
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
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .PARAMETER ResourceRecord
  #   An Indented.Dns.Message.ResourceRecord object created by ReadDnsResourceRecord.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)  
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.WINSR
  # .LINK
  #   http://msdn.microsoft.com/en-us/library/ms682748%28VS.85%29.aspx
  
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader,
    
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Dns.Message.ResourceRecord' } )]
    $ResourceRecord
  )

  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.WINSR")

  # Property: LocalFlag
  $ResourceRecord | Add-Member LocalFlag -MemberType NoteProperty -Value ([Indented.Dns.WINSMappingFlag]$BinaryReader.ReadBEUInt32())
  # Property: LookupTimeout
  $ResourceRecord | Add-Member LookupTimeout -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: CacheTimeout
  $ResourceRecord | Add-Member CacheTimeout -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: NumberOfDomains
  $ResourceRecord | Add-Member NumberOfDomains -MemberType NoteProperty -Value $BinaryReader.ReadBEUInt32()
  # Property: DomainNameList
  $ResourceRecord | Add-Member DomainNameList -MemberType NoteProperty -Value @()
  
  for ($i = 0; $i -lt $ResourceRecord.NumberOfDomains; $i++) {
    $ResourceRecord.DomainNameList += ConvertToDnsDomainName $BinaryReader
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
  
  return $ResourceRecord
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFvBv96ctmesrNy6XWvmNCJwd
# 1rygggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFHBb
# s5rI1oTAM2h72lN26ynsckOmMA0GCSqGSIb3DQEBAQUABIIBAEUVoLv8n8PIlzJD
# NUSlV8n9ZQZR2Uvq1Do6/n/TQZ8QmDr1hDfZteBjk9kDEGG91BhBLzBh2rTxrpu3
# KWYOpqH6rXyXvxwAh9DUJlMb3MFk4uYtuS+LBFCfXocfgiIPmr8ULVwuhlLxVInA
# rw9XU8TWlp0wWE7RRWTE8jdo7zEpsoLDZQ2qC1MGbyYy6FBjyRly1KHOBllsQqrK
# RAQUeQ5jbiQp3eKkGEHJ3IwuF5tdeEljtzqtEKBj8Z7ZgMjSzSRCbCfkaI4b7M2v
# 7CUgwTbOQ+1FZnAxqHLG6A+JsePMlarAW1CCCVv5S3B3n/8cqneMQmAffgi72U/d
# OGioqcY=
# SIG # End signature block
