function Attach-PSNote {
    param (
        [PSObject]$InputObject = $(Throw "InputObject is required")
        , [string]$Name = $(Throw "Note Name is Required")
        , $Value
        , [switch]$PassThru
    )

    if ($InputObject.psobject.members[$Name] -ne $null) {
        throw (new-object System.InvalidOperationException("note with name: $Name already exists."))
    }

    $member = new-object management.automation.PSNoteProperty $Name,$Value
    [Void]$InputObject.psobject.members.Add($member)

    if($PassThru) {
        return $InputObject
    }
}