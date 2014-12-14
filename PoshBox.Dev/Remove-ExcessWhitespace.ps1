function Remove-ExcessWhitespace {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$path
    )

    process {
        $path = Resolve-Path $path
        $lines = [Io.File]::ReadAllLines($path) | % { $_.TrimEnd() }
        [Io.File]::WriteAllLines($path, $lines)
    }
}
