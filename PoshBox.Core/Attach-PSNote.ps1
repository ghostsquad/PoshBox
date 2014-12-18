function Attach-PSNote {
    [cmdletbinding(DefaultParameterSetName='buildingblocks')]
    param (
        [Parameter(Position=0,ParameterSetName='buildingblocks')]
        [Parameter(ParameterSetName='PSNoteProperty')]
        [PSObject]$InputObject,

        [Parameter(Position=1,ParameterSetName='buildingblocks')]
        [string]$Name,

        [Parameter(Position=2,ParameterSetName='buildingblocks')]
        [object]$Value,

        [Parameter(Position=1,ParameterSetName='PSNoteProperty')]
        [management.automation.PSNoteProperty]$PSNoteProperty,

        [Parameter(Position=3,ParameterSetName='buildingblocks')]
        [Parameter(Position=2,ParameterSetName='PSNoteProperty')]
        [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject

    if($PSCmdlet.ParameterSetName -eq 'buildingblocks') {
        Guard-ArgumentNotNull 'Name' $Name
        $PSNoteProperty = new-object management.automation.PSNoteProperty $Name,$Value
    } else {
        Guard-ArgumentNotNull 'PSNoteProperty' $PSNoteProperty
        $Name = $PSNoteProperty.Name
    }

    if ($InputObject.psobject.members[$Name] -ne $null) {
        throw (new-object System.InvalidOperationException("note with name: $Name already exists."))
    }

    [Void]$InputObject.psobject.members.Add($PSNoteProperty)

    if($PassThru) {
        return $InputObject
    }
}