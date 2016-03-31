<#
.SYNOPSIS
Adds a file or folder to a  ZIP file.
.DESCRIPTION
Adds a file or folder to a  ZIP file.
If the ZIP does not exist yet, it will be created.

.PARAMETER $Path
The path to add to the ZIP file.

.PARAMETER ArchivePath
The path to the ZIP file.

.EXAMPLE
Add-RubbleArchiveFile -Path D:\temp\example D:\temp\example.zip

#>
function Add-RubbleArchiveFile
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [string] $ArchivePath
    )
    Process
    {
        if(-not (Test-Path $ArchivePath)) {
            $file = [System.IO.File]::Create($ArchivePath)
            $stream = New-Object ICSharpCode.SharpZipLib.Zip.ZipOutputStream $file
            $stream.Finish()
            $stream.Close()
        }

        $zip = New-Object ICSharpCode.SharpZipLib.Zip.ZipFile $ArchivePath
        $zip.BeginUpdate()

        $parentPath = (Resolve-Path (Split-Path $Path -Parent))

        if((Get-Item $Path) -is [System.IO.DirectoryInfo]) {
            ls $Path -Recurse | ? { -not $_.PSIsContainer } | % {
                $relativePath = $_.FullName.Replace($parentPath, "")
                $zip.Add($_.FullName, $relativePath)
            }
        }
        else {
            $zip.Add($Path, (Get-Item $Path).Name)
        }
        $zip.CommitUpdate()
        $zip.Close()
    }
}
