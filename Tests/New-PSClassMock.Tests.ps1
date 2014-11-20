$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestCommon.ps1"

Describe "New-PSClassMock" {
    BeforeEach {
        $testClass = New-PSClass "testClass" {
            method "foo" {
                throw "not implemented"
            }
        }
    }

    Context "Creation" {
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

        It "Throws if mocked method parameters don't match" {
            { $mock = New-PSClassMock $testClass {
                method "foo" {
                    param($a)
                }
              } } | Should Throw
        }
    }

    Context "Usage - Mocking Methods" {
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
    }

    Context "Usage - Verify Method Parameters" {
        It "Given VerifyParams, throws when parameter is not equivalent" {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" -VerifyParams @(1)
            }

            { $mock.foo(2) } | Should Throw
        }

        It "Given VerifyParams, does not throw when parameter is equivalent" {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" -VerifyParams @(1)
            }

            { $mock.foo(1) } | Should Not Throw
        }

        $verifyParamsInputDiff = @(
            @{a = 1; b = 2},
            @{a = 2; b = 1},
            @{a = 1; b = $null},
            @{a = 1; b = "I'm different"}
        )
        It "Given VerifyParams and multiple params, throws if any param is not equivalent to expectations" `
            -TestCases $verifyParamsInputDiff {

            param( $a, $b )

            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a, $b)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" -VerifyParams @(1,1)
            }

            { $mock.foo($a,$b) } | Should Throw
        }

        It "Given VerifyParams and multiple params, does not throw only if all params are equivalent to expectations" {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a, $b)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" -VerifyParams @(1,1)
            }

            { $mock.foo(1,1) } | Should Throw
        }
    }
}