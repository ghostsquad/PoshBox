function New-PSClass {
    param (
        [string]$ClassName = $( Throw "ClassName required for New-PSClass" )
      , [scriptblock]$Definition = $( Throw "Definition required for New-PSClass" )
      , $Inherit
    )

    #region Class Definition Functions
    #======================================================================
    # These Subfunctions are used in Class Definition Scripts
    #======================================================================

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: constructor
    #   Assigns Constructor script to Class
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function constructor {
        param (
            [scriptblock]$scriptblock = $(Throw "Constuctor scriptblock is required.")
        )

        if ($class.__ConstructorScript -ne $null) {
            Throw "Only one Constructor is allowed"
        }

        $class.__ConstructorScript = $scriptblock
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: note
    #   Adds Notes record to class if non-static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function note {
        param (
            [string]$name = $(Throw "Note Name is required.")
          , [object]$value
          , [Type]$type = ([object])
          , [switch]$static
        )

        if ($static) {
            Attach-PSNote $class $name $value
        } else {
            if($class.__Notes[$name] -ne $null) {
                throw (new-object System.InvalidOperationException("Note with name: $Name cannot be added twice."))
            }

            if($class.__BaseClass -and $class.__BaseClass.__Notes[$name] -ne $null) {
                throw (new-object System.InvalidOperationException("Note with name: $Name cannot be added, as it already exists on the base class."))
            }

            $class.__Notes[$name] = @{Name=$name;DefaultValue=$value;}
        }
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: property
    #   Add a property to Class definition or
    #   attaches it to the Class if it is static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function property {
        param (
            [string]$name
          , [scriptblock]$get
          , [scriptblock]$set
          , [Type]$returnType = ([object])
          , [switch]$static
          , [switch]$override
        )

        if ($static) {
            Attach-PSProperty $class $name $get $set
        } else {
            if($class.__Properties[$name] -ne $null) {
                throw (new-object System.InvalidOperationException("Property with name: $Name cannot be added twice."))
            }

            if($override) {
                $baseProperty = ?: {$class.__BaseClass} { $class.__BaseClass.__Properties[$name] } { $null }
                if($baseProperty -eq $null) {
                    throw (new-object System.InvalidOperationException("Property with name: $Name cannot be override, as it does not exist on the base class."))
                } elseif($baseProperty.SetScript -eq $null -xor $set -eq $null){
                    throw (new-object System.InvalidOperationException("Property with name: $Name has setter which does not match the base class setter."))
                }
            }

            $class.__Properties[$name] = @{Name=$name;GetScript=$get;SetScript=$set;Override=$override}
        }
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: method
    #   Add a method script to Class definition or
    #   attaches it to the Class if it is static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function method {
        param  (
            [string]$name = $(Throw "Method Name is required.")
          , [scriptblock]$script = $(Throw "Method Script is required.")
          , [Type]$returnType = ([object])
          , [switch]$static
          , [switch]$override
        )

        if ($static) {
            $scriptDelegate = GetDelegateFromScriptDefinition $script $returnType
            Attach-PSScriptMethod $class $name $scriptDelegate
        } else {
            if($class.__Methods[$name] -ne $null) {
                throw (new-object System.InvalidOperationException("Method with name: $Name cannot be added twice."))
            }

            if($override) {
                $baseMethod = ?: {$class.__BaseClass} { $class.__BaseClass.__Methods[$name] } { $null }
                if($baseMethod -eq $null) {
                    throw (new-object System.InvalidOperationException("Method with name: $Name cannot be override, as it does not exist on the base class."))
                } else {
                    Assert-ScriptBlockParametersEqual $script $baseMethod.Script
                }
            }

            $scriptDelegate = GetDelegateFromScriptDefinition $script $returnType

            $class.__Methods[$name] = @{Name=$name;Script=$scriptDelegate;Override=$override}
        }
    }
    #endregion Class Definition Functions

    $class = New-PSObject

    #region Class Internals
    Attach-PSNote $class __ClassName $ClassName
    Attach-PSNote $class __Notes @{}
    Attach-PSNote $class __Methods @{}
    Attach-PSNote $class __Properties @{}
    Attach-PSNote $class __BaseClass $Inherit
    Attach-PSNote $class __ConstructorScript

    # This is how the caller can create a new instance of this class
    Attach-PSScriptMethod $class "New" {
        $private:constructorParameters = $args

        if($this.__BaseClass -ne $null) {
            $private:instance = $this.__BaseClass.New($args)
        }
        else {
            $private:instance = New-PSObject
        }

        if($instance.psobject.members["__Class"] -eq $null){
            Attach-PSNote $instance __Class $this.__ClassName
        } else {
            $instance.__Class += (".{0}" -f $this.__ClassName)
        }

        if($instance.psobject.members["____MethodInfos____"] -eq $null) {
            Attach-PSNote $instance ____MethodInfos____ @{}
        }

        PSClass_AttachMembersToInstanceObject $instance $this

        if($this.__ConstructorScript -ne $null) {
            PSClass_RunConstructor $instance $this.__ConstructorScript $constructorParameters
        }

        return $instance
    }

    # invoking the scriptblock directly without first converting it to a string
    # does not reliably use the current context, thus the internal methods:
    # constructor, method, note, property
    # cannot be found
    #
    # The following has been tested and don't work at all or reliably
    # $Definition.getnewclosure().Invoke()
    # $Definition.getnewclosure().InvokeReturnAsIs()
    # $Definition.Invoke()
    # & $Definition.getnewclosure()
    # & $Definition
    [Void]([ScriptBlock]::Create($Definition.ToString()).InvokeReturnAsIs())

    return $class
}

