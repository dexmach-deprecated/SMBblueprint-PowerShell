#Requires -Version 3
#Requires -Module AzureRM.Profile
#Requires -Module AzureRM.Resources
#Requires -Module MSOnline
#Requires -Module Microsoft.Online.SharePoint.PowerShell
#Requires -Module AzureRM.Network
[cmdletbinding()]
param(

)
Set-StrictMode -Version Latest
$script:ErrorActionPreference = "stop"
New-Variable -Name Root -Scope Script -Value $PSScriptRoot -Force
#$script:TemplateUrl = "https://inovativbe.blob.core.windows.net/sbstemplatedev/azuredeploy.json"
#$script:ATPLicenseName = "ADALLOM_O365"

Get-ChildItem -Path "$script:Root\Functions\" -Include '*.ps1' -Recurse |
ForEach-Object {
    write-verbose "Registering function $($_.BaseName)"
    . $_.FullName;
    if($_.Directory.Name -eq 'public'){
        Write-Verbose "Exporting public function $($_.BaseName)"
        Export-ModuleMember -Function $_.BaseName
    }
}

Register-Classes
Set-ModuleVariable





