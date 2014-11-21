function New-PSObject {
    [CmdletBinding()]
    param(
        [System.Collections.Hashtable]$Property
    )

    return (new-object PSObject -Property $Property)
}