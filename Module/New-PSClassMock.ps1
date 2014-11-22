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
        $mock._mockedMethods[$name] = $mockMethodInfoClass.New($mock, $name, $script)
    }

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

        $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10 = $this._constructorArgs
        switch($this._constructorArgs.Count) {
            0 { $this._object = $this._mockedClass.New() }
            1 { $this._object = $this._mockedClass.New($p1) }
            2 { $this._object = $this._mockedClass.New($p1, $p2) }
            3 { $this._object = $this._mockedClass.New($p1, $p2, $p3) }
            4 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4) }
            5 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5) }
            6 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6) }
            7 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7) }
            8 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8) }
            9 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9) }
            10 { $this._object = $this._mockedClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10) }
            default {
                throw (new-object PSMockException("PSClassMock does not support more than 10 constructor arguments at this time."))
            }
        }

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
            foreach($callArgsCollection in $mockedMethod.Invocations) {
                foreach($callArg in $callArgsCollection){
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
            $scriptBlockText = [string]::Format('$this.____mock._mockedMethods[''{0}''].Invoke($Args)', $methodName)
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

$mockMethodInfoClass = New-PSClass 'MockMethodInfo' {
    note 'Name'
    note 'Script'
    note 'Invocations' (New-Object System.Collections.ArrayList)
    note 'PSClassMock'

    constructor {
        param($psClassMock, $name, $script = {})

        $this.PSClassMock = $psClassMock
        $this.Name = $name
        $this.Script = $script
    }

    method 'Invoke' {
        [void]$this.Invocations.Add(@($args))
        $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10 = $args
        $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10)
    }
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