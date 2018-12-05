<div class="chapterlogo"><img src="./Gripper.png" /></div>

# Gripper

Gripper is a helper machine used to bootstrap new modules in projects based on our new modular architecture.

In order to use Gripper call the New-FeatureModule, New-FoundationModule or New-ProjectModule cmdlet without any parameters from your Package Manager Console in Visual Studio. You will be asked three questions:

0. What is the name of your module? It is a plain name of the module, i.e. Identity.
0. Whether to add a test project to your module? The available options are y (yes) or n (no).

## Configuration

| Key | Description | Example | 
| --- | --- |
| GripperCodeProjectNugetPackages | A list of packages which willd be installed to the code project | `<GripperCodeProjectNugetPackages>` <br> `<Package ID="Unic.Logging.Core" Version="3.5.0" />` <br> `</GripperCodeProjectNugetPackages>` |
| GripperCodeTemplate | The path to the folder containing a template for code projects. | `<GripperCodeTemplate>src\Templates\Code\</GripperCodeTemplate>` |
| GripperCodeVisualStudioProjectPath | The path to the *proj file inside the project template (default: ProjectName.csproj) | `<GripperCodeVisualStudioProjectPath>ProjectName\ProjectName.xproj</GripperCodeVisualStudioProjectPath>` |
| GripperTestProjectNugetPackages | A list of packages which will be installed to the test project | `<GripperTestProjectNugetPackages>` <br> `<Package ID="NUnit" Version="3.5.0" />` <br> `</GripperTestProjectNugetPackages>` |
| GripperTestTemplate | The path to the folder containing a template for test projects. | `<GripperCodeTemplate>src\Templates\Code\</GripperCodeTemplate>` |
| GripperTestVisualStudioProjectPath | The path to the *proj file inside the project template for the test template (default: ProjectName.csproj) | `<GripperTestVisualStudioProjectPath>ProjectName\ProjectName.xproj</GripperTestVisualStudioProjectPath>` |

## Templates

You can create your own templates for your solution. Basically a template is a folder which gets transformed to the destination folder.
The folder must contain a file called ProjectName.csproj.
The following words can be used in a template and will be replaced:
| Name | Description |
| --- | --- |
| ProjectName | The name of the project without the ending ".csproj" |
| ModuleName | The name of the module typed by the user | 
| ModuleType | The type of the module. Normally either Project, Foundation or Feature |
