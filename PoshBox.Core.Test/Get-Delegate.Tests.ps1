$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe 'Get-Delegate Static Methods' {
    Context '[string]::format | get-delegate -delegate ''func[string,object,string]''' {
        It 'formats a string' {
            $delegate = [string]::format | Get-Delegate -Delegate 'func[string,object,string]'
            $actualResult = $delegate.invoke("hello, {0}", "world")
            $actualResult | Should Be "hello, world"
        }
    }

    Context '[console]::writeline | get-delegate -delegate ''action[int]''' {
        It 'is [action[int]] type' {
            $delegate = [console]::writeline | Get-Delegate -Delegate 'action[int]'
            $delegate -is [action[int]] | Should Be $true
        }
    }

    Context '[string]::format | get-delegate string,string' {
        It 'can accept types as input' {
            $delegate = [string]::format | Get-Delegate string,string
                $delegate.invoke("hello, {0}", "world") | Should Be "hello, world"
        }
    }

    Context '[console]::beep | Get-Delegate @()' {
        It 'can infer delegate type from input when provided empty param array' {
            $delegate = [console]::beep | Get-Delegate @()
            $delegate -is [action] | Should Be $true
        }
    }

    Context '[console]::beep | Get-Delegate -DelegateType action' {
        It 'can be told the delegate type to return' {
            $delegate = [console]::beep | Get-Delegate -DelegateType action
            $delegate -is [action] | Should Be $true
        }
    }

    Context '[string]::IsNullOrEmpty | get-delegate # single overload' {
        It 'can infer delegate type when no delegate type provided' {
            $delegate = [string]::IsNullOrEmpty | get-delegate
            $delegate -is [func[string,bool]] | Should Be $true
        }
    }

    Context '[string]::IsNullOrEmpty | get-delegate string # single overload' {
        It 'can infer delegate type provided func in only' {
            $delegate = [string]::IsNullOrEmpty | get-delegate string
            $delegate -is [func[string,bool]] | Should Be $true
        }
    }
}

Describe 'Get-Delegate Instance Methods' {
    Context '$sb.Append | get-delegate string' {
        It 'can produce delegate from instance method' {
            $sb = new-object text.stringbuilder
            $delegate = $sb.Append | get-delegate string
            $delegate -is [System.Func[string,System.Text.StringBuilder]]
        }
    }

    Context '$sb.AppendFormat | get-delegate string, int, int' {
        It 'can produce delegate from instance method overload' {
            $sb = new-object text.stringbuilder
            $delegate = $sb.AppendFormat | get-delegate string, int, int
            $delegate -is [System.Func[string,object,object,System.Text.StringBuilder]]
        }
    }
}
