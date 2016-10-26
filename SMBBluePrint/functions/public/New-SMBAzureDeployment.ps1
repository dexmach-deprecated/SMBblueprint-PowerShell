function New-SMBAzureDeployment {
	[cmdletbinding(DefaultParameterSetName="AzureTenantDomain")]
	param(  
	[parameter()]
	[switch] $AsJob,
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $CustomerName,
	[parameter(Mandatory=$true)]
	[ValidateSet('small','medium','large')]
	[string] $CustomerSize = 'small',
	[parameter()]
	[ValidateSet('none','small','medium')]
	[string] $AdditionalVMSize = 'none',
	[parameter()]
	[ValidateSet('none','small')]
	[string] $AdditionalSQLInstanceSize = 'none',
	[ValidateSet('none','standard')]
	[string] $Backup = 'none',
	[ValidateSet('none','basic')]
	[string] $VPN = 'none',
	[parameter()]
	[string] $SysAdminPassword = $(New-SWRandomPassword),
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[pscredential] $Credential = (Get-Credential -Message "Please provide your Partner Credentials"),
	[parameter(ParameterSetName="AzureTenantId",Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $TenantId,
	[parameter(ParameterSetName="AzureTenantDomain",Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $TenantDomain,
	[parameter()]
	[ValidateNotNullOrEmpty()]
	[string] $SubscriptionId,
	[parameter()]
	[ValidateNotNullOrEmpty()]
	[string] $SubscriptionName,
	[Parameter(DontShow=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $ResourceGroupPrefix = "smb_rg_",
	[Parameter(DontShow=$true)]
	[string] $Log = $null


	)
	
	begin{
		if([string]::IsNullOrEmpty($Log) -eq $false){
			if(test-path $Log){} else {
				$Log = Start-Log
			}
		} else {
			$Log = Start-Log
		}
		$PSDefaultParameterValues = @{"Write-Log:Log"=$Log}

		$CustomerNamePrefix = [Regex]::Replace($CustomerName,'[^a-zA-Z0-9]', '')
		$ResourceGroupName = "$ResourceGroupPrefix$CustomerNamePrefix"
		$SecurePassword = $SysAdminPassword|ConvertTo-SecureString -AsPlainText -Force
		write-log -Message "Using $CustomerNamePrefix as resource naming prefix"
		Write-Log -Message "Using $ResourceGroupName as target resource group"
		$ActiveSubscription = ""
		if($Credential){
			try {
				Connect-MsolService -Credential $Credential
				if($TenantId){
					$null = Add-AzureRMAccount -Credential $Credential -TenantId $TenantId
				} elseif ($TenantDomain){
					if(($TenantId = ((Get-MsolPartnerContract -all).where{$_.DefaultDomainName -eq $TenantDomain}).TenantId) -eq $null){
						Write-Log -Type Error -Message "Tenant Domain not found"
					} elseif($TenantId.GetType().IsArray) {
						Write-Log -Type Error -Message "There are multiple tenants with the specified domain name. Please use Tenant ID to specify an exact target tenant."
					} else {
						# everything OK
					}
					$null = Add-AzureRMAccount -Credential $Credential -TenantId $TenantId
					
				} else {
					$null = Add-AzureRMAccount -Credential $Credential
				}

				if($SubscriptionId){
					$null = Select-AzureRmSubscription -SubscriptionId $SubscriptionId
				} elseif($SubscriptionName){
					$null = Select-AzureRmSubscription -SubscriptionName $SubscriptionName
				} else {
					# use default subscription
				}
			} catch {
				write-log -type error -message "Error during Azure connection: $_"
			}
		}
		try{
			$null = Get-AzureRmContext
		}
		catch {
			Write-Error "No active Azure subscription is present in the session. Please use Login-AzureRMAccount and Select-AzureRMSubscription to set the target subscription, or specify Tenant/Credential information"
			return $null
		}
		if((Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Ignore) -ne $null){
			Write-Log -Type Error -Message "Resource group already exists, please choose another customer name"
			return
		}
		if((Test-AzureRmDnsAvailability -DomainNameLabel $CustomerNamePrefix.ToLower() -Location "westeurope") -eq $false){
			write-log -type error -Message "Domain Name already taken, please choose another customer name"
			return
		}

		$AzureParameters = @{
			customername = $CustomerNamePrefix
			customersize = $CustomerSize
			sql = $AdditionalSQLInstanceSize
			vm = $AdditionalVMSize
			backupEnabled = $Backup
			vpnGateway = $VPN
			scheduleid01=$([guid]::NewGuid().ToString())
			scheduleid02=$([guid]::NewGuid().ToString())               
		}
		$AzureParameters.Add('adminPassword',$SecurePassword)
		
		
		
	}
	process{
		
		Write-Log "Creating Resourcegroup '$($ResourceGroupName)'"
		try {
			$null = New-AzureRmResourceGroup -Name $ResourceGroupName -Location "westeurope" # currently hard-coded location, will Changed
		}
		catch {
			Write-log -Type Error -Message "Error while deploying resource group: $_"
			return $null
		}
		write-log "Deploying solution to resource group"
		try{
			$SyncHash = [hashtable]::Synchronized(@{})
			$SyncHash.ResourceGroupName = $ResourceGroupName
			$SyncHash.DeploymentParameters = $AzureParameters
			$SyncHash.Log = $Log
			$SyncHash.LogFunction = "$Root\functions\private\write-log.ps1"
			$SyncHash.PopupFunction = "$Root\functions\private\invoke-message.ps1"
			$SyncHash.ClassFunction = "$Root\functions\private\register-classes.ps1"
			$SyncHash.OperationFunction = "$Root\functions\private\invoke-operation.ps1"
			$CredentialGuid = [guid]::NewGuid().Guid
			$null = Save-AzureRmProfile -path "$env:TEMP\SBSDeployment-$CredentialGuid.json" -Force

			$SyncHash.DeploymentStart = get-date
			$SyncHash.DeploymentJob = new-object psobject -Property @{
				Type='Azure'
				Duration="00:00:00"
				Status = @{
					Deployment = @()
					Configuration = @{
						Domain="$CustomerNamePrefix.local"
						Login='sysadmin'
						Password = $SysAdminPassword
						ResourceGroup = $ResourceGroupName
						Connection = "https://$($CustomerNamePrefix.ToLower()).westeurope.cloudapp.azure.com/rdweb"
					}
				}
				Completed = $false
				Error = $null
				Log = $Log
			}

			$null = invoke-operation -synchash $SyncHash -code {
				try{
					$null = Select-AzureRmProfile -Path "$env:TEMP\SBSDeployment-$CredentialGuid.json"
					$null = New-AzureRmResourceGroupDeployment -TemplateUri 'https://inovativbe.blob.core.windows.net/sbstemplate/azuredeploy.json' `
					-TemplateParameterObject $SyncHash.DeploymentParameters -ResourceGroupName $SyncHash.ResourceGroupName
					if($? -eq $false){
						throw $Error[1]
					}
				} catch {
					$SyncHash.DeploymentJob.Error = $_.Exception
				}
				
			}
			
			$null = Invoke-Operation -synchash $SyncHash -code {
				try {
					$null = select-azurermprofile -path "$env:TEMP\SBSDeployment-$CredentialGuid.json"
					$DeploymentStatus = Get-AzureRmResourceGroupDeployment -ResourceGroupName $SyncHash.ResourceGroupName
					
					while(((($DeploymentStatus.where{$_.ProvisioningState -eq 'Running'}).count -gt 0) -or ((new-timespan -start $SyncHash.DeploymentStart -end (get-date)).TotalMinutes -lt 1)) -and ($SyncHash.DeploymentJob.Error -eq $null)){
						$Start = $SyncHash.DeploymentStart
						$End = Get-Date
						$Duration = New-TimeSpan -Start $Start -End $End
						
						$SyncHash.DeploymentJob.Duration = $("{0:HH:mm:ss}" -f ([datetime]$Duration.Ticks))
						$SyncHash.DeploymentJob.Status.Deployment = @()
						foreach($Item in $DeploymentStatus){
							$Status = new-object -TypeName psobject -Property @{
								Name = $Item.DeploymentName
								Status = $Item.ProvisioningState
							}
							$SyncHash.DeploymentJob.Status.Deployment += $Status
						}
						start-sleep -Seconds 10
						$DeploymentStatus = Get-AzureRmResourceGroupDeployment -ResourceGroupName $SyncHash.ResourceGroupName
					}


					foreach($Item in $DeploymentStatus){
						$Status = new-object -TypeName psobject -Property @{
							Name = $Item.DeploymentName
							Status = $Item.ProvisioningState
						}
						$SyncHash.DeploymentJob.Status.Deployment += $Status
					}
					
				} catch {
					$SyncHash.DeploymentJob.Error = $_
				}
				finally{
					$Duration = New-TimeSpan -Start $Start -End (get-date) 
					$SyncHash.DeploymentJob.Duration = $("{0:HH:mm:ss}" -f ([datetime]$Duration.Ticks))
					$SyncHash.DeploymentJob.Completed = $true
				}


			}
			if($AsJob){
				# return [ref]$SyncHash.DeploymentJob
			}
			else {
				while($SyncHash.DeploymentJob.Completed -ne $true){
					Write-Progress -id 100 -Activity "Deploying Azure Solution ($($SyncHash.DeploymentJob.Duration))" -PercentComplete -1
					$i = 0
					foreach($Item in $SyncHash.DeploymentJob.Status.Deployment){
						Write-Progress -Activity $Item.Name -Status $Item.Status -ParentId 100 -PercentComplete -1 -id $i
						$i++
					}
					start-sleep -Seconds 10
				}
				
			}
			remove-item -Path "$env:TEMP\SBSDeployment-$CredentialGuid.json" -Force -ErrorAction Ignore
			if($SyncHash.DeploymentJob.Error -ne $null){
				throw $SyncHash.DeploymentJob.Error
			}
		}
		catch {

			#  Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
			write-log -Type Error "Error while deploying solution: $($SyncHash.DeploymentJob.Error)."
		}
		finally{
			([ref]$SyncHash.DeploymentJob).value
		}
	}
	
	end{} 
}