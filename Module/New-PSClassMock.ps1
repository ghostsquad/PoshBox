function New-PSClassMock {
    param (
        [PSObject]$Class = $( Throw "parameter -Class is required." )
      , [Scriptblock]$Setup = {}
      , [Object[]]$ConstructorParams
      , [Switch]$Strict
    )

    $mockedMethods = @{}

    function method {
        param (
            [string]$name = $(Throw "Method Name is required.")
          , [scriptblock]$script = {}
        )
        $mockedMethods[$name] = $script
    }

    function constructor {}
    function note {}
    function property {}

    $mockedClass = $Class.PSObject.Copy()

    [Void]([ScriptBlock]::Create($Setup.ToString()).InvokeReturnAsIs())

    foreach($methodName in $Class.__Methods.Keys) {
        $mockedMethodScript = $mockedMethods[$methodName]
        $methodToMock = $Class.__Methods[$methodName]
        if($mockedMethodScript -eq $null) {
            if(-not $Strict) {
                $methodToMock.Script = {}
            } else {
                $methodToMock.Script = {
                    throw (new-object PSMockException("This Mock is strict and no expectation was set for this method"))
                }
            }
        }
        else {
            Assert-ScriptBlockParametersEqual $methodToMock.Script $mockedMethodScript
            $methodToMock.Script = $mockedMethodScript
        }
    }


    foreach($mockedMethodName in $mockedMethods.Keys) {
        $methodToMock = $Class.__Methods[$mockedMethodName]
        if($methodToMock -eq $null) {
            throw (new-object PSMockException("Method with name: $mockedMethodName cannot be found to mock!"))
        }
    }

    return $mockedClass.New($ConstructorParams)
}

if (-not ([System.Management.Automation.PSTypeName]'PSMockException').Type)
{
    Add-Type -TypeDefinition @"
    using System;

    public class PSMockException : Exception {
        public PSMockException(string message)
            : base(message)
        {
        }

        public PSMockException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
"@
}