function New-Closure {
#.SYNOPSIS
#  A more fine grained approach to capturing variables than GetNewClosure
#.EXAMPLE
#  $acc = New-Closure @{t = 0} {param($v = 1) $t += $v; $t} ; & $acc 10 ; & $acc
#  10
#  11
	[OutputType([scriptblock])]
	[CmdletBinding()]
	param(
		[System.Collections.IDictionary]$VariableDictionary,
		[scriptblock]$ScriptBlock
	)

    Guard-ArgumentNotNullOrEmpty 'VariableDictionary' $VariableDictionary
    Guard-ArgumentNotNull 'ScriptBlock' $ScriptBlock

	$private:moduleInfo = New-Object System.Management.Automation.PSModuleInfo $true
    $ScriptBlock = $moduleInfo.NewBoundScriptBlock($ScriptBlock)

    foreach ($varTuple in $VariableDictionary.GetEnumerator()) {
        $varSetScriptBlock = { Set-Variable -Name $args[0] -Value $args[1] -Scope script -Option AllScope }
        [Void]$moduleInfo.Invoke($varSetScriptBlock, $varTuple.Key, $varTuple.Value)
    }

    return $ScriptBlock
}