function ConvertTo-DottedDecimalIP {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$ipAddress
    )

    Switch -RegEx ($IP) {
        "([01]{8}\.){3}[01]{8}" {

            return [String]::Join('.', $( $ipAddress.Split('.') | %{
                [Convert]::ToInt32($_, 2) } ))
            }

        "\d" {
            $ipAddress = [UInt32]$ipAddress
            $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
            $Remainder = $IP % [Math]::Pow(256, $i)
            ($IP - $Remainder) / [Math]::Pow(256, $i)
            $IP = $Remainder
            } )

            return [String]::Join('.', $DottedIP)
        }

        default {
            Write-Error "Cannot convert this format"
        }
    }
}
