function Set-EncodingUtf8NoBom {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$path
    )

    process {
        $MyFile = Get-Content $path
        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
        [System.IO.File]::WriteAllLines($path, $MyFile, $Utf8NoBomEncoding)
    }
}
