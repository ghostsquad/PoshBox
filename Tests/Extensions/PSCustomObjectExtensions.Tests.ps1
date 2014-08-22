$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

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
        It 'Can Add NoteProperty using 2 arguments' {
            [string]$expectedPropertyName = "Foo"
            [string]$expectedPropertyValue = "Bar"
            $o = new-object PSObject
            $o.PSAddMember($expectedPropertyName, $expectedPropertyValue)
            $o.$expectedPropertyName | Should Be $expectedPropertyValue
        }

        It 'Can Add NoteProperty using 3 arguments' {
            [string]$expectedPropertyName = "Foo"
            [string]$expectedPropertyValue = "Bar"
            $o = new-object PSObject
            $o.PSAddMember($expectedPropertyName, $expectedPropertyValue, "NoteProperty")
            $o.$expectedPropertyName | Should Be $expectedPropertyValue
        }

        It 'Can Add NoteProperties using HashTable' {
            $hash = @{p1=4; p2="Q4"; p3=(new-object psobject)}
            $o = new-object PSObject
            $o.PSAddMember($hash)
            $o.p1 | Should Be $hash['p1']
            $o.p2 | Should Be $hash['p2']
            $o.p3 | Should Be $hash['p3']
        }
    }

    Context 'ScriptMethod' {
        It 'Can Add ScriptMethod using 3 arguments' {
            $definition = {$a=1;write-output $a}
            $o = new-object PSObject
            $o.PSAddMember("DoWork",$definition,"ScriptMethod")
            $o.DoWork() | Should Be 1
        }
    }
}