function PSClass_AttachMembersToInstanceObject {
    param (
        [PSObject]$Instance,
        [PSObject]$Class
    )

    # Attach Notes
    foreach($noteName in $Class.__Notes.Keys) {
        Attach-PSNote $Instance $noteName $Class.__Notes[$noteName].DefaultValue
    }

    # Attach Properties
    foreach($propertyName in $Class.__Properties.Keys) {
        $attachPropertyParams = @{
            InputObject = $Instance
            Name = $propertyName
            Get = $Class.__Properties[$propertyName].GetScript
            Set = $Class.__Properties[$propertyName].SetScript
            Override = $Class.__Properties[$propertyName].Override
        }
        Attach-PSProperty @attachPropertyParams
    }

    # Attach Methods
    foreach($methodName in $Class.__Methods.Keys){
        $attachScriptMethodParams = @{
            InputObject = $Instance
            Name = $methodName
            ScriptBlock = $Class.__Methods[$methodName].Script
            Override = $Class.__Methods[$methodName].Override
        }
        Attach-PSScriptMethod @attachScriptMethodParams
    }
}

$psClassMethodInfoClass = New-PSClass 'PSClassMethodInfo' {
    note 'Name'
    note 'Action'
    note 'Script'
    note 'GeneratedDelegate'

    constructor {
        param($name)

        $this.Name = $name
        $this.Script = $script
    }

    method 'Invoke' {
        [void]$this.Invocations.Add(@($args))

        $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10 = $args
        switch($args.Count) {
            0 { return $this.Script.InvokeReturnAsIs() }
            1 { return $this.Script.InvokeReturnAsIs($p1) }
            2 { return $this.Script.InvokeReturnAsIs($p1, $p2) }
            3 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3) }
            4 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4) }
            5 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5) }
            6 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6) }
            7 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7) }
            8 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8) }
            9 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9) }
            10 { return $this.Script.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10) }
            default {
                throw (new-object PSMockException("PSClassMock does not support more than 10 arguments for a method mock at this time."))
            }
        }
    }
}

function PSClass_RunConstructor {
    param (
        [PSObject]$This,
        [ScriptBlock]$Constructor,
        [Object]$ConstructorParameters
    )

    [Void]($Constructor.InvokeReturnAsIs($ConstructorParameters))
}

function GetDelegateFromScriptDefinition {
    param (
        [scriptblock]$script,
        [Type]$returnType
    )
    $paramDefinitions = @(?: {$script.Ast.ParamBlock -ne $null} {$script.Ast.ParamBlock.Parameters} {})
    [Type[]]$types = New-Object Type[] ($paramDefinitions.Count + 1)
    $types[$paramDefinitions.Count] = $returnType
    $delegateType = [System.Linq.Expressions.Expression]::GetDelegateType($types)
    return ($script -as $delegateType)
}