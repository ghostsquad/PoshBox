function New-PSObject {
    param(
        [System.Collections.Hashtable]$Property
    )

    return (New-Object PSObject -Property $Property)
}