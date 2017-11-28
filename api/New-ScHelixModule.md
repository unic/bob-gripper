

# New-ScHelixModule

Creates new projects for a new module according to our architecture guidelines.
## Syntax

    New-ScHelixModule [-moduleType] <String> [<CommonParameters>]


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
    New-ScHelixModule "Feature"































