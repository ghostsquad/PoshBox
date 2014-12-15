$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe "Get-ManagedCredential" {
    It "Gets credentials from Windows Credential Manager" {
        $expectedUserName = "testuser"
        $expectedPassword = "pass123"
        $target = [Guid]::NewGuid().ToString()
        $credManCred = new-object CredentialManagement.Credential($expectedUserName, $expectedPassword, $target)

        try {
            $credManCred.Save()
            $actualCreds = Get-ManagedCredential $target
            $actualCreds.UserName | Should Be $expectedUserName
            $actualCreds.GetNetworkCredential().Password | Should Be $expectedPassword
        } finally {
            if($credManCred.Load()) {
                $credManCred.Delete()
            }
        }
    }

    It "Throws exception if no credential exists for given target" {
        $target = "DOES_NOT_EXIST_" + [Guid]::NewGuid().ToString()
        { Get-ManagedCredential $target } | Should Throw
    }
}
