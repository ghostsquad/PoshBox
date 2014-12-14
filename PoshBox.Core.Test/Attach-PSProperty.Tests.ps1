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
            $expectedObject = New-PSObject
            Attach-PSProperty $expectedObject $expectedPropertyName $expectedGetterScript

            $actualGetter = $expectedObject.psobject.properties[$expectedPropertyName].GetterScript

            $actualGetter.ToString() | Should Be $expectedGetterScript.ToString()
        }
    }

    Context "Given Name, Get, Set" {
        It "Attaches ScriptProperty with Setter" {
            $expectedObject = New-PSObject
            Attach-PSProperty $expectedObject $expectedPropertyName {} $expectedSetterScript

            $actualSetter = $expectedObject.psobject.properties[$expectedPropertyName].SetterScript

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
            $expectedObject = New-PSObject
            $action = { Attach-PSProperty $expectedObject $expectedPropertyName {} {} -override }
            $action | Should Throw

        }

        It "overrides an existing property with same setter and getter" {
            $expectedObject = New-PSObject
            Attach-PSProperty $expectedObject $expectedPropertyName {} {}
            Attach-PSProperty $expectedObject $expectedPropertyName $expectedGetterScript $expectedSetterScript -override

            $expectedObject.psobject.properties[$expectedPropertyName].GetterScript.ToString() | Should Be $expectedGetterScript.ToString()
            $expectedObject.psobject.properties[$expectedPropertyName].SetterScript.ToString() | Should Be $expectedSetterScript.ToString()
        }

        It "throws if setter is missing from the original, and provided in override" {
            $expectedObject = New-PSObject
            Attach-PSProperty $expectedObject $expectedPropertyName {}
            $action = { Attach-PSProperty $expectedObject $expectedPropertyName $expectedGetterScript $expectedSetterScript -override }
            $action | Should Throw
        }
    }
}
