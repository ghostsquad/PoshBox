$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestCommon.ps1"

Describe "New-PSClassMock" {
    Context "Creation" {
        BeforeEach {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    throw "not implemented"
                }
            }
        }
        It "Given -Strict expects methods to have an expectation" {
            $mock = New-PSClassMock $testClass -Strict

            $errorRecord = $null
            try {
                $mock.Object.foo()
            } catch {
                $errorRecord = $_
            }

            ($errorRecord -eq $null) | Should Be $false
            $errorRecord.Exception.GetBaseException().GetType() | Should Be ([PSMockException])
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
        BeforeEach {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    throw "not implemented"
                }
            }
        }
        It "Given Basic Mock, mocked class methods are not called" {
            $mock = New-PSClassMock $testClass
            { $mock.Object.foo() } | Should Not Throw
        }

        It "Calls mocked method" {
            $mock = New-PSClassMock $testClass {
                method "foo" {
                    return "bar"
                }
            }

            $mockedObject = $mock.Object

            $mock.Object.foo() | Should Be "bar"
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
                method "foo" {
                    param($a)
                }
            }

            [Void]$mock.Object.foo(1)

            { $mock.Verify("foo", 2) } | Should Throw
        }

        It "Given VerifyParams, does not throw when parameter is equivalent" {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" {
                    param($a)
                }
            }

            [void]$mock.Object.foo(1)

            { $mock.Verify('foo', 1) } | Should Not Throw
        }

        $verifyParamsInputDiff = @(
            @{a = 1; b = 2},
            @{a = 2; b = 1},
            @{a = 1; b = $null},
            @{a = 1; b = "I'm different"},
            @{a = {param($n) $n -eq 2}; b = 1}
            @{a = {param($n) $n -eq 1}; b = {param($n) $n -eq 2};}
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
                method "foo" {
                    param($a, $b)
                }
            }

            [Void]$mock.Object.foo(1,1)

            { $mock.Verify('foo', @($a, $b)) } | Should Throw
        }

        It "Given VerifyParams and multiple params, does not throw only if all params are equivalent to expectations" {
            $testClass = New-PSClass "testClass" {
                method "foo" {
                    param($a, $b)
                }
            }

            $mock = New-PSClassMock $testClass {
                method "foo" {
                    param($a, $b)
                }
            }

            [Void]$mock.Object.foo(1,1)

            { $mock.Verify('foo', @(1,1)) } | Should Not Throw
        }
    }
}