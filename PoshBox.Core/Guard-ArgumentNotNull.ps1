function Guard-ArgumentNotNull {
    param(
        [string]$ArgumentName,
        [object]$ArgumentValue
    )

    if($ArgumentValue -eq $null) {
        throw (New-Object System.ArgumentNullException($ArgumentName))
    }
}