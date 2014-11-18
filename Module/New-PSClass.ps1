
# ===================================================================================
# Inspired by Bruce Payette's "Windows PowerShell in Action"
# Chapter 8 Script to add a CustomClass "keyword" to PowerShell
# http://manning.com/payette/
# ===================================================================================

function New-PSClass {
    param (
        [string]$ClassName = $( Throw "ClassName required for New-PSClass" )
      , [scriptblock]$Definition = $( Throw "Definition required for New-PSClass" )
      , $Inherit
    )

    #======================================================================
    # These Subfunctions are used in Class Definition Scripts
    #======================================================================

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: constructor
    #   Assigns Constructor script to Class
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function constructor {
        param (
            [scriptblock]$ctor = $(Throw "Script is required for 'constructor' in $ClassName")
        )

        if ($class.ConstructorScript) {
            Throw "Only one Constructor is allowed"
        }
        $class.ConstructorScript = $ctor
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: note
    #   Adds Notes record to class if non-static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function note {
        param (
            [string]$name = $(Throw "Note Name is Required")
          , [object]$value
          , [switch]$static
          , [switch]$private
        )

        if ($static) {
            if ($private) {
                Throw "Private Static Notes are not supported"
            }

            Attach-PSNote $class $name $value
        } else {
            $class.Notes += @{Name=$name;DefaultValue=$value;Private=$private}
        }
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: method
    #   Add a method script to Class definition or
    #   attaches it to the Class if it is static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function method {
        param  (
            [string]$name = $(Throw "Name is required for 'method'")
          , [scriptblock]$script = $(Throw "Script is required for 'method' $name in Class $ClassName")
          , [switch]$static
          , [switch]$private
          , [switch]$override
        )

        if ($static) {
            if ($private) {
                Throw "Private Static Methods not supported"
            }
            Attach-PSScriptMethod $class $name $script
        } else {
            $class.Methods[$name] = @{Name=$name;Script=$script;Private=$private;Override=$override}
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
          , [switch]$static
          , [switch]$private
          , [switch]$override
        )

        if ($static) {
            if ($private) {
                Throw "Private Static Properties not supported"
            }
            Attach-PSProperty $class $name $get $set
        } else {
            $class.Properties[$name] = @{Name=$name;GetScript=$get;SetScript=$set;Private=$private;Override=$override}
        }
    }

    $class = New-Object PSObject

    # Class Internals
    Attach-PSNote $class ClassName $ClassName
    Attach-PSNote $class Notes @()
    Attach-PSNote $class Methods @{}
    Attach-PSNote $class Properties @{}
    Attach-PSNote $class BaseClass $Inherit
    Attach-PSNote $class ConstructorScript
    Attach-PSNote $class PrivateName "__$($ClassName)_Private"

    Attach-PSScriptMethod $class AttachTo {
        function AttachAndInit($instance, [array]$parms) {
            $instance = __PSClassAttachObject $this $instance
            __PSClassInitialize $this $instance $parms
            $instance
        }

        $type = $Args[0].GetType()
        [array]$parms = $Args[1]
        if (($Args[0] -is [array]) -or ($Args[0] -is [System.Collections.ArrayList])) {
            # This handles the attachment of an array of objects
            $objects = $Args[0]
            foreach($object in $objects) {
                [Void](AttachAndInit $object $parms)
            }
        } else {
            [Void](AttachAndInit $Args[0] $parms)
        }
    }

    Attach-PSScriptMethod $class New {
        $instance = new-object Management.Automation.PSObject
        $this.AttachTo( $instance, $Args )
        return $instance
    }

    Attach-PSScriptMethod $class __LookupClassObject {
        __PSClassLookupClassObject $this $Args[0] $Args[1]
    }

    Attach-PSScriptMethod $class InvokeMethod {
        __PSClassInvokeMethod $this $Args[0] $Args[1] $Args[2]
    }

    Attach-PSScriptMethod $class InvokeProperty {
        __PSClassInvokePropertyMethod $this $Args[0] $Args[1] $Args[2] $Args[3]
    }

    & $Definition

    # return constructed class
    return $class
}

