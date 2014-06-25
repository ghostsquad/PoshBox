function Log-Info{
	param(
		[object]$object,
		[Exception]$exception
	)	
	
	$iLog = [log4net.LogManager]::GetLogger([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PsCommandPath))
	
	if($exception -ne $null){
		$iLog.Info($object, $exception)
	}
	
	$iLog.Info($object)
}