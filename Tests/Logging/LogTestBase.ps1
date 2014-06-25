function WithoutAddingAppender {
	param(		
		[scriptblock]$action,		
		[log4net.ILog]$logger
	)
	Context 'Without adding appender' {
		$logPath = (Convert-Path "TestDrive:\")
		
		It 'does not write to a file' {
			Log-Info "test info"
			
			if(Test-Path $logPath){
				@(gci $logPath).Count | Should Be 0
			}
			
			$possiblePath = (Join-Path $here "logs")
			Test-Path $possiblePath | Should Be $false
			
			@(gci $here -Include *.log).Count | Should Be 0
		}			
	}
}

function WithAddedFileAppender {
	param(
		[string]$logType,
		[string]$expectedMessage,
		[scriptblock]$action,
		[log4net.ILog]$logger
	)
	Context 'With added file appender' {
		$logPath = (Convert-Path "TestDrive:\")		
		
		$logFileName = [System.IO.Path]::GetFileNameWithoutExtension($testFileName) + ".log"
		Add-FileLogAppender -log $logger -logPath $logPath -logFile ($logFileName)
	
		It 'uses filename and path provided' {			
			$action.Invoke()
			Test-Path (Join-Path $logPath $logFileName)	| Should Be $true			
		}
		
		It 'log line contains the logtype and message' {						
			$logContents = @(gci $logPath | Select -First 1 | %{gc $_.fullname})
			$logContentCountBefore = $logContents.Count
			$action.Invoke()			
			$logContents = @(gci $logPath | Select -First 1 | %{gc $_.fullname})
			$expectedCount = ($logContentCountBefore + 1)
			$logContents.Count | Should Be $expectedCount
			$logLine = $logContents[$expectedCount - 1]
			$logLine -like "*$logType*" | Should Be $true
			$logLine -like "*$expectedMessage*" | Should Be $true
		}
	}
}