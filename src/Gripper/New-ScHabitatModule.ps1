<#
.SYNOPSIS
Creates new projects for a new module according to our architecture guidelines.

.DESCRIPTION
Creates new projects for a new module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.

.PARAMETER moduleType 
The type of the module to bootstrap.

.EXAMPLE
New-ScHabitatModule "Feature"

#>
function New-ScHabitatModule
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $moduleType
    )
    Process
    {
        Write-Warning "New-ScHabitatModule is deprecated, plase use New-ScHelixModule. Checkout http://helix.sitecore.net/introduction/what-is-helix.html to read about the difference between Helix and Habitat."
        New-ScHelixModule $moduleType
        Write-Warning "New-ScHabitatModule is deprecated, plase use New-ScHelixModule. Checkout http://helix.sitecore.net/introduction/what-is-helix.html to read about the difference between Helix and Habitat."
    }
}