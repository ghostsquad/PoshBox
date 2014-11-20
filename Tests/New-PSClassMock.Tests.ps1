$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestCommon.ps1"

Describe "New-PSClassMock" {
    Context "Sunny Day" {
        BeforeEach {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    throw "not implemented"
                }
            }
        }

        It "Given Basic Mock, mocked class methods are not called" {
            $mock = New-PSClassMock $testClass
            { $mock.foo() } | Should Not Throw
        }

        It "Calls mocked method" {
            $mock = New-PSClassMock $testClass {
                method "foo" {
                    return "bar"
                }
            }
            $mock.foo() | Should Be "bar"
        }

        It "Given -Strict expects methods to have an expectation" {
            $mock = New-PSClassMock $testClass -Strict
            $errorRecord = $null
            try {
                $mock.foo()
            } catch {
                $errorRecord = $_
            }

            $errorRecord.Exception.InnerException.InnerException.GetType() | Should Be ([PSMockException])
        }
    }
}