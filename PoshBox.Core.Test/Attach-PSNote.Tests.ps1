$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "Attach-PSNote" {
    Context "Given Name, Value" {
        It "Adds name/value as note property" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject
            Attach-PSNote $actualObject $expectedName $expectedValue
            $actualObject.$expectedName | Should Be $expectedValue
        }
    }

    Context "Given pre-existing note property" {
        It "Throws an exception" {
            $actualObject = New-PSObject
            Attach-PSNote $actualObject "foo" "bar"
            { Attach-PSNote $actualObject "foo" "bar"} | Should Throw
        }
    }

    Context "Given passthru" {
        It "Returns self" {
            $expectedObject = New-PSObject
            $actualObject = Attach-PSNote $expectedObject "foo" "bar" -PassThru
            $actualObject | Should Be $expectedObject
        }
    }

    Context 'Given PSNoteProperty' {
        It 'Adds the provided PSNoteProperty object' {
            $actualObject = New-PSObject
            $expectedName = "foo"
            $expectedValue = "bar"
            $expectedNoteProperty = new-object management.automation.PSNoteProperty $expectedName, $expectedValue
            Attach-PSNote $actualObject $expectedNoteProperty
            $actualObject.$expectedName | Should Be $expectedValue
        }

        It 'Throws an expection if note property already attached' {
            $actualObject = New-PSObject
            $expectedName = "foo"
            $expectedValue = "bar"
            $expectedNoteProperty = new-object management.automation.PSNoteProperty $expectedName, $expectedValue
            Attach-PSNote $actualObject $expectedNoteProperty
            { Attach-PSNote $actualObject $expectedNoteProperty } | Should Throw
        }
    }
}