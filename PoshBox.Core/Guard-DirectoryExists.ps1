function Guard-DirectoryExists {
    param(
        [string]$ArgumentName = $(throw 'parameter -ArgumentName is required.'),
        [string]$DirectoryName
    )

    Guard-ArgumentNotNullOrEmpty $ArgumentName $DirectoryName
    Guard-ArgumentValid $ArgumentName ('Directory not found: {0}' -f $DirectoryName) ([System.IO.Directory]::Exists($DirectoryName))
}