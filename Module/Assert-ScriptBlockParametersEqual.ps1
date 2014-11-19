function Assert-ScriptBlockParametersEqual {
    param (
        [ScriptBlock]$x,
        [ScriptBlock]$y
    )

    if($x -eq $null -or $y -eq $null) {
        throw "Null ScriptBlock found."
    }

    $xParams = Get-ScriptBlockParams $x
    $yParams = Get-ScriptBlockParams $y
    if($xParams.Count -ne $yParams.Count) {
        throw "param count mismatch!"
    }

    for($i = 0; $i -lt $xParams.Count; $i++) {
        if($xParams[$i].Value -ne $yParams[$i].Value) {
            throw ("param type mismatch. Found {0} but was expecting {1}." -f $yParams[$i].Value, $xParams[$i].Value)
        }
    }
}