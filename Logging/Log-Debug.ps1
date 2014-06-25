function Log-Debug {
	param(
		[object]$object,
		[Exception]$exception
	)
	
	$iLog = [log4net.LogManager]::GetLogger([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PsCommandPath))
	
	if($exception -ne $null){
		$iLog.Debug($object, $exception)
	}
	
	$iLog.Debug($object)
}