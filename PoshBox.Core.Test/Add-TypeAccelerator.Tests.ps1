$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "Add-TypeAccelerator" {
    It "Can add type accelerator" {
        Add-TypeAccelerator List "System.Collections.Generic.List``1"
        $MyList = New-Object List[String]
        $MyList.GetType() | Should Be ([System.Collections.Generic.List[string]])
    }
}