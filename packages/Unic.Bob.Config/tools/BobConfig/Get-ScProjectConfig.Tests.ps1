$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


function global:Get-ScProjectPath { "TestDrive:\"}

Describe "Get-ScProjectConfig" {
  Context "Bob.user.config" {

    $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
    <Configuration>
      <WebsiteCodeName>Website code parent</WebsiteCodeName>
      <LocalHostName>local host name code parent</LocalHostName>
    </Configuration>
"@
    $bobUserConfig = @"
<?xml version="1.0" encoding="utf-8"?>
    <Configuration>
      <LocalHostName>local host name code child</LocalHostName>
    </Configuration>
"@

    $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8
    $bobUserConfig | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8


    $config = Get-ScProjectConfig

    It "Should have keep parent value for WebsiteCodeName" {
      $config.WebsiteCodeName | Should Be "Website code parent"
    }

    It "Should have take child value for LocalHostName" {
      $config.LocalHostName | Should Be "local host name code child"
    }
  }

  Context "When there is no WebRoot" {
    $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
    <Configuration>
        <GlobalWebPath>D:\web</GlobalWebPath>
      <WebsiteCodeName>website-code</WebsiteCodeName>
      <WebFolderName>dummy</WebFolderName>
    </Configuration>
"@

    $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8

    $config = Get-ScProjectConfig

    It "WebRoot should be GlobalWebPath + WebsiteCodeName + WebFolderName" {
      $config.WebRoot | Should Be "D:\web\website-code\dummy"
    }
  }

  Context "When there is a WebRoot" {
        $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
        <Configuration>
            <GlobalWebPath>D:\dummy</GlobalWebPath>
          <WebsiteCodeName>website-dummy</WebsiteCodeName>
          <WebFolderName>dummy</WebFolderName>
          <WebRoot>D:\veredummy</WebRoot>
        </Configuration>
"@

        $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8

        $config = Get-ScProjectConfig

        It "Should return the WebRoot" {
            $config.WebRoot | Should Be "D:\veredummy"
        }
    }
    Context "When there is an XML config entry" {
        $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
        <Configuration>
            <XmlConfig>
                <SubConfig Foo="Bar" />
            </XmlConfig>
        </Configuration>
"@

        $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8

        $config = Get-ScProjectConfig


        It "Should be an array" {
            $config.XmlConfig.GetType() | Should Be "System.Object[]"
        }

        It "Should be an array with XmlElements" {
            $config.XmlConfig[0].GetType() | Should Be System.Xml.XmlElement
        }
    }
    Context "When there is an XML config entry with multiple elements" {
        $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
        <Configuration>
            <XmlConfig>
                <SubConfig Foo="Bar" />
                <SubConfig Foo="Bar" />
            </XmlConfig>
        </Configuration>
"@

        $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8

        $config = Get-ScProjectConfig


        It "Should return the WebRoot" {
            $config.XmlConfig.GetType() | Should Be "System.Object[]"
        }

        It "Should return the WebRoot" {
            $config.XmlConfig[0].GetType() | Should Be System.Xml.XmlElement
        }
    }
    Context "When there is an XML config entry which is set in Bob.config and Bob.config.user" {
        $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
    <XmlConfig>
        <SubConfig Foo="Bar One" />
        <SubConfig Foo="Bar Two" />
    </XmlConfig>
</Configuration>
"@
        $bobUserConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
    <XmlConfig>
        <SubConfig Foo="Bar Three" />
        <SubConfig Foo="Bar Four" />
    </XmlConfig>
</Configuration>
"@

        $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8
        $bobUserConfig | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8

        $config = Get-ScProjectConfig

        It "should merge values" {
            $config.XmlConfig.Count | Should Be 4
            $config.XmlConfig[2].Foo | Should Be "Bar Three"
        }
    }
        Context "When there is an XML config entry which is set in Bob.config and Bob.config.user with only one child element" {
            $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
    <XmlConfig>
        <SubConfig Foo="Bar One" />
    </XmlConfig>
</Configuration>
"@
            $bobUserConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
    <XmlConfig>
        <SubConfig Foo="Bar Two" />
    </XmlConfig>
</Configuration>
"@

            $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8
            $bobUserConfig | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8

            $config = Get-ScProjectConfig

            It "should merge values" {
                $config.XmlConfig.Count | Should Be 2
                $config.XmlConfig[1].Foo | Should Be "Bar Two"
            }
        }

    Context "When there is an XML config entry in Bob.config and Bob.config.user with a same element" {
        $bobConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
<XmlConfig>
    <SubConfig Foo="Bar One" />
</XmlConfig>
</Configuration>
"@
        $bobUserConfig = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
<XmlConfig>
    <SubConfig Foo="Bar One" />
    <SubConfig Foo="Bar Two" />
</XmlConfig>
</Configuration>
"@

        $bobConfig | Out-File "TestDrive:\Bob.config" -Encoding UTF8
        $bobUserConfig | Out-File "TestDrive:\Bob.config.user" -Encoding UTF8

        $config = Get-ScProjectConfig

        It "should merge values without duplicating it" {
            $config.XmlConfig.Count | Should Be 2
            $config.XmlConfig[1].Foo | Should Be "Bar Two"
        }
    }
}
