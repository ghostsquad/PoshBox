function Create-DirectoryIfNotExists {
    param (
        [string]$Path
    )

    [Void][System.IO.Directory]::CreateDirectory($Path)
}