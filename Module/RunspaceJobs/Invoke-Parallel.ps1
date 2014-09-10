function Invoke-Parallel {
    <#
        .SYNOPSIS
            Run arbitrary commands in parallel using runspaces

        .DESCRIPTION
            Run arbitrary commands in parallel using runspaces

        .PARAMETER Credential
            Alternate credentials to use for runspace invocation

        .PARAMETER Throttle
            Number of asynchonous jobs that will run at a time

        .EXAMPLE
            $results = Get-Content Servers.txt | Invoke-Parallel -ScriptBlock {
                param($computerName)
                Get-Process -ComputerName $computerName
            }

        .EXAMPLE
            $servers = Get-Content Servers.txt -ReadCount 0
            $results = Invoke-Parallel -InputObject $servers -ScriptBlock {
                param($computerName)
                Get-Process -ComputerName $computerName
            }

            Description
            -----------
            Retrieves all of network information from the remote servers while running 10 runspace jobs at a time.

        .EXAMPLE
            $servers = Get-Content Servers.txt -ReadCount 0
            $results = Invoke-Parallel -InputObject $servers -ScriptBlock {
                param($computerName)
                Get-Process -ComputerName $computerName
            } `
            -Credential domain\adminuser `
            -Throttle 10

            Description
            -----------
            Runs Get-Process from the systems in the text file. Also uses alternate administrator credentials provided.
    #>
    #Requires -Version 3.0
    [cmdletbinding(DefaultParameterSetName="ScriptBlock")]
    Param (
        [parameter(ValueFromPipeline, ValueFromPipeLineByPropertyName, Mandatory, ParameterSetName="ScriptBlock")]
        [parameter(ValueFromPipeline, ValueFromPipeLineByPropertyName, Mandatory, ParameterSetName="ScriptFile")]
        [object[]]$InputObject,

        [parameter(ParameterSetName="ScriptBlock")]
        [parameter(ParameterSetName="ScriptFile")]
        [Alias('RunAs')]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,

        [parameter(ParameterSetName="ScriptBlock")]
        [parameter(ParameterSetName="ScriptFile")]
        [int]$Throttle = 15,

        [parameter(ParameterSetName="ScriptBlock")]
        [parameter(ParameterSetName="ScriptFile")]
        [int]$Timeout = 0,

        [parameter(ParameterSetName="ScriptBlock")]
        [parameter(ParameterSetName="ScriptFile")]
        [int]$Wait = 100,

        [parameter(Mandatory, ParameterSetName="ScriptBlock")]
        [ScriptBlock]$ScriptBlock,

        [parameter(Mandatory, ParameterSetName="ScriptFile")]
        [string]$ScriptFile
    )
    Begin {
        function ManageRunspaces {
            param(

            )
        }

        Function Get-RunspaceData {
            [cmdletbinding()]
            param(
                [switch]$Wait
            )
            Do {
                $more = $false
                Foreach($runspace in $runspaces) {
                    If ($runspace.Runspace.isCompleted) {
                        $runspace.powershell.EndInvoke($runspace.Runspace)
                        $runspace.powershell.dispose()
                        $runspace.Runspace = $null
                        $runspace.powershell = $null
                        $Script:i++
                    } ElseIf ($runspace.Runspace -ne $null) {
                        $more = $true
                    }
                }
                If ($more -AND $PSBoundParameters['Wait']) {
                    Start-Sleep -Milliseconds 100
                }
                #Clean out unused runspace jobs
                $temphash = $runspaces.clone()
                $temphash | Where {
                    $_.runspace -eq $Null
                } | ForEach {
                    Write-Verbose ("Removing {0}" -f $_.computer)
                    $Runspaces.remove($_)
                }
            } while ($more -AND $PSBoundParameters['Wait'])
        }

        Write-Verbose ("Performing inital Administrator check")
        $usercontext = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $IsAdmin = $usercontext.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

        #Main collection to hold all data returned from runspace jobs
        $Script:report = @()

        Write-Verbose ("Building hash table for WMI parameters")
        $WMIhash = @{
            Class = "Win32_NetworkAdapterConfiguration"
            Filter = "IPEnabled='$True'"
            ErrorAction = "Stop"
        }

        #Supplied Alternate Credentials?
        If ($PSBoundParameters['Credential']) {
            $wmihash.credential = $Credential
        }

        #Define hash table for Get-RunspaceData function
        $runspacehash = @{}

        #Define Scriptblock for runspaces
        $scriptblock = {
            Param (
                $Computer,
                $wmihash
            )
            Write-Verbose ("{0}: Checking network connection" -f $Computer)
            If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                #Check if running against local system and perform necessary actions
                Write-Verbose ("Checking for local system")
                If ($Computer -eq $Env:Computername) {
                    $wmihash.remove('Credential')
                } Else {
                    $wmihash.Computername = $Computer
                }
                Try {
                        Get-WmiObject @WMIhash | ForEach {
                            $IpHash =  @{
                                Computername = $_.DNSHostName
                                DNSDomain = $_.DNSDomain
                                IPAddress = $_.IpAddress
                                SubnetMask = $_.IPSubnet
                                DefaultGateway = $_.DefaultIPGateway
                                DNSServer = $_.DNSServerSearchOrder
                                DHCPEnabled = $_.DHCPEnabled
                                MACAddress  = $_.MACAddress
                                WINSPrimary = $_.WINSPrimaryServer
                                WINSSecondary = $_.WINSSecondaryServer
                                NICName = $_.ServiceName
                                NICDescription = $_.Description
                            }
                            $IpStack = New-Object PSObject -Property $IpHash
                            #Add a unique object typename
                            $IpStack.PSTypeNames.Insert(0,"IPStack.Information")
                            $IpStack
                        }
                    } Catch {
                        Write-Warning ("{0}: {1}" -f $Computer,$_.Exception.Message)
                        Break
                }
            } Else {
                Write-Warning ("{0}: Unavailable!" -f $Computer)
                Break
            }
        }

        Write-Verbose ("Creating runspace pool and session states")
        $sessionstate = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
        $runspacepool.Open()

        Write-Verbose ("Creating empty collection to hold runspace jobs")
        $Script:runspaces = New-Object System.Collections.ArrayList
    }
    Process {
        $totalcount = $computername.count
        Write-Verbose ("Validating that current user is Administrator or supplied alternate credentials")
        If (-Not ($Computername.count -eq 1 -AND $Computername[0] -eq $Env:Computername)) {
            #Now check that user is either an Administrator or supplied Alternate Credentials
            If (-Not ($IsAdmin -OR $PSBoundParameters['Credential'])) {
                Write-Warning ("You must be an Administrator to perform this action against remote systems!")
                Break
            }
        }
        ForEach ($Computer in $Computername) {
           #Create the powershell instance and supply the scriptblock with the other parameters
           $powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer).AddArgument($wmihash)

           #Add the runspace into the powershell instance
           $powershell.RunspacePool = $runspacepool

           #Create a temporary collection for each runspace
           $temp = "" | Select-Object PowerShell,Runspace,Computer
           $Temp.Computer = $Computer
           $temp.PowerShell = $powershell

           #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
           $temp.Runspace = $powershell.BeginInvoke()
           Write-Verbose ("Adding {0} collection" -f $temp.Computer)
           $runspaces.Add($temp) | Out-Null

           Write-Verbose ("Checking status of runspace jobs")
           Get-RunspaceData @runspacehash
        }
    }
    End {
        Write-Verbose ("Finish processing the remaining runspace jobs: {0}" -f (@(($runspaces | Where {$_.Runspace -ne $Null}).Count)))
        $runspacehash.Wait = $true
        Get-RunspaceData @runspacehash

        Write-Verbose ("Closing the runspace pool")
        $runspacepool.close()
    }
}