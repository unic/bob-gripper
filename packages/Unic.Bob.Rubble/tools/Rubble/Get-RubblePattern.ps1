<#
.SYNOPSIS
Transforms a string with patterns and placeholders to an array of patterns

.DESCRIPTION
Transforms a string with multiple patterns and placeholders to an  array of patterens.
All patterns must be separated by a ';'.
Replacements are simple string replacements. Every occurence of a specific key
will be replaced by the specified value.


.PARAMETER Pattern
A semicolon separated list of patterns.

.PARAMETER Replacement
A hashtable of replacement. Every occurence of a specific key
will be replaced by the specified value.

.EXAMPLE
Get-RubblePattern "#role.config;env.config" @{"#role" = "myrole"; "env" = "myenv"}
This returns `@("myrole.config", "myenv.config")`
#>
function Get-RubblePattern
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $Pattern,
      [System.Collections.Hashtable] $Replacement = @{}
  )
  Process
  {
        $patterns = $Pattern.Split(';') | % {$_.Trim()} | ? {$_ -ne ""}
        $patterns = $patterns | % {
          $item = $_
          foreach($key in $Replacement.Keys) {
            $item = $item -replace ([Regex]::Escape($key)), $Replacement[$key]
          }
          $item
        }
        $patterns
  }
}
