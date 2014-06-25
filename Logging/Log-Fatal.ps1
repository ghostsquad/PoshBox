function Log-Fatal {
	param(
		[object]$object,
		[Exception]$exception
	)
	
	$iLog = [log4net.LogManager]::GetLogger([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.PsCommandPath))
	
	if($exception -ne $null)
	{
		$iLog.Fatal($object, $exception)
	}
	
	$iLog.Fatal($object)
}