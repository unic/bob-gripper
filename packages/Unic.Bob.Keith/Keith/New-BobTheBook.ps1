<#
.SYNOPSIS
Create a new book for all bob machines.
.DESCRIPTION
New-BobTheBook clones all bob machines, creates a book from their documentation
and merges all to one big "Bob - The Book"

.PARAMETER OutputLocation
The path to the location, where the repos should be cloned and the book written.

.PARAMETER Username
The username for the git repository.

.PARAMETER Password
The password for the git repository.

.PARAMETER BobTheBook
The path to the book which should be used as base for the book.

.EXAMPLE
New-BobTheBook D:\temp\bobthebook -Username yannis -Password Pass@word$ -BobTheBook D:\sources\bob-thebook
#>
function New-BobTheBook
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $OutputLocation,
        [Parameter(Mandatory=$true)]
        [string] $Username,
        [Parameter(Mandatory=$true)]
        [SecureString] $Password,
        [Parameter(Mandatory=$true)]
        [string] $BobTheBook
    )
    Process
    {
        $plainTextPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

        if(-not (Test-Path $OutputLocation)) {
            mkdir $OutputLocation | Out-Null
        }
        $bookDir = Join-Path $OutputLocation "book"

        if(Test-Path $bookDir) {
            rm $bookDir -Recurse -Force
        }
        mkdir $bookDir

        $machines = ConvertFrom-Json (Get-Content $PSScriptRoot\BobTheBook.json -Raw)
        $reposPath = Join-Path $OutputLocation "repos"
        if(Test-Path $reposPath) {
            rm $reposPath -Recurse -Force
        }
        mkdir $reposPath

        $cloneOptions = New-Object LibGit2Sharp.CloneOptions
        $credentials = New-Object LibGit2Sharp.UsernamePasswordCredentials
        $credentials.Username = $Username
        $credentials.Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        $cloneOptions.CredentialsProvider = {$credentials }

        $paket = ResolvePath "paket" "tools\paket.exe"

        $summary = ""

        foreach($machine in $machines) {
            $name = $machine.name
            $folder = Join-Path $reposPath $name
            [LibGit2Sharp.Repository]::Clone($machine.url, $folder, $cloneOptions)

            Push-Location $folder
            & $paket restore
            Pop-Location

            $docsFolder = Join-Path $folder "generated-docs"
            if($machine.module -and $machine.modulePath) {
                $modulePath = Join-Path $folder $machine.modulePath
                powershell -NoProfile -NoLogo -ExecutionPolicy Unrestricted {
                    param($keithPath, $modulePath, $docsFolder, $machineFolder, $moduleName)
                    Import-Module $keithPath
                    Import-Module (Join-Path $modulePath $moduleName)
                    New-PSDoc "$machineFolder\docs" $docsFolder $moduleName -Verbose
                } -args ((Get-Module Keith).Path), $modulePath, $docsFolder, $folder, $machine.module
            }
            else {
                if(-not (Test-Path $docsFolder)) {
                    mkdir $docsFolder
                }
                cp "$folder\docs\*" $docsFolder -Recurse
            }
            $machineFolder = "$bookDir\$name"
            mkdir $machineFolder
            cp "$docsFolder\*" $machineFolder -Recurse

            $summary += "* [$name]($name/README.md)" + "`n"
            $thisSummary = Get-Content "$docsFolder\SUMMARY.md"
            $editedSummary = foreach($line in $thisSummary) {
                if($line.Trim() -ne "") {
                    "    " + ($line -replace "(\[.*\])\((.*)\)", ('$1(' + $name +'/$2)')) + "`n"
                }
            }
            $summary += [string]::Join("", $editedSummary)
        }

        cp "$BobTheBook\*" $bookDir -Recurse
        $originalSummary = Get-Content "$bookDir\SUMMARY.md" -Raw
        $summary = $summary.Trim()
        $summary = $originalSummary.Replace("##MACHINES##", $summary)
        $summary | Out-File "$bookDir\SUMMARY.md" -Encoding UTF8

        if(-not (Test-Path ".\temp")) {
            mkdir ".\temp"
        }
        New-GitBook -GitBookPath $bookDir -TempPath (Resolve-Path ".\temp").Path -UserName $Username -Password $plainTextPassword -Buildserver:$true
    }
}
