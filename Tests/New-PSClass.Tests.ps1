$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

function IAmOutside {
    return "I Am Outside"
}

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

    BeforeEach {
        $testClass = New-PSClass "TestClass" {
            method "testMethodNoParams" { return "base" }
            note "foo" "base"
        }
    }

    Context "GivenBaseClass" {
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

        It "can use complex objects in base constructor" {
            $testClass = New-PSClass "test" {
                note "_foo" "default"
                note "_bar" "default"
                constructor {
                    param (
                        [psobject]$a,
                        [psobject]$b
                    )
                    $this._foo = $a
                    $this._bar = $b
                }
            }

            $derivedClass = New-PSClass "derived" -inherit $testClass {}

            $myAObject = New-PSObject @{
                someProp = (New-PSObject @{
                    anotherProp = "foo"
                })
            }

            $myBObject = New-PSObject @{
                prop1 = (New-PSObject @{
                    prop2 = "bar"
                })
            }

            $instance = $derivedClass.New($myAObject, $myBObject)
            $instance._foo.someProp.anotherProp | Should Be $myAObject.someProp.anotherProp
            $instance._bar.prop1.prop2 | Should Be $myBObject.prop1.prop2
        }
    }

    Context "Constructor - Sunny" {
        It "can access and set defined notes" {
            $testClass = New-PSClass "testClass" {
                constructor {
                    $this._foo = "set by constructor"
                }

                note "_foo" "default"
                property "foo" { return $this._foo }
            }

            $testObj = $testClass.New()
            $testObj.foo | Should Be "set by constructor"
        }

        It "calls base constructor when available" {
            $testBaseClass = New-PSClass "testBase" {
                note "_foo" "default"
                constructor {
                    $this._foo = $args[0]
                }
            }

            $derivedClass = New-PSClass "derived" -inherit $testBaseClass {

            }

            $expectedValue = "derived"

            $derived = $derivedClass.New($expectedValue)
            $derived._foo | Should Be $expectedValue
        }

        It "calls base constructor first then derived constructor with same args" {
            $testBaseClass = New-PSClass "testBase" {
                note "_foo" "default"
                note "_basenote"
                constructor {
                    $this._basenote = "base"
                }
            }

            $derivedClass = New-PSClass "derived" -inherit $testBaseClass {
                constructor {
                    $this._foo = "derived"
                }
            }

            $expectedValue = "derived"

            $derived = $derivedClass.New($expectedValue)
            $derived._foo | Should Be $expectedValue
            $derived._basenote | Should Be "base"
        }

        It "can use multiple constructor arguments" {
            $testClass = New-PSClass "test" {
                note "_foo" "default"
                note "_bar" "default"
                constructor {
                    param($a, $b)
                    $this._foo = $a
                    $this._bar = $b
                }
            }

            $expectedFoo = "expected foo"
            $expectedBar = "expected bar"

            $instance = $testClass.New($expectedFoo, $expectedBar)
            $instance._foo | Should Be $expectedFoo
            $instance._bar | Should Be $expectedBar
        }

        It "can use constructor args auto variable" {
            $testClass = New-PSClass "test" {
                note "_foo" "default"
                note "_bar" "default"
                constructor {
                    $this._foo = $args[0]
                    $this._bar = $args[1]
                }
            }

            $expectedFoo = "expected foo"
            $expectedBar = "expected bar"

            $instance = $testClass.New($expectedFoo, $expectedBar)
            $instance._foo | Should Be $expectedFoo
            $instance._bar | Should Be $expectedBar
        }

        It "can use complex objects in constructor" {
            $testClass = New-PSClass "test" {
                note "_foo" "default"
                note "_bar" "default"
                constructor {
                    param (
                        [psobject]$a,
                        [psobject]$b
                    )
                    $this._foo = $a
                    $this._bar = $b
                }
            }

            $myAObject = New-PSObject @{
                someProp = (New-PSObject @{
                    anotherProp = "foo"
                })
            }

            $myBObject = New-PSObject @{
                prop1 = (New-PSObject @{
                    prop2 = "bar"
                })
            }

            $instance = $testClass.New($myAObject, $myBObject)
            $instance._foo.someProp.anotherProp | Should Be $myAObject.someProp.anotherProp
            $instance._bar.prop1.prop2 | Should Be $myBObject.prop1.prop2
        }

        It "can use outside functions" {
            $testClass = New-PSClass "test" {
                method "foo" {
                    return (IAmOutside)
                }
            }

            $instance = $testClass.New()

            $instance.foo() | Should Be "I Am Outside"
        }
    }

    Context "Construction - Rainy" {
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