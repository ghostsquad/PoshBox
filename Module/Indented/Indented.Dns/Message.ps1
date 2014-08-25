<#
  Module file content:

  CmdLet Name                 Category                  Access modifier       Updated
  -----------                 --------                  ---------------       -------
  ConvertToDnsDomainName      DNS resolver              Private               07/10/2013
  ConvertFromDnsDomainname    DNS resolver              Private               18/12/2013
  ReadDnsCharacterString      DNS resolver              Private               07/10/2013
  NewDnsMessageHeader         DNS resolver              Private               18/12/2013
  NewDnsMessageQuestion       DNS resolver              Private               18/12/2013
  NewDnsOPTRecord             DNS resolver              Private               20/12/2013
  NewDnsSOARecord             DNS resolver              Private               18/12/2013
  NewDnsMessage               DNS resolver              Private               20/12/2013
  ReadDnsMessageHeader        DNS resolver              Private               19/12/2013
  ReadDnsMessageQuestion      DNS resolver              Private               18/12/2013
  ReadDnsMessage              DNS resolver              Private               20/12/2013
  NewDnsUpdateMessage         DNS resolver              Private               10/01/2014
#>

function ConvertToDnsDomainName {
  # .SYNOPSIS
  #   Converts a DNS domain name from a byte stream to a string. This CmdLet also expands compressed names.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   DNS messages implement compression to avoid bloat by repeated use of labels.
  #
  #   If a label occurs elsewhere in the message a flag is set and an offset recorded as follows:
  #
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    | 1  1|                OFFSET                   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   System.String
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )

  $Name = New-Object Text.StringBuilder
  [UInt64]$CompressionStart = 0
  
  # Read until we find the null terminator
  while ($BinaryReader.PeekByte() -ne 0) {
    # The length or compression reference
    $Length = $BinaryReader.ReadByte()
    
    if (($Length -band [Indented.Dns.MessageCompression]::Enabled) -eq [Indented.Dns.MessageCompression]::Enabled) {
      # Record the current position as the start of the compression operation.
      # Reader will be returned here after this operation is complete.
      if ($CompressionStart -eq 0) {
        $CompressionStart = $BinaryReader.BaseStream.Position
      }
      # Remove the compression flag bits to calculate the offset value (relative to the start of the message)
      [UInt16]$Offset = ([UInt16]($Length -bxor [Indented.Dns.MessageCompression]::Enabled) -shl 8) -bor $BinaryReader.ReadByte()
      # Move to the offset
      $BinaryReader.BaseStream.Seek($Offset, 0) | Out-Null
    } else {
      # Read a label
      $Name.Append($BinaryReader.ReadChars($Length)) | Out-Null
      $Name.Append('.') | Out-Null
    }
  }
  # If expansion was used, return to the starting point (plus 1 byte)
  if ($CompressionStart -gt 0) {
    $BinaryReader.BaseStream.Seek($CompressionStart, 0) | Out-Null
  }
  # Read off and discard the null termination on the end of the name
  $BinaryReader.ReadByte() | Out-Null
  
  $NameString = $Name.ToString()
  if (-not $NameString.EndsWith('.')) {
    $NameString = "$NameString."
  }
    
  return $NameString
}

function ConvertFromDnsDomainName {
  # .SYNOPSIS
  #   Converts a DNS domain name from a string to a byte array.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   RFC 1034:
  #
  #   "Internally, programs that manipulate domain names should represent them
  #    as sequences of labels, where each label is a length octet followed by
  #    an octet string.  Because all domain names end at the root, which has a
  #    null string for a label, these internal representations can use a length
  #    byte of zero to terminate a domain name."
  #
  #   RFC 1035:
  #
  #   "<domain-name> is a domain name represented as a series of labels, and
  #    terminated by a label with zero length.  <character-string> is a single
  #    length octet followed by that number of characters.  <character-string>
  #    is treated as binary information, and can be up to 256 characters in
  #    length (including the length octet)."
  #
  # .PARAMETER Name
  #   The name to convert to a byte array.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Byte[]
  # .LINK
  #   http://www.ietf.org/rfc/rfc1034.txt
  #   http://www.ietf.org/rfc/rfc1035.txt

  [CmdLetBinding()]
  param(
    [String]$Name
  )

  # Drop any trailing . characters from the name. They are no longer necessary all names must be absolute by this point.
  $Name = $Name.TrimEnd('.')

  $Bytes = @()
  if ($Name) {
    $Bytes += $Name -split '\.' | ForEach-Object {
      $_.Length
      "$_" | ConvertTo-Byte
    }
  }
  # Add a zero length root label
  $Bytes += [Byte]0

  return [Byte[]]$Bytes
}

