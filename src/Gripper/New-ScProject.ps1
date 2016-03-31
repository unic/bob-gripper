<#
.SYNOPSIS
Creates a new instance of Sitecore project or module based on a specific template.

.DESCRIPTION
Creates a new instance of Sitecore project or module based on a specific
template by copying all folders and replacing the specified replacements in
the file content and all file and folder names.

.PARAMETER TemplateLocation
The location to the template.

.PARAMETER Replacements
A hashtable of replacements to use. It will always use the PascalCase and
camelCase of a replacement. This means when @{"Customer"="Unic"} all instances
of Customer will be replaced by Unic and all instances of customer will be
replaced by unic.

.PARAMETER OutputLocation
The folder where the resulting project will be written to.

.EXAMPLE
New-ScProject -TemplateLocation D:\bob-boilerplate -Replacements @{"Customer" = "Unic"} -OutputLocation D:\unic-website

#>
function New-ScProject
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $TemplateLocation,
        [Parameter(Mandatory=$true)]
        [Hashtable] $Replacements,
        [Parameter(Mandatory=$true)]
        [string] $OutputLocation

    )
    Process
    {
        $TemplateLocation = (Get-Item (Resolve-Path $TemplateLocation).Path).FullName

        if(-not (Test-Path $OutputLocation)) {
            mkdir $OutputLocation
        }

        if((ls $OutputLocation).Length -gt 0) {
            Write-Error "$OutputLocation is not empty."
        }

        $OutputLocation = (Get-Item (Resolve-Path $OutputLocation).Path).FullName

        $fixedReplacements = Resolve-ScReplacements $Replacements

        ls $TemplateLocation -Directory -Recurse  | % {
            $relativeName = $_.FullName.Replace($TemplateLocation, "")
            $fixedReplacements.Keys | %{$relativeName = $relativeName.Replace($_, $fixedReplacements[$_])}
            $newFolderName = "$OutputLocation\$relativeName"
            if(-not (Test-Path $newFolderName)) { mkdir $newFolderName }
        }

        foreach($file in (ls $TemplateLocation -Recurse -File).FullName) {
            $relativeName = $file.Replace($TemplateLocation, "")
            $fixedReplacements.Keys | %{$relativeName = $relativeName.Replace($_, $fixedReplacements[$_])}
            $newFileName = "$OutputLocation\$relativeName"
            if(-not (Test-BinaryFile $file)) {
                $content = (Get-Content $file | Out-String)
                $fixedReplacements.Keys | %{$content = $content.Replace($_, $fixedReplacements[$_])}
                $content | Out-File -FilePath $newFileName  -Encoding utf8
            }
            else {
                cp $file $newFileName
            }
        }

    }
}
