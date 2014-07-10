function Fix-SourceFiles {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
        [System.Io.FileInfo]$fileInfo
    )
    process {
        Write-Verbose "fixing up $($fileinfo.Fullname)"
        Write-Verbose "Removing BOM"
        Set-EncodingUtf8NoBom $fileInfo.Fullname
        Write-Verbose "Replacing Tabs"
        Replace-TabsWithSpaces $fileInfo.Fullname
        Write-Verbose "Removing excess whitespace"
        Remove-ExcessWhitespace $fileInfo.Fullname
    }
}
