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
    Param(
    )
    Process
    {
        $moduleName = Read-Host "Please enter the name of your module"
        $moduleType = Read-Host "Please enter the type of your module"
        $createTest = Read-Host "Please enter if you want to create a test project for your module"
        
        Write-Verbose $moduleName
        Write-Verbose $moduleType
        Write-Verbose $createTest        
    }
}