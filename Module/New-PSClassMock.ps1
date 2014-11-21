function New-PSClassMock {
    param (
        [PSObject]$Class = $( Throw "parameter -Class is required." )
      , [Scriptblock]$Setup = {}
      , [Object[]]$ConstructorParams
      , [Switch]$Strict
      , [Object[]]$SetupParams
    )

    unction method {
        param (
            [string]$name = $(Throw "Method Name is required.")
          , [scriptblock]$script = {}
        )
        $mockedMethods[$name] = @{script=$script;calls=@()}
    }

    function constructor {}
    function note {}
    function property {}

    New-Variable -Name 'mock' -Value (New-PSObject) -Scope Private
    Attach-PSNote $mock '_strict' $Strict
    Attach-PSNote $mock '_mockedClass' $Class.PSObject.Copy()
    Attach-PSNote $mock '_initialized' $false
    Attach-PSNote $mock '_object'
    Attach-PSProperty $mock "Object" {
        if($this._initialized) {
            return $this._object
        }

        $this._initialized = $true
        $this._object = $this._mockedClass.New($ConstructorParams)
        return $this._object
    }

    Attach-PSNote $mock '_mockedMethods' @{}
    Attach-PSProperty 'Object' {
        return $this._object
    }

    Attach-PSScriptMethod 'Verify' {
        param (
            [string]$methodName,
            [object[]]$expectations
        )

        function Assert-True {
            param(
                $actualValue,
                $expectation
            )

            $expectationType = $expectation.GetType()
            if($expectationType -is ([scriptblock]) -or $expectationType -is ([System.MulticastDelegate])) {
                $result = $expectation.InvokeReturnAsIs($actualValue)
                if(-not $result) {
                    throw (new-object PSMockException(
                        [string]::Format("Expected {0} to return true for input: {1}", $expectation, $actualValue)))
                }
            }
            else {
                if($actualValue -ne $expectation) {
                    throw (new-object PSMockException(
                        [string]::Format("Expected {0} but found {1}", $expectation, $actualValue)))
                }
            }
        }

        $mockedMethod = $this._mockedMethods[$methodName]
        if($mockedMethod -eq $null) {
            throw (new-object PSMockException(
                [string]::Format("Unable to verify a method [{0}] that has no expectations!",
                    $methodName)))
        }

        foreach($expectation in $expectations) {
            foreach($call in $mockedMethod.calls) {
                foreach($callArg in $call){
                    Assert-True $callArg $expectation
                }
            }
        }
    }

    [Void]([ScriptBlock]::Create($Setup.ToString()).InvokeReturnAsIs($SetupParams))

    foreach($methodName in $Class.__Methods.Keys) {
        $mockedMethodScript = $mockedMethods[$methodName].Script
        $methodToMockScript = $Class.__Methods[$methodName].Script
        if($mockedMethodScript -eq $null) {
            if(-not $Strict) {
                $mockedMethodScript = {}
            } else {
                $mockedMethodScript = {
                    throw (new-object PSMockException("This Mock is strict and no expectation was set for this method"))
                }
            }
        }
        else {
            Assert-ScriptBlockParametersEqual $mockedMethodScript $mockedMethodScript
            $mockedMethodScript = $mockedMethodScript
        }
    }


    foreach($mockedMethodName in $mockedMethods.Keys) {
        $methodToMock = $Class.__Methods[$mockedMethodName]
        if($methodToMock -eq $null) {
            throw (new-object PSMockException("Method with name: $mockedMethodName cannot be found to mock!"))
        }
    }

    return $mock
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