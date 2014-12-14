function Assert-ScriptBlockParametersEqual {
    param (
        [ScriptBlock]$x,
        [ScriptBlock]$y,
        [Switch]$AssertNamesMatch
    )

    if($x -eq $null -or $y -eq $null) {
        throw (New-Object ParametersNotEquivalentException('X or Y is Null'))
    }

    $xParams = @(?: {$x.Ast.ParamBlock -ne $null} {$x.Ast.ParamBlock.Parameters} {})
    $yParams = @(?: {$y.Ast.ParamBlock -ne $null} {$y.Ast.ParamBlock.Parameters} {})
    if($xParams.Count -ne $yParams.Count) {
        throw (New-Object ParametersNotEquivalentException(('Param count mismatch. x: {0} y: {1}' -f $xParams.Count, $yParams.Count)))
    }

    for($i = 0; $i -lt $xParams.Count; $i++) {
        if($xParams[$i].StaticType -ne $yParams[$i].StaticType) {
            throw (New-Object ParametersNotEquivalentException(('Param type mismatch. x: {0} y: {1}' -f $xParams[$i].StaticType, $yParams[$i].StaticType)))
        }

        if($AssertNamesMatch) {
            if($xParams[$i].Name.ToString() -ne $yParams[$i].Name.ToString()) {
                throw (New-Object ParametersNotEquivalentException(('Param name mismatch. x: {0} y: {1}' -f $xParams[$i].Name, $yParams[$i].Name)))
            }
        }
    }
}

if (-not ([System.Management.Automation.PSTypeName]'ParametersNotEquivalentException').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
    using System;
    using System.Management.Automation;

    public class ParametersNotEquivalentException : Exception {
        public ParametersNotEquivalentException(string message)
            : base(message)
        {
        }

        public ParametersNotEquivalentException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
"@
}