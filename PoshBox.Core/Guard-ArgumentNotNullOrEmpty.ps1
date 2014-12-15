function Guard-ArgumentNotNullOrEmpty {
    param(
        [string]$ArgumentName,
        $ArgumentValue
    )

    Guard-ArgumentNotNull $ArgumentName $ArgumentValue

    if($ArgumentValue -is [System.Collections.IEnumerable]) {
        if (!$ArgumentValue.GetEnumerator().MoveNext()) {
            throw (New-Object System.ArgumentException("Argument was empty", $ArgumentName))
        }
    }

    if($ArgumentValue -is [string] -and [String]::IsNullOrEmpty($ArgumentValue.ToString())) {
        throw (New-Object System.ArgumentException("Argument was empty", $ArgumentName))
    }
}