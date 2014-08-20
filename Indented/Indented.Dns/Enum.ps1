##############################################################################################################################################################
#                                                                            IANA                                                                            #
##############################################################################################################################################################

#
# Address family
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.IanaAddressFamily" -Type "UInt16" -Members @{
  IPv4                   = 1;        # IP version 4
  IPv6                   = 2;        # IP version 6
  NSAP                   = 3;        # NSAP
  HDLC                   = 4;        # HDLC (8-bit multidrop)
  BBN                    = 5;        # BBN 1822
  "802"                  = 6;        # 802 (includes all 802 media plus Ethernet "canonical format")
  "E.163"                = 7;        # E.163
  "E.164"                = 8;        # E.164 (SMDS, Frame Relay, ATM)		
  "F.69"                 = 9;        # F.69 (Telex)
  "X.121"                = 10;       # X.121 (X.25, Frame Relay)
  IPX                    = 11;       # IPX
  Appletalk              = 12;       # Appletalk
  DecNetIV               = 13;       # DecNet IV
  BanyanVines            = 14;       # Banyan Vines
  "E.164NSAP"            = 15;       # E.164 with NSAP format subaddress         [ATM Forum UNI 3.1. October 1995.][Andy_Malis]
  DNS                    = 16;       # DNS (Domain Name System)
  DistinguishedName      = 17;       # Distinguished Name                        [Charles_Lynn]	
  ASNumber               = 18;       # AS Number                                 [Charles_Lynn]
  XTPOverIpv4            = 19;       # XTP over IP version 4                     [Mike_Saul]
  XTPOverIPv6            = 20;       # XTP over IP version 6                     [Mike_Saul]
  XTPNativeMode          = 21;       # XTP native mode XTP                       [Mike_Saul]
  FibreChannelWWPortName = 22;       # Fibre Channel World-Wide Port Name        [Mark_Bakke]
  FibreChannelWWNodeName = 23;       # Fibre Channel World-Wide Node Name        [Mark_Bakke]
  GWID                   = 24;       # GWID                                      [Subra_Hegde]
  AFIForL2VPN            = 25;       # AFI for L2VPN information                 [RFC4761][RFC6074]
  MPLSTPSectionID        = 26;       # MPLS-TP Section Endpoint Identifier       [RFC-ietf-mpls-gach-adv-08]
  MPLSTPLSPID            = 27;       # MPLS-TP LSP Endpoint Identifier           [RFC-ietf-mpls-gach-adv-08]
  MPLSTPPseudowireID     = 28;       # MPLS-TP Pseudowire Endpoint Identifier    [RFC-ietf-mpls-gach-adv-08]
  EIGRPCommon            = 16384;    # EIGRP Common Service Family               [Donnie_Savage]
  EIGRPIPv4              = 16385;    # EIGRP IPv4 Service Family                 [Donnie_Savage]
  EIGRPIPv6              = 16386;    # EIGRP IPv6 Service Family                 [Donnie_Savage]
  LCAF                   = 16387;    # LISP Canonical Address Format (LCAF)      [David_Meyer]
  BGPLS                  = 16388;    # BGP-LS                                    [draft-ietf-idr-ls-distribution]
  MAC48bit               = 16389;    # 48-bit MAC                                [RFC-eastlake-rfc5342bis-05]
  MAC64bit               = 16390;    # 64-bit MAC                                [RFC-eastlake-rfc5342bis-05]
  OUI                    = 16391;    # OUI                                       [draft-eastlake-trill-ia-appsubtlv]
  MAC24                  = 16392;    # MAC/24                                    [draft-eastlake-trill-ia-appsubtlv]
  MAC40                  = 16393;    # MAC/40                                    [draft-eastlake-trill-ia-appsubtlv]
  "IPv6-64"              = 16394;    # IPv6/64                                   [draft-eastlake-trill-ia-appsubtlv]
  RBridgePortID          = 16395;    # RBridge Port ID                           [draft-eastlake-trill-ia-appsubtlv]
}

