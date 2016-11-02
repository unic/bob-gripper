<#
.SYNOPSIS
Creates new projects for a new module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.

.PARAMETER moduleType 
The type of the module to bootstrap.

.EXAMPLE
New-ScHelixModule "Feature"

#>
function New-ScHelixModule
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $moduleType
    )
    Process
    {
        function InstallNugetPackages($projectName, $packages) {
            foreach($package in $packages) {
                Install-Package $package.ID -Version $package.Version -ProjectName $projectName 
            }
        }
        
        if (!$dte) {
            
            Write-Error "The script must be executed in the context of Visual Studio solution."
            
        }
       
        if ((-not $moduleType -eq 'Feature') -or (-not $moduleType -eq 'Foundation') -or (-not $moduleType -eq 'Project'))
        {
            Write-Error "Module type must be either 'Feature', 'Foundation' or 'Project'."
        }
        
        $moduleName = Read-Host "Please enter the short name of your module (i.e. 'Identity')"
        $createTest = Read-Host "Please enter if you want to create a test project for your module ([y]es or [n]o)"       
        
        if ([string]::IsNullOrEmpty($moduleType) -or  [string]::IsNullOrEmpty($moduleName) -or [string]::IsNullOrEmpty($createTest))
        {
            Write-Error "Module type, name and whether to create a test project are required."
        }
        
        $config = Get-ScProjectConfig
        
        $sitecoreVersion = $config.SitecoreVersion
        
        if ([string]::IsNullOrEmpty($sitecoreVersion))
        {
            Write-Error "The Sitecore version must be set in Bob.config"
        }
        
        $solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
        $solutionFolder = Split-Path -Parent $solutionNode.FullName
        $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($solutionNode.FullName)

        $codeDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\code"
                
        mkdir $codeDir | Out-Null
                
        $serializationDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\serialization"
                
        mkdir $serializationDir | Out-Null
                
        $moduleTypeVisualStudioFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq $moduleType } | Select -First 1  
        
        $moduleNameVisualStudioFolder = $moduleTypeVisualStudioFolder.Object.AddSolutionFolder($moduleName)
        
        $projectName = "" 
        $projectExtensionName = "csproj"
        
        if ($moduleType -eq 'Feature') {
            
            $projectName =  "$solutionName.$moduleType.$moduleName"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Feature -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            if($config.GripperCodeProjectNugetPackages) {
                InstallNugetPackages $projectName $config.GripperCodeProjectNugetPackages
            }
        }
        
        if($moduleType -eq 'Foundation') {
            
            $projectName =  "$solutionName.$moduleType.$moduleName"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Foundation -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            if($config.GripperCodeProjectNugetPackages) {
                InstallNugetPackages $projectName $config.GripperCodeProjectNugetPackages
            }
        }
            
        if ($moduleType -eq 'Project') {
            
            $projectName =  "$solutionName.$moduleName.Website"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Project -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            if($config.GripperCodeProjectNugetPackages) {
                InstallNugetPackages $projectName $config.GripperCodeProjectNugetPackages
            }
        }
        
        switch($createTest.ToLower()) {
                   
            {($_ -eq "y") -or ($_ -eq "yes")} { 
                        
                $testsDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\tests"

                mkdir $testsDir | Out-Null
            
                $testProjectName =  "$solutionName.$moduleType.$moduleName.Tests"
            
                New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Tests -Replacements @{"ProjectName" = "$testProjectName"} -OutputLocation $testsDir | Out-Null                     
                 
                $moduleNameVisualStudioFolder.Object.AddFromFile("$testsDir\$testProjectName.$projectExtensionName") | Out-Null
            
                if($config.GripperTestProjectNugetPackages) {
                    InstallNugetPackages $testProjectName $config.GripperTestProjectNugetPackages
                }
            
                $projectObject = Get-Project $projectName
                $testProjectObject = Get-Project $testProjectName
            
                $testProjectObject.Object.References.AddProject($projectObject) | Out-Null                                    
            }
        }
        
        Write-Host "The set up has been completed successfully."        
    }
}