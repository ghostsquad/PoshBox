$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

function _AddNoteProperties1Arg {
    param (
        [object]$object = (new-object PSObject)
    )

    $hash = @{p1=4; p2="Q4"; p3=(new-object psobject)}
    $object = new-object PSObject
    $object.PSAddMember($hash)
    $object.p1 | Should Be $hash['p1']
    $object.p2 | Should Be $hash['p2']
    $object.p3 | Should Be $hash['p3']
}

function _AddNoteProperty2Args {
    param (
        [object]$object = (new-object PSObject)
    )
    $object.PSAddMember($expectedPropertyName, $expectedPropertyValue)
    $object.$expectedPropertyName | Should Be $expectedPropertyValue
}

function _AddNoteProperty3Args {
    param (
        [object]$object = (new-object PSObject)
    )
    $object = new-object PSObject
    $object.PSAddMember($expectedPropertyName, $expectedPropertyValue, "NoteProperty")
    $object.$expectedPropertyName | Should Be $expectedPropertyValue
}

function _AddScriptMethod3Args {
    param (
        [object]$object = (new-object PSObject)
    )

    $definition = {$a=1;write-output $a}
    $object = new-object PSObject
    $object.PSAddMember("DoWork",$definition,"ScriptMethod")
    $object.DoWork() | Should Be 1
}

Describe 'PSCustomObject.PSAddMember' {
    Context 'Overloads' {
        It 'throws an error when using 0 arguments' {
            $o = new-object PSObject
            { $o.PSAddMember() } | Should Throw
        }

        It 'throws an error when using 4 arguments' {
            $o = new-object PSObject
            { $o.PSAddMember(1,2,3,4) } | Should Throw
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