##############################################################################
#.SYNOPSIS
# Add a type accelerator to the current session.
#
#.DESCRIPTION
# The Add-TypeAccelerator function allows you to add a simple type accelerator
# (like [regex]) for a longer type (like [System.Text.RegularExpressions.Regex]).
#
#.PARAMETER Name
# The short form accelerator should be just the name you want to use (without
# square brackets).
#
#.PARAMETER Type
# The type you want the accelerator to accelerate.
#
#.PARAMETER Force
# Overwrites any existing type alias.
#
#.EXAMPLE
# Add-TypeAccelerator List "System.Collections.Generic.List``1"
# $MyList = New-Object List[String]
##############################################################################
function Add-TypeAccelerator {

    [CmdletBinding()]
    param(

        [Parameter(Position=1,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,

        [Parameter(Position=2,Mandatory=$true,ValueFromPipeline=$true)]
        [Type]$Type,

        [Parameter()]
        [Switch]$Force

    )

    process {

        $TypeAccelerators = [PSCustomObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")

        foreach ($a in $Name) {
            if ( $TypeAccelerators::Get.ContainsKey($a) ) {
                if ( $Force ) {
                    $TypeAccelerators::Remove($a) | Out-Null
                    $TypeAccelerators::Add($a,$Type)
                }
                elseif ( $Type -ne $TypeAccelerators::Get[$a] ) {
                    Write-Error "$a is already mapped to $($TypeAccelerators::Get[$a])"
                }
            }
            else {
                $TypeAccelerators::Add($a, $Type)
            }
        }

    }

}