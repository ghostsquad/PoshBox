function Guard-ArgumentNotNull {
    param(
        [string]$ArgumentName,
        $ArgumentValue
    )

    if($ArgumentValue -eq $null) {
        throw (New-Object System.ArgumentNullException($ArgumentName)
    }
}