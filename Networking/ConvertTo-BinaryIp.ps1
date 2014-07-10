function ConvertTo-BinaryIP {
    [cmdletbinding()]
    param (
        [Parameter(Mandator=$true,ValueFromPipeline=$true)]
        [String]$ipAddress
    )

      $ipAddressObj = [Net.IPAddress]::Parse($ipAddress)

    $addressBytes = $ipAddressObj.GetAddressBytes() | %{[Convert]::ToString($_, 2).PadLeft(8, '0')}

      return [String]::Join('.', $addressBytes)
}
