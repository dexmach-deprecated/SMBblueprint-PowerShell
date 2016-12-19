#Requires -Version 3
#Requires -Module AzureRM.Profile
#Requires -Module AzureRM.Resources
#Requires -Module MSOnline
#Requires -Module Microsoft.Online.SharePoint.PowerShell
#Requires -Module AzureRM.Network
[cmdletbinding()]
param(
    [string]$LogName = "Execution.log"
)
Set-StrictMode -Version Latest
$script:ErrorActionPreference = "stop"
New-Variable -Name Root -Scope Script -Value $PSScriptRoot -Force
#New-Variable -Name Log -Scope Script -Force
<#$script:DebugPreference = "continue"
$script:InformationPreference = "continue"
$script:VerbosePreference = "continue"
New-Variable -Name GUI -Scope Script -Force
New-Variable -Name AzureCredential -Scope Script -Force
New-Variable -Name OfficeCredential -Scope Script -Force

New-Variable -Name Done -Value $false -Scope Script -Force
New-Variable -Name ResourceGroupRefix -Value "rg_sbs_" -Scope Script -Force#>

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




