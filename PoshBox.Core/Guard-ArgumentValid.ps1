function Guard-ArgumentValid {
    param(
        [string]$ArgumentName = $(throw 'parameter -ArgumentName is required.'),
        [string]$Message = "Argument Failed Validation",
        [bool]$Test
    )

    if(-not $Test) {
        throw new ArgumentException($Message, $ArgumentName)
    }
}