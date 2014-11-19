$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

Describe "New-PSClass" {
    Context "GivenStaticMethod" {
        It "runs provided script block" {
            $testClass = New-PSClass "TestClass" {
                method "testMethod" -static {
                    return "expected"
                }
            }
            $testClass.testMethod() | Should Be "expected"
        }
    }

    Context "GivenBaseClass" {
        BeforeEach {
            $testClass = New-PSClass "TestClass" {
                method "testMethodNoParams" { return "base" }
                note "foo" "base"
            }
        }

        It "can override method with empty params" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass {
                method -override "testMethodNoParams" { return "expected" }
            }

            $newDerived = $derivedClass.New()
            $newDerived.testMethodNoParams() | Should Be "expected"
        }

        It "can call non overridden base method" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass {}
            $newDerived = $derivedClass.New()
            $newDerived.testMethodNoParams() | Should Be "base"
        }

        It "can call non overridden base note" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass {}
            $newDerived = $derivedClass.New()
            $newDerived.foo | Should Be "base"
        }
    }

    Context "Construction - Rainy" {
        It "cannot call private notes from the outside" {
            $testClass = New-PSClass TestClass {
                note -private "foo"
            }

            $actual = $testClass.New()
            { $actual.foo } | Should Throw
        }

        It "Throws when attempting to add multiple static methods with same name" {
            { New-PSClass TestClass {
                method "testMethod" -static {}
                method "testMethod" -static {}
              }
            } | Should Throw
        }

        It "Throws when attempting to add multiple methods with same name" {
            { New-PSClass TestClass {
                method "testMethod" {}
                method "testMethod" {}
              }
            } | Should Throw
        }

        It "Throws when attempting to add multiple properties with same name" {
            { New-PSClass TestClass {
                property "testProp" {}
                property "testProp" {}
              }
            } | Should Throw
        }

        It "Throws when attempting to add multiple notes with same name" {
            { New-PSClass TestClass {
                note "testNote"
                note "testNote"
              }
            } | Should Throw
        }

        It "Throws when attempting to override a method if method does not exist" {
            $testClass = New-PSClass TestClass {}
            { $derivedClass = New-PSClass "derived" -inherit $testClass {
                method -override "doesnotexist" {}
              }
            } | Should Throw
        }

        It "Throws when attempting to override a method if params are different" {
            $testClass = New-PSClass TestClass {
                method "testMethod" {}
            }
            { $derivedClass = New-PSClass "derived" -inherit $testClass {
                method -override "testMethod" {param($a)}
              }
            } | Should Throw
        }

        It "Throws when attempting to override a property if set is defined in base and not in derived" {
            $testClass = New-PSClass TestClass {
                property "testProp" {} -Set {}
            }
            { $derivedClass = New-PSClass "derived" -inherit $testClass {
                property -override "testProp" {param($a)}
              }
            } | Should Throw
        }

        It "Throws when attempting to define a note that already exists" {
            $testClass = New-PSClass TestClass {
                note "testNote" "base"
            }
            { $derivedClass = New-PSClass "derived" -inherit $testClass {
                note "testNote" "derived"
              }
            } | Should Throw
        }
    }
}