function ReadDnsCharacterString {
  # .SYNOPSIS
  #   Reads a character-string from a DNS message.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS resource record.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   System.String
  # .LINK
  #   http://www.ietf.org/rfc/rfc1035.txt

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )
  
  $Length = $BinaryReader.ReadByte()
  $CharacterString = New-Object String (,$BinaryReader.ReadChars($Length))
  
  return $CharacterString
}

function NewDnsMessageHeader {
  # .SYNOPSIS
  #   Creates a new DNS message header.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      ID                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    QDCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ANCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    NSCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ARCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .OUTPUTS
  #   Indented.Dns.Message.Header

  [CmdLetBinding()]
  param( )

  $DnsMessageHeader = New-Object PsObject -Property ([Ordered]@{
    ID      = [UInt16](Get-Random -Maximum ([Int32]([UInt16]::MaxValue)));
    QR      = [Indented.Dns.QR]::Query;
    OpCode  = [Indented.Dns.OpCode]0;
    Flags   = [Indented.Dns.Flags]::RD;
    RCode   = [Indented.Dns.RCode]0;
    QDCount = [UInt16]1;
    ANCount = [UInt16]0;
    NSCount = [UInt16]0;
    ARCount = [UInt16]0;
  })
  $DnsMessageHeader.PsObject.TypeNames.Add("Indented.Dns.Message.Header")

  # Method: ToByte
  $DnsMessageHeader | Add-Member ToByte -MemberType ScriptMethod -Value {
    $Bytes = @()

    $Bytes += ConvertTo-Byte $this.ID -BigEndian

    # The UInt16 value which comprises QR, OpCode, Flags (including Z) and RCode.
    $Flags = [UInt16]([UInt16]$this.QR + [UInt16]$this.OpCode + [UInt16]$this.Flags + [UInt16]$this.RCode)
    $Bytes += ConvertTo-Byte $Flags -BigEndian

    $Bytes += ConvertTo-Byte $this.QDCount -BigEndian
    $Bytes += ConvertTo-Byte $this.ANCount -BigEndian
    $Bytes += ConvertTo-Byte $this.NSCount -BigEndian
    $Bytes += ConvertTo-Byte $this.ARCount -BigEndian

    return [Byte[]]$Bytes
  }

  # Method: ToString
  $DnsMessageHeader | Add-Member ToString -MemberType ScriptMethod -Force -Value {
    return [String]::Format("ID: {0} QR: {1} OpCode: {2} RCode: {3} Flags: {4} Query: {5} Answer: {6} Authority: {7} Additional: {8}",
      $this.ID.ToString(),
      $this.QR.ToString().ToUpper(),
      $this.OpCode.ToString().ToUpper(),
      $this.RCode.ToString().ToUpper(),
      $this.Flags,
      $this.QDCount,
      $this.ANCount,
      $this.NSCount,
      $this.ARCount)
  }

  return $DnsMessageHeader
}

