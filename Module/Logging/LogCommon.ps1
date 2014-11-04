function GetDefaultLogThreshold {
    $vp = (Get-Variable -Name VerbosePreference -Scope Script -ValueOnly -ErrorAction SilentlyContinue)
    $dp = (Get-Variable -Name DebugPreference -Scope Script -ValueOnly -ErrorAction SilentlyContinue)
    if($vp -ne "SilentlyContinue" -or $dp -ne "SilentlyContinue"){
        return [log4net.Core.Level]::Debug
    }

    return [log4net.Core.Level]::Info
}