$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

Describe "Get-ScriptBlockParams" {
    It "finds strongly typed single param" {
        $scriptBlock = {param([int]$a)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 1
        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([int])
    }

    It "finds single param no type" {
        $scriptBlock = {param($a)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 1
        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([object])
    }

    It "finds multiple param no type" {
        $scriptBlock = {param($a, $b)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 2

        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([object])

        $actualParams[1].Key | Should Be 'b'
        $actualParams[1].Value | Should Be ([object])
    }

    It "finds multiple param mixed strong type" {
        $scriptBlock = {param([int]$a, [string]$b)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 2

        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([int])

        $actualParams[1].Key | Should Be 'b'
        $actualParams[1].Value | Should Be ([string])
    }

    It "finds param generic type" {
        $scriptBlock = {param([system.collections.generic.list[string]]$a)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 1
        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([system.collections.generic.list[string]])
    }

    It "finds multiple param of mixed type and no type" {
        $scriptBlock = {param([int]$a, $b)}

        $actualParams = Get-ScriptBlockParams $scriptBlock

        $actualParams.Count | Should Be 2

        $actualParams[0].Key | Should Be 'a'
        $actualParams[0].Value | Should Be ([int])

        $actualParams[1].Key | Should Be 'b'
        $actualParams[1].Value | Should Be ([object])
    }
}