function NewDnsMessageQuestion {
  # .SYNOPSIS
  #   Creates a new DNS message question.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     QNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     QTYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     QCLASS                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER Name
  #   A name value as a domain-name.
  # .PARAMETER RecordClass
  #   The record class, IN by default.
  # .PARAMETER RecordType
  #   The record type for the question. ANY by default.
  # .INPUTS
  #   System.String
  #   Indented.Dns.RecordClass
  #   Indented.Dns.RecordType
  # .OUTPUTS
  #   Indented.Dns.Message.Question

  [CmdLetBinding()]
  param(
    [String]$Name,

    [Indented.Dns.RecordClass]$RecordClass = [Indented.Dns.RecordClass]::IN,

    [Indented.Dns.RecordType]$RecordType = [Indented.Dns.RecordType]::ANY
  )

  $DnsMessageQuestion = New-Object PsObject -Property ([Ordered]@{
    Name        = $Name;
    RecordClass = $RecordClass;
    RecordType  = $RecordType;
  })
  $DnsMessageQuestion.PsObject.TypeNames.Add("Indented.Dns.Message.Question")

  # Method: ToByte
  $DnsMessageQuestion | Add-Member ToByte -MemberType ScriptMethod -Value {
    $Bytes = @()

    $Bytes += ConvertFromDnsDomainName $this.Name
    $Bytes += ConvertTo-Byte ([UInt16]$this.RecordType) -BigEndian
    $Bytes += ConvertTo-Byte ([UInt16]$this.RecordClass) -BigEndian

    return [Byte[]]$Bytes
  }

  # Method: ToString
  $DnsMessageQuestion | Add-Member ToString -MemberType ScriptMethod -Force -Value {
    return [String]::Format("{0}            {1} {2}",
      $this.Name.PadRight(29, ' '),
      $this.RecordClass.ToString().PadRight(5, ' '),
      $this.RecordType.ToString().PadRight(5, ' ')
    )
  }

  return $DnsMessageQuestion
}

function NewDnsOPTRecord {
  # .SYNOPSIS
  #   Creates a new OPT record instance for advertising DNSSEC support.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Modified / simplified OPT record structure for advertising DNSSEC support. 
  #  
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+
  #    |         NAME          |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      TYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |              MAXIMUM PAYLOAD SIZE             |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |    EXTENDED-RCODE     |        VERSION        |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                       Z                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   RDLENGTH                    |  
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .OUTPUTS
  #   Indented.Dns.Message.ResourceRecord.OPT
  # .LINK
  #   http://www.ietf.org/rfc/rfc2671.txt

  [CmdLetBinding()]
  param( )
  
  $ResourceRecord = New-Object PsObject -Property ([Ordered]@{
    Name               = ".";
    RecordType         = [Indented.Dns.RecordType]::OPT;
    MaximumPayloadSize = [UInt16]4096;
    ExtendedRCode      = 0;
    Version            = 0;
    Z                  = [Indented.Dns.EDnsDNSSECOK]::DO;
    RecordDataLength   = 0;
  })
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord")
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.OPT")

  # Method: ToByte
  $ResourceRecord | Add-Member ToByte -MemberType ScriptMethod -Value {
    $Bytes = New-Object Byte[] 11
    
    # Property: RecordType
    $Bytes[2] = 0x29
    # Property: MaximumPayloadSize
    $MaximumPayloadSizeBytes = $this.MaximumPayloadSize | ConvertTo-Byte -BigEndian
    [Array]::Copy($MaximumPayloadSizeBytes, 0, $Bytes, 3, 2)
    # Property: Z - DO bit
    $Bytes[7] = 0x80
    
    return [Byte[]]$Bytes
  }
  
  return $ResourceRecord
}

