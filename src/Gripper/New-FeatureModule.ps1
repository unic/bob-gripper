<#
.SYNOPSIS
Creates new projects for a new feature module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new feature module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.

.EXAMPLE
New-FeatureModule

#>
function New-FeatureModule
{
    [CmdletBinding()]
    Param()
    Process
    {
        New-ScHabitatModule "Feature"      
    }
}