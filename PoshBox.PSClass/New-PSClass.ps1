function New-PSClass {
    param (
        [string]$ClassName
      , [scriptblock]$Definition
      , [object]$Inherit
      , [switch]$PassThru
    )

    Guard-ArgumentNotNullOrEmpty 'ClassName' $ClassName
    Guard-ArgumentNotNull 'Definition' $Definition

    if($Inherit -ne $null) {
        if($Inherit -is [string]) {
            $Inherit = [PSClassContainer]::ClassDefinitions[$Inherit]
        } else {
            Guard-ArgumentValid 'Inherit' '-Inherit Value must be a PSClass definition object' ($Inherit.__ClassName -ne $null)
        }
    }

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

        $splat = @{
            class = $class
            scriptblock = $scriptblock
        }

        Attach-PSClassConstructor @splat
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: note
    #   Adds Notes record to class if non-static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function note {
        [cmdletbinding()]
        param (
            [string]$name = $(Throw "Note Name is required.")
          , [object]$value
          , [switch]$static
          , [switch]$forceValueAssignment
        )

        $splat = @{
            class = $class
            name = $name
            value = $value
            static = $static
            forceValueAssignment = $forceValueAssignment
        }

        Attach-PSClassNote @splat
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: property
    #   Add a property to Class definition or
    #   attaches it to the Class if it is static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function property {
        [cmdletbinding()]
        param (
            [string]$name
          , [scriptblock]$get
          , [scriptblock]$set
          , [switch]$static
          , [switch]$override
        )

        $splat = @{
            class = $class
            name = $name
            get = $get
            set = $set
            static = $static
            override = $override
        }

        Attach-PSClassProperty @splat
    }

    # - - - - - - - - - - - - - - - - - - - - - - - -
    # Subfunction: method
    #   Add a method script to Class definition or
    #   attaches it to the Class if it is static
    # - - - - - - - - - - - - - - - - - - - - - - - -
    function method {
        [cmdletbinding()]
        param  (
            [string]$name = $(Throw "Method Name is required.")
          , [scriptblock]$script = $(Throw "Method Script is required.")
          , [switch]$static
          , [switch]$override
        )

        $splat = @{
            class = $class
            name = $name
            script = $script
            static = $static
            override = $override
        }

        Attach-PSClassMethod @splat
    }
    #endregion Class Definition Functions

    $class = New-PSObject

    #region Class Internals
    Attach-PSNote $class __ClassName $ClassName
    Attach-PSNote $class __Notes @{}
    Attach-PSNote $class __Methods @{}
    Attach-PSNote $class __Properties @{}
    Attach-PSNote $class __Members (New-Object System.Collections.Generic.List[System.Management.Automation.PSMemberInfo])
    Attach-PSNote $class __BaseClass $Inherit
    Attach-PSNote $class __ConstructorScript

    # This is how the caller can create a new instance of this class
    Attach-PSScriptMethod $class "New" {
        $private:constructorParameters = $args

        if($this.__BaseClass -ne $null) {
            $private:p1, $private:p2, $private:p3, $private:p4, $private:p5, $private:p6, `
                $private:p7, $private:p8, $private:p9, $private:p10 = $private:constructorParameters
            switch($private:constructorParameters.Count) {
                0 {  $private:instance = $this.__BaseClass.New() }
                1 {  $private:instance = $this.__BaseClass.New($p1) }
                2 {  $private:instance = $this.__BaseClass.New($p1, $p2) }
                3 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3) }
                4 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4) }
                5 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5) }
                6 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5, $p6) }
                7 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7) }
                8 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8) }
                9 {  $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9) }
                10 { $private:instance = $this.__BaseClass.New($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10) }
                default {
                    throw (new-object PSClassException("PSClass does not support more than 10 arguments for a constructor."))
                }
            }
        }
        else {
            $private:instance = New-PSObject
        }

        $instance.psobject.TypeNames.Insert(0, $this.__ClassName);

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
    # & $Definition.getnewclosure()
    # & $Definition
    [Void]([ScriptBlock]::Create($Definition.ToString()).InvokeReturnAsIs())

    [Void]([PSClassContainer]::ClassDefinitions.Add($ClassName, $class))

    if($PassThru) {
        return $class
    }
}

function PSClass_AttachMembersToInstanceObject {
    param (
        [PSObject]$Instance,
        [PSObject]$Class
    )

    # Attach Notes
    foreach($noteName in $Class.__Notes.Keys) {
        $attachNoteParams = @{
            InputObject = $Instance
            PSNoteProperty = $Class.__Notes[$noteName].PSNoteProperty
        }

        try {
            Attach-PSNote @attachNoteParams
        } catch {
            $msg = "Unable to attach method: {0}; see AttachParams property for details" -f $methodName
            $exception = (new-object PSClassException($msg, $_))
            Attach-PSNote $exception "AttachParams" $attachNoteParams
            throw $exception
        }

    }

    # Attach Properties
    foreach($propertyName in $Class.__Properties.Keys) {
        $attachPropertyParams = @{
            InputObject = $Instance
            PSScriptProperty = $Class.__Properties[$propertyName].PSScriptProperty
            Override = $Class.__Properties[$propertyName].Override
        }

        try {
            Attach-PSProperty @attachPropertyParams
        } catch {
            $msg = "Unable to attach property: {0}; see AttachParams property for details" -f $propertyName
            $exception = (new-object PSClassException($msg, $_))
            Attach-PSNote $exception "AttachParams" $attachPropertyParams
            throw $exception
        }
    }

    # Attach Methods
    foreach($methodName in $Class.__Methods.Keys){
        $attachScriptMethodParams = @{
            InputObject = $Instance
            PSScriptMethod = $Class.__Methods[$methodName].PSScriptMethod
            Override = $Class.__Methods[$methodName].Override
        }
        try {
            Attach-PSScriptMethod @attachScriptMethodParams
        } catch {
            $msg = "Unable to attach method: {0}; see AttachParams property for details" -f $methodName
            $exception = (new-object PSClassException($msg, $_))
            Attach-PSNote $exception "AttachParams" $attachScriptMethodParams
            throw $exception
        }
    }
}

function PSClass_RunConstructor {
    param (
        [PSObject]$This,
        [ScriptBlock]$Constructor,
        [Object]$ConstructorParameters
    )

    $private:p1, $private:p2, $private:p3, $private:p4, $private:p5, $private:p6, `
        $private:p7, $private:p8, $private:p9, $private:p10 = $ConstructorParameters
    switch($ConstructorParameters.Count) {
        0 {  [Void]($Constructor.InvokeReturnAsIs()) }
        1 {  [Void]($Constructor.InvokeReturnAsIs($p1)) }
        2 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2)) }
        3 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3)) }
        4 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4)) }
        5 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5)) }
        6 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6)) }
        7 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7)) }
        8 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8)) }
        9 {  [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9)) }
        10 { [Void]($Constructor.InvokeReturnAsIs($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10)) }
        default {
            throw (new-object PSClassException("PSClass does not support more than 10 arguments for a constructor."))
        }
    }
}

if (-not ([System.Management.Automation.PSTypeName]'PSClassException').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
    using System;
    using System.Management.Automation;

    public class PSClassException : Exception {
        public ErrorRecord ErrorRecord { get; private set; }

        public PSClassException(string message)
            : base(message)
        {
        }

        public PSClassException(string message, ErrorRecord errorRecord)
            : base(message)
        {
            this.ErrorRecord = errorRecord;
        }

        public PSClassException(string message, Exception inner)
            : base(message, inner)
        {
        }
    }
"@
}

if (-not ([System.Management.Automation.PSTypeName]'PSClassTypeAttribute').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
        using System;

        public class PSClassTypeAttribute : Attribute {
            public string Name { get; set; }

            public PSClassTypeAttribute(string name) {
                this.Name = name;
            }
        }
"@
}

if (-not ([System.Management.Automation.PSTypeName]'PSClassContainer').Type)
{
    Add-Type -WarningAction Ignore -TypeDefinition @"
        using System;
        using System.Collections.Generic;
        using System.Management.Automation;

        public static class PSClassContainer {
            public static readonly Dictionary<String,PSObject> ClassDefinitions = new Dictionary<String,PSObject>();
        }
"@
}