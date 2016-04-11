<#
.SYNOPSIS
Reads the BOB configuration files and returns it as a hashtable
.DESCRIPTION
Reads the BOB configuration files and returns it as a hashtable
Per default the config file is taken from the the first Bob.config that we come across going from where we are upwards.
When there is a Bob.config.user file, string values will be overwritten by it
and XML elements will be merged.

.PARAMETER ProjectPath
The path of the project for which the config should be read.
If not provided the current Visual Studio project or the *.Website project will be used.

.PARAMETER ConfigFileName
The names of the config files


.EXAMPLE
Get-ScProjectConfig
.EXAMPLE
Get-ScProjectConfig -ProjectPath D:\projects\Spider\src\Spider.Website
#>

Function Get-ScProjectConfig
{
    [CmdletBinding(
        SupportsShouldProcess=$True,
        ConfirmImpact="Low"
    )]
    Param(
        [String]$ProjectPath = "",
        [String[]]$ConfigFileName = @("Bob.config", "Bob.config.user")
    )
    
    Process
    {
        $ProjectPath = Get-ScProjectPath -ProjectPath $ProjectPath -ConfigFileName $ConfigFileName

        if(-not $ProjectPath) {
            throw "No ProjectPath could be found. Please provide one."
        }

        $config = @{
            "WebsitePath" = $ProjectPath
        }
        foreach($configFile in $ConfigFileName) {
            $path = Join-Path $ProjectPath "$configFile"
            if(Test-Path $path) {
                Write-Verbose "Read config file $path"
                $xml = [xml](Get-Content $path )
                if($xml.Configuration) {
                    foreach($node in $xml.Configuration.ChildNodes) {
                        if($node.NodeType -eq "Element") {
                            Write-Verbose "Read config-key $($node.Name) with value $($node.InnerText)"
                            $childElements = ($node.ChildNodes | ? {$_.NodeType -eq "Element"})
                            if($childElements) {
                                if($config[$node.Name] -and ($config[$node.Name]  -is [Array])) {
                                    foreach($element in $childElements) {
                                        if(-not ($config[$node.Name] | ? {$_.OuterXml -eq $element.OuterXml})) {
                                            $config[$node.Name] += $element
                                        }
                                    }
                                }
                                else {
                                    $config[$node.Name] = @($childElements | % {$_})
                                }
                            }
                            else {
                                $config[$node.Name] = $node.InnerText
                            }
                        }
                    }
                }
            }
        }
        if(-not $config.WebRoot) {
            $config.WebRoot = "$($config.GlobalWebPath)\$($config.WebsiteCodeName)\$($config.WebFolderName)"
        }
        return $config;
    }
}
