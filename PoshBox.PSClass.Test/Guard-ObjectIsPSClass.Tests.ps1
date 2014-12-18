$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\..\TestCommon.ps1"

Describe 'Guard-ObjectIsPSClass' {
    Context 'Given an object derived from a PSClass' {
        It 'Does not throw if same PSClass is provided' {
            $className = [Guid]::NewGuid().ToString()
            $testClass = New-PSClass $className {}
            $testObject = $testClass.New()

            Guard-ObjectIsPSClass $testObject $testClass
        }

        It 'Does not throw if same PSClassName is provided' {
            $className = [Guid]::NewGuid().ToString()
            $testClass = New-PSClass $className {}
            $testObject = $testClass.New()

            Guard-ObjectIsPSClass $testObject $className
        }

        It 'Does not throw object is a derived version of the PSClass provided' {
            $className = [Guid]::NewGuid().ToString()
            $baseClass = New-PSClass $className {}
            $derivedClassName = [Guid]::NewGuid().ToString()
            $derivedClass = New-PSClass $derivedClassName -Inherit $baseClass {}

            $derivedObject = $derivedClass.New()

            Guard-ObjectIsPSClass $derivedObject $baseClass
        }

        It 'Throws if object is less derived than PSClass' {
            $className = [Guid]::NewGuid().ToString()
            $baseClass = New-PSClass $className {}
            $derivedClassName = [Guid]::NewGuid().ToString()
            $derivedClass = New-PSClass $derivedClassName -Inherit $baseClass {}

            $baseObject = $baseClass.New()

            { Guard-ObjectIsPSClass $baseObject $derivedClass } | Should Throw
        }

        It 'Throws if object was not created by PSClass' {
            $object = New-PSObject
            $className = [Guid]::NewGuid().ToString()
            $baseClass = New-PSClass $className {}

            { Guard-ObjectIsPSClass $object $derivedClass } | Should Throw
        }

        It 'Throws if object is not the same class, using className' {
            $otherClassName = [Guid]::NewGuid().ToString()
            $otherClass = New-PSClass $otherClassName {}

            $className = [Guid]::NewGuid().ToString()
            $testClass = New-PSClass $className {}

            $testObject = $testClass.New()

            { Guard-ObjectIsPSClass $testObject $otherClassName } | Should Throw
        }

        It 'Throws if object is not the same class, using PSClass' {
            $otherClassName = [Guid]::NewGuid().ToString()
            $otherClass = New-PSClass $otherClassName {}

            $className = [Guid]::NewGuid().ToString()
            $testClass = New-PSClass $className {}

            $testObject = $testClass.New()

            { Guard-ObjectIsPSClass $testObject $otherClass } | Should Throw
        }
    }
}