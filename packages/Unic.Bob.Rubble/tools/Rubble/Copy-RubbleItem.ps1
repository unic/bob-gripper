<#
.SYNOPSIS
Copies items in a folder based on a pattern to a specific location.

.DESCRIPTION
Copies files from a specific location to another.
Optionally patterns can be specified, to only copy a subset of files.

.PARAMETER Path
The path to copy from.

.PARAMETER Destination
The path to copy to.


.PARAMETER Pattern
An array of patterns. If specified only files matching this patternm, will be copied.
A pattern must be in the format an PowerShell `-like` argument.

.EXAMPLE
Copy-RubbleItem -Path D:\source -Destination d:\target  -Pattern *.config, "App_Config\*\*.example"

#>
function Copy-RubbleItem
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $Path,
      [Parameter(Mandatory=$true)]
      [string] $Destination,
      [String[]] $Pattern,
      [ValidateSet("CopyAll", "DoNothing")]
      [String] $NoFilesAction = "CopyAll"
  )
  Process
  {
    $Path = $Path.TrimEnd("\") + "\"

    if($Pattern) {
      $files = @()
      foreach($file in (ls $Path -Recurse )) {
        $relativePath = $file.FullName -replace  ([Regex]::Escape($Path)), ""
        foreach($filter in $Pattern) {
          if($relativePath -like $filter) {
            $files += $relativePath
            break;
          }
        }
      }
    }
    if($files) {
      Write-Verbose "Found files to copy: $([string]::Join(', ', $files))"
    }
    else {
      Write-Verbose "Copy all files"
    }

    if($files) {
      $files | % {
        $target = (Join-Path $Destination $_)
        $parent = Split-Path $target
        if(-not (Test-Path $parent)) {
          mkdir $parent | Out-Null
        }
        cp (Join-Path $Path $_) $target
      }
    }
    elseif($NoFilesAction -eq "CopyAll") {
      cp $Path\* $Destination -Recurse
    }
  }
}
