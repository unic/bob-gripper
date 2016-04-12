$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-ScProjectPath" {
    Context "When invoking without Bob.config" {
        $path = "TestDrive:\a\b\c\d"
        
        mkdir $path
        It "Should return null" {
            Push-Location $path
            Get-ScProjectPath | Should be $null
            Pop-Location 
        }        
        
    }
    
    Context "When invoking with Bob.config" {
        $path = "TestDrive:\a\b\c\d"
        mkdir $path
        "" | Out-File "TestDrive:\a\b\Bob.config"
        
        It "Should return the path" {
            Push-Location $path
            Get-ScProjectPath | Should be "TestDrive:\a\b"
            Pop-Location 
        }        
        
    }
}