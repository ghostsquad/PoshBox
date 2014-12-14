function Guard-FileExists {
    param(
        [string]$ArgumentName = $(throw 'parameter -ArgumentName is required.'),,
        [string]$FileName
    )

    Guard-ArgumentNotNullOrEmpty $ArgumentName $FileName
    Guard-ArgumentValid $ArgumentName ('File not found: {0}' -f $FileName) { [System.IO.File]::Exists($FileName) }
}