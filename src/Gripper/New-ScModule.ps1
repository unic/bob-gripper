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
        
        $moduleType = Read-Host "Please enter the type of your module ([f]eature, f[o]undation or [p]roject)"
        $moduleName = Read-Host "Please enter the name of your module (i.e. 'Sitecore.Feature.Identity')"
        $createTest = Read-Host "Please enter if you want to create a test project for your module ([y]es or [n]o)"
        
        if ([string]::IsNullOrEmpty($moduleType) -or  [string]::IsNullOrEmpty($moduleName) -or [string]::IsNullOrEmpty($createTest))
        {
            Write-Error "Module type, name and whether to create a test project are required."
        }
        
        switch($moduleType.ToLower())
        {
            {($_ -eq "f") -or ($_ -eq "feature")} { 
                
                
                                                
            } 
            
            {($_ -eq "o") -or ($_ -eq "foundation")} {
                
                                
                
            }
            
            {($_ -eq "p") -or ($_ -eq "project")} {
                
                Install-Package Microsoft.AspNet.Mvc -Version 5.2.3
                
            }
            
            default {
                
                Write-Error "This module type does not exist."
                
            } 
        }      
    }
}