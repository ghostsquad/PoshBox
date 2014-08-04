function ConvertTo-DecimalIP {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$ipAddress
    )

    $ipAddressObj = [Net.IPAddress]::Parse($ipAddress)

    $i = 3; $DecimalIP = 0;
    $ipAddressObj.GetAddressBytes() | %{
        $DecimalIP += $_ * [Math]::Pow(256, $i); $i--
    }

      return [UInt32]$DecimalIP
}
