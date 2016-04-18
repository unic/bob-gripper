<div class="chapterlogo">![Gripper](Gripper.png)</div>

# Gripper
Gripper is a helper machine used to bootstrap new modules in projects based on our new modular architecture.


In order to use Gripper call the New-FeatureModule, New-FoundationModule or New-ProjectModule cmdlet without any parameters from your Package Manager Console in Visual Studio. You will be asked three questions:

1. What is the name of your module? It is a plain name of the module, i.e. Identity.
2. Whether to add a test project to your module? The available options are y (yes) or n (no).


**Be careful: Gripper installs nuget packages from both sources - nuget.org and our Unic Team City. They must be present on your package sources list in Visual Studio and the All must be selected for the package sources.**