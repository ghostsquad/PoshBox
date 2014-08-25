function ConvertTo-Hash {
    param (
        [parameter(ValueFromPipeline)]
        [PSObject]$inputObject
    )

    process {
        $hash = $inputObject.psobject.properties | foreach -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}
        return $hash
    }
}