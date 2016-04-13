<div class="chapterlogo">![Gripper](Gripper.png)</div>

# Gripper
Gripper is a helper machine used to bootstrap new modules in projects based on our new modular architecture.


In order to use Gripper call the New-ScModule cmdlet without any parameters from your Package Manager Console in Visual Studio. You will be asked three questions:

1. What type of module you want to create? The available options are Feature, Foundation or Project.
2. What is the name of your module? It is a plain name of the module, i.e. Identity.
3. Whether to add a test project to your module? The available options are y (yes) or n (no).