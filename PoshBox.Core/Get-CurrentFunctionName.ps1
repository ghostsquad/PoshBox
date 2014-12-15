function Get-CurrentFunctionName {
    return (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name;
}
