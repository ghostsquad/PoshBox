function Assert-ScriptBlockParametersEqual {
    param (
        [ScriptBlock]$x,
        [ScriptBlock]$y
    )

    if($x -eq $null -or $y -eq $null) {
        throw "Null ScriptBlock found."
    }

    $xParams = @(?: {$x.Ast.ParamBlock -ne $null} {$x.Ast.ParamBlock.Parameters} {})
    $yParams = @(?: {$y.Ast.ParamBlock -ne $null} {$y.Ast.ParamBlock.Parameters} {})
    if($xParams.Count -ne $yParams.Count) {
        throw "param count mismatch!"
    }

    for($i = 0; $i -lt $xParams.Count; $i++) {
        if($xParams[$i].StaticType -ne $yParams[$i].StaticType) {
            throw ("param type mismatch. x: {0} y: {1}." -f $yParams[$i].StaticType, $xParams[$i].StaticType)
        }

        if($xParams[$i].Name.ToString() -ne $yParams[$i].Name.ToString()) {
            throw ("param name mismatch. x: {0} y: {1}." -f $yParams[$i].Name, $xParams[$i].Name)
        }
    }
}