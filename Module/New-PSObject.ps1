function New-PSObject {
    [CmdletBinding()]
    param(
        [System.Collections.Hashtable]$Property
    )

    Write-Output (new-object PSObject -Property $Property)
}