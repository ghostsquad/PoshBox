function Replace-TabsWithSpaces {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$path
    )

    process {
        $path = Resolve-Path $path
        $lines = [Io.File]::ReadAllLines($path) | %{ $_ -replace "`t", '    ' }
        [Io.File]::WriteAllLines($path, $lines)
    }
}
