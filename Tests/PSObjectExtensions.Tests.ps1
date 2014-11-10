$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

Describe "PSAddMember" {
    Context "One Arg" {
        It "Adds single note property given a hashtable" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $hashtable = @{$expectedName = $expectedValue}
            $actualObject = new-object PSObject
            [Void]$actualObject.PSAddMember($hashtable)

            $actualObject.$expectedName | Should Be $expectedValue
        }

        It "Adds multiple note propertie given a hashtable" {
            $firstExpectedName = "prop1"
            $firstExpectedValue = "value1"
            $secondExpectedName = "prop2"
            $secondExpectedValue = "value2"
            $hashtable = @{
                $firstExpectedName = $firstExpectedValue
                $secondExpectedName = $secondExpectedValue
            }
            $actualObject = new-object PSObject
            [Void]$actualObject.PSAddMember($hashtable)

            $actualObject.$firstExpectedName | Should Be $firstExpectedValue
            $actualObject.$secondExpectedName | Should Be $secondExpectedValue
        }

        It "Throws an exception if inputobject is not IDictionary" {
            $input = "foo"
            $actualObject = new-object PSObject
            { [Void]$actualObject.PSAddMember($input) } | Should Throw
        }

        It "Returns self" {
            $hashtable = @{"foo" = "bar"}
            $actualObject = new-object PSObject
            $return = $actualObject.PSAddMember($hashtable)

            $return | Should Be $actualObject
        }
    }

    Context "Two Args" {
        It "Adds a Note Property" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = new-object PSObject

            [Void]$actualObject.PSAddMember($expectedName, $expectedValue)
            $actualObject.$expectedName | Should Be $expectedValue
        }

        It "Adds a scriptblock as a noteproperty" {
            $expectedName = "foo"
            $expectedValue = {return $expectedName}
            $actualObject = new-object PSObject

            [Void]$actualObject.PSAddMember($expectedName, $expectedValue)
            $actualObject.$expectedName | Should Be $expectedValue
            $actualObject.$expectedName.Invoke() | Should Be $expectedName
        }

        It "Returns self" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = new-object PSObject
            $return = $actualObject.PSAddMember($expectedName, $expectedValue)

            $return | Should Be $actualObject
        }
    }

    Context "Three Args" {
        It "Can add arbitrary membertype" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = new-object PSObject
            [Void]$actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty")

            $actualObject.$expectedName | Should Be $expectedValue
        }

        It "Returns self" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = new-object PSObject
            $return = $actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty")

            $return | Should Be $actualObject
        }
    }
}

Describe "PSOverrideScriptMethod" {
    It "Overrides a scriptmethod if it already exists and has the same parameters" {
        $expectedName = "foo"
        $actualDefinition = {param($a) return "original"}

        $actualObject = new-psobject
        $actualObject | Add-Member -MemberType ScriptMethod -Name $expectedName -Value $actualDefinition

        [Void]$actualObject.PSOverrideScriptMethod("foo", {param($a) return "new"})

        $actualObject.$expectedName() | Should Be "new"
    }

    It "Throws an expection if param definition is different" {
        $expectedName = "foo"
        $actualDefinition = {param($a)}

        $actualObject = new-psobject
        $actualObject | Add-Member -MemberType ScriptMethod -Name $expectedName -Value $actualDefinition

        { [Void]$actualObject.PSOverrideScriptMethod("foo", {param($a, $b)}) } | Should Throw
    }
}
