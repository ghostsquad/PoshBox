function New-PSClassMock {
    param (
        [PSObject]$Class = $( Throw "parameter -Class is required." )
      , [Scriptblock]$Setup = {}
      , [Object]$SetupInput
      , [Object[]]$ConstructorArgs = (New-Object Object[] 0)
      , [Switch]$Strict
    )

    function method {
        param (
            [string]$name = $(Throw "Method Name is required.")
          , [scriptblock]$script = {}
        )
        $mock._mockedMethods[$name] = New-PSObject @{script=$script;calls=@()}
    }

    function constructor {}
    function note {}
    function property {}

    $mock = New-PSObject
    Attach-PSNote $mock '_strict' ([bool]$Strict)
    Attach-PSNote $mock '_mockedClass' $Class.PSObject.Copy()
    Attach-PSNote $mock '_mockedMethods' @{}
    Attach-PSNote $mock '_constructorArgs' $ConstructorArgs
    Attach-PSNote $mock '_initialized' ([bool]$false)
    Attach-PSNote $mock '_object'
    Attach-PSProperty $mock 'Object' {
        if($this._initialized) {
            return $this._object
        }

        $this._initialized = $true

        if ($this._constructorArgs.Count -gt 10) {
            throw (new-object PSMockException("PSClassMock does not support more than 10 constructor arguments at this time."))
        }

        $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10 = $this._constructorArgs
        $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10)

        Attach-PSNote $this._object '____mock' $this

        return $this._object
    }

    Attach-PSScriptMethod $mock 'Verify' {
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

    [Void]([ScriptBlock]::Create($Setup.ToString()).InvokeReturnAsIs($SetupInput))

    foreach($methodName in $Class.__Methods.Keys) {
        $methodToMockScript = $Class.__Methods[$methodName].Script

        $mockedMethod = $mock._mockedMethods[$methodName]
        $mockedMethodScript = $null
        if($mockedMethod -ne $null) {
            $mockedMethodScript = $mock._mockedMethods[$methodName].Script
        }

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
            Assert-ScriptBlockParametersEqual $methodToMockScript $mockedMethodScript
            $scriptBlockStringFormat = '$this.____mock._mockedMethods[''{0}''].calls += $Args;' +`
                '$p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10 = $Args;' +`
                '{{ {1} }}.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10)'

            $scriptBlockText = [string]::Format($scriptBlockStringFormat, $methodName, $mockedMethodScript)

            $mockedMethodScript = [ScriptBlock]::Create($scriptBlockText)
        }

        $Class.__Methods[$methodName].Script = $mockedMethodScript
    }


    foreach($mockedMethodName in $mock._mockedMethods.Keys) {
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