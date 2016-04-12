<#
.SYNOPSIS
Sets a config value in the Bob.config.user

.DESCRIPTION
Sets a config value in the current Bob.config.user.
If the file does not exist yet, it will be created.
If the Bob.config.user does not contain a Key yet, it will be added.

.PARAMETER Key
The config key to set

.PARAMETER Value
The value to set.

.PARAMETER ProjectPath
If specified, the Bob.config.user will be searched inside this path.

.PARAMETER ConfigFileName
A list of config file names which will be used to find the correct project, when no ProjectPath was provided.

.EXAMPLE

#>

function Set-ScUserConfigValue
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string]$Key,
      [Parameter(Mandatory=$true)]
      [string]$Value,
      [String]$ProjectPath = "",
      [String[]]$ConfigFileName = @("Bob.config", "Bob.config.user")
  )
  Process
  {
    $ProjectPath = Get-ScProjectPath -ProjectPath $ProjectPath -ConfigFileName $ConfigFileName

    if(-not $ProjectPath) {
      throw "No ProjectPath could be found. Please provide one."
    }

    $path = Join-Path $ProjectPath "Bob.config.user"
    if(-not (Test-Path $path)) {
      @"
<?xml version="1.0"?>
<Configuration>
</Configuration>
"@ | Out-File $path -Encoding UTF8
    }

    $document = ([xml](Get-Content $path))
    $root = $document.SelectSingleNode("/Configuration")
    if(-not $root) {
    return
      throw "No configuration node in config file $path"
    }

    $node = $root.SelectSingleNode("//$Key")
    if(-not $node) {
      $node = $document.CreateElement($key);
      $root.AppendChild($node)
    }

    $node.InnerText = $value

    $document.Save((Resolve-Path $path))
  }
}