function Deserialize-PSClass ($deserialized) {
    $class = $deserialized.Class

    if(-not $class.AttachTo) {
        Attach-PSScriptMethod $class AttachTo {
            function AttachAndInit($instance) {
                $instance = __PSClassAttachObject $this $instance
                return $instance
            }
            AttachAndInit $Args[0]
        }

        Attach-PSScriptMethod $class __LookupClassObject {
            __PSClassLookupClassObject $this $Args[0] $Args[1]
        }

        Attach-PSScriptMethod $class InvokeMethod {
            __PSClassInvokeMethod $this $Args[0] $Args[1] $Args[2]
        }

        Attach-PSScriptMethod $class InvokeProperty {
            __PSClassInvokePropertyMethod $this $Args[0] $Args[1] $Args[2] $Args[3]
        }
    }

    $instance = new-object Management.Automation.PSObject
    $instance = $class.AttachTo($instance)

    foreach($note in $class.Notes) {
        if(-not $note.Private) {
            continue
        }

        $originalValue = $deserialized.$($deserialized.Class.PrivateName).$($note.Name)
        if($originalValue.Class -is [array]) {
            $value = @()
            for($i = 0; $i -lt $originalValue.Class.Count; $i++) {
                $value += @(Deserialize-PSClass $originalValue[$i])
            }
        } elseif($originalValue.Class) {
            $value = Deserialize-PSClass $originalValue
        } else {
            $value = $originalValue
        }

        $instance.$($instance.Class.PrivateName).$($note.Name) = $value
    }

    foreach($note in $class.Notes) {
        if(-not $note.Private) {
            $instance.$($note.Name) = $deserialized.$($note.Name)
        }
    }

    return $instance
}

# ===================================================================================
# These helper Cmdlets should only be called by New-PSClass.  They exist to reduce
# the amount of code attached to each PSClass object.  They rely on context
# variables not passed as parameters.
# ===================================================================================
# __PSClassInitialize
#    Invokes Constructor Script and provides helper Base function to facilitate
#    Inherited Constructors
# ===================================================================================
function __PSClassInitialize ($class, $instance, $params) {
    function Base {
        if ($this.Class.BaseClass -eq $null) {
            Throw "No BaseClass implemented for $($this.Class.ClassName)"
        }
        __PSClassInitialize $this.Class.BaseClass $this $Args
    }

    try {
        if ($class.ConstructorScript) {
            $constructor = $class.ConstructorScript

            $private = $Instance.($class.privateName)
            $this = $instance
            $constructor.InvokeReturnAsIs( $params )
        }
    } catch {
        $exception = $_
        if ( $exception.Message -match "Error Position:" ) {
            $errorMsg = $exception.Message
		}
		else {
            $errorMsg = $exception.Message
            $errorMsg += $exception.ErrorRecord.InvocationInfo.PositionMessage
        }

        $errorMsg = ($errorMsg -replace '(Exception calling ".*" with ".*" argument\(s\)\: ")(.*)','' )
        Throw $errorMsg
    }
}

