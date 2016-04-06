<#
.SYNOPSIS
Tests if a specific file is a binary file or a text file.

.DESCRIPTION
Tests if a specific file is a binary file or a text file.

.PARAMETER  Path
The path to the file to test.

.EXAMPLE
Test-BinaryFile test.txt

#>
function Test-BinaryFile
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Path
    )
    Process
    {

        $encoding = ""

        # Get the first 1024 bytes from the file
        $byteArray = Get-Content -Path $Path -Encoding Byte -TotalCount 1024

        if($byteArray.Length -lt 4) {
            return $true
        }

        if( ("{0:X}{1:X}{2:X}" -f $byteArray) -eq "EFBBBF" )
        {
            # Test for UTF-8 BOM
            $encoding = "UTF-8"
        }
        elseif( ("{0:X}{1:X}" -f $byteArray) -eq "FFFE" )
        {
            # Test for the UTF-16
            $encoding = "UTF-16"
        }
        elseif( ("{0:X}{1:X}" -f $byteArray) -eq "FEFF" )
        {
            # Test for the UTF-16 Big Endian
            $encoding = "UTF-16 BE"
        }
        elseif( ("{0:X}{1:X}{2:X}{3:X}" -f $byteArray) -eq "FFFE0000" )
        {
            # Test for the UTF-32
            $encoding = "UTF-32"
        }
        elseif( ("{0:X}{1:X}{2:X}{3:X}" -f $byteArray) -eq "0000FEFF" )
        {
            # Test for the UTF-32 Big Endian
            $encoding = "UTF-32 BE"
        }

        if($encoding)
        {
            # File is text encoded
            return $false
        }

        if( $byteArray -contains 0 )
        {
            # Test for binary
            return $true
        }

        return $false
    }
}