#
# Certificate types
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.CertificateType" -Type "UInt16" -Members @{
  PKIX    = 1;      # X.509 as per PKIX
  SPKI    = 2;      # SPKI certificate
  PGP     = 3;      # OpenPGP packet
  IPKIX   = 4;      # The URL of an X.509 data object
  ISPKI   = 5;      # The URL of an SPKI certificate
  IPGP    = 6;      # The fingerprint and URL of an OpenPGP packet
  ACPKIX  = 7;      # Attribute Certificate
  IACPKIX = 8;      # The URL of an Attribute Certificate
  URI     = 253;    # URI private
  OID     = 254;    # OID private
}

#
# Digest types
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.DigestType" -Type "Byte" -Members @{
  SHA1   = 1;    # MANDATORY    [RFC3658]
  SHA256 = 2;    # MANDATORY    [RFC4059]
  GOST   = 3;    # OPTIONAL     [RFC5933]
  SHA384 = 4;    # OPTIONAL     [RFC6605]
}

#
# Encryption algorithm
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.EncryptionAlgorithm" -Type "Byte" -Members @{
  RSAMD5               = 1;       # RSA/MD5 (deprecated, see 5)    [RFC3110][RFC4034]
  DH                   = 2;       # Diffie-Hellman                 [RFC2539]
  DSA                  = 3;       # DSA/SHA1                       [RFC3755]
  RSASHA1              = 5;       # RSA/SHA-1                      [RFC3110][RFC4034]
  "DSA-NSEC3-SHA1"     = 6;       # DSA-NSEC3-SHA1                 [RFC5155]
  "RSASHA1-NSEC3-SHA1" = 7;       # RSASHA1-NSEC3-SHA1             [RFC5155]
  RSASHA256            = 8;       # RSA/SHA-256                    [RFC5702]
  RSASHA512            = 10;      # RSA/SHA-512                    [RFC5702]
  "ECC-GOST"           = 12;      # GOST R 34.10-2001              [RFC5933]
  ECDSAP256SHA256      = 13;      # ECDSA Curve P-256 with SHA-256 [RFC6605]
  ECDSAP384SHA384      = 14;      # ECDSA Curve P-384 with SHA-384 [RFC6605]
  INDIRECT             = 252;     # Reserved for indirect keys     [RFC4034]
  PRIVATEDNS           = 253;     # Private algorithm              [RFC4034]
  PRIVATEOID           = 254;     # Private algorithm OID          [RFC4034]
}

#
# SSH algorithms
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.SSHAlgorithm" -Type "Byte" -Members @{
  RSA = 1;    # [RFC4255]
  DSS = 2;    # [RFC4255]
}

#
# SSH fingerprint type
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.SSHFPType" -Type "Byte" -Members @{
  SHA1 = 1;    # [RFC4255]
}


##############################################################################################################################################################
#                                                                    RESOLVER PARAMETERS                                                                     #
##############################################################################################################################################################

#
# Flags - Offset to allow direct parsing of a 16-bit unsigned value
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.Flags" -Type "UInt16" -SetFlagsAttribute -Members @{
  None = 0;
  AA   = 1024;    # Authoritative Answer  [RFC1035]
  TC   = 512;     # Truncated Response    [RFC1035]
  RD   = 256;     # Recursion Desired     [RFC1035]
  RA   = 128;     # Recursion Allowed     [RFC1035]
  AD   = 32;      # Authenticated Data    [RFC4035]
  CD   = 16;      # Checking Disabled     [RFC4035]
}

#
# Message compression flag
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.MessageCompression" -Type "Byte" -Members @{
  Enabled  = 192;
  Disabled = 0;
}

#
# MS XFR compression
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.MSDNSOption" -Type "UInt32" -Members @{
  CompressXFR = 19795
}

#
# OpCode
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.OpCode" -Type "UInt16" -Members @{
  Query  = 0;    # [RFC1035]
  IQuery = 1;    # [RFC3425]
  Status = 2;    # [RFC1035]
  Notify = 4;    # [RFC1996]
  Update = 5;    # [RFC2136]
}

#
# Query flag
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.QR" -Type "UInt16" -Members @{
  Query    = 0;
  Response = 32768
}

