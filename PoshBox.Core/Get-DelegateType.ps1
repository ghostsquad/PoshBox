#http://www.exploit-monday.com/2012/05/accessing-native-windows-api-in.html
# Create a delegate type with CalcFunction function signature
# $CalcFunctionDelegateType = Get-DelegateType @([Int32], [Int32]) ([Int32])

# This scriptblock will serve as the callback function
# $Action = {
#   # Define params in place of $args[0] and $args[1]
#   # Note: These parameters need to match the params
#   #of EnumChildProc.
#   Param (
#       [Int32] $a,
#       [Int32] $b
#   )
#   return ($a + $b)
# }

# Cast the scriptblock as the CalcFunctionDelegateType delegate created earlier
# $CalcFunction = $Action -as $MyDelegateType
function Get-DelegateType
{
    [OutputType([Type])]
    Param
    (
        [Parameter( Position = 0)]
        [Type[]]$Parameters = (New-Object Type[](0)),

        [Parameter( Position = 1 )]
        [Type]$ReturnType = [Void]
    )

    Guard-ArgumentNotNull 'Parameters' $Parameters
    Guard-ArgumentNotNull 'ReturnType' $ReturnType

    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('ReflectedDelegate')
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemoryModule', $false)
    $TypeBuilder = $ModuleBuilder.DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $ConstructorBuilder = $TypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $Parameters)
    $ConstructorBuilder.SetImplementationFlags('Runtime, Managed')
    $MethodBuilder = $TypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $ReturnType, $Parameters)
    $MethodBuilder.SetImplementationFlags('Runtime, Managed')

    return $TypeBuilder.CreateType()
}