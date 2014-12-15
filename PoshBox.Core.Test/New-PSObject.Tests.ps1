$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "New-PSObject" {
    It "creates a new PSCustomObject" {
        $actualObject = New-PSObject
        $actualObject.GetType() | Should Be ([System.Management.Automation.PSCustomObject])
    }

    It "adds properties hash" {
        $propertiesHash = @{Foo="Bar"}
        $actualObject = New-PSObject -Property $propertiesHash

        $actualProperties = @($actualObject.PSObject.Properties | ?{$_.MemberType -eq "NoteProperty"} | %{$_})
        $actualProperties.Count | Should Be 1
        $actualProperties[0].Name | Should Be "Foo"
        $actualProperties[0].Value | Should Be "Bar"
    }
}