#
# RecordClass
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.RecordClass" -Type "UInt16" -Members @{
  IN   = 1;      # [RFC1035]
  CH   = 3;      # [Moon1981]
  HS   = 4;      # [Dyer1987]
  NONE = 254;    # [RFC2136] 
  ANY  = 255;    # [RFC1035]
}

#
# RecordType
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.RecordType" -Type "UInt16" -Members @{
  EMPTY      = 0;        # an empty record                             [RFC1034] [MS DNS]
  A          = 1;        # a host address                              [RFC1035]
  NS         = 2;        # an authoritative name server                [RFC1035]
  MD         = 3;        # a mail destination (Obsolete - use MX)      [RFC1035]
  MF         = 4;        # a mail forwarder (Obsolete - use MX)        [RFC1035]
  CNAME      = 5;        # the canonical name for an alias             [RFC1035]
  SOA        = 6;        # marks the start of a zone of authority      [RFC1035]
  MB         = 7;        # a mailbox domain name (EXPERIMENTAL)        [RFC1035]
  MG         = 8;        # a mail group member (EXPERIMENTAL)          [RFC1035]
  MR         = 9;        # a mail rename domain name (EXPERIMENTAL)    [RFC1035]
  NULL       = 10;       # a null RR (EXPERIMENTAL)                    [RFC1035]
  WKS        = 11;       # a well known service description            [RFC1035]
  PTR        = 12;       # a domain name pointer                       [RFC1035]
  HINFO      = 13;       # host information                            [RFC1035]
  MINFO      = 14;       # mailbox or mail list information            [RFC1035]
  MX         = 15;       # mail exchange                               [RFC1035]
  TXT        = 16;       # text strings                                [RFC1035]
  RP         = 17;       # for Responsible Person                      [RFC1183]
  AFSDB      = 18;       # for AFS Data Base location                  [RFC1183]
  X25        = 19;       # for X.25 PSDN address                       [RFC1183]
  ISDN       = 20;       # for ISDN address                            [RFC1183]
  RT         = 21;       # for Route Through                           [RFC1183]
  NSAP       = 22;       # for NSAP address; NSAP style A record       [RFC1706]
  NSAPPTR    = 23;       # for domain name pointer; NSAP style         [RFC1348] 
  SIG        = 24;       # for security signature                      [RFC4034][RFC3755][RFC2535]
  KEY        = 25;       # for security key                            [RFC4034][RFC3755][RFC2535]
  PX         = 26;       # X.400 mail mapping information              [RFC2163]
  GPOS       = 27;       # Geographical Position                       [RFC1712]
  AAAA       = 28;       # IP6 Address                                 [RFC3596]
  LOC        = 29;       # Location Information                        [RFC1876]
  NXT        = 30;       # Next Domain - OBSOLETE                      [RFC3755][RFC2535]
  EID        = 31;       # Endpoint Identifier                         [Patton]
  NIMLOC     = 32;       # Nimrod Locator                              [Patton]
  SRV        = 33;       # Server Selection                            [RFC2782]
  ATMA       = 34;       # ATM Address                                 [ATMDOC]
  NAPTR      = 35;       # Naming Authority Pointer                    [RFC2915][RFC2168]
  KX         = 36;       # Key Exchanger                               [RFC2230]
  CERT       = 37;       # CERT                                        [RFC4398]
  A6         = 38;       # A6 (Experimental)                           [RFC3226][RFC2874]
  DNAME      = 39;       # DNAME                                       [RFC2672]
  SINK       = 40;       # SINK                                        [Eastlake]
  OPT        = 41;       # OPT                                         [RFC2671]
  APL        = 42;       # APL                                         [RFC3123]
  DS         = 43;       # Delegation Signer                           [RFC4034][RFC3658]
  SSHFP      = 44;       # SSH Key Fingerprint                         [RFC4255]
  IPSECKEY   = 45;       # IPSECKEY                                    [RFC4025]
  RRSIG      = 46;       # RRSIG                                       [RFC4034][RFC3755]
  NSEC       = 47;       # NSEC                                        [RFC4034][RFC3755]
  DNSKEY     = 48;       # DNSKEY                                      [RFC4034][RFC3755]
  DHCID      = 49;       # DHCID                                       [RFC4701]
  NSEC3      = 50;       # NSEC3                                       [RFC5155]
  NSEC3PARAM = 51;       # NSEC3PARAM                                  [RFC5155]
  HIP        = 55;       # Host Identity Protocol                      [RFC5205]
  NINFO      = 56;       # NINFO                                       [Reid]
  RKEY       = 57;       # RKEY                                        [Reid]
  SPF        = 99;       #                                             [RFC4408]
  UINFO      = 100;      #                                             [IANA-Reserved]
  UID        = 101;      #                                             [IANA-Reserved]
  GID        = 102;      #                                             [IANA-Reserved]
  UNSPEC     = 103;      #                                             [IANA-Reserved]
  TKEY       = 249;      # Transaction Key                             [RFC2930]
  TSIG       = 250;      # Transaction Signature                       [RFC2845]
  IXFR       = 251;      # incremental transfer                        [RFC1995]
  AXFR       = 252;      # transfer of an entire zone                  [RFC1035]
  MAILB      = 253;      # mailbox-related RRs (MB; MG or MR)          [RFC1035]
  MAILA      = 254;      # mail agent RRs (Obsolete - see MX)          [RFC1035]
  ANY        = 255;      # A request for all records (*)               [RFC1035]
  TA         = 32768;    # DNSSEC Trust Authorities                    [Weiler] 2005-12-13
  DLV        = 32769;    # DNSSEC Lookaside Validation                 [RFC4431]
  WINS       = 65281;    # WINS records (WINS Lookup record)           [MS DNS]
  WINSR      = 65282;    # WINSR records (WINS Reverse Lookup record)  [MS DNS]
}

