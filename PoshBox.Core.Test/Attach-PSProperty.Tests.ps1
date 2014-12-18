$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "Attach-PSProperty" {
    BeforeEach {
        $expectedPropertyName = "foo"
        $expectedGetterScript = {return "bar"}
        $expectedSetterScript = {return}
    }

    Context "Given Name, GetScript" {
        It "Attaches ScriptMethod with Getter" {
            $actualObject = New-PSObject
            Attach-PSProperty $actualObject $expectedPropertyName $expectedGetterScript

            $actualGetter = $actualObject.psobject.properties[$expectedPropertyName].GetterScript

            $actualGetter.ToString() | Should Be $expectedGetterScript.ToString()
        }
    }

    Context "Given Name, Get, Set" {
        It "Attaches ScriptProperty with Setter" {
            $actualObject = New-PSObject
            Attach-PSProperty $actualObject $expectedPropertyName {} $expectedSetterScript

            $actualSetter = $actualObject.psobject.properties[$expectedPropertyName].SetterScript

            $actualSetter.ToString() | Should Be $expectedSetterScript.ToString()
        }
    }

    Context "Given PassThru" {
        It "returns inputobject" {
            $expectedObject = New-PSObject
            $actualObject = Attach-PSProperty $expectedObject "foo" {} {} -PassThru
            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }

    Context "Given Override" {
        It "throws if existing property does not exist" {
            $actualObject = New-PSObject
            $action = { Attach-PSProperty $actualObject $expectedPropertyName {} {} -override }
            $action | Should Throw

        }

        It "overrides an existing property with same setter and getter" {
            $actualObject = New-PSObject
            Attach-PSProperty $actualObject $expectedPropertyName {} {}
            Attach-PSProperty $actualObject $expectedPropertyName $expectedGetterScript $expectedSetterScript -override

            $actualObject.psobject.properties[$expectedPropertyName].GetterScript.ToString() | Should Be $expectedGetterScript.ToString()
            $actualObject.psobject.properties[$expectedPropertyName].SetterScript.ToString() | Should Be $expectedSetterScript.ToString()
        }

        It "throws if setter is missing from the original, and provided in override" {
            $actualObject = New-PSObject
            Attach-PSProperty $actualObject $expectedPropertyName {}
            $action = { Attach-PSProperty $actualObject $expectedPropertyName $expectedGetterScript $expectedSetterScript -override }
            $action | Should Throw
        }
    }

    Context 'Given PSScriptProperty' {
        It 'Adds the provided PSScriptProperty object' {
            $actualObject = New-PSObject
            $expectedScriptProperty = new-object management.automation.PSScriptProperty $expectedPropertyName, $expectedGetterScript, $expectedSetterScript
            Attach-PSProperty $actualObject $expectedScriptProperty

            $actualObject.psobject.properties[$expectedPropertyName].GetterScript.ToString() | Should Be $expectedGetterScript.ToString()
            $actualObject.psobject.properties[$expectedPropertyName].SetterScript.ToString() | Should Be $expectedSetterScript.ToString()
        }

        It 'Throws an expection if script property already attached' {
            $actualObject = New-PSObject
            $expectedScriptProperty = new-object management.automation.PSScriptProperty $expectedPropertyName, $expectedGetterScript, $expectedSetterScript
            Attach-PSProperty $actualObject $expectedScriptProperty
            { Attach-PSProperty $actualObject $expectedScriptProperty } | Should Throw
        }
    }
}
