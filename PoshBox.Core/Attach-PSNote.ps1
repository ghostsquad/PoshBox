function Attach-PSNote {
    param (
        [PSObject]$InputObject
        , [string]$Name
        , $Value
        , [switch]$PassThru
    )

    Guard-ArgumentNotNull 'InputObject' $InputObject
    Guard-ArgumentNotNull 'Name' $Name

    if ($InputObject.psobject.members[$Name] -ne $null) {
        throw (new-object System.InvalidOperationException("note with name: $Name already exists."))
    }

    $member = new-object management.automation.PSNoteProperty $Name,$Value
    [Void]$InputObject.psobject.members.Add($member)

    if($PassThru) {
        return $InputObject
    }
}