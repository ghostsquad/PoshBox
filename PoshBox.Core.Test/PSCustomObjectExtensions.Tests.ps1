$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

function _AddNoteProperties1Arg {
    param (
        [object]$object = (New-PSObject)
    )

    $hash = @{p1=4; p2="Q4"; p3=(New-PSObject)}
    $object = New-PSObject
    $object.PSAddMember($hash)
    $object.p1 | Should Be $hash['p1']
    $object.p2 | Should Be $hash['p2']
    $object.p3 | Should Be $hash['p3']
}

function _AddNoteProperty2Args {
    param (
        [object]$object = (New-PSObject)
    )
    $object.PSAddMember($expectedPropertyName, $expectedPropertyValue)
    $object.$expectedPropertyName | Should Be $expectedPropertyValue
}

function _AddNoteProperty3Args {
    param (
        [object]$object = (New-PSObject)
    )
    $object = New-PSObject
    $object.PSAddMember($expectedPropertyName, $expectedPropertyValue, "NoteProperty")
    $object.$expectedPropertyName | Should Be $expectedPropertyValue
}

function _AddScriptMethod3Args {
    param (
        [object]$object = (New-PSObject)
    )

    $definition = {$a=1;write-output $a}
    $object = New-PSObject
    $object.PSAddMember("DoWork",$definition,"ScriptMethod")
    $object.DoWork() | Should Be 1
}

Describe 'PSAddMember' {
    Context 'Overloads' {
        It 'throws an error when using 0 arguments' {
            $o = New-PSObject
            { $o.PSAddMember() } | Should Throw
        }

        It 'throws an error when using 4 arguments' {
            $o = New-PSObject
            { $o.PSAddMember(1,2,3,4) } | Should Throw
        }
    }

    Context "One Arg" {
        It "Adds single note property given a hashtable" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $hashtable = @{$expectedName = $expectedValue}
            $actualObject = New-PSObject
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
            $actualObject = New-PSObject
            [Void]$actualObject.PSAddMember($hashtable)

            $actualObject.$firstExpectedName | Should Be $firstExpectedValue
            $actualObject.$secondExpectedName | Should Be $secondExpectedValue
        }

        It "Throws an exception if inputobject is not IDictionary" {
            $input = "foo"
            $actualObject = New-PSObject
            { [Void]$actualObject.PSAddMember($input) } | Should Throw
        }

        It "Returns self" {
            $hashtable = @{"foo" = "bar"}
            $actualObject = New-PSObject
            $return = $actualObject.PSAddMember($hashtable)

            $return | Should Be $actualObject
        }
    }

    Context "Two Args" {
        It "Adds a Note Property" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject

            [Void]$actualObject.PSAddMember($expectedName, $expectedValue)
            $actualObject.$expectedName | Should Be $expectedValue
        }

        It "Adds a scriptblock as a noteproperty" {
            $expectedName = "foo"
            $expectedValue = {return $expectedName}
            $actualObject = New-PSObject

            [Void]$actualObject.PSAddMember($expectedName, $expectedValue)
            $actualObject.$expectedName | Should Be $expectedValue
            $actualObject.$expectedName.Invoke() | Should Be $expectedName
        }

        It "Returns self" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $expectedObject = New-PSObject
            $actualObject = $expectedObject.PSAddMember($expectedName, $expectedValue)

            { $actualObject.Equals($expectedName) } | Should Be $true
        }

        It "Throws if member already exists" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject
            [Void]$actualObject.PSAddMember($expectedName, $expectedValue)
            { $actualObject.PSAddMember($expectedName, $expectedValue) } | Should Throw
        }
    }

    Context "Three Args" {
        It "Can add arbitrary membertype" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject
            [Void]$actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty")

            $actualObject.$expectedName | Should Be $expectedValue
        }

        It "Returns self" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject
            $return = $actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty")

            $return | Should Be $actualObject
        }

        It "Throws if member already exists" {
            $expectedName = "foo"
            $expectedValue = "bar"
            $actualObject = New-PSObject
            [Void]$actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty")
            { $actualObject.PSAddMember($expectedName, $expectedValue, "NoteProperty") } | Should Throw
        }
    }

    Context 'Properties' {
        [string]$expectedPropertyName = "Foo"
        [string]$expectedPropertyValue = "Bar"

        It 'Can Add NoteProperties using HashTable' {
            _AddNoteProperties1Arg
        }

        It 'Can Add NoteProperty using 2 arguments' {
            _AddNoteProperty2Args
        }

        It 'Can Add NoteProperty using 3 arguments' {
            _AddNoteProperty3Args
        }
    }

    Context 'ScriptMethod' {
        It 'Can Add ScriptMethod using 3 arguments' {
            _AddScriptMethod3Args
        }
    }

    Context '.Net Objects' {
        [string]$expectedPropertyName = "Foo"
        [string]$expectedPropertyValue = "Bar"

        It 'Can Add NoteProperties using HashTable' {
            _AddNoteProperties1Arg (new-object System.Collections.ArrayList)
        }

        It 'Can Add NoteProperty using 2 arguments' {
            _AddNoteProperty2Args (new-object System.Collections.ArrayList)
        }

        It 'Can Add NoteProperty using 3 arguments' {
            _AddNoteProperty3Args (new-object System.Collections.ArrayList)
        }

        It 'Can Add ScriptMethod using 3 arguments' {
            _AddScriptMethod3Args (new-object System.Collections.ArrayList)
        }
    }
}

