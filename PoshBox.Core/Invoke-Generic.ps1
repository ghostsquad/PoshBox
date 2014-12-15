function Invoke-Generic {
    #.Synopsis
    #  Invoke Generic method definitions via reflection:
    [CmdletBinding()]
    param(
       [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
       [Alias('On','Type')]
       $InputObject,

       [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
       [Alias('Named')]
       [string]$MethodName,

       [Parameter(Position=2)]
       [Alias('Returns')]
       [Type]$ReturnType,

       [Parameter(Position=3, ValueFromRemainingArguments=$true, ValueFromPipelineByPropertyName=$true)]
       [Object[]]$WithArgs
    )

    process {
        Guard-ArgumentNotNull 'InputObject' $InputObject

        $Type = $InputObject -as [Type]
        if(!$Type) {
            $Type = $InputObject.GetType()
        }

        [Type[]]$ArgumentTypes = New-Object Type[]($WithArgs.Count)
        [Object[]]$Arguments = New-Object Object[]($WithArgs.Count)

        foreach($withArg in $withArgs) {
            [Void]$ArgumentTypes.Add($withArg.GetType())
            [Void]$Arguments.Add($withArg.PSObject.BaseObject)
        }

        return $Type.GetMethod($MethodName, $ArgumentTypes).MakeGenericMethod($returnType).Invoke($on, $Arguments)
    }
}
