$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$testFileName = $MyInvocation.MyCommand.Path
$testBasePath = "$here\LogTestBase.ps1"
. "$here\..\TestCommon.ps1"
. $testBasePath

Describe 'Log-Warning' {
	$logger = Get-Logger
	$action = { Log-Warning "test msg" }

	WithoutAddingAppender $action $logger
	
	WithAddedFileAppender "Warn" "test msg" $action $logger
}