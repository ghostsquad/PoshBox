$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

if (-not ([System.Management.Automation.PSTypeName]'TestDisposable').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
        using System;

        public class TestDisposable : IDisposable {
            public bool Disposed { get; private set; }

            public void Dispose() {
                this.Disposed = true;
            }
        }
"@
}

Describe 'Invoke-Using' {
    Context 'IDisposable' {
        It 'Disposes of an IDisposable' {
            $IDisposableThing = (New-Object TestDisposable)
            Invoke-Using ($IDisposableThing = (New-Object TestDisposable)) {}

            $IDisposableThing.Disposed | Should Be $true
        }
    }

    Context 'Psuedo Disposable' {
        It 'Calls Dispose method of an psobject that has it' {
            $IDisposableThing = New-PSObject
            Attach-PSNote $IDisposableThing 'Disposed' $false
            Attach-PSScriptMethod $IDisposableThing 'Dispose' {
                $this.Disposed = $true
            }

            Invoke-Using $IDisposableThing {}

            $IDisposableThing.Disposed | Should Be $true
        }
    }

    Context 'Ignores the rest' {
        It 'does not throw for non-IDisposable' {
            $NonDisposable = New-Object System.Object

            Invoke-Using ($NonDisposable) {}
        }

        It 'does not throw for psobject without Dispose' {
            $NonDisposable = New-PSObject

            Invoke-Using ($NonDisposable) {}
        }
    }
}