#
# RCode
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.RCode" -Type "UInt16" -Members @{
  NoError  = 0;     # No Error                                    [RFC1035]
  FormErr  = 1;     # Format Error                                [RFC1035]
  ServFail = 2;     # Server Failure                              [RFC1035]
  NXDomain = 3;     # Non-Existent Domain                         [RFC1035]
  NotImp   = 4;     # Not Implemented                             [RFC1035]
  Refused  = 5;     # Query Refused                               [RFC1035]
  YXDomain = 6;     # Name Exists when it should not              [RFC2136]
  YXRRSet  = 7;     # RR Set Exists when it should not            [RFC2136]
  NXRRSet  = 8;     # RR Set that should exist does not           [RFC2136]
  NotAuth  = 9;     # Server Not Authoritative for zone           [RFC2136]
  NotZone  = 10;    # Name not contained in zone                  [RFC2136]
  BadVers  = 16;    # Bad OPT Version                             [RFC2671]
  BadSig   = 16;    # TSIG Signature Failure                      [RFC2845]
  BadKey   = 17;    # Key not recognized                          [RFC2845]
  BadTime  = 18;    # Signature out of time window                [RFC2845]
  BadMode  = 19;    # Bad TKEY Mode                               [RFC2930]
  BadName  = 20;    # Duplicate key name                          [RFC2930]
  BadAlg   = 21;    # Algorithm not supported                     [RFC2930]
  BadTrunc = 22;    # Bad Truncation                              [RFC4635]
}

##############################################################################################################################################################
#                                                             RESOLVER RECORD SPECIFIC PARAMETERS                                                            #
##############################################################################################################################################################

#
# AFSDB
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.AFSDBSubType" -Type "UInt16" -Members @{
  AFSv3Loc   = 1;    # Andrews File Service v3.0 Location Service  [RFC1183]
  DCENCARoot = 2;    # DCE/NCA root cell directory node            [RFC1183]
}

#
# ATMA: Format
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.ATMAFormat" -Type "UInt16" -Members @{
  AESA = 0;    # ATM End System Address
  E164 = 1;    # E.164 address format
  NSAP = 2;    # Network Service Access Protocol (NSAP) address model 
}

#
# IPSEC
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.IPSECGatewayType" -Type "Byte" -Members @{
  NoGateway  = 0;    # No gateway is present                    [RFC4025]
  IPv4       = 1;    # A 4-byte IPv4 address is present         [RFC4025]
  IPv6       = 2;    # A 16-byte IPv6 address is present        [RFC4025]
  DomainName = 3;    # A wire-encoded domain name is present    [RFC4025]
}

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.IPSECAlgorithm" -Type "Byte" -Members @{
  DSA = 1;    # [RFC4025]
  RSA = 2;    # [RFC4025]
}

