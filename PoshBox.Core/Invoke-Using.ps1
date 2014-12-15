# http://support-hq.blogspot.com/2011/07/using-clause-for-powershell.html
function Invoke-Using {
    param (
        [System.IDisposable]$InputObject = $(throw "The parameter -inputObject is required."),
        [ScriptBlock]$ScriptBlock = $(throw "The parameter -scriptBlock is required.")
    )

    Try {
        $ScriptBlock.InvokeReturnAsIs()
    } Finally {
        if ($InputObject -ne $null) {
            if ($InputObject.psbase -eq $null) {
                $InputObject.Dispose()
            } else {
                $InputObject.psbase.Dispose()
            }
        }
    }
}
