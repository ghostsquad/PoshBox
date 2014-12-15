function Remove-ManagedCredential {
    param (
        [string]$Target = $(throw "missing parameter -Target")
    )

    $managedCredential = new-object CredentialManagement.Credential
    $managedCredential.Target = $Target

    Invoke-Using $managedCredential {
        if(-not $managedCredential.Exists())
        {
            throw "Credential does not exist"
        }

        if(-not $managedCredential.Delete()) {
            throw "Unable to delete managed credential with target: $Target"
        }
    }
}