function Attach-PSScriptMethod {
    [cmdletbinding(DefaultParameterSetName = 'buildingblocks')]
    param (
        [Parameter(Position=0,ParameterSetName = 'buildingblocks')]
        [Parameter(Position=0,ParameterSetName = 'PSScriptMethod')]
        [PSObject]$InputObject,

        [Parameter(Position=1,ParameterSetName = 'buildingblocks')]
        [string]$Name,

        [Parameter(Position=2,ParameterSetName = 'buildingblocks')]
        [scriptblock]$ScriptBlock,

        [Parameter(Position=1,ParameterSetName = 'PSScriptMethod')]
        [management.automation.PSScriptMethod]$PSScriptMethod,

        [Parameter(Position=3,ParameterSetName = 'buildingblocks')]
        [Parameter(Position=2,ParameterSetName = 'PSScriptMethod')]
        [switch]$Override,

        [Parameter(Position=4,ParameterSetName = 'buildingblocks')]
        [Parameter(Position=3,ParameterSetName = 'PSScriptMethod')]
        [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject

    if($PSCmdlet.ParameterSetName -eq 'buildingblocks') {
        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'ScriptBlock' $ScriptBlock
        $PSScriptMethod = new-object management.automation.PSScriptMethod $Name,$ScriptBlock
    } else {
        Guard-ArgumentNotNull 'PSScriptMethod' $PSScriptMethod
        $Name = $PSScriptMethod.Name
    }

    if($Override) {
        $existingMethod = $InputObject.psobject.Methods[$Name]
        if($existingMethod -ne $null) {
            Assert-ScriptBlockParametersEqual $PSScriptMethod.Script $existingMethod.Script
            $InputObject.psobject.methods.remove($Name)
        } else {
            throw (new-object System.InvalidOperationException("Could not find a method with name: $Name"))
        }
    }

    if($InputObject.psobject.Methods[$Name] -eq $null) {
        [Void]$InputObject.psobject.methods.add($PSScriptMethod)
    } else {
        throw (new-object System.InvalidOperationException("method with name: $Name already exists. Parameter: -Override required."))
    }
}