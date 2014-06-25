function Log-Error {
	param(
		[object]$object,
		[Exception]$exception
	)
	
	$iLog = [log4net.LogManager]::GetLogger([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PsCommandPath))
	
	if($exception -ne $null){
		$iLog.Error($object, $exception)
	}
	
	$iLog.Error($object)
}