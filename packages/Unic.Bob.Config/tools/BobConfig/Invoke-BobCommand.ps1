<#
.SYNOPSIS
If Invoke-BobCommand is called from the NuGet package manager console,
it will start a new process to run the command, else it just runs the specified code-block normally.

.DESCRIPTION
`Invoke-BobCommand` can be used to ensure a cmdlet is run in a custom PowerShell
process instead of the package manager console. If it's called from a normal
PowerShell host, it will just run the specified code normally, if it's called
from the package manager host, it will start a new PowerShell process
and rerun the original command with the original parameters.
If the original command has a parameter "ProjectPath" , it will be set with
`Get-ScProjectPath`.

.PARAMETER Code
The code to execute, when the command is called from a normal PowerShell host.
Normally this will be the whole body of the calling command.

.EXAMPLE
Invoke-BobCommand {Write-Host "Hey"}


#>
function Invoke-BobCommand
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock] $Code
    )
    Process
    {
        if($host.Name -eq "Package Manager Host") {
            $caller = (Get-PSCallStack)[1]
            $command = Get-Command $caller.Command
            $module = $command.Module.Path
            $parameters = $caller.InvocationInfo.BoundParameters
            $newCommand = $caller.Command
            foreach($key in $parameters.Keys) {
                $value = $parameters[$key]

                if($command.Parameters[$key].ParameterType -eq [System.Management.Automation.SwitchParameter]) {
                    $newCommand += " -${Key}:`$$value"
                }
                elseif ($value -ne ""){
                    $escapedValue = $value -replace "'", "``'"
                    $newCommand += " -${Key} '$escapedValue'"
                }
            }

            if(-not ($caller.InvocationInfo.BoundParameters["ProjectPath"])) {
                $projectPath = Get-ScProjectPath
                $newCommand += " -ProjectPath $projectPath"
            }

            Write-Verbose $newCommand
            Write-Debug "Restart with module $module"

            $transcript = "${env:TEMP}\$([Guid]::NewGuid())"
            $script = @"
                try {
                    Start-Transcript $transcript
                    Import-Module $module
                    $newCommand
                }
                catch {
                    if(`$_.Exception -is [Microsoft.PowerShell.Commands.WriteErrorException]) {
                        Write-Output (""""Error: """" +  `$_.ToString())
                    }
                    else {
                        Write-Output (""""Error: """" +  `$_.ToString() + """"``n"""" + `$_.ScriptStackTrace)
                    }
                    Stop-Transcript
                    exit 1
                }

                Stop-Transcript
"@
            # 'sysnative' will force to start a x64 PowerShell which is way cooler :)
            $p = New-Object System.Diagnostics.Process
            $psi = New-Object System.Diagnostics.ProcessStartInfo "C:\Windows\sysnative\WindowsPowerShell\v1.0\powershell.exe"
            $psi.Arguments = @("-NoProfile","-NoLogo", $script)
            $p.StartInfo = $psi

            $p.Start() | Out-Null

            $i = 0
            $commentStarted = $false
            while (-not $p.HasExited   ) {
                Start-Sleep -m 50
                if(Test-Path $transcript) {
                    $lines = Get-Content $transcript
                    for(; $i -lt ($lines.Count - 1); $i++) {
                        $line = $lines[$i]
                        if($line -eq "**********************") {
                            $commentStarted = -not $commentStarted
                        }
                        elseif(-not $commentStarted -and -not ($line.ToString().StartsWith("Transcript started, output file is"))) {
                            Write-Host  $line
                        }
                    }
                }
            }

            if($p.ExitCode -ne 0) {
                Write-Error "Error while running command $newCommand. Please check the log above."
            }
        }
        else {
            & $Code
        }
    }
}
