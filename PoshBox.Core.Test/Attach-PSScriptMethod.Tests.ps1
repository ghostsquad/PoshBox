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
            $expectedObject = New-PSObject
            Attach-PSScriptMethod $expectedObject $expectedMethodName $expectedScript

            $actualScript = $expectedObject.psobject.methods[$expectedMethodName].Script

            $actualScript.ToString() | Should Be $expectedScript.ToString()
        }
    }

    Context "Given PassThru" {
        It "returns inputobject" {
            $expectedObject = New-PSObject
            $actualObject = Attach-PSScriptMethod $expectedObject "foo" {} -PassThru
            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }

    Context "Given Override" {
        It "throws if existing method does not exist" {
            $expectedObject = New-PSObject
            { Attach-PSScriptMethod $expectedObject $expectedMethodName {} -override } | Should Throw

        }

        It "overrides an existing property with same script parameters" {
            $expectedObject = New-PSObject
            Attach-PSScriptMethod $expectedObject $expectedMethodName {}
            Attach-PSScriptMethod $expectedObject $expectedMethodName $expectedScript -override

            $expectedObject.psobject.methods[$expectedMethodName].Script.ToString() | Should Be $expectedScript.ToString()
        }

        It "throws if original method has no parameters defined and override has parameters defined" {
            $expectedObject = New-PSObject
            Attach-PSScriptMethod $expectedObject $expectedMethodName {}
            $action = { Attach-PSScriptMethod $expectedObject $expectedMethodName {param($a)} -override }
            $action | Should Throw
        }

        It "throws if original method has parameters defined and override has no parameters defined" {
            $expectedObject = New-PSObject
            Attach-PSScriptMethod $expectedObject $expectedMethodName {param($a)}
            $action = { Attach-PSScriptMethod $expectedObject $expectedMethodName {} -override }
            $action | Should Throw
        }

        It "throws if method parameter count is mismatched" {
            $expectedObject = New-PSObject
            Attach-PSScriptMethod $expectedObject $expectedMethodName {param($a)}
            $action = { Attach-PSScriptMethod $expectedObject $expectedMethodName {param($a, $b)} -override }
            $action | Should Throw
        }
    }
}