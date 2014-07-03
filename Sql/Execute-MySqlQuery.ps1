function Execute-MySqlQuery {
<#
.SYNOPSIS
   Execute-MySQLQuery
    
.DESCRIPTION
   By default, this script will:
    - Will open a MySQL Connection
	- Will Send a Command to a MySQL Server
	- Will close the MySQL Connection
	This function uses the MySQL .NET Connector or MySQL.Data.dll file
     
.PARAMETER ConnectionString
    Adds the MySQL Connection String for the specific MySQL Server
     
.PARAMETER Query
 
    The MySQL Query which should be send to the MySQL Server
	
.EXAMPLE
    C:\PS> Executre-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;database=project;" -Query "SELECT * FROM firsttest" 
    
    Description
    -----------
    This command run the MySQL Query "SELECT * FROM firsttest" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword and selects the database project
         
.EXAMPLE
    C:\PS> Execute-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;database=project;" -Query "UPDATE firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
    
    Description
    -----------
    This command run the MySQL Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword
	
.EXAMPLE
    C:\PS> Execute-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;" -Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
    
    Description
    -----------
    This command run the MySQL Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword and selects the database project
    
#>
	[cmdletbinding()]
	Param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'default',
            ValueFromPipeline = $true)]
            [string]$query,   
		[Parameter(
            Mandatory = $true,
            ParameterSetName = 'default',
            ValueFromPipeline = $true)]
            [string]$connectionString
    )
	
	Process {
		try {
			# load MySQL driver and create connection
			Write-Verbose "Create Database Connection"
			# You could also could use a direct Link to the DLL File
			# $mySQLDataDLL = "C:\scripts\mysql\MySQL.Data.dll"
			# [void][system.reflection.Assembly]::LoadFrom($mySQLDataDLL)
			[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
			$connection = New-Object MySql.Data.MySqlClient.MySqlConnection
			$connection.ConnectionString = $ConnectionString
			Write-Verbose "Open Database Connection"
			$connection.Open()
			
			# Run MySQL Querys
			Write-Verbose "Run MySQL Querys"
			$command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
			$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet, "data")
			return $dataSet.Tables["data"]
		}		
		catch {
			Write-Error ("Could not run MySQL Query " + $Error[0])
		}	
		finally {
			Write-Verbose "Close Connection"
			$connection.Close()
		}
    }
}