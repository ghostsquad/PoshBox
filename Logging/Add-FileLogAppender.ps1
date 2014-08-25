function Add-FileLogAppender{
    [CmdletBinding()]
    param (
        [log4net.Core.Level]$logLevelThreshold = [log4net.Core.Level]::Info,
        [string]$logPattern = "%date{ISO8601} [%thread] %-5level [%ndc] - %message%newline",
        [string]$logPath = (Join-Path $PSScriptRoot "logs"),
        [string]$logFile = ((Split-Path $MyInvocation.PSCommandPath -Leaf) `
                + ([DateTime]::UtcNow.ToString("s") -replace ":","-") + "Z.log"),
        [parameter(ValueFromPipeline=$true)]
        [log4net.ILog]$log
    )

    process {
        Write-Debug "logLevelThreshold: $($logLevelThreshold.ToString())"
        Write-Debug "logPattern: $logPattern"
        Write-Debug "logPath: $logPath"
        Write-Debug "logFile: $logFile"

        if($log -eq $null){
            $log = Get-Logger -callStackStart 2
        }

        $logger = $log.Logger

        $patternLayout = new-object log4net.Layout.PatternLayout($logPattern)
        $fullLogFile = (Join-Path $logPath $logFile)
        $fileAppender = New-Object log4net.Appender.FileAppender($patternLayout, $fullLogFile, $true)
        $fileAppender.Threshold = $logLevelThreshold
        $fileAppender.LockingModel = new-object log4net.Appender.FileAppender+MinimalLock
        $fileAppender.ActivateOptions()

        $logger.AddAppender($fileAppender)
    }
}

function AddConsoleLogAppender {
    param(
        [log4net.Core.Level]$logLevelThreshold = [log4net.Core.Level]::Debug,
        [string]$logPattern = "%date{ISO8601} [%thread] %-5level [%ndc] - %message%newline"
    )

    function AddMapping {
        [cmdletbinding()]
        param(
            [Parameter(ValueFromPipeline=$True)]
            $appender,
            [log4net.Core.Level]$level,
            [string]$fore,
            [int]$foreFlags,
            [string]$back,
            [int]$backFlags
        )

        $mapping = New-Object log4net.Appender.ColoredConsoleAppender+LevelColors
        $mapping.Level = $level
        if(-not [string]::IsNullOrEmpty($fore)){
            $mapping.ForeColor = [Enum]::Parse([log4net.Appender.ColoredConsoleAppender+Colors], $fore, $true)
        }
        else {
            $mapping.ForeColor = $foreFlags
        }

        if(-not [string]::IsNullOrEmpty($back)){
            $mapping.BackColor = [Enum]::Parse([log4net.Appender.ColoredConsoleAppender+Colors], $back, $true)
        }
        else {
            $mapping.BackColor = $backFlags
        }

        $null = $appender.AddMapping($mapping)
    }

    $patternLayout = new-object log4net.Layout.PatternLayout($logPattern)
    $consoleAppender = new-object log4net.Appender.ColoredConsoleAppender($patternLayout)

    # determines the log statements that show up
    $consoleAppender.Threshold = $logLevelThreshold

    $blackColorFlags = [log4net.Appender.ColoredConsoleAppender+Colors]::Blue `
        -band [log4net.Appender.ColoredConsoleAppender+Colors]::Green `
        -band [log4net.Appender.ColoredConsoleAppender+Colors]::Red
    $lightYellowFlags = [log4net.Appender.ColoredConsoleAppender+Colors]::Yellow `
        -band [log4net.Appender.ColoredConsoleAppender+Colors]::White

    $consoleAppender | AddMapping -level ([log4net.Core.Level]::Debug) -foreFlags $lightYellowFlags `
        -backFlags $blackColorFlags
    $consoleAppender | AddMapping -level ([log4net.Core.Level]::Info)  -fore "White" `
        -backFlags $blackColorFlags
    $consoleAppender | AddMapping -level ([log4net.Core.Level]::Warn)  -fore "Yellow" `
        -backFlags $blackColorFlags
    $consoleAppender | AddMapping -level ([log4net.Core.Level]::Error) -fore "Red" `
        -backFlags $blackColorFlags
    $consoleAppender | AddMapping -level ([log4net.Core.Level]::Fatal) -fore "Red" `
        -backFlags $blackColorFlags

    $consoleAppender.ActivateOptions()

    $repository = [log4net.LogManager]::GetRepository() -as [log4net.Repository.Hierarchy.Hierarchy]
    $repository.Root.Level = $logLevelThreshold
    $repository.Configured = $true;
    $repository.Root.AddAppender($consoleAppender)
}
