<#
.SYNOPSIS
Extracts a ZIP file.

.DESCRIPTION
Extracts a ZIP file.

.PARAMETER Path
The path to the ZIP file.

.PARAMETER OutputLocation
The path where to extract the content of the file.

.EXAMPLE
Expand-RubbleArchive -Path D:\temp\archive.zip -OutputLocation d:\temp\output

#>
function Expand-RubbleArchive
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
      $zip.ExtractZip($Path,$OutputLocation, $null)
    }
}
