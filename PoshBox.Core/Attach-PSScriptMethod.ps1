function Attach-PSScriptMethod {
    param (
        [PSObject]$InputObject
        , [string]$Name
        , [scriptblock]$ScriptBlock
        , [switch]$Override
        , [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject
    Guard-ArgumentNotNull 'Name' $Name
    Guard-ArgumentNotNull 'ScriptBlock' $ScriptBlock

    $member = new-object management.automation.PSScriptMethod $Name,$ScriptBlock

    if($Override) {
        $existingMethod = $InputObject.psobject.Methods[$Name]
        if($existingMethod -ne $null) {
            Assert-ScriptBlockParametersEqual $ScriptBlock $existingMethod.Script
            $InputObject.psobject.methods.remove($Name)
        } else {
            throw (new-object System.InvalidOperationException("Could not find a method with name: $Name"))
        }
    }

    if($InputObject.psobject.Methods[$Name] -eq $null) {
        [Void]$InputObject.psobject.methods.add($member)
    } else {
        throw (new-object System.InvalidOperationException("method with name: $Name already exists. Parameter: -Override required."))
    }
}