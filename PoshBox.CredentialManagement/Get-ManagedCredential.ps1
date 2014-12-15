function Get-ManagedCredential {
    param (
        [string]$Target
    )

    $managedCredential = new-object CredentialManagement.Credential
    $managedCredential.Target = $Target
    if($managedCredential.Load()) {
        return (New-PSCredential $managedCredential.Username $managedCredential.Password)
    } else {
        throw (new-object System.InvalidOperationException("no credentials found in Windows Credential Manager for target [$Target]."))
    }
}