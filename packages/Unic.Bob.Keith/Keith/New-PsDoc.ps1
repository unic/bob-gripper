<#
.SYNOPSIS
Generates a new documentation for a PowerShell module.

.DESCRIPTION
Generates a new documentation for a PowerShell module,
by merging the handwritten and the API documentation.

.PARAMETER Path
The path to the handwritten documentation.

.PARAMETER OutputLocation
The path to a folder where the generated documentation should be written.

.PARAMETER Module
The name of the PowerShell module, for which the API doc should be generated.

.EXAMPLE
New-PsDoc -Path .\docs -OutputLocation .\docs-generated -Module keith

#>
function New-PsDoc
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [string] $OutputLocation,
        [string] $Module
    )
    Process
    {
        if(-not (Test-Path $OutputLocation)){
            mkdir $OutputLocation | Out-Null
        }
        cp $Path\* $OutputLocation -Recurse -Force
        if($Module) {
            New-PsApiDoc -Path $OutputLocation -Module $Module
        }
    }
}
