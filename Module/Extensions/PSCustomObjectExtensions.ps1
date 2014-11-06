# Usage
# $p.PSAddMember("q1","Value1")
# $p.PSAddMember("q3",{"*"* $this.Threads.Count},"ScriptProperty")
# $hash = @{q3=4; q4="Q4"; q5=(gsv alg)}
# $p.PSAddMember($hash)

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddNoteProperty `
    -Value {
        switch ($args.count)  {
            1 {
                Add-Member -InputObject $this -NotePropertyMembers $args[0] -Force -Passthru
            }

            2 {
                $name,$value = $args
                Add-Member -InputObject $this -NotePropertyName $name -NotePropertyValue $value -Force -Passthru
            }

            default { throw "No overload for PSAddNoteProperty takes the specified number of parameters." }
        }
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddScriptProperty `
    -Value {
        if($args.count -eq 3) {
            $name,$getter,$setter = $args
            Add-Member -InputObject $this -Name $name -Value $getter -SecondValue $setter -MemberType ScriptProperty -Force -Passthru
        } else {
            throw (new-object System.InvalidOperationException("No overload for PSAddScriptProperty takes the specified number of parameters."))
        }
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddScriptMethod `
    -Value {
        if($args.count -eq 2) {
            $name,$scriptblock = $args
            Add-Member -InputObject $this -Name $name -Value $scriptblock -MemberType ScriptMethod -Force -Passthru
        } else {
            throw (new-object System.InvalidOperationException("No overload for PSAddScriptMethod takes the specified number of parameters."))
        }
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddMember `
    -Value {
        switch ($args.count)  {
            1 {
                $this.PSAddNoteProperty($args[0])
            }

            2 {
                $this.PSAddNoteProperty($args[0], $args[1])
            }

            3 {
                $name,$value,$memberType = $args
                Add-Member -InputObject $this -Name $name -Value $value -MemberType $memberType -Force -Passthru
            }

            default { throw "No overload for PSAddMember takes the specified number of parameters." }
        }
    } `
    -Force