function NewDnsSOARecord {
  # .SYNOPSIS
  #   Creates a new SOA record instance for use with IXFR queries.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Modified / simplified SOA record structure for executing IXFR transfers. 
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      NAME                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      TYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     CLASS                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      TTL                      |
  #    |                                               |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                   RDLENGTH                    |  
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     MNAME                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     RNAME                     |
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
  # .PARAMETER Name
  #   Name is passed into this CmdLet as an optional aesthetic value. It serves no real purpose. 
  #
  #   All Name values (Name, NameServer and ResponsiblePerson) are referenced using a message compression flag with the offset set to 12, the name used in the Question.
  # .PARAMETER Serial
  #   A serial number to pass with the IXFR request.
  # .INPUTS
  #   System.String
  #   System.UInt32
  # .OUTPUTS
  #   System.Byte[]

  param(
    [String]$Name = ".",

    [Parameter(Mandatory = $true)]
    [UInt32]$SerialNumber
  )

  $ResourceRecord = New-Object PsObject -Property ([Ordered]@{
    Name              = $Name;
    TTL               = 0;
    RecordClass       = [Indented.Dns.RecordClass]::IN;
    RecordType        = [Indented.Dns.RecordType]::SOA;
    RecordDataLength  = 24;
    NameServer        = $Name;
    ResponsiblePerson = $Name;
    Serial            = $SerialNumber;
    Refresh           = 0;
    Retry             = 0;
    Expire            = 0;
    MinimumTTL        = 0;
  })
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord")
  $ResourceRecord.PsObject.TypeNames.Add("Indented.Dns.Message.ResourceRecord.SOA")

  # Property: RecordData
  $ResourceRecord | Add-Member RecordData -MemberType ScriptProperty -Force -Value {
    [String]::Format("{0} {1} (`n" +
                     "    {2} ; serial`n" +
                     "    {3} ; refresh`n" +
                     "    {4} ; retry`n" +
                     "    {5} ; expire`n" +
                     "    {6} ; minimum ttl`n" +
                     ")",
      $this.NameServer,
      $this.ResponsiblePerson,
      $this.Serial.ToString().PadRight(10, ' '),
      $this.Refresh.ToString().PadRight(10, ' '),
      $this.Retry.ToString().PadRight(10, ' '),
      $this.Expire.ToString().PadRight(10, ' '),
      $this.MinimumTTL.ToString().PadRight(10, ' ')
    )
  }

  # Method: ToByte
  $ResourceRecord | Add-Member ToByte -MemberType ScriptMethod -Value {
    $Bytes = New-Object Byte[] 36
    
    # Property: Name
    $Bytes[0] = 0xC0; $Bytes[1] = 0x0C
    # Property: RecordType
    $Bytes[3] = 0x06;
    # Property: RecordClass
    $Bytes[5] = 0x01;
    # Property: RecordDataLength
    $Bytes[11] = 0x18;
    # Property: NameServer
    $Bytes[12] = 0xC0; $Bytes[13] = 0x0C
    # Property: ResponsiblePerson
    $Bytes[14] = 0xC0; $Bytes[15] = 0x0C
    # Property: SerialNumber
    $SerialBytes = $this.Serial | ConvertTo-Byte -BigEndian
    [Array]::Copy($SerialBytes, 0, $Bytes, 16, 4)

    return [Byte[]]$Bytes
  }

  return $ResourceRecord
}