#
# KEY: Flags
#

# Bits 1 and 2
New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.KEYAC" -Type "Byte" -Members @{
  AuthAndConfPermitted = 0;    # Use of the key for authentication and/or confidentiality is permitted. 
  AuthProhibited       = 2;    # Use of the key is prohibited for authentication.
  ConfProhibited       = 1;    # Use of the key is prohibited for confidentiality.
  NoKey                = 3;    # No key information
}

# Bits 6 and 7
New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.KEYNameType" -Type "Byte" -Members @{
  UserKey  = 0;    # Indicates that this is a key associated with a "user" or "account" at an end entity, usually a host.
  ZoneKey  = 1;    # Indicates that this is a zone key for the zone whose name is the KEY RR owner name.
  NonZone  = 2;    # Indicates that this is a key associated with the non-zone "entity" whose name is the RR owner name.
  Reserved = 3;    # Reserved
}

#
# KEY: Protocol
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.KEYProtocol" -Type "Byte" -Members @{
  Reserved = 0;
  TLS      = 1;
  EMmail   = 2;
  DNSSEC   = 3;
  IPSEC    = 4;
  All      = 255;
}

#
# OPT: EDNS option codes
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.EDnsOptionCode" -Type "UInt16" -Members @{
  LLQ                  = 1;    # On-hold      [http://files.dns-sd.org/draft-sekar-dns-llq.txt]
  UL                   = 2;    # On-hold      [http://files.dns-sd.org/draft-sekar-dns-ul.txt]
  NSID                 = 3;    # Standard     [RFC5001]
  DAU                  = 5;    # Standard     [RFC6975]
  DHU                  = 6;    # Standard     [RFC6975]
  N3U                  = 7;    # Standard     [RFC6975]
  "EDNS-client-subnet" = 8;    # Optional     [draft-vandergaast-edns-client-subnet][Wilmer_van_der_Gaast]
}

#
# OPT: DNSSEC Validation flag
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.EDnsDNSSECOK" -Type "UInt16" -SetFlagsAttribute -Members @{
  NONE = 0;
  DO   = 32768;    # DNSSEC answer OK    [RFC4035][RFC3225]
}

#
# OPT: LLQ
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.LLQOpCode" -Type "UInt16" -Members @{
  LLQSetup   = 1;
  LLQRefresh = 2;
  LLQEvent   = 3;
}

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.LLQErrorCode" -Type "UInt16" -Members @{
  NoError    = 0;
  ServFull   = 1;
  Static     = 2;
  FormatErr  = 3;
  NoSuchLLQ  = 4;
  BadVers    = 5;
  UnknownErr = 6;
}

#
# NSEC3 (NextSECure3): Parameters 
#

# DNSSEC NSEC3 Flags
New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.NSEC3Flags" -Type "Byte" -Members @{
  OptOut = 1;    # [RFC5155]
}

# DNSSEC NSEC3 Hash Algorithms
New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.NSEC3HashAlgorithm" -Type "Byte" -Members @{
  SHA1 = 1;    # [RFC5155]
}

#
# TKEY: Mode
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.TKEYMode" -Type "UInt16" -Members @{
  ServerAssignment   = 1;    # Server assignment          [RFC2930]
  DH                 = 2;    # Diffie-Hellman Exchange    [RFC2930]
  GSSAPI             = 3;    # GSS-API negotiation        [RFC2930]
  ResolverAssignment = 4;    # Resolver assignment        [RFC2930]
  KeyDeletion        = 5;    # Key deletion               [RFC2930]
}

#
# WINS
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.WINSMappingFlag" -Type "UInt32" -Members @{
  Replication   = 0;
  NoReplication = 65536;
}

##############################################################################################################################################################
#                                                                        WMI - GENERIC                                                                       #
##############################################################################################################################################################

#
# Registry
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.RegistryHive" -Type "UInt32" -Members @{
  HKCR = 2147483628;    # HKEY_CLASSES_ROOT
  HKCU = 2147483649;    # HKEY_CURRENT_USER
  HKLM = 2147483650;    # HKEY_LOCAL_MACHINE
  HKU  = 2147483651;    # HKEY_USERS
  HKCC = 2147483653;    # HKEY_CURRENT_CONFIG
}

