

# New-ScHabitatModule

Creates new projects for a new module according to our architecture guidelines.
## Syntax

    New-ScHabitatModule [-moduleType] <String> [<CommonParameters>]


## Description

Creates new projects for a new module according to our architecture guidelines. You will be asked a few questions and Gripper will create new projects 
in proper directories in the file system and Visual Studio solution.





## Parameters

    
    -moduleType <String>
_The type of the module to bootstrap._

| Position | Required | Default value | Accept pipeline input | Accept wildchard characters |
| -------- | -------- | ------------- | --------------------- | --------------------------- |
| 1 | true |  | false | false |


----

    

## Examples

### -------------------------- EXAMPLE 1 --------------------------
    New-ScHabitatModule "Feature"































