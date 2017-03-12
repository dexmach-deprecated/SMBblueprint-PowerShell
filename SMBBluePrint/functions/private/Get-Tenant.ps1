function Get-Tenant {
    [cmdletbinding()]
    param(
        [Parameter()]
        [string] $TenantDomain,
        [Parameter()]
        [string] $TenantId,
        [Parameter()]
        [switch] $All
    )

    begin {
        $Tenants = New-Object System.Collections.ArrayList
        $Tenant = $null
    }
    process {
        try{
            # Add Local Tenant info
            # Local Office
            $LocalTenant = Get-AzureADTenantDetail
            $LocalTenantId = $LocalTenant.ObjectId
            $LocalDomain = ($LocalTenant.VerifiedDomains|?{$_._Default -eq $true}).Name
            $null = $Tenants.Add($(New-Object Tenant|%{$_.Id = $LocalTenantId;$_.Name = $LocalDomain;$_.Default = $true;$_.Type = "Office";$_}))
            # Local Azure
            
            # Add MSOL CSP Tenants
            try{
                $IsCSP = $false
                foreach($Item in (Get-AzureADContract -all $true -ErrorAction SilentlyContinue)){
                    if($IsCSP -eq $false){
                        $IsCSP = $true
                    }
                    $null = $Tenants.Add($(new-object Tenant|%{$_.Id = $Item.CustomerContextId;$_.Name = $Item.DisplayName;$_.Type = "Office";$_.Default = $false;$_}))
                }
                if($IsCSP -eq $false){
                    throw "NotCSP"
                }
            } catch {
                Write-Log -Message "Credential is not CSP, only retrieving local tenants"
            }
            # Add Azure CSP Tenants
            foreach($Item in (Get-AzureRmTenant)){
                $null = $Tenants.Add($(new-object Tenant|%{$_.Id = $Item.TenantId;$_.Name = $Item.Domain;$_.Type = "Azure";$_.Default = $false;$_}))
            }
            # Dedup

            foreach($Id in (($Tenants|Group -Property Id).where({$_.Count -gt 1}).Name)){
                $Temp = $Tenants.Where({$_.Id -eq $Id})
                foreach($Item in $Temp){
                    $Tenants.Remove($Item)
                }
                $Temp = $Temp[0]
                $Temp.Type = "All"
                $null = $Tenants.Add($Temp)
                $Tenants = $Tenants|sort -Property Name
            
            }
            
      
            if($All){
                
            }
            elseif(($TenantDomain -eq $null) -or ($TenantId -eq $null)){
                $Tenants = @($Tenants.where({$_.Default -eq $true}))
                $TenantDomain = $Tenant[0].Name;
                $TenantId = $Tenant[0].Id;
            }
            elseif($TenantDomain){
                $Tenants = @($Tenants.where({$_.Name -eq $TenantDomain}))
            }
            elseif($TenantId){
                $Tenants = @($Tenants.where({$_.Id -eq $TenantId}))
            }
            if(!$Tenants){
                throw "Tenant Not Found"
                
            }
        } catch {
            throw "Throw error during Tenant Enumeration: $_"
        }
    }
    end {
        $Return = new-object System.Collections.ArrayList
        if($Tenants -is [System.Array]){
            $null = $Return.AddRange($Tenants)
        } else {
            $null = $Return.Add($Tenants)
        }
        return $Return
    }
}