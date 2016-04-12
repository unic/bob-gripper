<#
.SYNOPSIS
Generates the documentation for a specific module.

.DESCRIPTION
Generates the documentation for a specific module.


.PARAMETER ModuleName
The name of the module for which the documentation should be generated.


.PARAMETER Path
The Path where the documentation should be written to.



.EXAMPLE
New-PSApiDoc -ModuleName Dummy -Path "${env:TEMP}\DummyDoc"

Generate the documentation for the "Dummy" module to a temp directory.



#>
function New-PSApiDoc
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ModuleName,
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    Process
    {
        $moduleData = Get-Module -Name $ModuleName | Select -Last 1
        $commands = $moduleData.ExportedCommands | Select-Object -ExpandProperty 'Keys' | % {Get-Help $_ -Detailed}
        $apiPath = "$Path\api\"

        if(Test-Path $apiPath) {
            rm $apiPath -Recurse
        }
        mkdir $apiPath | Out-Null

        $basePath = Resolve-Path "$PSScriptRoot\..\Templates"
        Format-RazorTemplate (Get-Content "$basePath\README.cshtml" -Raw) @{"Module"= $moduleData; "Commands"= $commands} |
            Out-File "$apiPath\README.md" -Encoding ASCII

        $apiSummary = Format-RazorTemplate (Get-Content "$basePath\SUMMARY.cshtml" -Raw) @{"Module"= $moduleData; "Commands"= $commands}
        (Get-Content "$Path\SUMMARY.md" -Raw) -replace "##API##", $apiSummary.Trim() |
            Out-File "$Path\SUMMARY.md" -Encoding ASCII

        foreach($command in $commands) {
            $template = Get-Content "$basePath\_command.cshtml" -Raw
            $outPath = "$apiPath\$($command.Name).md"
            if($command.examples.example -is [PSObject]) {
                $command.examples.example = @($command.examples.example)
            }
            if($command.PARAMETERS.parameter -is [PSObject]) {
                $command.PARAMETERS.parameter = @($command.PARAMETERS.parameter)
            }
            Format-RazorTemplate $template @{"Module"= $moduleData; "Command"= $command} | Out-File $outPath -Encoding ASCII
        }
    }
}
