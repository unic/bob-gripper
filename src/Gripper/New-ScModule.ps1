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
        function InstallCompilersNugetPackages()
        {
            Install-Package Microsoft.CodeDom.Providers.DotNetCompilerPlatform -Version 1.0.1 -ProjectName $projectName | Out-Null
            Install-Package Microsoft.Net.Compilers -Version 1.0.0 -ProjectName $projectName | Out-Null
        }
        
        function InstallAspMvcNugetPackages()
        {
            Install-Package Newtonsoft.Json -Version 6.0.8 -ProjectName $projectName | Out-Null
            Install-Package Microsoft.AspNet.Mvc -Version 5.2.3 -ProjectName $projectName | Out-Null
        }
        
        function InstallAspWebApiNugetPackages()
        {
            Install-Package Microsoft.AspNet.WebApi -Version 5.2.3 -ProjectName $projectName | Out-Null
        }
        
        function InstallWebInfrastructureNugetPackage()
        {
            Install-Package Microsoft.Web.Infrastructure -Version 1.0.0 -ProjectName $projectName | Out-Null
        }
        
        function InstallSitecoreNugetPackages($sitecoreVersion)
        {
            Install-Package Sitecore -Version $sitecoreVersion -ProjectName $projectName | Out-Null
            Install-Package Sitecore.Kernel -Version $sitecoreVersion -ProjectName $projectName | Out-Null
            Install-Package Sitecore.Mvc -Version $sitecoreVersion -ProjectName $projectName | Out-Null
        }
        
        function InstallNunitNugetPackage()
        {
            Install-Package nunit -Version 3.2.0 -ProjectName $testProjectName | Out-Null
        }
        
        if (!$dte) {
            
            Write-Error "The script must be executed in the context of Visual Studio solution."
            
        }
       
        $moduleType = Read-Host "Please enter the type of your module ('Feature', 'Foundation' or 'Project')"
        
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
        
        $config = Get-ScProjectConfig
        
        $sitecoreVersion = $config.SitecoreVersion
        
        if ($moduleType -eq 'Feature') {
            
            $projectName =  "$solutionName.$moduleType.$moduleName"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Feature -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            InstallAspMvcNugetPackages
            InstallWebInfrastructureNugetPackage
            InstallSitecoreNugetPackages($sitecoreVersion)
        }
        
        if($moduleType -eq 'Foundation') {
            
            $projectName =  "$solutionName.$moduleType.$moduleName"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Foundation -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            InstallCompilersNugetPackages
            InstallAspMvcNugetPackages
            InstallSitecoreNugetPackages($sitecoreVersion)
        }
            
        if ($moduleType -eq 'Project') {
            
            $projectName =  "$solutionName.$moduleName.Website"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Project -Replacements @{"ProjectName" = "$projectName"; "ModuleName" = $moduleName} -OutputLocation $codeDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$codeDir\$projectName.$projectExtensionName") | Out-Null
            
            InstallCompilersNugetPackages
            InstallAspMvcNugetPackages
            InstallAspWebApiNugetPackages
            InstallSitecoreNugetPackages($sitecoreVersion)
        }
        
        switch($createTest.ToLower()) {
                   
            {($_ -eq "y") -or ($_ -eq "yes")} { 
                        
            $testsDir = Join-Path $solutionFolder "src\$moduleType\$moduleName\Tests"

            mkdir $testsDir | Out-Null
            
            $testProjectName =  "$solutionName.$moduleType.$moduleName.Tests"
            
            New-ScProject -TemplateLocation $PSScriptRoot\..\Templates\Tests -Replacements @{"ProjectName" = "$testProjectName"} -OutputLocation $testsDir | Out-Null                     
                 
            $moduleNameVisualStudioFolder.Object.AddFromFile("$testsDir\$testProjectName.$projectExtensionName") | Out-Null
            
            InstallNunitNugetPackage
            
            $projectObject = Get-Project $projectName
            $testProjectObject = Get-Project $testProjectName
            
            $testProjectObject.Object.References.AddProject($projectObject) | Out-Null                                    
            }
        }
        
        Write-Host "The set up has been completed successfully."        
    }
}