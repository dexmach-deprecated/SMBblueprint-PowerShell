Function New-AzureServicePrincipal {
 [cmdletbinding()]
 [outputtype([string])]
  Param (

 # Use to set scope to resource group. If no value is provided, scope is set to subscription.
 [Parameter(Mandatory=$false)]
 [String] $ResourceGroup,

 # Use to set subscription. If no value is provided, default subscription is used. 
 [Parameter(Mandatory=$false)]
 [String] $SubscriptionId,

 [Parameter(Mandatory=$true)]
 [String] $ApplicationDisplayName,

 [Parameter(Mandatory=$false)]
 [String] $Password = (New-SWRandomPassword)
 )

 try {

    if ($SubscriptionId -eq "") 
    {
        $SubscriptionId = (Get-AzureRmContext).Subscription.SubscriptionId
    }
    else
    {
        $null = Set-AzureRmContext -SubscriptionId $SubscriptionId
    }

    if ($ResourceGroup -eq "")
    {
        $Scope = "/subscriptions/" + $SubscriptionId
    }
    else
    {
        $Scope = (Get-AzureRmResourceGroup -Name $ResourceGroup -ErrorAction Stop).ResourceId
    }

    # Create Azure Active Directory application with password
    $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $ApplicationDisplayName) -Password $Password

    # Create Service Principal for the AD app
    $ServicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
    $null = Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id 

    $NewRole = $null
    $Retries = 0;
    While ($NewRole -eq $null -and $Retries -le 6)
    {
        # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
        Sleep 15
        $null = New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -Scope $Scope | Write-Verbose -ErrorAction SilentlyContinue
        $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
        $Retries++;
    }
    $Application.ApplicationId.ToString()
 } catch {
     throw "Error while setting up Azure SPN: $($Error[0].ToString())"
 }  
}
