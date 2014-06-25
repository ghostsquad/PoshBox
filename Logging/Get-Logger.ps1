function Get-Logger {
	[cmdletbinding()]
	param(
		[string]$loggerName = $([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PSCommandPath))
	)
	
	Write-Output ([log4net.LogManager]::GetLogger($loggerName))
}