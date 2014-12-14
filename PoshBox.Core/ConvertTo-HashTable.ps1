function ConvertTo-HashTable {
    param (
        [parameter(ValueFromPipeline)]
        [PSObject]$inputObject
    )

    process {
        $hashtable = @{}

        foreach($property in $inputObject.psobject.properties) {
            [Void]$hashtable.Add($property.Name, $property.Value)
        }

        return $hashtable
    }
}