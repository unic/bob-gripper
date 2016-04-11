$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Remove-RubbleItem" {
    Context "When '-Files' is not specified" {
        mkdir TestDrive:\test\00_base
        mkdir TestDrive:\test\00_base_local
        mkdir TestDrive:\test\00_local
        mkdir TestDrive:\test\01_local
        mkdir TestDrive:\test\01_local\deep\
        mkdir TestDrive:\test\01_local\deep2\
        "" | Out-File TestDrive:\test\foo.txt
        "" | Out-File TestDrive:\test\00_base\foo.txt
        "" | Out-File TestDrive:\test\00_base_local\foo.txt
        "" | Out-File TestDrive:\test\01_local\delete.txt
        "" | Out-File TestDrive:\test\01_local\deep\notdelete.txt
        "" | Out-File TestDrive:\test\01_local\deep\delete.txt
        
        Remove-RubbleItem "$TestDrive\test" @("00_base", "01_local\deep\notdelete.txt")
        
        It "should not have deleted base folder" {
            Test-Path TestDrive:\test\00_base | Should be $true
        }
        It "should have deleted local folder" {
            Test-Path TestDrive:\test\00_local | Should be $false
        }
        It "should not have deleted file" {
            Test-Path TestDrive:\test\foo.txt | Should be $true
        }
        It "should not have deleted sub file" {
            Test-Path TestDrive:\test\00_base\foo.txt | Should be $true
        }
        It "should have deleted base_local folder" {
            Test-Path TestDrive:\test\00_base_local| Should be $false
        }
        It "should have deleted delete.txt" {
             Test-Path TestDrive:\test\01_local\delete.txt | Should be $false
        }
        
        It "should have deleted deep delete.txt" {
             Test-Path TestDrive:\test\01_local\deep\delete.txt | Should be $false
        }
        It "should not have deleted deep delete.txt" {
             Test-Path TestDrive:\test\01_local\deep\notdelete.txt | Should be $true
        }
        It "should have deleted deep2 folder" {
             Test-Path TestDrive:\test\01_local\deep2 | Should be $false
        }
    }
    
    Context "When '-Files' is specified" {
        mkdir TestDrive:\test\00_base
        mkdir TestDrive:\test\00_local
        "" | Out-File TestDrive:\test\foo.txt
        "" | Out-File TestDrive:\test\00_base\foo.txt
        
        Remove-RubbleItem "$TestDrive\test" @("00_base") -Files
        
        It "should not have deleted base folder" {
            Test-Path TestDrive:\test\00_base | Should be $true
        }
        It "should have deleted local folder" {
            Test-Path TestDrive:\test\00_local | Should be $false
        }
        It "should not have deleted file" {
            Test-Path TestDrive:\test\foo.txt | Should be $false
        }
        It "should not have deleted sub file" {
            Test-Path TestDrive:\test\00_base\foo.txt | Should be $true
        }
    }
}
