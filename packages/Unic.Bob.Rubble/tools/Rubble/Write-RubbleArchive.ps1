<#
.SYNOPSIS
Writes the content of a folder to a ZIP file.
.DESCRIPTION
Writes the content of a folder to a ZIP file.

.PARAMETER Path
The folder to pack.

.PARAMETER OutputLocation
The ZIP file to write.

.EXAMPLE
Write-RubbleArchive D:\example D:\example.zip

#>
function Write-RubbleArchive
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $Path,
      [Parameter(Mandatory=$true)]
      [string] $OutputLocation
  )
  Process
  {
    $zip = New-Object ICSharpCode.SharpZipLib.Zip.FastZip
    $zip.CreateZip($OutputLocation,$Path,$true, $null)
  }
}
