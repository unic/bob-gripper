<#
.SYNOPSIS
Removes all subfolders in a specific folder which doesn't match any of the specified patterns.
.DESCRIPTION
Removes all subfolders in a specific folder which doesn't match any of the specified patterns.

.PARAMETER Folder
The folder where the subfolders should be deleted.

.PARAMETER Pattern
The patterns which should **not** be deleted.

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
      [string[]] $Pattern
  )
  Process
  {
    $Folder = $Folder.TrimEnd("\") + "\"

    $itemsToKeep = @()
    foreach($patt in $Pattern) {
      foreach($subFolder in (ls $Folder -recurse | Where {$_.PSIsContainer})) {
        if($subFolder.FullName.Replace($Folder, "") -like $patt) {
          $itemsToKeep += $subFolder.FullName
        }
      }
    }
    foreach($item in (ls "$Folder" -Recurse | Where {$_.PSIsContainer -eq $true})) {
      $delete = $true;
      foreach($keep in $itemsToKeep) {
        if($keep.StartsWith($item.FullName)) {
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
