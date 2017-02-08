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
        
        if (!$dte) {
            Write-Error "The script must be executed in the context of Visual Studio solution."
        }
       
        if ((-not $moduleType -eq 'Feature') -or (-not $moduleType -eq 'Foundation') -or (-not $moduleType -eq 'Project')) {
            Write-Warn "Module type should be either 'Feature', 'Foundation' or 'Project'."
        }
        
        $moduleName = Read-Host "Please enter the short name of your module (i.e. 'Identity')"   
        
        if ( [string]::IsNullOrEmpty($moduleName)) {
            Write-Error "Module name is required."
        }
        
        $config = Get-ScProjectConfig
                
        $codeTemplate = "$PSScriptRoot\..\Templates\Code"
        if($config.GripperCodeTemplate) {
            $codeTemplate = Resolve-Path $config.GripperCodeTemplate
        }

        $solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
        $solutionFolder = Split-Path -Parent $solutionNode.FullName
        $solutionName = [System.IO.Path]::GetFileNameWithoutExtension($solutionNode.FullName)

        $moduleTypeVisualStudioFolder = $solutionNode.Projects | where-object { $_.ProjectName -eq $moduleType } | Select -First 1  
        $moduleNameVisualStudioFolder = $moduleTypeVisualStudioFolder.Object.AddSolutionFolder($moduleName)
        
        $projectName =  "$solutionName.$moduleType.$moduleName"
        if($moduleType -eq "Project") {
            $projectName =  "$solutionName.$moduleName.Website"
        }

        $codeVisualStudioProjectPath = "ProjectName.csproj"
        if($config.GripperCodeVisualStudioProjectPath) {
             $codeVisualStudioProjectPath = $config.GripperCodeVisualStudioProjectPath
        }

        $codeDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\code"

        CreateVisualStudioProject -Directory $codeDir `
            -ProjectName $projectName `
            -ModuleName $moduleName `
            -ModuleType $moduleType `
            -TemplateLocation $codeTemplate `
            -VisualStudioProjectPathTemplate $codeVisualStudioProjectPath `
            -NugetPackages $config.GripperCodeProjectNugetPackages
        
        if($moduleType -ne "Project") {
            $testTemplate = "$PSScriptRoot\..\Templates\Tests"
            if($config.GripperTestTemplate) {
                $testTemplate = Resolve-Path $config.GripperTestTemplate
            }
            
            $testsDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\tests"
            $testProjectName =  "$solutionName.$moduleType.$moduleName.Tests"

            $testVisualStudioProjectPath = "ProjectName.csproj"
            if($config.GripperTestVisualStudioProjectPath) {
                $testVisualStudioProjectPath = $config.GripperTestVisualStudioProjectPath
            }

            CreateVisualStudioProject -Directory $testsDir `
                -ProjectName $testProjectName `
                -ModuleName $moduleName `
                -ModuleType $moduleType `
                -TemplateLocation $testTemplate `
                -VisualStudioProjectPathTemplate $testVisualStudioProjectPath `
                -NugetPackages $config.GripperTestProjectNugetPackages

            $projectObject = Get-Project $projectName
            $testProjectObject = Get-Project $testProjectName
            $testProjectObject.Object.References.AddProject($projectObject) | Out-Null      
        }

        Write-Host "The set up has been completed successfully."        
    }

    begin {
        function InstallNugetPackages($projectName, $packages) {
            foreach($package in $packages) {
                Install-Package $package.ID -Version $package.Version -ProjectName $projectName 
            }
        }

        function CreateVisualStudioProject(
            $directory,
            $projectName,
            $moduleName,
            $moduleType,
            $templateLocation,
            $visualStudioProjectPathTemplate,
            $nugetPackages
        ) {
            mkdir $directory | Out-Null

            New-ScProject -TemplateLocation $templateLocation -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName; "ModuleType" = "$moduleType"} -OutputLocation $directory | Out-Null 
            
            $visualStudioProjectPath = $visualStudioProjectPathTemplate.Replace("ProjectName", $projectName)            
            write-host "$directory\$visualStudioProjectPath"        
            $moduleNameVisualStudioFolder.Object.AddFromFile("$directory\$visualStudioProjectPath") | Out-Null
            if($nugetPackages) {
                InstallNugetPackages $projectName $nugetPackages
            }
        }
    }
}