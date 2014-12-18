$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "Attach-PSScriptMethod" {
    BeforeEach {
        $expectedMethodName = "foo"
        $expectedScript = {return "bar"}
    }

    Context "Given Name, Script" {
        It "Attaches ScriptMethod with Getter" {
            $actualObject = New-PSObject
            Attach-PSScriptMethod $actualObject $expectedMethodName $expectedScript

            $actualScript = $actualObject.psobject.methods[$expectedMethodName].Script

            $actualScript.ToString() | Should Be $expectedScript.ToString()
        }
    }

    Context "Given PassThru" {
        It "returns inputobject" {
            $actualObject = New-PSObject
            $actualObject = Attach-PSScriptMethod $actualObject "foo" {} -PassThru
            { $actualObject.Equals($actualObject) } | Should Be $true
        }
    }

    Context "Given Override" {
        It "throws if existing method does not exist" {
            $actualObject = New-PSObject
            { Attach-PSScriptMethod $actualObject $expectedMethodName {} -override } | Should Throw

        }

        It "overrides an existing property with same script parameters" {
            $actualObject = New-PSObject
            Attach-PSScriptMethod $actualObject $expectedMethodName {}
            Attach-PSScriptMethod $actualObject $expectedMethodName $expectedScript -override

            $actualObject.psobject.methods[$expectedMethodName].Script.ToString() | Should Be $expectedScript.ToString()
        }

        It "throws if original method has no parameters defined and override has parameters defined" {
            $actualObject = New-PSObject
            Attach-PSScriptMethod $actualObject $expectedMethodName {}
            $action = { Attach-PSScriptMethod $actualObject $expectedMethodName {param($a)} -override }
            $action | Should Throw
        }

        It "throws if original method has parameters defined and override has no parameters defined" {
            $actualObject = New-PSObject
            Attach-PSScriptMethod $actualObject $expectedMethodName {param($a)}
            $action = { Attach-PSScriptMethod $actualObject $expectedMethodName {} -override }
            $action | Should Throw
        }

        It "throws if method parameter count is mismatched" {
            $actualObject = New-PSObject
            Attach-PSScriptMethod $actualObject $expectedMethodName {param($a)}
            $action = { Attach-PSScriptMethod $actualObject $expectedMethodName {param($a, $b)} -override }
            $action | Should Throw
        }
    }

    Context 'Given PSScriptMethod' {
        It 'Adds the provided PSScriptProperty object' {
            $actualObject = New-PSObject
            $expectedScriptMethod = new-object management.automation.PSScriptMethod $expectedMethodName,$expectedScript
            Attach-PSScriptMethod $actualObject $expectedScriptMethod

            $actualObject.psobject.methods[$expectedMethodName].Script.ToString() | Should Be $expectedScript.ToString()
        }

        It 'Throws an expection if script property already attached' {
            $actualObject = New-PSObject
            $expectedScriptMethod = new-object management.automation.PSScriptMethod $expectedMethodName,$expectedScript
            Attach-PSScriptMethod $actualObject $expectedScriptMethod
            { Attach-PSScriptMethod $actualObject $expectedScriptMethod } | Should Throw
        }
    }
}