function NewDnsMessage {
  # .SYNOPSIS
  #   Reads a DNS message from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   Authority is added when attempting an incremental zone transfer.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                    HEADER                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                   QUESTION                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                                               /
  #    /                   AUTHORITY                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

  param(
    [String]$Name = "",

    [Indented.Dns.RecordType]$RecordType = [Indented.Dns.RecordType]::ANY,

    [Indented.Dns.RecordClass]$RecordClass = [Indented.Dns.RecordClass]::IN,

    [UInt32]$SerialNumber
  )

  $DnsMessage = New-Object PsObject -Property ([Ordered]@{
    Header             = NewDnsMessageHeader;
    Question           = (NewDnsMessageQuestion -Name $Name -RecordType $RecordType -RecordClass $RecordClass);
    Answer             = @();
    Authority          = @();
    Additional         = @();
    Server             = "";
    Size               = 0;
    TimeTaken          = 0;
  })
  $DnsMessage.PsObject.TypeNames.Add("Indented.Dns.Message")
  
  if ($SerialNumber -and $RecordType -eq [Indented.Dns.RecordType]::IXFR) {
    $DnsMessage.Header.NSCount = [UInt16]1
    $DnsMessage.Authority = NewDnsSOARecord -Name $Name -SerialNumber $SerialNumber
  }

  # Property: QuestionToString
  $DnsMessage | Add-Member QuestionToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Question)
  }
  # Property: AnswerToString
  $DnsMessage | Add-Member AnswerToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Answer)
  }
  # Property: AuthorityToString
  $DnsMessage | Add-Member AuthorityToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Authority)
  }
  # Property: AdditionalToString
  $DnsMessage | Add-Member AdditionalToString -MemberType ScriptProperty -Value {
    return [String]::Join("`n", $this.Additional)
  }
  
  # Method: SetEDnsBufferSize
  $DnsMessage | Add-Member SetEDnsBufferSize -MemberType ScriptMethod -Value {
    param(
      [UInt16]$EDnsBufferSize = 4096
    )
    
    $this.Header.ARCount = [UInt16]1
    $this.Additional += NewDnsOPTRecord
    $this.Additional[0].MaximumPayloadSize = $EDnsBufferSize
  }
  # Method: SetAcceptDnsSec
  $DnsMessage | Add-Member SetAcceptDnsSec -MemberType ScriptMethod -Value {
    $this.Header.Flags = [Indented.Dns.Flags]([UInt16]$this.Header.Flags -bxor [UInt16][Indented.Dns.Flags]::AD)
  }
  
  # Method: ToByte
  $DnsMessage | Add-Member ToByte -MemberType ScriptMethod -Value {
    param(
      [Net.Sockets.ProtocolType]$ProtocolType = [Net.Sockets.ProtocolType]::Udp
    )
  
    $Bytes = [Byte[]]@()

    $Bytes += $this.Header.ToByte()
    $Bytes += $this.Question.ToByte()

    if ($this.Header.NSCount -gt 0) {
      $Bytes += $this.Authority | ForEach-Object {
         $_.ToByte()
      }
    }
    if ($this.Header.ARCount -gt 0) {
      $Bytes += $this.Additional | ForEach-Object {
        $_.ToByte()
      }
    }
    
    if ($ProtocolType -eq [Net.Sockets.ProtocolType]::Tcp) {
      # A value must be added to denote payload length when using a stream-based protocol.
      $LengthBytes = [BitConverter]::GetBytes([UInt16]$Bytes.Length)
      [Array]::Reverse($LengthBytes)
      $Bytes = $LengthBytes + $Bytes
    }
   
    return [Byte[]]$Bytes
  }

  return $DnsMessage
}

function ReadDnsMessageHeader {
  # .SYNOPSIS
  #   Reads a DNS message header from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                      ID                       |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    QDCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ANCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    NSCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                    ARCOUNT                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS message.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.Header

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [IO.BinaryReader]$BinaryReader
  )

  $DnsMessageHeader = NewDnsMessageHeader

  # Property: ID
  $DnsMessageHeader.ID = $BinaryReader.ReadBEUInt16()

  $Flags = $BinaryReader.ReadBEUInt16()

  # Property: QR
  $DnsMessageHeader.QR = [Indented.Dns.QR]($Flags -band 0x8000)
  # Property: OpCode
  $DnsMessageHeader.OpCode = [Indented.Dns.OpCode]($Flags -band 0x7800)
  # Property: Flags
  $DnsMessageHeader.Flags = [Indented.Dns.Flags]($Flags -band 0x07F0)
  # Property: RCode
  $DnsMessageHeader.RCode = [Indented.Dns.RCode]($Flags -band 0x000F)
  # Property: QDCount
  $DnsMessageHeader.QDCount = $BinaryReader.ReadBEUInt16()
  # Property: ANCount
  $DnsMessageHeader.ANCount = $BinaryReader.ReadBEUInt16()
  # Property: NSCount
  $DnsMessageHeader.NSCount = $BinaryReader.ReadBEUInt16()
  # Property: ARCount
  $DnsMessageHeader.ARCount = $BinaryReader.ReadBEUInt16()

  return $DnsMessageHeader
}