Describe "PSAddScriptMethod" {
    Context 'Overloads' {
        It 'throws an error when using 1 arguments' {
            $o = New-PSObject
            { $o.PSAddScriptMethod("foo") } | Should Throw
        }

        It 'throws an error when using 3 arguments' {
            $o = New-PSObject
            { $o.PSAddScriptMethod("foo", {}, {}) } | Should Throw
        }
    }

    Context "2 args" {
        It "adds scriptmethod to object" {
            $expectedObject = New-PSObject
            $expectedObject.PSAddScriptMethod("foo", { return 'bar' })

            $expectedObject.Foo() | Should Be "bar"
        }

        It "Returns self" {
            $expectedObject = New-PSObject
            $actualObject = $expectedObject.PSAddScriptMethod("foo", {})

            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }
}

Describe "PSOverrideScriptMethod" {
    Context 'Overloads' {
        It 'throws an error when using 1 arguments' {
            $o = New-PSObject
            { $o.PSOverrideScriptMethod("foo") } | Should Throw
        }

        It 'throws an error when using 3 arguments' {
            $o = New-PSObject
            { $o.PSOverrideScriptMethod(1,2,3) } | Should Throw
        }
    }

    Context "2 args" {
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

        It "Returns self" {
            $expectedObject = New-PSObject
            $expectedName = "foo"
            Attach-PSScriptMethod $expectedObject "foo" {}

            $actualObject = $expectedObject.PSOverrideScriptMethod($expectedName, {})

            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }
}

Describe "PSAddScriptProperty" {
    Context 'Overloads' {
        It 'throws an error when using 0 arguments' {
            $o = New-PSObject
            { $o.PSAddScriptProperty() } | Should Throw
        }

        It 'throws an error when using 3 arguments' {
            $o = New-PSObject
            { $o.PSAddScriptProperty(1,2,3) } | Should Throw
        }
    }

    Context "1 args" {
        It "Getter is added" {
            $o = New-PSObject
            $o.PSAddScriptProperty("foo", {return "bar"})
            $o.foo | Should Be "bar"
        }

        It "Setter is not added" {
            $o = New-PSObject
            $o.PSAddScriptProperty("foo", {return "bar"})

            { $o.foo = "hello world" } | Should Throw
        }

        It "Returns self" {
            $expectedObject = New-PSObject
            $actualObject = $expectedObject.PSAddScriptProperty("foo", {})

            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }

    Context "2 args" {
        It "Getter is added" {
            $o = New-PSObject
            $o.PSAddScriptProperty("foo", {return "bar"}, {})
            $o.foo | Should Be "bar"
        }

        It "Setter is added" {
            $o = New-PSObject
            $o | Add-Member -membertype noteproperty '_internal' 'unexpected'
            $o.PSAddScriptProperty("foo", {return "bar"}, {$this._internal = $args[0]})

            $expectedValue = 'hello world'
            $o.foo = $expectedValue

            $o._internal | Should Be $expectedValue
        }

        It "Returns self" {
            $expectedObject = New-PSObject
            $actualObject = $expectedObject.PSAddScriptProperty("foo", {}, {})

            { $actualObject.Equals($expectedObject) } | Should Be $true
        }
    }
}