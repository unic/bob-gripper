<#
.SYNOPSIS
Creates new projects for a new foundation module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new foundation module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.

.EXAMPLE
New-FoundationModule

#>
function New-FoundationModule
{
    [CmdletBinding()]
    Param()
    Process
    {
        New-ScHelixModule "Foundation"
    }
}