function ReadDnsMessageQuestion {
  # .SYNOPSIS
  #   Reads a DNS question from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                     QNAME                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     QTYPE                     |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    |                     QCLASS                    |
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER Name
  #   A name value 
  # .PARAMETER BinaryReader
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS message.
  #
  #   If a binary reader is not passed as an argument an empty DNS question is returned.
  # .INPUTS
  #   System.IO.BinaryReader
  #
  #   The BinaryReader object must be created using New-BinaryReader (Indented.Common)
  # .OUTPUTS
  #   Indented.Dns.Message.Question

  [CmdLetBinding(DefaultParameterSetName = 'NewQuestion')]
  param(
    [Parameter(Position = 1, ParameterSetName = 'NewQuestion')]
    [String]$Name = ".",

    [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'ReadQuestion')]
    [IO.BinaryReader]$BinaryReader
  )

  $DnsMessageQuestion = NewDnsMessageQuestion

  # Property: Name
  $DnsMessageQuestion.Name = ConvertToDnsDomainName $BinaryReader
  # Property: RecordType
  $DnsMessageQuestion.RecordType = [Indented.Dns.RecordType]$BinaryReader.ReadBEUInt16()
  # Property: RecordClass
  if ($DnsMessageQuestion.RecordType -eq [Indented.Dns.RecordType]::OPT) {
    $DnsMessageQuestion.RecordClass = $BinaryReader.ReadBEUInt16()
  } else {
    $DnsMessageQuestion.RecordClass = [Indented.Dns.RecordClass]$BinaryReader.ReadBEUInt16()
  }

  return $DnsMessageQuestion
}

function ReadDnsMessage {
  # .SYNOPSIS
  #   Reads a DNS message from a byte stream.
  # .DESCRIPTION
  #   Internal use only.
  #
  #                                    1  1  1  1  1  1
  #      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    HEADER                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   QUESTION                    /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                    ANSWER                     /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                   AUTHORITY                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #    /                  ADDITIONAL                   /
  #    /                                               /
  #    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  #
  # .PARAMETER Message
  #   A binary reader created by using New-BinaryReader (Indented.Common) containing a byte array representing a DNS message.
  #
  #   If a binary reader is not passed as an argument an empty DNS message is returned.
  # .INPUTS
  #   Indented.Common.SocketResponse
  #
  #   Response data is generated using Receive-Bytes.
  # .OUTPUTS
  #   Indented.Dns.Message  

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.Common.SocketResponse' } )]
    $Message
  )

  $BinaryReader = New-BinaryReader -ByteArray $Message.Data

  $DnsMessage = NewDnsMessage
  $DnsMessage.Question = @()
  $DnsMessage.Size = $Message.Data.Length
  $DnsMessage.Server = $Message.RemoteEndPoint.Address

  $DnsMessage.Header = ReadDnsMessageHeader $BinaryReader

  for ($i = 0; $i -lt $DnsMessage.Header.QDCount; $i++) {
    $DnsMessage.Question += ReadDnsMessageQuestion $BinaryReader
  }
  for ($i = 0; $i -lt $DnsMessage.Header.ANCount; $i++) {
    $DnsMessage.Answer += ReadDnsResourceRecord $BinaryReader
  }
  for ($i = 0; $i -lt $DnsMessage.Header.NSCount; $i++) {
    $DnsMessage.Authority += ReadDnsResourceRecord $BinaryReader
  }
  for ($i = 0; $i -lt $DnsMessage.Header.ARCount; $i++) {
    $DnsMessage.Additional += ReadDnsResourceRecord $BinaryReader
  }

  return $DnsMessage
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEt02RRCtvyiYvPUQCM5m1uUn
# A9mgggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFK+1
# fdDQbBgnhr89N1bCgdMmb1ZEMA0GCSqGSIb3DQEBAQUABIIBAItlryDiDz/xyFkQ
# YFAZ1Sb1yGWYZxJRYe4FheBExUeo7oRXgTJdxYTXeMFradghR+We8V8FPE0V0F3p
# QyqXBAum/+vjKC+CzQ8zWsOhg056wA0gpQ686VU/Eus5qsUx+AdVZsnMp0U/Mvw6
# K8e7vja5zLFDm9U9Tqd1QvVp0gGekC7gYcr5GSHkD3KnkXJ7DpLQ/l5XYZyOW1cc
# 7tsJvslyLtMDJcXphC9hpG58vrPjbm2jnZnsHFGF71tPEbrMEphQ6rzdy3zx2YRU
# 41KqEIZZGl8hGPHACrNRhks9mAH/MSrzKYOgQJLhkvo57Wjko1kmSftwdWnXu4TP
# PZ/DkTw=
# SIG # End signature block
