# Gripper

## 1.0

* Initial release on GH
* Support for Gitbook 3

## 0.6

* Added possibility to create project templates per solution by adding config keys:
    * `GripperCodeTemplate`
    * `GripperCodeVisualStudioProjectPath`
    * `GripperTestTemplate`
    * `GripperTestVisualStudioProjectPath`
* Removed switch for the test project creation. The test project will always be create except for "Project" modules

## 0.5

* No NuGet package is installed anymore. Instead you need to configure which one are installed in Bob.config with the keys `GripperCodeProjectNugetPackages` and `GripperTestProjectNugetPackages` 
* Renamed Habitat to Helix
* Updated the theme

## 0.4

* Updated docs

## 0.3

* Replaced one big cmdlet with three smaller ones: New-FeatureModule, New-FoundationModule and New-ProjectModule
* Removed unicorn configuration files from boilerplates
* Changed runtime to .NET 4.6

## 0.2

* Removed debug and release web configuration files from project templates

## 0.1

* Initital version