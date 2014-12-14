function Guard-ArgumentNotNullOrEmpty {
    param(
        [string]$ArgumentName,
        $ArgumentValue
    )

    Guard-ArgumentNotNull $ArgumentName $ArgumentValue

    if($ArgumentValue -is [IEnumerable]) {
        if (!argValue.GetEnumerator().MoveNext()) {
            throw new ArgumentException("Argument was empty", $ArgumentName)
        }
    }

    if([String]::IsNullOrEmpty($ArgumentValue.ToString()) {
        throw new ArgumentException("Argument was empty", $ArgumentName)
    }
}