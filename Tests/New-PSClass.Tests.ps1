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

        It "can call non overridden base method" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass {}
            $newDerived = $derivedClass.New()
            $newDerived.testMethodNoParams() | Should Be "base"
        }

        It "can override method with empty params" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass {
                method -override "testMethodNoParams" { return "expected" }
            }

            $newDerived = $derivedClass.New()
            $newDerived.testMethodNoParams() | Should Be "expected"
        }

        It "can call non overridden base note" {
            $derivedClass = New-PSClass "derivedClass" -inherit $testClass
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
            { $derivedClass = NewPSClass -inherit $testClass {
                method -override "doesnotexist" {}
              }
            } | Should Throw
        }

        It "Throws when attempting to override a method if params are different" {
            $testClass = New-PSClass TestClass {
                method "testMethod" {}
            }
            { $derivedClass = NewPSClass -inherit $testClass {
                method -override "testMethod" {param($a)}
              }
            } | Should Throw
        }

        It "Throws when attempting to override a property if set is defined in base and not in derived" {
            $testClass = New-PSClass TestClass {
                property "testProp" {} -Set {}
            }
            { $derivedClass = NewPSClass -inherit $testClass {
                property -override "testProp" {param($a)}
              }
            } | Should Throw
        }

        It "Throws when attempting to define a note that already exists" {
            $testClass = New-PSClass TestClass {
                note "testNote" "base"
            }
            { $derivedClass = NewPSClass -inherit $testClass {
                note "testNote" "derived"
              }
            } | Should Throw
        }
    }

    Context "GivenAnObjectWithMethods_WhenDeserializing" {
        $testClass = New-PSClass TestObject {
            note -private myVariable 10
            method getVariable {
                return $private.myVariable
            }
        }
        $toSerialize = $testClass.New();

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

            It "ItShouldStillHaveMethods" {
            $deserialized.getVariable().should.be(10)
        }
    }

    Context "GivenAnObjectWithPublicNotes_AndANonDefaultValue_WhenDeserializing" {
        $testClass = New-PSClass TestObject {
            note myVariable 10
        }
        $toSerialize = $testClass.New();
        $toSerialize.myVariable = 8;

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

        It "ItShouldStillHaveMethods" {
            $deserialized.myVariable.should.be(8)
        }
    }

    Context "GivenAnObjectWithStaticNotes_AndANonDefaultValue_WhenDeserializing" {
        $testClass = New-PSClass TestObject {
            note -static myVariable 10
        }
        $toSerialize = $testClass.New();
        $toSerialize.Class.myVariable = 8;

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

        It "ItShouldStillHaveMethods" {
            $deserialized.Class.myVariable.should.be(8)
        }
    }

    Context "GivenAnObjectWithAConstructor_WhenDeserializing" {
        $testClass = New-PSClass TestObject {
            note executedTimes 0
            constructor {
                $this.executedTimes++;
            }
        }
        $toSerialize = $testClass.New();

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)

        It "ItShouldDeserializeWithoutExecuting" {
            $deserialized.executedTimes.should.be(1)
        }
    }

    Context "GivenAnObjectWithADifferentNameToTestObject_AndPrivateNotes_WhenDeserializing" {
        $testClass = New-PSClass AnotherTestObject {
            note -private executedTimes 0
        }
        $toSerialize = $testClass.New();

        Export-Clixml -InputObject $toSerialize -Path .\object.xml

        It "ItShouldDeserializeWithoutErroring" {
            $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
        }
    }

    Context "GivenAnObjectWithAPropertyWhichIsAPSObject_AndTheBackingFieldIsUpdatedAfterDeserializing_WhenDeserializing" {
        $referencedObject = New-PSClass ReferencedObject {
            note -private myVariable 0
            property MyVariable { $private.myVariable }
            method SetVariable {
                param($val)
                $private.myVariable = $val
            }
        }

        $testClass = New-PSClass TestObject {
            constructor {
                param($refObject)
                $private.referencedObject = $refObject
            }

            note -private referencedObject
            property ReferencedObject { $private.referencedObject }
        }

        $toSerialize = $testClass.New($referencedObject.New());

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
        $deserialized.ReferencedObject.SetVariable(10)

        It "ShouldReflectTheValue" {
            $deserialized.ReferencedObject.MyVariable.should.be(10)
        }
    }

    Context "GivenAnObjectWithACollectionOfObjects_WhenDeserializing" {
        $referencedObject = New-PSClass ReferencedObject {
            note -private myVariable 0
            property MyVariable { $private.myVariable }
            method SetVariable {
                param($val)
                $private.myVariable = $val
            }
        }

        $testClass = New-PSClass TestObject {
            constructor {
                param($refObjects)
                $private.referencedObjects = $refObjects
            }

            note -private referencedObjects @()
            property ReferencedObjects { $private.referencedObjects }
        }

        $toSerialize = $testClass.New(@($referencedObject.New(), $referencedObject.New()));

        Export-Clixml -InputObject $toSerialize -Path .\object.xml
        $deserialized = Deserialize-PSClass (Import-Clixml .\object.xml)
        $deserialized.ReferencedObjects[0].SetVariable(10)
        $deserialized.ReferencedObjects[1].SetVariable(20)

        It "TheObjectsInTheCollectionShouldBeDeserialized" {
            $deserialized.ReferencedObjects[0].MyVariable.should.be(10)
            $deserialized.ReferencedObjects[1].MyVariable.should.be(20)
        }
    }
}