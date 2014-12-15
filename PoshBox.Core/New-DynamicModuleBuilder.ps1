function New-DynamicModuleBuilder {
    # .SYNOPSIS
    #   Creates a new assembly and a dynamic module within the current AppDomain.
    # .DESCRIPTION
    #   Prepares a System.Reflection.Emit.ModuleBuilder class to allow construction of dynamic types.
    #   The ModuleBuilder is created to allow the creation of multiple types under a single assembly.
    # .PARAMETER AssemblyName
    #   A name for the in-memory assembly.
    # .INPUTS
    #   System.Reflection.AssemblyName
    # .OUTPUTS
    #   System.Reflection.Emit.ModuleBuilder
    # .EXAMPLE
    #   New-DynamicModuleBuilder "Example.Assembly"

    [CmdLetBinding()]
    [OutputType([System.Reflection.Emit.ModuleBuilder])]
    param(
        [Reflection.AssemblyName]$AssemblyName
    )

    Guard-ArgumentNotNull 'AssemblyName' $AssemblyName

    $appDomain = [AppDomain]::CurrentDomain

    # Multiple assemblies of the same name can exist. This check aborts if the assembly name exists on the assumption
    # that this is undesirable.
    $assemblyRegEx = '^{0},' -f ($AssemblyName.Name -replace '\.', '\.')
    $existingAssembly = $false
    foreach($assembly in $AppDomain.GetAssemblies()) {
        if($assembly.IsDynamic -and $assembly.Name -match $assemblyRegEx) {
            throw (new-object System.InvalidOperationException(("Dynamic assembly {0} already exists." -f $AssemblyName.Name)))
        }
    }

    # Create a dynamic assembly in the current AppDomain
    $AssemblyBuilder = $AppDomain.DefineDynamicAssembly(
        $AssemblyName,
        [Reflection.Emit.AssemblyBuilderAccess]::Run
    )

    return $AssemblyBuilder.DefineDynamicModule($AssemblyName.Name)
}