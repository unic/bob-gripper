<#
.SYNOPSIS
Creates new projects for a new project module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new project module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.

.EXAMPLE
New-ProjectModule

#>
function New-ProjectModule
{
    [CmdletBinding()]
    Param()
    Process
    {
        New-ScHelixModule "Project"
    }
}