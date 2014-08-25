#http://csharpening.net/?p=1462
function New-Interface
{
    param(
        [String]$Name = $(throw (new-object ArgumentNullException("Name"))),
        [PSObject]$Definition = (new-object PSCustomObject)
    )

    $InterfaceType = Add-Type -TypeDefinition "
        public class $Name : System.Management.Automation.PSObject {
            public $Name(System.Management.Automation.PSObject obj) : base(obj) {
                PoshBox.PowershellCaster.CheckCompatible(obj, Definition, this.GetType());
            }
            public static System.Management.Automation.PSObject Definition {get;set;}
        }
    " -PassThru -ReferencedAssemblies (Join-Path $global:PoshBoxModuleRoot "PoshBox.dll")

    ($Name -as [Type])::Definition = $Definition

    $acceleratorsType = [PSCustomObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
    $acceleratorsType::Add($Name, $InterfaceType);
}