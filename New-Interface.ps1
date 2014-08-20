#http://csharpening.net/?p=1462
function New-Interface
{
    param(
    [String]$Name,
    [PSCustomObject]$Definition
    )

    $InterfaceType = Add-Type -TypeDefinition "
        public class $Name : System.Management.Automation.PSObject
        {
            public $Name(System.Management.Automation.PSObject obj) : base(obj)
            {
                if (Definition == null) throw new System.NullReferenceException(`"Defintion is null!`");
                if (obj == null) throw new System.ArgumentNullException(`"Obj was null!`");

                foreach(var interfaceMember in Definition.Members)
                {
                    if (interfaceMember == null) continue;

                    bool found = false;
                    foreach(var inheritorMember in obj.Members)
                    {
                        if (inheritorMember == null) continue;

                        if(inheritorMember.IsInstance &&
                           inheritorMember.MemberType == interfaceMember.MemberType &&
                           inheritorMember.Name == interfaceMember.Name)
                        {
                            found = true;
                            break;
                        }
                    }

                    if (!found)
                    {
                        throw new System.InvalidCastException(`"The object is not of type $Name. Missing member `" + interfaceMember.Name);
                    }
                }
            }

            public static System.Management.Automation.PSObject Definition {get;set;}
        }
    " -PassThru
    $acceleratorsType = [PSCustomObject].Assembly.gettype("System.Management.Automation.TypeAccelerators")
    $acceleratorsType::Add($Name, $InterfaceType);
    $InterfaceType::Definition = $Definition
}