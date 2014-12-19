# http://support-hq.blogspot.com/2011/07/using-clause-for-powershell.html
function Invoke-Using {
    param (
        $InputObject = $(throw "The parameter -inputObject is required."),
        [ScriptBlock]$ScriptBlock = $(throw "The parameter -scriptBlock is required.")
    )

    Try {
        $ScriptBlock.InvokeReturnAsIs()
    } Finally {
        if ($InputObject -ne $null) {
            if($InputObject -is [IDisposable] `
                -or ($InputObject -is [psobject] `
                    -and $InputObject.psobject.Methods['dispose'] -ne $null)) {

                $InputObject.Dispose()
            }
        }
    }
}