##############################################################################################################################################################
#                                                                      WMI - DNS RECORD                                                                      #
##############################################################################################################################################################

#
# RecordType
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.WmiRecordType" -Type "UInt16" -Members @{
  MicrosoftDNS_AType     = 1;        # Represents an Address (A) RR
  MicrosoftDNS_NSType	   = 2;        # Represents a Name Server (NS) RR
  MicrosoftDNS_MDType	   = 3;        # Represents a Mail Agent for Domain (MD) RR
  MicrosoftDNS_MFType	   = 4;        # Represents a Mail Forwarding Agent for Domain (MF) RR
  MicrosoftDNS_CNAMEType = 5;        # Represents a Canonical Name (CNAME) RR
  MicrosoftDNS_SOAType   = 6;        # Represents a Start Of Authority (SOA) RR
  MicrosoftDNS_MBType	   = 7;        # Represents a Mailbox (MB) RR
  MicrosoftDNS_MGType    = 8;        # Represents an MG RR
  MicrosoftDNS_MRType    = 9;        # Represents a Mailbox Rename (MR) RR
  MicrosoftDNS_WKSType   = 11;       # Represents a Well-Known Service (WKS) RR
  MicrosoftDNS_PTRType   = 12;       # Represents a Pointer (PTR) RR
  MicrosoftDNS_HINFOType = 13;       # Represents a Host Information (HINFO) RR
  MicrosoftDNS_MINFOType = 14;       # Represents an Mail Information (MINFO) RR
  MicrosoftDNS_MXType    = 15;       # Represents a Mail Exchanger (MX) RR
  MicrosoftDNS_TXTType   = 16;       # Represents a Text (TXT) RR
  MicrosoftDNS_RPType    = 17;       # Represents a Responsible Person (RP) RR
  MicrosoftDNS_AFSDBType = 18;       # Represents an Andrew File System Database Server (AFSDB) RR
  MicrosoftDNS_X25Type   = 19;       # Represents an X.25 (X25) RR
  MicrosoftDNS_ISDNType  = 20;       # Represents an ISDN RR
  MicrosoftDNS_RTType    = 21;       # Represents a Route Through (RT) RR
  MicrosoftDNS_SIGType   = 24;       # Represents a Signature (SIG) RR
  MicrosoftDNS_KEYType   = 25;       # Represents a KEY RR
  MicrosoftDNS_AAAAType  = 28;       # Represents an IPv6 Address (AAAA); often pronounced quad-A RR
  MicrosoftDNS_NXTType   = 30;       # Represents a Next (NXT) RR
  MicrosoftDNS_SRVType   = 33;       # Represents a Service (SRV) RR
  MicrosoftDNS_ATMAType  = 34;       # Represents an ATM Address-to-Name (ATMA) RR.
  MicrosoftDNS_WINSType  = 65281;    # Represents a WINS RR
  MicrosoftDNS_WINSRType = 65282;    # Represents a WINS-Reverse (WINSR) RR
}

##############################################################################################################################################################
#                                                                       WMI - DNS ZONE                                                                       #
##############################################################################################################################################################

#
# ZoneType - Used by WMI MicrosoftDNS_Zone and AD dnsProperty
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.ZoneType" -Type "UInt32" -Members @{
  Hint      = 0;
  Master    = 1;
  Slave     = 2;
  Stub      = 3;
  Forwarder = 4;
}

#
# Dynamic update flag
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.DynamicUpdate" -Type "UInt32" -Members @{
  None       = 0;
  All        = 1;
  SecureOnly = 2;
}

#
# Zone transfer flag
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.ZoneTransfer" -Type "UInt32" -Members @{
  Any  = 0;
  NS   = 1;
  List = 2;
  None = 3;
}

#
# Notify flag
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.Notify" -Type "UInt32" -Members @{
  None = 0;
  NS   = 1;
  List = 2;
}

##############################################################################################################################################################
#                                                                      WMI - DNS SERVER                                                                      #
##############################################################################################################################################################

