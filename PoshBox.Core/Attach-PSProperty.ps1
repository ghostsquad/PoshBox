function Attach-PSProperty {
    [cmdletbinding(DefaultParameterSetName = 'buildingblocks')]
    param (
        [Parameter(Position=0,ParameterSetName='buildingblocks')]
        [Parameter(Position=0,ParameterSetName='PsScriptProperty')]
        [PSObject]$InputObject,

        [Parameter(Position=1,ParameterSetName='buildingblocks')]
        [string]$Name,

        [Parameter(Position=2,ParameterSetName='buildingblocks')]
        [scriptblock]$Get,

        [Parameter(Position=3,ParameterSetName='buildingblocks')]
        [scriptblock]$Set,

        [Parameter(Position=1,ParameterSetName='PsScriptProperty')]
        [management.automation.PsScriptProperty]$PsScriptProperty,

        [Parameter(Position=4,ParameterSetName='buildingblocks')]
        [Parameter(Position=2,ParameterSetName='PsScriptProperty')]
        [switch]$Override,

        [Parameter(Position=5,ParameterSetName='buildingblocks')]
        [Parameter(Position=3,ParameterSetName='PsScriptProperty')]
        [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject

    if($PSCmdlet.ParameterSetName -eq 'buildingblocks') {
        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'Get' $Get
        $PsScriptProperty = new-object management.automation.PsScriptProperty $Name,$Get,$Set
    } else {
        Guard-ArgumentNotNull 'PsScriptProperty' $PsScriptProperty
        $Name = $PsScriptProperty.Name
    }

    if($Override) {
        $existingProperty = $InputObject.psobject.properties[$Name]
        if($existingProperty -ne $null) {
            if($existingProperty.SetterScript -eq $null -xor $PsScriptProperty.SetterScript -eq $null) {
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

    [Void]$InputObject.psobject.properties.add($PsScriptProperty)

    if($PassThru) {
        return $InputObject
    }
}