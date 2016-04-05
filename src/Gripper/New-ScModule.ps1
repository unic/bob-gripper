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
        
        if ($moduleType -eq 'Feature') {
            
            
            
        }
        
        if($moduleType -eq 'Foundation') {
            
            
            
        }
            
        if ($moduleType -eq 'Project') {
                
                $solutionNode = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
                $solutionFolder = Split-Path -Parent $solutionNode.FullName
                
                Write-Verbose $solutionFolder
                
                Write-Verbose $titledModuleType
                
                $codeDir = Join-Path $solutionFolder "src/$titledModuleType/$moduleName/code"
                
                Write-Verbose $codeDir
                
                mkdir $codeDir
                
                $serializationDir = Join-Path $solutionFolder "src/$titledModuleType/$moduleName/serialization"
                
                Write-Verbose $serializationDir
                
                mkdir $serializationDir
                
                switch($createTest.ToLower())
                {
                    {($_ -eq "y") -or ($_ -eq "yes")} { 
                        
                        $testsDir = Join-Path $solutionFolder "src/$titledModuleType/$moduleName/Tests"
                        
                        Write-Verbose $testsDir
                        
                        mkdir $testsDir
                                                
                    }
                } 
            }    
    }
}