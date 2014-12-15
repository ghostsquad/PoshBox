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
                Add-Member -InputObject $this -NotePropertyMembers $args[0] -Passthru
            }

            2 {
                $name,$value = $args
                Attach-PSNote $this $name $value -Passthru
            }

            default { throw "No overload for PSAddNoteProperty takes the specified number of parameters." }
        }
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddScriptProperty `
    -Value {
        if($args.count -lt 2 -or $args.Count -gt 3) {
            throw (new-object System.InvalidOperationException("No overload for PSAddScriptProperty takes the specified number of parameters."))
        }

        $name,$getter,$setter = $args
        Attach-PSProperty $this $name $getter $setter -Passthru
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSAddScriptMethod `
    -Value {
        if($args.count -eq 2) {
            $name,$scriptblock = $args
            Attach-PSScriptMethod $this $name $scriptblock -Passthru
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
                Attach-PSNote $this $args[0] $args[1] -Passthru
            }

            3 {
                $name,$value,$memberType = $args
                Add-Member -InputObject $this -Name $name -Value $value -MemberType $memberType -Passthru
            }

            default { throw "No overload for PSAddMember takes the specified number of parameters." }
        }
    } `
    -Force

Update-TypeData -TypeName System.Object `
    -MemberType ScriptMethod `
    -MemberName PSOverrideScriptMethod `
    -Value {
        if($args.count -eq 2) {
            Attach-PSScriptMethod $this $args[0] $args[1] -override -Passthru
        } else {
            throw (new-object System.InvalidOperationException("No overload for PSOverrideScriptMethod takes the specified number of parameters."))
        }
    } `
    -Force