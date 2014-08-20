if(-not Get-Module PSCX){
    Write-Host "Installing Dependency Module: PSCX"
    $env:Path += ";C:\Program Files (x86)\PowerShell Community Extensions\Pscx3\Pscx"
    Write-Host "Downloading PSCX msi package..." -ForegroundColor Gray
    $pscxDownloadUrl = "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=pscx&DownloadId=744915&FileTime=130265033731230000&Build=20911"
    $tempPath = [System.IO.Path]::Join([System.IO.Path]::GetTempPath(), [guid]::NewGuid().ToString())
    $destination = Join-Path $tempPath "pscx.msi"
    (new-object Net.WebClient).DownloadFile($pscxDownloadUrl, $destination)

    $installLog = Join-Path $tempPath "pscx_install.log"

    $params = '/i "{0}" /quiet /qn /norestart /log {1}' -f $destination, $installLog

    $installProcess = Start-Process -FilePath msiexec -ArgumentList $params -Wait -PassThru;
    if($installProcess.ExitCode -ne 0){
        throw "failed to install Powershell Community Extension. see $installLog"
    }
}

Import-Module PSCX

$null = Add-Type -Path (Join-Path $PSScriptRoot "logging/log4net.2.0.3/log4net.dll")
$null = Add-Type -Path (Join-Path $PSScriptRoot "sql/mysql.data.dll")
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$global:PoshBoxSettings = New-Object PSObject -Property @{
    AWSAccessKey              = ""
    AWSSecretKey              = ""
    Version                   = "0.1 alpha"
}

# setup root logger with console appender
[log4net.LogManager]::ResetConfiguration();

. $here\Logging\Add-FileLogAppender.ps1

AddConsoleLogAppender

. $here\PSUsing.ps1

Export-ModuleMember -Function PSUSing

# Logging
. $here\Logging\Get-Logger.ps1
. $here\Logging\Log-Debug.ps1
. $here\Logging\Log-Info.ps1
. $here\Logging\Log-Warning.ps1
. $here\Logging\Log-Error.ps1
. $here\Logging\Log-Fatal.ps1

. $here\Get-Delegate.ps1
. $here\New-Interface.ps1
. $here\ConvertTo-Hash.ps1

. $here\Invoke-Generic.ps1

. $here\Sql\Execute-MySqlQuery.ps1
. $here\Sql\Execute-MySqlNonQuery.ps1
. $here\Sql\Execute-SqlQuery.ps1
. $here\Sql\Execute-SqlNonQuery.ps1

. $here\Ui\New-ConsoleTable.ps1

. $here\Networking\ConvertTo-BinaryIp.ps1
. $here\Networking\ConvertTo-DecimalIP.ps1

. $here\Development\Fix-SourceFiles.ps1
. $here\Development\Remove-ExcessWhitespace.ps1
. $here\Development\Replace-TabsWithSpaces.ps1
. $here\Development\Set-EncodingUtf8NoBom.ps1

Export-ModuleMember -Function *-*