# ===================================================================================
# __PSClassAttachObject
#    Attaches Notes, Methods, and Properties to Instance Object
# ===================================================================================
function __PSClassAttachObject ($Class, [PSObject] $Instance) {
    # function AssurePrivate {
        # param (
            # $Class,
            # $Instance
        # )

        # if ($Instance.psobject.properties.Item($Class.privateName) -eq $null) {
            # Attach-PSNote $Instance ($Class.privateName) (new-object Management.Automation.PSObject)
            # Attach-PSNote $Instance.($Class.privateName) __Parent
        # }

        # $Instance.($Class.privateName).__Parent = $Instance
    # }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    #  Attach BaseClass
    # - - - - - - - - - - - - - - - - - - - - - - - -
    if ($Class.BaseClass -ne $null) {
        $instance = __PSClassAttachObject $Class.BaseClass $instance
    }

    Attach-PSNote $instance Class $Class

    # - - - - - - - - - - - - - - - - - - - - - - - -
    #  Attach Notes
    # - - - - - - - - - - - - - - - - - - - - - - - -
    #AssurePrivate $Class $Instance

    foreach ($note in $Class.Notes) {
        if ($note.private) {
            Attach-PSNote $instance.($Class.privateName) $note.Name $note.DefaultValue
        } else {
            Attach-PSNote $instance $note.Name $note.DefaultValue
        }
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    #  Attach Methods
    # - - - - - - - - - - - - - - - - - - - - - - - -
    foreach ($key in $Class.Methods.keys) {
        $method = $Class.Methods[$key]
        $targetObject = $instance

        # Private Methods are attached to the Private Object.
        # However, when the script gets invoked, $this needs to be
        # pointing to the instance object. $ObjectString resolves
        # this for InvokeMethod
        if ($method.private) {
            #AssurePrivate
            $targetObject = $instance.($Class.privateName)
            $ObjectString = '$this.__Parent'
        } else {
            $targetObject = $instance
            $ObjectString = '$this'
        }

        # The actual script is not attached to the object.  The Script attached to Object calls
        # InvokeMethod on the Class.  It looks up the script and executes it
        $instanceScriptText = $ObjectString + '.Class.InvokeMethod( "' + $method.name + '", ' + $ObjectString + ', $Args )'
        $instanceScript = $ExecutionContext.InvokeCommand.NewScriptBlock( $instanceScriptText )

        Attach-PSScriptMethod $targetObject $method.Name $instanceScript -override:$method.override
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    #  Attach Properties
    # - - - - - - - - - - - - - - - - - - - - - - - -
    foreach ($key in $Class.Properties.keys) {
        $Property = $Class.Properties[$key]
        $targetObject = $instance

        # Private Properties are attached to the Private Object.
        # However, when the script gets invoked, $this needs to be
        # pointing to the instance object. $ObjectString resolves
        # this for InvokeMethod
        if ($Property.private) {
            AssurePrivate
            $targetObject = $instance.($Class.privateName)
            $ObjectString = '$this.__Parent'
        } else {
            $targetObject = $instance
            $ObjectString = '$this'
        }

        # The actual script is not attached to the object.  The Script attached to Object calls
        # InvokeMethod on the Class.  It looks up the script and executes it
        $instanceScriptText = $ObjectString + '.Class.InvokeProperty( "GET", "' + $Property.name + '", ' + $ObjectString + ', $Args )'
        $getScript = $ExecutionContext.InvokeCommand.NewScriptBlock( $instanceScriptText )

        if ($Property.SetScript -ne $null) {
            $instanceScriptText = $ObjectString + '.Class.InvokeProperty( "SET", "' + $Property.name + '", ' + $ObjectString + ', $Args )'
            $setScript = $ExecutionContext.InvokeCommand.NewScriptBlock( $instanceScriptText )
        } else {
            $setScript = $null
        }

        Attach-PSProperty $targetObject $Property.Name $getScript $setScript -override:$Property.override
    }

    return $instance
}

# ===================================================================================
# __PSClassLookupClassObject
#   intended to look up methods and property objects on the Class.  However,
#   it can be used to look up any Hash Table entry on the class.
#
#   if the object is not found on the instance class, it searches all Base Classes
#
#   $ObjectType is the HashTable Member
#   $ObjectName is the HashTable Key
#
#   it returns the Class and Hashtable entry it was found in
# ===================================================================================
function __PSClassLookupClassObject ($Class, $ObjectType, $ObjectName) {
    $object = $Class.$ObjectType[$ObjectName]
    if ($object -ne $null) {
        Write-Output $Class
        Write-Output $object
    } else {
        if ($Class.BaseClass -ne $null) {
            $Class.BaseClass.__LookupClassObject($ObjectType, $ObjectName)
        }
    }
}

# ===================================================================================
# __PSClassInvokeScript
#   Used to invoke Method and Property scripts
#     It adds an error handler so Script Info can be seen in the error
#     It marshals $this and $private variables for the context of the script
#     It provides a helper Invoke-BaseClassMethod for invoking base class methods
# ===================================================================================
function __PSClassInvokeScript ($class, $script, $object, [array]$parms ){
    function Invoke-BaseClassMethod ($methodName, [array]$parms) {
        if ($this.Class.BaseClass -eq $null) {
            Throw "$($this.Class.ClassName) does not have a BaseClass"
        }
        $class,$method = $this.Class.BaseClass.__LookupClassObject('Methods', $MethodName)

        if ($method -eq $null) {
            Throw "Method $MethodName not defined for $className"
        }
        __PSClassInvokeScript $class $method.Script $this $parms
    }

    try {

        $this = $object
        $private = $this.($Class.privateName)

        if($script -is [string]) {
            [ScriptBlock]::Create($script).InvokeReturnAsIs( $parms )
        }
        else {
            $script.InvokeReturnAsIs($parms)
        }
    } catch {
        $exception = $_
        if ( $exception.Message -match "Error Position:" ) {
            $errorMsg = $exception.Message
		}
		else {
            $errorMsg = $exception.Message
            $errorMsg += $exception.ErrorRecord.InvocationInfo.PositionMessage
        }

        $errorMsg = ($errorMsg -replace '(Exception calling ".*" with ".*" argument\(s\)\: ")(.*)','' )
        Throw $errorMsg
    }
}

# ===================================================================================
# __PSClassInvokeMethod
#   Script called by methods attached to instances.  Looks up Method Script
#   in instance class or in inherited class
# ===================================================================================
function __PSClassInvokeMethod($Class, $MethodName, $instance, [array]$parms) {
    $FoundClass,$method = $Class.__LookupClassObject('Methods', $MethodName)

    if ($method -eq $null) {
        Throw "Method $MethodName not defined for $($Class.ClassName)"
    }

    __PSClassInvokeScript $FoundClass $method.Script $instance $parms
}

# ===================================================================================
# __PSClassInvokePropertyMethod
#   Script called by property scripts attached to instances.  Looks up property Script
#   in instance class or in inherited class
# ===================================================================================
function __PSClassInvokePropertyMethod ($Class, $PropertyType, $PropertyName, $instance, [array]$parms) {
    $FoundClass,$property = $Class.__LookupClassObject('Properties', $PropertyName)

    if ($property -eq $null) {
        Throw "Property $PropertyName not defined for $($Class.ClassName)"
    }

    if ($PropertyType -eq "GET") {
        __PSClassInvokeScript $FoundClass $property.GetScript $instance $parms
    } else {
        __PSClassInvokeScript $FoundClass $property.SetScript $instance $parms
    }
}

# ===================================================================================
function Attach-PSNote {
    param ( [PSObject]$object=$(Throw "Object is required")
        , [string]$name=$(Throw "Note Name is Required")
        , $value
    )

    if (! $object.psobject.members[$name]) {
        $member = new-object management.automation.PSNoteProperty $name,$value
        $object.psobject.members.Add($member)
    }

    if($value -ne $null) {
        $object.$name = $value
    }
}

# ===================================================================================
function Attach-PSScriptMethod {
    param ( [PSObject]$object=$(Throw "Object is required")
        , [string]$name=$(Throw "Method Name is Required")
        , [scriptblock] $script
        , [switch] $override
    )

    if($override) {
        [Void]$object.PSOverrideScriptMethod($name, $script)
    } else {
        [Void]$object.PSAddScriptMethod($name, $script)
    }
}

# ===================================================================================
function Attach-PSProperty {
    param ( [PSObject]$object=$(Throw "Object is required")
        , [string]$name=$(Throw "Method Name is Required")
        , [scriptblock] $get=$(Throw "get script is required on property $name in Class $ClassName")
        , [scriptblock] $set
        , [switch] $override
    )

    if ($set) {
        $scriptProperty = new-object management.automation.PsScriptProperty $name,$get,$set
    } else {
        $scriptProperty = new-object management.automation.PsScriptProperty $name,$get
    }

    if ( $object.psobject.properties[$name] -and $override) {
        $object.psobject.properties.Remove($name)
    }

    $object.psobject.properties.add($scriptProperty)
}