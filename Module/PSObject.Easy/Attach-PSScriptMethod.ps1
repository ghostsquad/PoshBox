function Attach-PSScriptMethod {
    param (
        [PSObject]$InputObject = $(Throw "InputObject is required")
        , [string]$Name = $(Throw "Method Name is Required")
        , [scriptblock]$ScriptBlock
        , [switch]$Override
        , [switch]$PassThru
    )

    $member = new-object management.automation.PSScriptMethod $Name,$ScriptBlock

    if($Override) {
        $existingMethod = $InputObject.psobject.Methods[$Name]
        if($existingMethod -ne $null) {
            $newMethodParams = Get-ScriptBlockParams $ScriptBlock
            $existingMethodParams = Get-ScriptBlockParams $existingMethod.Script
            if($newMethodParams.Count -ne $existingMethodParams.Count) {
                throw "param count mismatch!"
            }

            for($i = 0; $i -lt $existingMethodParams.Count; $i++) {
                if($existingMethodParams[$i].Value -ne $newMethodParams[$i].Value) {
                    throw ("param type mismatch. Found {0} but was expecting {1}." -f $newMethodParams[$i].Value, $existingMethodParams[$i].Value)
                }
            }

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