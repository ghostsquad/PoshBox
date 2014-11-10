function Get-ScriptBlockParams {
    param (
        [scriptblock]$scriptblock
    )

    $parseErrors = $null
    $tokens = [System.Management.Automation.PSParser]::Tokenize($scriptblock, [ref] $parseErrors)

    if ($parseErrors.Count -gt 0) {
        throw "The scriptblock contains syntax errors."
    }

    $paramsList = New-Object System.Collections.ArrayList

    if($tokens[0].Type -eq "keyword" -and $tokens[0].Content -eq "param") {
        $groupLevel = 1

        :outer
        for ($i = 2; $i -lt $tokens.Count; $i++) {
            switch ($tokens[$i].Type) {
                ([System.Management.Automation.PSTokenType]::GroupStart) {
                    $groupLevel++
                    break
                }

                ([System.Management.Automation.PSTokenType]::Variable) {
                    if($groupLevel -eq 1) {
                        $prevIndex = $i - 1
                        $type = ([object])
                        if($prevIndex -ge 0 `
                            -and $tokens[$prevIndex].Type -eq [System.Management.Automation.PSTokenType]::Type) {

                            $tokenContent = $tokens[$prevIndex].Content
                            # strip the brackets from the type. eg. [string] becomes string
                            $type = $tokenContent.Substring(1, $tokenContent.Length - 2) -as [Type]
                        }
                        $kvp = New-GenericObject 'System.Collections.Generic.KeyValuePair' @('string', 'type') @($tokens[$i].Content, $type)
                        $null = $paramsList.Add($kvp)
                    }
                    break
                }

                ([System.Management.Automation.PSTokenType]::GroupEnd) {
                    $groupLevel--

                    if ($groupLevel -le 0) {
                        break :outer
                    }

                    break
                }
            }
        }
    }

    return ,$paramsList
}