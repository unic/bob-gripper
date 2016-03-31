$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$here\Rubble.psm1"

Describe "Full archive test." {
    Context "When creating an empty ZIP and adding a file to it." {

        mkdir "TestDrive:\Init"
        mkdir "TestDrive:\Update"

        Write-RubbleArchive "$TestDrive\Init" "$TestDrive\Test.zip"
        "test" > "$TestDrive\Update\test.txt"
        Add-RubbleArchiveFile "$TestDrive\Update\test.txt" "$TestDrive\Test.zip"
        Expand-RubbleArchive "$TestDrive\Test.zip" "$TestDrive\Result"

        It "Should have added to file." {
            Test-Path "$TestDrive\Result\test.txt" | Should Be $true
        }
    }
    Context "When creating an empty ZIP and adding a folder to it." {

        mkdir "TestDrive:\Init"
        mkdir "$TestDrive\Update\Recurse"

        Write-RubbleArchive "$TestDrive\Init" "$TestDrive\Test.zip"
        "test" > "$TestDrive\Update\test.txt"
        "test" > "$TestDrive\Update\Recurse\test.txt"
        Add-RubbleArchiveFile "$TestDrive\Update\" "$TestDrive\Test.zip"
        Expand-RubbleArchive "$TestDrive\Test.zip" "$TestDrive\Result"

        It "Should have added the folder to the ZIP." {
            Test-Path "$TestDrive\Result\Update" | Should Be $true
        }

        It "Should have added the file to the ZIP." {
            Test-Path "$TestDrive\Result\Update\test.txt" | Should Be $true
        }

        It "Should have added the file in a subfolder to the ZIP." {
            Test-Path "$TestDrive\Result\Update\Recurse\test.txt" | Should Be $true
        }
    }

    Context "When adding a file to a non-existing ZIP file" {
        "test" > "$TestDrive\test.txt"
        Add-RubbleArchiveFile "$TestDrive\test.txt" "$TestDrive\Test.zip"
        Expand-RubbleArchive "$TestDrive\Test.zip" "$TestDrive\Result"


        It "Should have created the ZIP and added the file to it." {
            Test-Path "$TestDrive\test.txt" | Should Be $true
        }
    }

}
