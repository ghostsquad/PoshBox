function New-PSCredential {
    param (
        [string]$UserName,
        [string]$Password
    )

    Guard-ArgumentNotNullOrEmpty 'UserName' $UserName
    Guard-ArgumentNotNullOrEmpty 'Password' $Password

    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential($UserName, $secpasswd)
}