#
# Auto-configure zones
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.AutoConfigZones" -Type "UInt32" -Members @{
  None                     = 0;    # None
  AllowDynamicUpdateOnly   = 1;    # Only servers that allow dynamic updates
  AllowNoDynamicUpdateOnly = 2;    # Only servers that do not allow dynamic updates
  All                      = 4;    # All Servers
}

#
# Auto-creation / auto-update flag
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.ServerDynamicUpdate" -Type "UInt32" -SetFlagsAttribute -Members @{
  NoRestriction  = 0;    # No Restrictions
  NoSOAUpdate    = 1;    # Does not allow dynamic updates of SOA records
  NoRootNSUpdate = 2;    # Does not allow dynamic updates of NS records at the zone root
  NoNSUpdate     = 4;    # Does not allow dynamic updates of NS records not at the zone root (delegation NS records)
}

#
# Boot method
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.BootMethod" -Type "UInt32" -Members @{
  Unitialised              = 0;    # Uninitialized
  FromFile                 = 1;    # Boot from file
  FromRegistry             = 2;    # Boot from registry
  FromDirectoryAndRegistry = 3;    # Boot from directory and registry
}

#
# DNSSEC
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.DnsSecMode" -Type "UInt32" -Members @{
  None = 0;   # No DNSSEC records are included in the response unless the query requested a resource record set of the DNSSEC record type.
  All  = 1;   # DNSSEC records are included in the response according to RFC 2535.
  Opt  = 2;   # DNSSEC records are included in a response only if the original client query contained the OPT resource record according to RFC 2671
}

#
# Logging
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.EventLogLevel" -Type "UInt32" -Members @{
  None              = 0;    # None
  Errors            = 1;    # Log only errors
  ErrorsAndWarnings = 2;    # Log only warnings and errors.
  All               = 4;    # Log all events.
}

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.LogLevel" -Type "UInt32" -SetFlagsAttribute -Members @{
  None         = 0;
  Query        = 1;
  Notify       = 16;
  Update       = 32;
  NonQuery     = 254;
  Questions    = 256;
  Answers      = 512;
  Send         = 4096;
  Receive      = 8192;
  Udp          = 16384;
  Tcp          = 32768;
  AllPackets   = 65535;
  DSWrite      = 65536;
  DSUpdate     = 131072;
  FullPackets  = 16777216;
  WriteThrough = 2147483648;
}

#
# Name validity checking
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.NameCheckFlag" -Type "UInt32" -Members @{
  StrictRFCANSI = 0;
  NonRFCANSI    = 1;
  MultibyteUTF8 = 2;
  AllNames      = 3;
}

#
# RPC mode
#

New-Enum -ModuleBuilder $IndentedDnsMB  -Name "Indented.Dns.RpcProtocol" -Type "UInt32" -SetFlagsAttribute -Members @{
  None       = 0;
  Tcp        = 1;
  NamedPipes = 2;
  Lpc        = 4;
}

##############################################################################################################################################################
#                                                                             AD                                                                             #
##############################################################################################################################################################

#
# DCPromo flag
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.DcPromoFlag" -Type "UInt32" -Members @{
  None          = 0;    # No change to existing zone storage.
  ConvertDomain = 1;    # Zone is to be stored in DNS domain partition. See DNS_ZONE_CREATE_FOR_DCPROMO (section 2.2.5.2.7.1).
  ConvertForest = 2;    # Zone is to be stored in DNS forest partition. See DNS_ZONE_CREATE_FOR_DCPROMO_FOREST (section 2.2.5.2.7.1).
}

#
# Rank
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.Rank" -Type "Byte" -Members @{
  None              = 0;      # Tombstoned record
  CacheBit          = 1;      # The record came from the cache.
  RootHint          = 8;      # The record is a preconfigured root hint.
  OutsideGlue       = 32;     # This value is not used.
  CacheNAAdditional = 49;     # The record was cached from the additional section of a nonauthoritative response.
  CacheNAAuthority  = 65;     # The record was cached from the authority section of a nonauthoritative response.
  CacheAAdditional  = 81;     # The record was cached from the additional section of an authoritative response.
  CacheNAAnswer     = 97;     # The record was cached from the answer section of a nonauthoritative response.
  CacheAAuthority   = 113;    # The record was cached from the authority section of an authoritative response.
  Glue              = 128;    # The record is a glue record in an authoritative zone.
  NSGlue            = 130;    # The record is a delegation (type NS) record in an authoritative zone.
  CacheAAnswer      = 193;    # The record was cached from the answer section of an authoritative response.
  ZoneRecord        = 240;    # The record comes from an authoritative zone.
}

