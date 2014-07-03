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
        $fullLogFileNameAndPath = Join-Path $logPath $logFileName
        Add-FileLogAppender -log $logger -logPath $logPath -logFile ($logFileName) -logLevelThreshold $([log4net.Core.Level]::Debug)

        It 'uses filename and path provided' {
            $action.Invoke()
            Test-Path (Join-Path $logPath $logFileName)    | Should Be $true
        }

        It 'log line contains the logtype and message' {
            $logContents = gc $fullLogFileNameAndPath
            $logContentCountBefore = $logContents.Count
            $action.Invoke()
            $logContents = gc $fullLogFileNameAndPath
            Write-Debug "log: $fullLogFileNameAndPath"
            $expectedCount = ($logContentCountBefore + 1)
            $logContents.Count | Should Be $expectedCount
            $logLine = $logContents[$expectedCount - 1]
            $logLine -like "*$logType*" | Should Be $true
            $logLine -like "*$expectedMessage*" | Should Be $true
        }
    }
}
