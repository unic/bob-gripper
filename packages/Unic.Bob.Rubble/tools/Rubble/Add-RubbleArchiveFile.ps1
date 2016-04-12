<#
.SYNOPSIS
Adds a file or folder to a  ZIP file.
.DESCRIPTION
Adds a file or folder to a  ZIP file.
If the ZIP does not exist yet, it will be created.

.PARAMETER Path
The path to add to the ZIP file.

.PARAMETER ArchivePath
The path to the ZIP file.

.PARAMETER RelativeToPath
An optional parameter which specifies relative to which folder the items get added.
So when adding D:\a\b\c\d\e with RelativeToPath D:\a\b the path inside the ZIP file 
will be c\d\e
If its not specified the parent of $Path will be taken.

.EXAMPLE
Add-RubbleArchiveFile -Path D:\temp\example D:\temp\example.zip

.EXAMPLE
Add-RubbleArchiveFile -Path D:\temp\example\a\b -ArchvivePath D:\temp\example.zip -RelativeToPath D:\temp\example

#>
function Add-RubbleArchiveFile
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [string] $ArchivePath,
        [string] $RelativeToPath
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

        
        if(-not $RelativeToPath) {
            $RelativeToPath = (Split-Path $Path -Parent)
        }
        $RelativeToPath = Resolve-Path $RelativeToPath
        
        if((Get-Item $Path) -is [System.IO.DirectoryInfo]) {
            ls $Path -Recurse | ? { -not $_.PSIsContainer } | % {
                $relativePath = $_.FullName.Replace($RelativeToPath, "")
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