#
# Zone property fields
#

New-Enum -ModuleBuilder $IndentedDnsMB -Name "Indented.Dns.ZonePropertyID" -Type "UInt32" -Members @{
  Type                = 1;      # The zone type. See dwZoneType (section 2.2.5.2.4.1).
  AllowUpdate         = 2;      # Whether dynamic updates are allowed. See fAllowUpdate (section 2.2.5.2.4.1).
  Securetime          = 8;      # The time; in seconds and expressed as an unsigned 64-bit integer; at which the zone became secure.
  NoRefreshInterval   = 16;     # The zone no refresh interval. See dwNoRefreshInterval (section 2.2.5.2.4.1).
  ScavengingServers   = 17;     # Servers that will perform scavenging. See aipScavengingServers (section 2.2.5.2.4.1).
  AgingEnabledTime    = 18;     # The time interval before the next scavenging cycle. See dwAvailForScavengeTime (section 2.2.5.2.4.1).
  RefreshInterval     = 32;     # The zone refresh interval. See dwRefreshInterval (section 2.2.5.2.4.1).
  AgingState          = 64;     # Whether aging is enabled. See fAging (section 2.2.5.2.4.1).
  DeletedFromHostname = 128;    # The name of the server that deleted the zone. The value is a null-terminated Unicode string.
  MasterServers       = 129;    # Servers to perform zone transfers. See aipMasters (section 2.2.5.2.4.1).
  AutoNSServers       = 130;    # A list of servers which MAY autocreate a delegation. The list is formatted as DNS_ADDR_ARRAY (section 2.2.3.2.3).
  DCPromoConvert      = 131;    # The flag value representing the state of conversion of the zone. See DcPromo Flag (section 2.3.1.1.2).
  ScavengingServersDA = 144;    # Servers that will perform scavenging. Same format as DSPROPERTY_ZONE_SCAVENGING_SERVERS.
  MasterServersDA     = 145;    # Servers to perform zone transfers. Same format as DSPROPERTY_ZONE_MASTER_SERVERS.
  AutoNSServersDA     = 146;    # A list of servers which MAY autocreate a delegation. Same format as DSPROPERTY_ZONE_AUTO_NS_SERVERS.
  NodeDBFlags         = 256;    # See DNS_RPC_NODE_FLAGS (section 2.2.2.1.2).
}

# SIG # Begin signature block
# MIIPkQYJKoZIhvcNAQcCoIIPgjCCD34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUftYUYjs+6irShDxz18uN7kJq
# 7tCgggzGMIIGTjCCBTagAwIBAgICDfcwDQYJKoZIhvcNAQELBQAwgYwxCzAJBgNV
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPKY
# NOg/lprPZAc9tgIFcSrzeujOMA0GCSqGSIb3DQEBAQUABIIBAJ8+H5Q2oYbLJ3PB
# DR/Svxxky8Ny+wE9DVzfGmOY3gAdPYasfLoK3T0GKi9nOHxlIgvyTUoOD0yBuh5f
# sd2L+rF8pZaGs+KN93+118anGbLyLeF3pNeYZRmulgRbZbL2bcZTTfosNpEsdmFy
# zhJ0+E41s8qFTEqrwfiMJznj9QGgCHIobl6o7zdXxtNgBqpjpnq7FWbBBhf+yZbK
# SA3/XCXgsjqYaDATgGSZCD7ThXqqve5BknK124DBzUFbKSYqu6frDPeGtqQMmAOR
# FTGgPCvgRy3eLb7TyQJhIRGmC7qzTJ0OC7y9L9XmJmPMBGCHq1SIu4LfBEsGD8Xy
# hlREBNA=
# SIG # End signature block
