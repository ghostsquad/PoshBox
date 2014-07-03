function Get-FunctionName {
    (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name;
}
