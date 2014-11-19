function Attach-PSProperty {
    param (
        [PSObject]$InputObject = $(Throw "InputObject is required")
        , [string]$Name = $(Throw "Method Name is Required")
        , [scriptblock]$Get = $(Throw "get script is required")
        , [scriptblock]$Set
        , [switch]$Override
        , [switch]$PassThru
    )

    if ($Set) {
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