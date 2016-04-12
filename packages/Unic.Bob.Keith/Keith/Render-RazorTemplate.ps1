<#
.SYNOPSIS
Renders the specified Razor template.

.DESCRIPTION
Renders the specified Razor template
with an optional model.
Based on: https://github.com/knutkj/misc/blob/master/PowerShell/Razor/Render-RazorTemplate.ps1

.PARAMETER Template
The content of a Razor template.
.PARAMETER Model
 A model to use in the template.

.EXAMPLE
Render-RazorTemplate -Template "Hello World!"
Output: Hello World!

.EXAMPLE
Render-RazorTemplate "<ul>@foreach(var i in Model){<li>@i</li>}</ul>" (0..3)
Output: <ul><li>0</li><li>1</li><li>2</li><li>3</li></ul>

#>
Function Format-RazorTemplate {
[CmdLetBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string] $Template,
    [Parameter()]
    [object] $Model = $null
)
process {

    $ModelType = "dynamic"
    $TemplateClassName = "t{0}" -f ([System.IO.Path]::GetRandomFileName() -replace "\.", "")
    $TemplateBaseClassName = "t{0}" -f
    ([System.IO.Path]::GetRandomFileName() -replace "\.", "")
    $TemplateNamespace = "Kkj.Templates"
    $templateBaseCode = @"
using System;
using System.Text;
using Microsoft.CSharp.RuntimeBinder;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
namespace {2} {{
public abstract class {1}
{{
protected {0} Model;
private StringBuilder _sb = new StringBuilder();
public abstract void Execute();

public virtual void Write(object value)
{{
WriteLiteral(value);
}}
public virtual void WriteLiteral(object value)
{{
_sb.Append(value);
}}
public string Render ({0} model)
{{
Model = model;
Execute();
var res = _sb.ToString();
_sb.Clear();
return res;
}}

public string OutString (PSObject obj)
{{
Runspace runspace = RunspaceFactory.CreateRunspace();
runspace.Open();
Pipeline pipeline = runspace.CreatePipeline();

Command cmd = new Command("Out-String");
cmd.Parameters.Add("InputObject", obj);
cmd.Parameters.Add("Width", 1024);
pipeline.Commands.Add(cmd);


var results = pipeline.Invoke();

// close the runspace
runspace.Close();

// convert the script result into a single string
StringBuilder stringBuilder = new StringBuilder();
foreach (PSObject returnObj in results)
{{
stringBuilder.AppendLine(returnObj.ToString());
}}

// return the results of the script that has
// now been converted to text
return stringBuilder.ToString();
}}
}}
}}
"@ -f $ModelType, $TemplateBaseClassName, $TemplateNamespace
    #
    # A Razor template.
    #
    $language = New-Object `
    -TypeName System.Web.Razor.CSharpRazorCodeLanguage
    $engineHost = New-Object `
        -TypeName System.Web.Razor.RazorEngineHost `
        -ArgumentList $language `
        -Property @{
            DefaultBaseClass = "{0}.{1}" -f
            $TemplateNamespace, $TemplateBaseClassName;
            DefaultClassName = $TemplateClassName;
            DefaultNamespace = $TemplateNamespace;
        }
    $engine = New-Object `
        -TypeName System.Web.Razor.RazorTemplateEngine `
        -ArgumentList $engineHost
    $stringReader = New-Object `
        -TypeName System.IO.StringReader `
        -ArgumentList $Template
    $code = $engine.GenerateCode($stringReader)
    #
    # Template compilation.
    #
    $stringWriter = New-Object -TypeName System.IO.StringWriter
    $compiler = New-Object `
    -TypeName Microsoft.CSharp.CSharpCodeProvider
    $compilerResult = $compiler.GenerateCodeFromCompileUnit(
    $code.GeneratedCode, $stringWriter, $null
    )
    $templateCode =
    $templateBaseCode + "`n" + $stringWriter.ToString()
    Add-Type `
    -TypeDefinition $templateCode `
    -ReferencedAssemblies System.Core, Microsoft.CSharp
    #
    # Template execution.
    #
    $templateInstance = New-Object -TypeName `
    ("{0}.{1}" -f $TemplateNamespace, $TemplateClassName)
    $templateInstance.Render($Model)
    }
}
