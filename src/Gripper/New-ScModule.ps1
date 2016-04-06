<#
.SYNOPSIS
Creates new projects for a new module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new module according to our architecture guidelines.

.EXAMPLE
New-ScModule

#>

function New-ScModule
{
    [CmdletBinding()]
    Param()
    Process
    {
        if (!$dte) {
            
            Write-Error "The script must be executed in the context of Visual Studio solution."
            
        }
        
        $moduleType = Read-Host "Please enter the type of your module ('Feature', 'Foundation' or 'Project')"
        $moduleName = Read-Host "Please enter the short name of your module (i.e. 'Identity')"
        $createTest = Read-Host "Please enter if you want to create a test project for your module ([y]es or [n]o)"
        
        if ([string]::IsNullOrEmpty($moduleType) -or  [string]::IsNullOrEmpty($moduleName) -or [string]::IsNullOrEmpty($createTest))
        {
            Write-Error "Module type, name and whether to create a test project are required."
        }
        
        $solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
        $solutionFolder = Split-Path -Parent $solutionNode.FullName
        $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($solutionNode.FullName)

        $codeDir = Join-Path $solutionFolder "src/$moduleType/$moduleName/code"
                
        mkdir $codeDir | Out-Null
                
        $serializationDir = Join-Path $solutionFolder "src/$moduleType/$moduleName/serialization"
                
        mkdir $serializationDir | Out-Null
                
       switch($createTest.ToLower()) {
                   
            {($_ -eq "y") -or ($_ -eq "yes")} { 
                        
            $testsDir = Join-Path $solutionFolder "src/$moduleType/$moduleName/Tests"

            mkdir $testsDir | Out-Null
                                            
            }
        }     
        
        $moduleTypeVisualStudioFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq $moduleType } | Select -First 1  
        
        $moduleNameVisualStudioFolder = $moduleTypeVisualStudioFolder.AddSolutionFolder($moduleName)
        
        if ($moduleType -eq 'Feature') {
            
        }
        
        if($moduleType -eq 'Foundation') {
            
        }
            
        if ($moduleType -eq 'Project') {
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\WebsiteProject -Replacements @{"ProjectName" = "$solutionName.$moduleName"} -OutputLocation $codeDir | Out-Null                     
                 
        }
        
        $moduleNameVisualStudioFolder.AddFromFile("$codeDir/$solutionName.$moduleName.Website.csproj")
    }
}