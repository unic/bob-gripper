$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

function Get-ScProjectPath {
  "$TestDrive\"
}

Describe "Set-ScUserConfigValue" {
  Context "Create user config if it does not exist" {

    Set-ScUserConfigValue -Key dummy -Value dummy
    It "Should have create Bob.config.user" {
      Test-Path  "TestDrive:\Bob.config.user" | Should Be $true
    }
    It "Should have an configuration node in Bob.config.user" {
      ([xml](Get-Content "TestDrive:\Bob.config.user")).SelectSingleNode("/Configuration") | Should Not  BeNullOrEmpty
    }
  }

  Context "Should add value if it doesn't exist yet" {
    Set-ScUserConfigValue -Key dummyKey -Value dummy

    It "Should have added dummyKey node with value dummy " {
      ([xml](Get-Content "TestDrive:\Bob.config.user")).Configuration.dummyKey | Should Be  "dummy"
    }
  }


    Context "Should update value if it allready exist" {
@"
<?xml version="1.0"?>
<Configuration>
  <dummyKey>Old</dummyKey>
  <superDummyKey>superDummy</superDummyKey>
</Configuration>
"@ | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8
      Set-ScUserConfigValue -Key dummyKey -Value New

      It "Should have updated dummyKey node with value dummy" {
        ([xml](Get-Content "TestDrive:\Bob.config.user")).Configuration.ChildNodes[0].InnerText | Should Be  "New"
        ([xml](Get-Content "TestDrive:\Bob.config.user")).Configuration.ChildNodes[0].Name | Should Be  "dummyKey"
      }

      It "Should not have touched superDummy" {
        ([xml](Get-Content "TestDrive:\Bob.config.user")).Configuration.ChildNodes[1].Name | Should Be  "superDummyKey"
        ([xml](Get-Content "TestDrive:\Bob.config.user")).Configuration.ChildNodes[1].InnerText | Should Be  "superDummy"

    }
  }

  Context "Should keep comments" {
@"
<?xml version="1.0"?>
<Configuration>
<!-- Important Comment -->
<dummyKey>Old</dummyKey>
<!-- Other fancy important Comment -->
<superDummyKey>superDummy</superDummyKey>
</Configuration>
"@ | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8

    Set-ScUserConfigValue -Key dummyKey -Value New

    It "Should have kept comments" {
      $content = [xml](Get-Content "TestDrive:\Bob.config.user")
      $content.Configuration.ChildNodes[0].InnerText | Should be " Important Comment "

      $content.Configuration.ChildNodes[1].InnerText | Should be "New"
      $content.Configuration.ChildNodes[2].InnerText | Should be " Other fancy important Comment "
    }

  }
}
