function Connect-Cloud {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [pscredential] $credential,
        [parameter()]
        [ValidateNotNull()]
        [string] $TenantId
    )

    begin{}
    process{
        if($TenantId){
            $null = Connect-AzureAD -TenantId $TenantId -Credential $credential
            $null = Add-AzureRmAccount -TenantId $TenantId -Credential $credential
        } else {
            $null = Connect-AzureAD -Credential $credential
            $null = Add-AzureRmAccount -Credential $credential
        }
    }
    end{}
}