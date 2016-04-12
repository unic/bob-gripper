<#
.SYNOPSIS
Removes all subfolders in a specific folder which doesn't match any of the specified patterns.
.DESCRIPTION
Removes all subfolders in a specific folder which doesn't match any of the specified patterns.

.PARAMETER Folder
The folder where the subfolders should be deleted.

.PARAMETER Pattern
The patterns which should **not** be deleted.

.PARAMETER Files
If true the files which are directly in the root will also be deleted.

.EXAMPLE
Remove-RubbleItem -Folder D:\dummy -Pattern "Do\Not\*Delete"

#>
function Remove-RubbleItem
{
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$true)]
      [string] $Folder,
      [Parameter(Mandatory=$true)]
      [string[]] $Pattern,
      [switch] $Files
  )
  Process
  {
    $Folder = (Resolve-Path ($Folder.TrimEnd("\") + "\"))

    $itemsToKeep = @()
    foreach($patt in $Pattern) {
      foreach($item in (ls $Folder -recurse)) {
        if($item.FullName.Replace($Folder, "") -like $patt) {
            if($item.PSIsContainer) {
                $itemsToKeep += $item.FullName + "\" 
            }
            else {
                 $itemsToKeep += $item.FullName
            }
        }
      }
    }
    
    foreach($item in (ls "$Folder" -Recurse | Where {$Files -or ($_.PSIsContainer -eq $true) -or ((Split-Path $_.FullName -parent) -ne $Folder.TrimEnd("\"))})) {
      $delete = $true;
      foreach($keep in $itemsToKeep) {
          if(($keep.EndsWith("\") -and ($item.FullName + "\").StartsWith($keep)) -or 
                ($item.PSIsContainer -and $keep.StartsWith($item.FullName + "\"))  -or ($keep -eq  $item.FullName )) {
          $delete = $false
          break;
        }
      }

      if($delete -and (Test-Path $item.FullName)) {
          $item.FullName
          rm $item.FullName -Recurse
      }
    }
  }
}
