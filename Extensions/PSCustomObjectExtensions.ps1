# Usage
# $p.PSAddMember("q1","Value1")
# $p.PSAddMember("q3",{"*"* $this.Threads.Count},"ScriptProperty")
# $hash = @{q3=4; q4="Q4"; q5=(gsv alg)}
# $p.PSAddMember($hash)

Update-TypeData -TypeName System.Management.Automation.PSCustomObject `
    -MemberType ScriptMethod `
    -MemberName PSAddMember `
    -Value {
        switch ($args.count)  {
            1 {
                $hash = $args[0] -as [HashTable]
                foreach ($key in $hash.keys) {
                    Add-Member -InputObject $this -Name $key -value $hash.$key -MemberType Noteproperty -Force
                }
            }

            2 {
                $name,$value = $args
                Add-Member -InputObject $this -Name $name -value $value -MemberType Noteproperty -Force
            }

            3 {
                $name,$value,$MemberType = $args
                Add-Member -InputObject $this -Name $name -value $value -MemberType $MemberType -Force
            }

            default { throw "No overload for PSAddMember takes the specified number of parameters." }
        }
    } `
    -Force