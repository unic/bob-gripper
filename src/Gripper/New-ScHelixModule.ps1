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
            Write-Warn "Module type should be either 'Feature', 'Foundation' or 'Project'."
        }
        
        $moduleName = Read-Host "Please enter the short name of your module (i.e. 'Identity')"   
        
        if ([string]::IsNullOrEmpty($moduleType) -or  [string]::IsNullOrEmpty($moduleName))
        {
            Write-Error "Module type, name and whether to create a test project are required."
        }
        
        $config = Get-ScProjectConfig
                
        $codeTemplate = "$PSScriptRoot\..\Templates\Code"
        if($config.GripperCodeTemplate) {
            $codeTemplate = Resolve-Path $config.GripperCodeTemplate
        }

        $solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
        $solutionFolder = Split-Path -Parent $solutionNode.FullName
        $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($solutionNode.FullName)

        $codeDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\code"
        mkdir $codeDir | Out-Null
        $moduleTypeVisualStudioFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq $moduleType } | Select -First 1  
        $moduleNameVisualStudioFolder = $moduleTypeVisualStudioFolder.Object.AddSolutionFolder($moduleName)
        $projectExtensionName = "csproj"
        $projectName =  "$solutionName.$moduleType.$moduleName"
        if($moduleType -eq "Project") {
            $projectName =  "$solutionName.$moduleName.Website"
        }
        New-ScProject -TemplateLocation $codeTemplate -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName; "ModuleType" = "$moduleType"} -OutputLocation $codeDir | Out-Null                     
        $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
        if($config.GripperCodeProjectNugetPackages) {
            InstallNugetPackages $projectName $config.GripperCodeProjectNugetPackages
        }


        if($moduleType -ne "Project") {
            $testTemplate = "$PSScriptRoot\..\Templates\Tests"
            if($config.GripperTestTemplate) {
                $testTemplate = Resolve-Path $config.GripperTestTemplate
            }
            
            $testsDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\tests"
            mkdir $testsDir | Out-Null
            $testProjectName =  "$solutionName.$moduleType.$moduleName.Tests"
            New-ScProject -TemplateLocation $testTemplate -Replacements @{"ProjectName" = "$testProjectName";  "ModuleName" = $moduleName; "ModuleType" = "$moduleType"} -OutputLocation $testsDir | Out-Null                     
            $moduleNameVisualStudioFolder.Object.AddFromFile("$testsDir\$testProjectName.$projectExtensionName") | Out-Null
            if($config.GripperTestProjectNugetPackages) {
                InstallNugetPackages $testProjectName $config.GripperTestProjectNugetPackages
            }
        
            $projectObject = Get-Project $projectName
            $testProjectObject = Get-Project $testProjectName
            $testProjectObject.Object.References.AddProject($projectObject) | Out-Null      
        }

        Write-Host "The set up has been completed successfully."        
    }
}