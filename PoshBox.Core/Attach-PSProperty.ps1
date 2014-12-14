function Attach-PSProperty {
    param (
        [PSObject]$InputObject
        , [string]$Name
        , [scriptblock]$Get
        , [scriptblock]$Set
        , [switch]$Override
        , [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject
    Guard-ArgumentNotNull 'Name' $Name
    Guard-ArgumentNotNull 'Get' $Get

    if ($Set -ne $null) {
        $scriptProperty = new-object management.automation.PsScriptProperty $Name,$Get,$Set
    } else {
        $scriptProperty = new-object management.automation.PsScriptProperty $Name,$Get
    }

    if($Override) {
        $existingProperty = $InputObject.psobject.properties[$Name]
        if($existingProperty -ne $null) {
            if($existingProperty.SetterScript -eq $null -xor $Set -eq $null) {
                throw (new-object System.InvalidOperationException("Setter behavior does not match existing property"))
            }

            $InputObject.psobject.properties.Remove($Name)
        } else {
            throw (new-object System.InvalidOperationException("Could not find a property with name: $Name"))
        }
    }

    if ($InputObject.psobject.properties[$Name] -ne $null) {
        throw (new-object System.InvalidOperationException("property with name: $Name already exists. Parameter: -Override required."))
    }

    [Void]$InputObject.psobject.properties.add($scriptProperty)

    if($PassThru) {
        return $InputObject
    }
}