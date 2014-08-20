function New-PSCredential {
    param (
        [string]$UserName,
        [string]$Password,
    )

    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    New-Object System.Management.Automation.PSCredential ($UserName, $secpasswd)
}