$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# here : /branch/tests/Poshbox.Test
. "$here\TestCommon.ps1"

Describe 'Get-IniContent' {
	
	$goodFilePath = Join-Path $here "TestData\TestConfig.Ini"

	Context 'Good File' {
		It 'quotes included' {
			$expectedValue = '"hello world"'
		
			# act
			$iniContent = Get-IniContent $goodFilePath
			
			# assert
			
			$iniContent["section"]["value1"] | Should Be $expectedValue
		}
		
		It 'Can get value without quotes' {
			$expectedValue = 'hello world'
		
			# act
			$iniContent = Get-IniContent $goodFilePath
			
			# assert
			
			$iniContent["section"]["value2"] | Should Be $expectedValue
		}
	}
}