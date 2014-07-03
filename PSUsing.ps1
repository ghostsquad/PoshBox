# http://support-hq.blogspot.com/2011/07/using-clause-for-powershell.html
function PSUsing {
    param (
        [System.IDisposable] $inputObject = $(throw "The parameter -inputObject is required."),
        [ScriptBlock] $scriptBlock = $(throw "The parameter -scriptBlock is required.")
    )

    Try {
        &$scriptBlock
    } Finally {
        if ($inputObject -ne $null) {
            if ($inputObject.psbase -eq $null) {
                $inputObject.Dispose()
            } else {
                $inputObject.psbase.Dispose()
            }
        }
    }
}

# http://solutionizing.net/2008/09/21/multi-purpose-powershell-using-function/
# maybe also this??