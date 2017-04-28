function New-SMBAzureDeployment {
    [cmdletbinding(DefaultParameterSetName = "AzureTenantDomain")]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Location,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $AutomationLocation,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $LogAnalyticsLocation,
        [parameter()]
        [switch] $AsJob,
        [parameter(Mandatory = $true)]
        [ValidateLength(1,15)]
        [string] $CustomerName,
        [parameter(Mandatory = $true)]
        [ValidateSet('small', 'medium', 'large')]
        [string] $CustomerSize = 'small',
        [parameter()]
        [ValidateSet('none', 'small', 'medium')]
        [string] $AdditionalVMSize = 'none',
        [parameter()]
        [ValidateSet('none', 'small')]
        [string] $AdditionalSQLInstanceSize = 'none',
        [ValidateSet('none', 'standard')]
        [string] $Backup = 'none',
        [ValidateSet('none', 'basic')]
        [string] $VPN = 'none',
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('free')]
        [string] $Management = 'free',
        [parameter()]
        [ValidateSet('2012R2', '2016')]
        [string] $OS = '2012R2',
        [parameter()]
        [string] $SysAdminPassword = $(New-SWRandomPassword),
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Credential = (Get-Credential -Message "Please provide your Partner Credentials"),
        [parameter(ParameterSetName = "AzureTenantId", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TenantId,
        [parameter(ParameterSetName = "AzureTenantDomain", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $TenantDomain,
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,
        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionName,
        [Parameter(DontShow = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceGroupPrefix = "smb_rg_",
        [Parameter()]
        [switch] $NoUpdateCheck,
        [Parameter()]
        [ValidateSet('Standard_LRS', "Standard_ZRS", "Standard_GRS", "Standard_RAGRS", "Premium_LRS")]
        [string] $StorageType = "Standard_LRS",
        [Parameter(DontShow = $true)]
        [string] $InstanceId
    )
	
    begin {
        $Continue = $true
        $Management = 'free'
        if(!$LogAnalyticsLocation){
            $LogAnalyticsLocation = $Location
        }
        if(!$AutomationLocation){
            $AutomationLocation = $Location
        }
        $Log = $null
        if ($PSBoundParameters.ContainsKey('InstanceId')) {
            $SyncHash = Get-JobVariable -Id $InstanceId
            $Log = $SyncHash.log
        }
        else {
            $SyncHash = Get-JobVariable
            $Log = Start-Log -InstanceId $SyncHash.InstanceId
            $SyncHash.Log = $Log
        }
        $PSDefaultParameterValues = @{"Write-Log:Log" = $Log}
        if (!$PSBoundParameters.ContainsKey('NoUpdateCheck')) {
            Test-ModuleVersion -ModuleName "SMBBluePrint"
        }

        $CustomerNamePrefix = [Regex]::Replace($CustomerName, '[^a-zA-Z0-9]', '')
        $ResourceGroupName = "$ResourceGroupPrefix$CustomerNamePrefix"
        $SecurePassword = $SysAdminPassword|ConvertTo-SecureString -AsPlainText -Force
        write-log -Message "Using $CustomerNamePrefix as resource naming prefix"
        Write-Log -Message "Using $ResourceGroupName as target resource group"
        $ActiveSubscription = ""
        if ($Credential) {
            try {
                Connect-Cloud -Credential $Credential
                $Tenant = Get-Tenant -TenantDomain $TenantDomain -TenantId $TenantId
                if ($Tenant.Default -eq $false) {
                    $null = Add-AzureRMAccount -Credential $Credential -TenantId $TenantId
                }
                else {
                    $null = Add-AzureRMAccount -Credential $Credential
                }

                if ($SubscriptionId) {
                    $null = Select-AzureRmSubscription -SubscriptionId $SubscriptionId
                }
                elseif ($SubscriptionName) {
                    $null = Select-AzureRmSubscription -SubscriptionName $SubscriptionName
                }
                else {
                    # use default subscription
                }
            } catch {
                write-log -type error -message "Error during Azure connection: $_"
            }
        }
        try {
            $null = Get-AzureRmContext
        }
        catch {
            Write-Error "No active Azure subscription is present in the session. Please use Login-AzureRMAccount and Select-AzureRMSubscription to set the target subscription, or specify Tenant/Credential information"
            return $null
        }
        if ((Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Ignore)) {
            Write-Log -Type Error -Message "Resource group already exists, please choose another customer name"
            return
        }
        if ((Test-AzureRmDnsAvailability -DomainNameLabel $CustomerNamePrefix.ToLower() -Location "westeurope") -eq $false) {
            write-log -type error -Message "Domain Name already taken, please choose another customer name"
            return
        }
        if ($CustomerNamePrefix -like "*microsoft*") {
            write-log -type error -message "'Microsoft' can not be a part of the customer name, please choose another customer name"
            return
        }
        if ((Test-AADPasswordComplexity -MinimumLength 12 -Password $SysAdminPassword) -eq $false) {
            write-log -type error -message "Password does not meet complexity requirements"
            return
        }
        Write-Log -Message "Checking resource availability"
        $CompatibilityResults = Test-AzureResourceLocation -Location $Location -ResourceFile "$Root\resources"
        Write-Log -Message "Incompatible resources: $($CompatibilityResults.Count)"

        $Count = $CompatibilityResults.Count
        
        if ($Count -gt 0) {
            $Continue = $false
            foreach ($Result in $CompatibilityResults) {
                Write-Log -Message "Incompatible resource: $($Result["Resource"])"
                switch -regex ($Result["Resource"]) {
					
                    "microsoft\.(operationalinsights|operationsmanagement)" {
						
                       
                            if($LogAnalyticsLocation -in $Result["AvailableLocations"]) {
                                $Continue = $true
                                break
                            }
                            
                            $choices = $Result["AvailableLocations"]
                            $params = @{
                                Title = "Log Analytics Features Unsupported for this Region"
                                Message = "The selected Azure Region does not support the Log Analytics features of the SMB Blueprint solution. In which region should they be deployed instead (by re-running this command with the -LogAnalyticsLocation Parameter you can automatically deploy non-compatible resources to a fallback region)?" 
                                Choices = $choices
                            }
                            $answer = Read-Choice @params
                           
                            write-log -message "You chose: $answer"
                            switch ($answer) {
                                "Cancel" {
                                    write-log -message "Deployment Cancelled";
                                    $Continue = $false
                                }
                                default {
									
                                    $LogAnalyticsLocation = $answer
                                    write-log -message "Continuing Deployment with Log Analytics Location: $LogAnalyticsLocation"
                                    $Continue = $true
                                }
                            }
                       
                    }



                    "microsoft\.automation" {
						
                        if ($AutomationLocation -in $Result["AvailableLocations"]) {
                            $Continue = $true
                            break
                        }
                            
                            $choices = $Result["AvailableLocations"]
                            $params = @{
                                Title = "Automation Features Unsupported for this Region"
                                Message = "The selected Azure Region does not support the Automation features of the SMB Blueprint solution. In which region should they be deployed instead (by re-running this command with the -AutomationLocation Parameter you can automatically deploy non-compatible resources to a fallback region)?" 
                                Choices = $choices
                            }
                            $answer = Read-Choice @params
                           
                            write-log -message "You chose: $answer"
                            switch ($answer) {
                                "Cancel" {
                                    write-log -message "Deployment Cancelled"
                                    $Continue = $false
                                }
                                default {
									
                                    $AutomationLocation = $answer
                                    write-log -message "Continuing Deployment with Automation Location: $AutomationLocation"
                                    $Continue = $true
                                }
                            }
                        }

                    "microsoft.recoveryservices" {
                        write-log -type warning -message "Backup is not supported at this location. The feature will not be deployed"
                        $Backup = "none"
                    }
                }
            }
        }
        else {
            # do nothing
        }
        $AzureParameters = @{
            customername = $CustomerNamePrefix
            customersize = $CustomerSize
            sql = $AdditionalSQLInstanceSize
            vm = $AdditionalVMSize
            backupEnabled = $Backup
            vpnGateway = $VPN
            scheduleid01 = $([guid]::NewGuid().ToString())
            scheduleid02 = $([guid]::NewGuid().ToString())
            scheduleStartDate = (get-date).AddDays(1).ToString("yyyy/MM/dd") 
            managementEnabled = $Management
            logAnalyticsLocation = $LogAnalyticsLocation
            automationLocation = $AutomationLocation
            OSVersion = $OS
            storageType = $StorageType
        }
        $AzureParameters.Add('adminPassword', $SecurePassword)
		
		
		
    }
    process {
        if (!$Continue) {
            Write-Log "Deployment aborted"
            return
        }
        Write-Log "Creating Resourcegroup '$($ResourceGroupName)'"
        try {
            $null = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
        }
        catch {
            Write-log -Type Error -Message "Error while deploying resource group: $_"
            return $null
        }

        # Write-Log "Creating Service Principal"
        # Try {
        #     $spnId = New-AzureServicePrincipal -ApplicationDisplayName $ResourceGroupName.Replace("_rg_","_spn_") -ResourceGroup $ResourceGroupName -SubscriptionId $SubscriptionId -Password $SysAdminPassword
        #     $AzureParameters.add('SPNId',$spnId)
        # } catch {
        #     Write-Log -Type Error -Message "Error while deploying SPN: $_"
        # }

        write-log "Deploying solution to resource group using template url $($global:templateurl)"
        try {
            #   if((Get-Variable -name 'SyncHash' -ErrorAction SilentlyContinue) -eq $null){
            #write-log -message "Running in CLI mode"
            #      $SyncHash = [hashtable]::Synchronized(@{})
            #     $SyncHash.Root = $global:root
            #    $SyncHash.Log = $Log
            #} else {
            #write-log -message "Running in GUI mode"
            #}

            $SyncHash.ResourceGroupName = $ResourceGroupName
            $SyncHash.DeploymentParameters = $AzureParameters
            $SyncHash.Credential = $Credential
            $SyncHash.TenantId = $TenantId
            $SyncHash.SubscriptionId = $SubscriptionId
            $CredentialGuid = $SyncHash.InstanceId
            $CredentialDirectory = "$env:APPDATA\SMBBlueprint\credentials"
            #$null = new-item -Path $CredentialDirectory -ItemType Directory -Force
            # while(!(test-path "$CredentialDirectory\SBSDeployment-$($SyncHash.InstanceId).json")){
            #    $null = Save-AzureRmProfile -path "$CredentialDirectory\SBSDeployment-$($SyncHash.InstanceId).json" -Force
            #}

            $SyncHash.DeploymentStart = get-date
            $SyncHash.DeploymentJob = new-object psobject -Property @{
                Type = 'Azure'
                Duration = "00:00:00"
                Status = @{
                    Deployment = @()
                    Configuration = @{
                        Domain = "$CustomerNamePrefix.local"
                        Login = 'sysadmin'
                        Password = $SysAdminPassword
                        ResourceGroup = $ResourceGroupName
                        Connection = "https://$($CustomerNamePrefix.ToLower()).$($Location).cloudapp.azure.com/rdweb"
                    }
                }
                Completed = $false
                Error = $null
                Log = $Log
                CredentialFile = "$CredentialDirectory\SBSDeployment-$($SyncHash.InstanceId).json"
            }

            $null = invoke-operation -synchash $SyncHash -root $SyncHash.Root -Log $SyncHash.Log -code {
                try {
                    #$null = Select-AzureRmProfile -Path $SyncHash.DeploymentJob.CredentialFile
                    $null = Add-AzureRmAccount -Credential $SyncHash.Credential -TenantId $SyncHash.TenantId -SubscriptionId $SyncHash.SubscriptionId
                    $null = New-AzureRmResourceGroupDeployment -TemplateUri $Global:TemplateUrl `
					-TemplateParameterObject $SyncHash.DeploymentParameters -ResourceGroupName $SyncHash.ResourceGroupName -Force
                    if ($? -eq $false) {
                        throw $Error[1]
                    }
                } catch {
                    $SyncHash.DeploymentJob.Error = $_.Exception
                }
				
            }
			
            $null = Invoke-Operation -synchash $SyncHash -log $SyncHash.Log -root $SyncHash.Root -code {
                try {
                    $null = Add-AzureRmAccount -Credential $SyncHash.Credential -TenantId $SyncHash.TenantId -SubscriptionId $SyncHash.SubscriptionId
                    $DeploymentStatus = Get-AzureRmResourceGroupDeployment -ResourceGroupName $SyncHash.ResourceGroupName
					
                    while (((($DeploymentStatus.where{$_.ProvisioningState -eq 'Running'}).count -gt 0) -or ((new-timespan -start $SyncHash.DeploymentStart -end (get-date)).TotalMinutes -lt 1)) -and ($SyncHash.DeploymentJob.Error -eq $null)) {
                        $Start = $SyncHash.DeploymentStart
                        $End = Get-Date
                        $Duration = New-TimeSpan -Start $Start -End $End
						
                        $SyncHash.DeploymentJob.Duration = $("{0:HH:mm:ss}" -f ([datetime]$Duration.Ticks))
                        $SyncHash.DeploymentJob.Status.Deployment = @()
                        foreach ($Item in $DeploymentStatus) {
                            $Status = new-object -TypeName psobject -Property @{
                                Name = $Item.DeploymentName
                                Status = $Item.ProvisioningState
                            }
                            $SyncHash.DeploymentJob.Status.Deployment += $Status
                        }
                        start-sleep -Seconds 10
                        $DeploymentStatus = Get-AzureRmResourceGroupDeployment -ResourceGroupName $SyncHash.ResourceGroupName
                    }


                    foreach ($Item in $DeploymentStatus) {
                        $Status = new-object -TypeName psobject -Property @{
                            Name = $Item.DeploymentName
                            Status = $Item.ProvisioningState
                        }
                        $SyncHash.DeploymentJob.Status.Deployment += $Status
                    }
					
                } catch {
                    $SyncHash.DeploymentJob.Error = $Error[0].ToString()
                }
                finally {
                    $Duration = New-TimeSpan -Start $Start -End (get-date) 
                    $SyncHash.DeploymentJob.Duration = $("{0:HH:mm:ss}" -f ([datetime]$Duration.Ticks))
                    $SyncHash.DeploymentJob.Completed = $true
                }


            }
            if ($AsJob) {
                # return [ref]$SyncHash.DeploymentJob
            }
            else {
                while ($SyncHash.DeploymentJob.Completed -ne $true) {
                    Write-Progress -id 100 -Activity "Deploying Azure Solution ($($SyncHash.DeploymentJob.Duration))" -PercentComplete -1
                    $i = 0
                    foreach ($Item in $SyncHash.DeploymentJob.Status.Deployment) {
                        Write-Progress -Activity $Item.Name -Status $Item.Status -ParentId 100 -PercentComplete -1 -id $i
                        $i++
                    }
                    start-sleep -Seconds 10
                }
				
            }
            #remove-item -Path $SyncHash.DeploymentJob.CredentialFile -Force -ErrorAction Ignore
            if ($SyncHash.DeploymentJob.Error -ne $null) {
                throw $SyncHash.DeploymentJob.Error
            }
        }
        catch {

            #  Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
            write-log -Type Error "Error while deploying solution: $($SyncHash.DeploymentJob.Error)."
        }
        finally {
            ([ref]$SyncHash.DeploymentJob).value
        }
    }
	
    end {
    } 
}