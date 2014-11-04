function Get-Logger {
    [cmdletbinding()]
    param(
        [string]$loggerName,
        [int]$callStackStart = 1
    )

    function TryGetLogger([log4net.ILog[]]$loggers, [string]$loggerName, [ref]$logger){
        foreach($ilog in $loggers){
            if($ilog.Logger.Name -eq $loggerName){
                $logger.Value = $ilog
                return $true
            }
        }
        return $false
    }

    function TryGetValidLoggerName {
        param(
            [System.Management.Automation.CallStackFrame]$callStackFrame,
            [ref]$loggerCandidateName
        )
        if([string]::IsNullOrWhiteSpace($callStackFrame.ScriptName)){
            Write-Debug "scriptname is empty!"
            return $false
        }
        $loggerCandidateName.Value = $([System.IO.Path]::GetFileNameWithoutExtension($callStackFrame.ScriptName))
        return $true
    }

    [log4net.ILog]$logger = $null

    # if a custom log name was provided, use the defined logger
    if(-not [string]::IsNullOrWhiteSpace($loggerName)){
        $logger = [log4net.LogManager]::GetLogger($loggerName)
    }

    # try to get an existing logger using the call stack
    if($logger -eq $null) {
  
        $loggers = [log4net.LogManager]::GetCurrentLoggers()

        if($loggers.Count -gt 0){
            Write-Debug ("Current Loggers: " + $([string]::Join(", ", ($loggers | %{$_.Logger.Name}))))
        } else{
            Write-Debug "No loggers registered."
        }

        $callStack = @(Get-PSCallStack)

        if($loggers.count -gt 0){
            for($callStackFrameIndex = $callStackStart; $callStackFrameIndex -lt $callStack.Count; $callStackFrameIndex++){
                [string]$loggerCandidateName = $null
                $tryGetValidLoggerNameResult = TryGetValidLoggerName $callStack[$callStackFrameIndex] ([ref]$loggerCandidateName)
                if($tryGetValidLoggerNameResult){
                    $tryGetLoggerResult = TryGetLogger $loggers $loggerCandidateName ([ref]$logger)
                    if($tryGetLoggerResult){
                        Write-Debug "Found Logger: $loggerCandidateName"
                    }
                }
            }
        }
    }

    # create a new logger if possible
    if($logger -eq $null) {
        [string]$loggerCandidateName = $null
        $result = TryGetValidLoggerName $callStack[$callStackStart] ([ref]$loggerCandidateName)
        if($result){
            Write-Debug "Using Logger: $loggerCandidateName"
            $logger = [log4net.LogManager]::GetLogger($loggerCandidateName)
        } else {
            Write-Debug "Can't find logger"
            Write-Debug ($callStack | select Command, Location, ScriptName, ScriptLineNumber, Position, FunctionName | fl -Force | Out-String)
            $logger = [log4net.LogManager]::GetLogger([Guid]::NewGuid().ToString())
        }
    }

    if($logger.Logger.Level -eq $null) {
        $logger.Logger.Level = GetDefaultLogThreshold
    }

    return $logger
}
