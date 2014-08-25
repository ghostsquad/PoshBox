$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

Add-Type -TypeDefinition @"
namespace Test
{
    public class Foo {
        public string THING { get; set; }
    }

    public interface IFoo {
        string thing { get; set; }
    }

    public interface INoParams {
        void DoStuff();
    }

    public class NoParams {
        public void DoStuff() {}
    }

    public interface IOneParam {
        void DoStuff(int value);
    }

    public class OneParam {
        public void DoStuff(int value){}
    }

    public interface ITwoParams {
        void DoStuff(int value, string secondvalue);
    }

    public class TwoParams {
        public void DoStuff(int value, string secondvalue){}
    }

    public interface INonVoid {
        int DoStuff(int value, string secondvalue);
    }

    public class NonVoid {
        public int DoStuff(int value, string secondvalue){return 1;}
    }
}
"@

function GetRandomInterfaceName {
    return ("I" + ([Guid]::NewGuid().ToString() -replace "-",""))
}

function GetThingPropertyPsObject {
    $inheritor = new-object PSObject
    $inheritor.PSAddMember("THING", ([string]"foo"))

    return $inheritor
}

function AssertInheritorNotNull {
    ($inheritor -as ($interfaceName -as [type])) | Should Not Be $null
}

Describe "New-Interface" {
    Context "Properties/NoteProperties" {
        # It "cast succeeds when property with name and type defined on both sides (different case)" {
            # $inheritor = GetThingPropertyPsObject
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.IFoo])

            # AssertInheritorNotNull
        # }

        It "cast succeeds when noteproperty with name and type defined on both sides (different case)" {
            $inheritor = GetThingPropertyPsObject
            $interfaceName = GetRandomInterfaceName

            New-Interface -Name $interfaceName -Definition ([PSCustomObject]@{"thing"=[string]})

            AssertInheritorNotNull
        }

        # It "cast succeeds when object has noteproperty and interface has property (different case)" {
            # $inheritor = GetThingPropertyPsObject
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.IFoo])

            # AssertInheritorNotNull
        # }

        # It "cast succeeds when object has property and interface has noteproperty (different case)" {
            # $inheritor = new-object Test.Foo
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -Definition ([PSCustomObject]@{"thing"=[string]})

            # AssertInheritorNotNull
        # }

        # It "cast fails when no matching name is found" {
            # $inheritor = GetThingPropertyPsObject
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -Definition ([PSCustomObject]@{"thing"=[string]})

            # ($inheritor -as ($interfaceName -as [type])) | Should Be $null
        # }

        # It "cast fails when type is different" {
            # $inheritor = GetThingPropertyPsObject
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -Definition ([PSCustomObject]@{"thing"=[string]})

            # ($inheritor -as ($interfaceName -as [type])) | Should Be $null
        # }
    }

    Context "Methods/ScriptMethods" {
        # It "cast succeeds when psobject compared to .net interface - 0 params" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("DOSTUFF",{},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.INoParams])

            # AssertInheritorNotNull
        # }

        It "cast succeeds when psobject compared to psobject definition - 0 params" {
            $inheritor = new-object PSObject
            $inheritor.PSAddMember("DOSTUFF",{param()},"ScriptMethod")
            $interfaceName = GetRandomInterfaceName

            $definition = (new-object PSCustomObject)
            $definition.PSAddMember("dostuff",{param()},"scriptmethod")

            New-Interface -Name $interfaceName -Definition $definition

            AssertInheritorNotNull
        }

        It "cast succeeds when psobject compared to psobject definition - missing param block" {
            $inheritor = new-object PSObject
            $inheritor.PSAddMember("DOSTUFF",{},"ScriptMethod")
            $interfaceName = GetRandomInterfaceName

            $definition = (new-object PSCustomObject)
            $definition.PSAddMember("dostuff",{},"scriptmethod")

            New-Interface -Name $interfaceName -Definition $definition

            AssertInheritorNotNull
        }

        # It "cast succeeds when psobject compared to .net interface - 1 param" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("DOSTUFF",{param([int]$a)},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.IOneParam])

            # AssertInheritorNotNull
        # }

        It "cast succeeds when psobject compared to psobject definition - 1 param" {
            $inheritor = new-object PSCustomObject
            $inheritor.PSAddMember("DOSTUFF",{param([int]$a)},"ScriptMethod")
            $interfaceName = GetRandomInterfaceName

            $definition = (new-object PSCustomObject)
            $definition.PSAddMember("dostuff",{param([int]$a)},"scriptmethod")

            New-Interface -Name $interfaceName -Definition $definition

            AssertInheritorNotNull
        }

        # It "cast succeeds when psobject compared to .net interface - 2 params" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("DOSTUFF",{param([int]$a,[string]$b)},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.ITwoParams])

            # AssertInheritorNotNull
        # }

        It "cast succeeds when psobject compared to psobject definition - 2 params" {
            $inheritor = new-object PSCustomObject
            $inheritor.PSAddMember("DOSTUFF",{param([int]$a,[string]$b)},"ScriptMethod")
            $interfaceName = GetRandomInterfaceName

            $definition = (new-object PSCustomObject)
            $definition.PSAddMember("dostuff",{param([int]$a, [string]$b)},"scriptmethod")

            New-Interface -Name $interfaceName -Definition $definition

            AssertInheritorNotNull
        }

        # It "cast fails when param count mismatch" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("DOSTUFF",{param([int]$a)},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.ITwoParams])

            # AssertInheritorNotNull
        # }

        # It "cast fails when param type order mismatch" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("DOSTUFF",{param([string]$a, [int]$b)},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -InterfaceTypes ([Test.ITwoParams])

            # AssertInheritorNotNull
        # }

        # It "can compose multiple psobject definitions" {
            # $inheritor = new-object PSObject
            # $inheritor.PSAddMember("walk",{},"ScriptMethod")
            # $inheritor.PSAddMember("quack",{},"ScriptMethod")
            # $inheritor.PSAddMember("fly",{},"ScriptMethod")
            # $interfaceName = GetRandomInterfaceName

            # New-Interface -Name $interfaceName -Definition ([PSCustomObject]@{walk=[action]}) `
                # -Implements ([PSCustomObject]@{quack=[action]}),([PSCustomObject]@{fly=[action]})

            # AssertInheritorNotNull
        # }
    }
}