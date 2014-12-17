#Describe "Lazy" {
#    $lazy = New-Lazy { return "test" }
#
#    It "Should not have a value evaluated" {
#        $lazy.IsValueCreated.Should.Be($false)
#    }
#
#    It "Should get lazy value" {
#        $lazy.Value.Should.Be("test")
#        $lazy.IsValueCreated.Should.Be($true)
#    }
#}

function New-Lazy {
    param (
        [scriptblock]$Script
    )

    $delegate = [System.Func[object]] $Script
    $lazy = New-Object System.Lazy[object] $delegate

    return $lazy
}