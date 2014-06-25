function Log-Warning {
	param(		
		[object]$object,
		[Exception]$exception
	)
	
	$iLog = [log4net.LogManager]::GetLogger([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PsCommandPath))
	
	if($exception -ne $null){
		$iLog.Warn($object, $exception)
	}
	
	$iLog.Warn($object)
}