function New-SMBAzureDeployment {
	[cmdletbinding(DefaultParameterSetName="AzureTenantDomain")]
	param(
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $Location,
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('southeastasia','westeurope','australiasoutheast')]
	[string] $FallbackLocation,
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
	[ValidateNotNullOrEmpty()]
	[ValidateSet('free')]
	[string] $Management = 'free',
	[parameter()]
	[ValidateSet('2012R2','2016')]
	[string] $OS = '2012R2',
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
		$Continue = $true
		$Management = 'free'
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
		if($CustomerNamePrefix -like "*microsoft*"){
			write-log -type error -message "'Microsoft' can not be a part of the customer name, please choose another customer name"
			return
		}

		$CompatibilityResults = Test-AzureResourceLocation -Location $Location -ResourceFile "$Root\resources"
		$Break = $false
		$Count = 0
		if(((get-variable -name CompatibilityResults -ErrorAction Ignore) -eq $null) -or ($CompatibilityResults -eq $null)){
			$Count = 0
		} else {
			$Count = $CompatibilityResults.Count
		}
		if($Count -gt 0){
			$Continue = $false
			foreach($Result in $CompatibilityResults){
				switch -regex ($Result) {
					
					"microsoft\.(automation|operationalinsights|operationsmanagement)"{
						
						if(!$FallbackLocation){
							if($Break){
								break
							}
							$title = "Automation & Monitoring Features Unsupported for this Region"
							$message = "The selected Azure Region does not support the automation & monitoring features of the SMB Blueprint solution. In which region should they be deployed instead (by re-running this command with the -FallBackLocation Parameter you can automatically deploy non-compatible resources to a fallback region)?" 
							$choices = new-object System.Collections.ArrayList<System.Management.Automation.Host.ChoiceDescription>
							$null = $choices.add($(New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel","Aborts the deployment"))
							$me = get-command -name new-smbazuredeployment
							#$me.Parameters["FallbackLocation"].Attributes
							foreach($ChoiceLocation in ((($me.Parameters["FallbackLocation"]).Attributes|?{$_.TypeId.Name -eq 'ValidateSetAttribute'})).ValidValues){
								$null = $choices.Add($(New-Object System.Management.Automation.Host.ChoiceDescription "&$ChoiceLocation","Deploys the resources in '$ChoiceLocation'"))
							}
							$choices = $choices.ToArray([System.Management.Automation.Host.ChoiceDescription])
						

							

							$result = $host.ui.PromptForChoice($title, $message, $choices, 0) 
							write-log -message "You chose: $($choices[$result].Label.Replace('&',''))"
							switch ($choices[$result].Label.Replace('&',''))
							{
								"Cancel" {write-log -message "Deployment Cancelled";$Continue = $false}
								default {
									
									$FallbackLocation = ($choices[$result]).Label.Replace('&','')
									write-log -message "Continuing Deployment with Fallback Location: $FallbackLocation"
									$Continue = $true
								}
							}
						} else {
							$Continue = $true
						}
					
					#	if($Continue){
					#		$Backup = 'none';$Management = 'none'
					#	}
					$Break = $true
					}
					"microsoft.recoveryservices" {
						write-log -type warning -message "Backup is not supported at this location. The feature will not be deployed"
						$Backup = "none"
					}
					Default {}
				}
					
				
			}
		} else {
			# do nothing
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
            scheduleStartDate = (get-date).AddDays(1).ToString("yyyy/MM/dd") 
			managementEnabled =  $Management
			useFallbackLocation = $(if($FallbackLocation){'yes'}else{'no'})
			fallbackLocation = $(if($FallbackLocation ){$FallbackLocation} else {'westeurope'})
			OSVersion = $OS
		}
		$AzureParameters.Add('adminPassword',$SecurePassword)
		
		
		
	}
	process{
		if(!$Continue){return}
		Write-Log "Creating Resourcegroup '$($ResourceGroupName)'"
		try {
			$null = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
		}
		catch {
			Write-log -Type Error -Message "Error while deploying resource group: $_"
			return $null
		}
		write-log "Deploying solution to resource group"
		try{
			if((Get-Variable -name 'SyncHash' -ErrorAction SilentlyContinue) -eq $null){
				#write-log -message "Running in CLI mode"
				$SyncHash = [hashtable]::Synchronized(@{})
				$SyncHash.Root = $script:Root
				$SyncHash.Log = $Log
			} else {
				#write-log -message "Running in GUI mode"
			}

			$SyncHash.ResourceGroupName = $ResourceGroupName
			$SyncHash.DeploymentParameters = $AzureParameters
		<#	$SyncHash.Log = $Log
			$SyncHash.LogFunction = "$Root\functions\private\write-log.ps1"
			$SyncHash.PopupFunction = "$Root\functions\private\invoke-message.ps1"
			$SyncHash.ClassFunction = "$Root\functions\private\register-classes.ps1"
			$SyncHash.OperationFunction = "$Root\functions\private\invoke-operation.ps1" #>
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
						Connection = "https://$($CustomerNamePrefix.ToLower()).$($Location).cloudapp.azure.com/rdweb"
					}
				}
				Completed = $false
				Error = $null
				Log = $Log
			}

			$null = invoke-operation -synchash $SyncHash -root $SyncHash.Root -Log $SyncHash.Log -code {
				try{
					$null = Select-AzureRmProfile -Path "$env:TEMP\SBSDeployment-$CredentialGuid.json"
					$null = New-AzureRmResourceGroupDeployment -TemplateUri 'https://inovativbe.blob.core.windows.net/sbstemplatedev/azuredeploy.json' `
					-TemplateParameterObject $SyncHash.DeploymentParameters -ResourceGroupName $SyncHash.ResourceGroupName
					if($? -eq $false){
						throw $Error[1]
					}
				} catch {
					$SyncHash.DeploymentJob.Error = $_.Exception
				}
				
			}
			
			$null = Invoke-Operation -synchash $SyncHash -log $SyncHash.Log -root $SyncHash.Root -code {
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