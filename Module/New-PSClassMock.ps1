function New-PSClassMock {
    param (
        [PSObject]$Class = $( Throw "parameter -Class is required." )
      , [Switch]$Strict
    )

    $mock = New-PSObject
    Attach-PSNote $mock '_strict' ([bool]$Strict)
    Attach-PSNote $mock '_originalClass' $Class
    Attach-PSNote $mock '_mockedMethods' @{}
    Attach-PSNote $mock 'Object' (New-PSObject)
    Attach-PSNote $mock.Object '____mock' $mock

    Attach-PSScriptMethod $mock 'SetupMethod' {
        param (
            [string]$methodName
          , [scriptblock]$script
        )

        if(-not $this._originalClass.__Methods.ContainsKey($methodName)) {
            throw (new-object PSMockException("Method with name: $methodName cannot be found to mock!"))
        }

        $methodToMockScript = $this._originalClass.__Methods[$methodName].Script

        try {
            Assert-ScriptBlockParametersEqual $methodToMockScript $script
        } catch {
            $msg = "Unable to mock method: {0}" -f $methodName
            $exception = (new-object PSMockException($msg, $_))
            throw $exception
        }

        # add the actual mocked script to the mock internals
        $this._mockedMethods[$methodName] = $mockMethodInfoClass.New($this, $methodName, $script)

        # replace the method script in the class we are to mock with a call to the mocked script
        # because we are doing a bit of redirection, it allows us to capture information about each method call
        $scriptBlockText = [string]::Format('$this.____mock._mockedMethods[''{0}''].Invoke($Args)', $methodName)
        $mockedMethodScript = [ScriptBlock]::Create($scriptBlockText)

        $member = new-object management.automation.PSScriptMethod $methodName,$mockedMethodScript
        $this.Object.psobject.methods.remove($methodName)
        [Void]$this.Object.psobject.methods.add($member)
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

    foreach($methodName in $Class.__Methods.Keys) {
        if(-not $Strict) {
            $mockedMethodScript = {}
        } else {
            $mockedMethodScript = {
                throw (new-object PSMockException("This Mock is strict and no expectation was set for this method"))
            }
        }

        Attach-PSScriptMethod $mock.Object $methodName $mockedMethodScript
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
        switch($args.Count) {
            0 {  return $this.Script.InvokeReturnAsIs() }
            1 {  return $this.Script.InvokeReturnAsIs($p1) }
            2 {  return $this.Script.InvokeReturnAsIs($p1, $p2) }
            3 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3) }
            4 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4) }
            5 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5) }
            6 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6) }
            7 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7) }
            8 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8) }
            9 {  return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9) }
            10 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10) }
            default {
                throw (new-object PSMockException("PSClassMock does not support more than 10 arguments for a method mock."))
            }
        }
    }
}

if (-not ([System.Management.Automation.PSTypeName]'PSMockException').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
    using System;
    using System.Management.Automation;

    public class PSMockException : Exception {
        public ErrorRecord ErrorRecord { get; private set; }

        public PSMockException(string message)
            : base(message)
        {
        }

        public PSMockException(string message, ErrorRecord errorRecord)
            : base(message)
        {
            this.ErrorRecord = errorRecord;
        }

        public PSMockException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
"@
}