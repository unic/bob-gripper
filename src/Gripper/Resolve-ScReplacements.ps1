<#
.SYNOPSIS
Returns a PascalCase and camelCase version of every passed replacement.

.DESCRIPTION
Returns a PascalCase and camelCase version of every passed replacement.
So if @{"Customer"="Unic"} is passed @{"Customer"="Unic"; "customer" = "unic"}
is returned.

.PARAMETER  Replacements
A PowerShell hashtable of replacements to return.

.EXAMPLE
Resolve-ScReplacements @{"Customer"="Unic"}
#>
function Resolve-ScReplacements
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Hashtable] $Replacements
    )
    Process
    {
        function LowerFirstLetter {
            param($Value)

            $Value[0].ToString().ToLower() + $Value.Substring(1)
        }
        function UpperFirstLetter {
            param($Value)

            $Value[0].ToString().ToUpper() + $Value.Substring(1)
        }

        $fixedReplacements =  New-Object System.Collections.Hashtable
        $Replacements.Keys | % {
            $value =  $Replacements[$_]
            Write-Host
            if($_ -and [char]::IsLetter($_[0]) -and $value -and [char]::IsLetter($value[0])) {
                $lowerKey = (LowerFirstLetter($_))
                $fixedReplacements[$lowerKey] = LowerFirstLetter($value)
                $upperKey = (UpperFirstLetter($_))
                $fixedReplacements[$upperKey] = UpperFirstLetter($value)
            }
            else {
                $fixedReplacements[$_] = $value
            }
        }
        $fixedReplacements
    }
}
