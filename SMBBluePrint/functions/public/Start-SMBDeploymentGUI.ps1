Function Start-SMBDeploymentGUI {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch] $NoUpdateCheck
    )
    $SyncHash = Get-JobVariable
    $Log = Start-Log -InstanceId $SyncHash.InstanceId
    $SyncHash.Log = $Log
    $PSDefaultParameterValues = @{"Write-Log:Log"="$Log"}
    if(!$PSBoundParameters.ContainsKey('NoUpdateCheck')){
        Test-ModuleVersion -ModuleName SMBBluePrint
    }
    #$script:SyncHash = [hashtable]::Synchronized(@{})
    # Create empty view-model
    $SyncHash.ViewModel = new-object psobject -Property @{
        Tenants = @()
        Subscriptions = @()
        AzureCredential = $null
        OfficeCredential = $null
        Groups = @()
        Users = @()
        VMSize = 'none'
        SQLSize = 'none'
        Backup='none'
        VPN='none'
        CustomerName = 'Inovativ'
        Customersize = 'small'
        Password = New-SWRandomPassword -MinPasswordLength 16 -MaxPasswordLength 16
        Licenses = @()
        ResourceGroup = $null
        ActiveTenant=$null
        ActiveSubscription=$null
        TabState = "Collapsed"
        CommandName = $null
        CommandParameters = $null
        MailDomain = $null
        AzureLocation = $null
        FallbackAction = $null
        Management = 'free'
        OS = '2016'
        StorageType = $null
    }
    write-host "Please wait while the graphical interface is being loaded"
    #	if($Log -eq $null){
    #		$Log = Start-Log
    #	}

    $SyncHash.Module = "$global:root\SMBDeployment.psd1"
    $SyncHash.XAML = (get-xaml)
	
    $SyncHash.Root = $global:root

	
	
    $null = invoke-operation -log $SyncHash.Log -root $SyncHash.Root -synchash $SyncHash -code {
        try{

            # Create GUI windows from WPF XAML
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName PresentationCore
            Add-Type -AssemblyName PresentationFramework
            Add-Type -AssemblyName WindowsBase
            [xml]$XAML = $SyncHash.XAML
            $XAMLReader = new-object -typename System.Xml.XmlNodeReader -ArgumentList $XAML
            $SyncHash.GUI = [Windows.Markup.XamlReader]::Load( $XAMLReader )
			
            $XAML.SelectNodes("//*[@Name]")|
            ForEach-Object{
                #   write-log -Type Debug -Message "Adding variable for control $($_.Name): $($SyncHash.GUI.FindName($_.Name))"
                $SyncHash."WPF_$($_.Name)" = $SyncHash.GUI.FindName($_.Name)
            }
			
        } catch {
			
            return
        }
		
        # UI functions


		
		
        function Get-AzureSubscription {
            try{
                $SyncHash.ViewModel.Subscriptions = @()
                $cmb_Tenants = $SyncHash.WPF_Cmb_Tenants
                write-log -type debug -message "Reconnecting to Azure with selected tenant"
                if($cmb_Tenants.SelectedItem -ne ""){
                    $SelectedTenant = [Tenant]$cmb_Tenants.selecteditem
                    $SyncHash.ViewModel.ActiveTenant = $SelectedTenant
                    $SyncHash.ViewModel.Licenses = Get-O365License -TenantId $SelectedTenant.Id
                    $TxtCustomer = $SelectedTenant.Name.Replace(".","")
                    if ($TxtCustomer.length -gt 15) {
                        $TxtCustomer = $TxtCustomer.SubString(0,15)
                    }
                    $SyncHash.GUI.FindName('Txt_Customer').Text = $TxtCustomer
                    Add-AzureRmAccount -Credential $SyncHash.ViewModel.AzureCredential -TenantId $($SelectedTenant.Id)
                write-log -Message "Getting subscriptions for Tenant $SelectedTenant" -type Debug
                foreach($Subscription in (Get-AzureRmSubscription -TenantId $SelectedTenant.Id)){
                    $SubscriptionObject = New-Object Subscription
                    $SubscriptionObject.Name = $Subscription.SubscriptionName
                    $SubscriptionObject.Id = $Subscription.SubscriptionId
                    write-log -Type Debug -Message "Found Subscription '$($SubscriptionObject.Name)'"
                    $SyncHash.ViewModel.Subscriptions += $SubscriptionObject
						
                }
            }
				
            $SyncHash.WPF_Cmb_Subscriptions.ItemsSource = $SyncHash.ViewModel.Subscriptions
            $SyncHash.WPF_Cmb_Subscriptions.SelectedIndex = 0
            $Locations = @()
            foreach($Location in (get-azurermlocation)){
                $Locations += $Location.Location
            }
            $Locations = $Locations|sort
            $SyncHash.WPF_Cmb_PrimaryLocation.ItemsSource = $Locations
            # Some tinkering to get the license selection box working properly
            $array = new-object Object[] $SyncHash.ViewModel.Licenses.Values.Count
            $SyncHash.ViewModel.Licenses.Values.CopyTo($array,0)
            $SyncHash.WPF_Lst_Licenses.ItemsSource = $array
				
            #$SyncHash.WPF_Lst_Licenses.SelectedIndex = 0
            $SyncHash.ViewModel.MailDomain = (Get-AzureADDomain|where{$_.IsDefault -eq $true}).Name
            ### Debug Code:
            $SyncHash.WPF_Txt_Mail.IsReadOnly = $false
            ###
            $SyncHash.WPF_Txt_Mail.Text = $SyncHash.ViewModel.MailDomain
            $SyncHash.GUI.DataContext = $SyncHash.ViewModel
            $SyncHash.GUI.Dispatcher.Invoke(
                "Render",
                [action]{
                    $SyncHash.WPF_Btn_O365Link.Visibility = [System.Windows.Visibility]::Visible
                    $SyncHash.WPF_Btn_AzureLink.Visibility = [System.Windows.Visibility]::visible
                    if($SyncHash.ViewModel.Subscriptions.Count -gt 0){
                        $SyncHash.WPF_Btn_AzureLink.Visibility = [System.Windows.Visibility]::Visible
                    }
                    if($SyncHash.ViewModel.Licenses.Count -gt 0){
                        $SyncHash.WPF_Btn_O365Link.Visibility = [System.Windows.Visibility]::Visible
                    }
					
                }
            )
				
				
        } catch {
            write-log -Message $_ -Type Debug
        }
    } 

		

		


    ##################################################################################################################################################

		
    try {
			
			

        # Define the GUI control variable
        #$SyncHash.GUI.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

        # Add listeners to controls
        $SyncHash.WPF_Btn_ConnectToAzure.Add_Click(
            <#  {
				Set-Busy -On -Activity "Connecting with Azure"
				Get-AzureConnection
				Set-Busy -Off
			} #> {
				
                Write-Log -Message "Connecting to Azure using the provided credentials"
                $txt_logonuser = $SyncHash.WPF_Txt_LogonUser
                $txt_logonpass = $SyncHash.WPF_Txt_LogonPass
                if([String]::IsNullOrEmpty($txt_LogonUser.Text) -or [String]::IsNullOrEmpty($txt_logonpass.Password)){
                    Invoke-Message -Message "User or Password not provided. Please fill in all information."
                    return
                }
                $User = $txt_logonuser.Text
                $Password = ($txt_logonpass.Password|ConvertTo-Securestring -AsPlainText -Force)
                $SyncHash.ViewModel.AzureCredential = new-object pscredential $User,$Password
				
				
				
                $job = invoke-operation -synchash $SyncHash -Log $SyncHash.Log -Root $SyncHash.Root -Code {
                    try{                 
						
                        $SyncHash.GUI.Dispatcher.Invoke(
                            "Render",
                            [action]{
							
                                $SyncHash.WPF_Lbl_Title.Text = "Retrieving Tenant Information"}
                        )
                        <#Add-AzureRmAccount -Credential $SyncHash.ViewModel.AzureCredential
						if($? -eq $false){
							throw $Error[0]
						}
						write-log -message "Connected to AzureRM" -type verbose
						Connect-MSOLService -Credential $SyncHash.ViewModel.AzureCredential
						if($? -eq $false){
							throw $Error[0]
						}
						write-log -message "Connected to MSOnline" -type verbose
						$SyncHash.ViewModel.Tenants = @()
						foreach($Tenant in Get-AzureRmTenant){
							$TenantObject = new-object Tenant
							$TenantObject.Id = $Tenant.TenantId
							$TenantObject.Name = $Tenant.Domain
							write-log -message "Found internal Tenant $($TenantObject.Name)" -type debug
							$SyncHash.ViewModel.Tenants += $TenantObject
						}
						foreach($Tenant in Get-MSOLPartnerContract -All){
							$TenantObject = new-object Tenant
							$TenantObject.Id = $Tenant.TenantId
							$TenantObject.Name = $Tenant.DefaultDomainName
							$SyncHash.ViewModel.Tenants += $TenantObject
							write-log -message "Found CSP Tenant $($TenantObject.Name)" -type debug
						} #>
                        $null = Connect-Cloud -Credential $SyncHash.ViewModel.AzureCredential
                        $SyncHash.ViewModel.Tenants = @($(Get-Tenant -All))

						
						
                    $SyncHash.GUI.Dispatcher.Invoke(
                        [action]{
                            $SyncHash.WPF_Cmb_Tenants.ItemsSource = $SyncHash.ViewModel.Tenants
                            # $SyncHash.WPF_Cmb_Tenants.SelectedIndex = 0
                            $SyncHash.WPF_Cmb_Tenants.IsDropDownOpen = $true
                        }
						
                    )
						
						
						
                } 
					
                catch {
                    Invoke-Message -Message "$_ @ $($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line) Trace: $($_.ScriptStackTrace)"
                    return
                }
                finally{
                    $SyncHash.GUI.Dispatcher.Invoke(
                        [action]{
                            $SyncHash.WPF_Lbl_Title.Text = 'SMB Deployment GUI'
							
                        })
                }
            }
        }
			
			
    )

    $cmb_Tenants = [System.Windows.Controls.ComboBox]$SyncHash.WPF_Cmb_Tenants
			
    $cmb_Tenants.Add_SelectionChanged( {

            Get-AzureSubscription
        }
    )

    $SyncHash.WPF_Txt_Mail.Add_TextChanged({
	
            $SyncHash.ViewModel.MailDomain = $SyncHash.WPF_Txt_Mail.Text
        })
			
			

    $SyncHash.WPF_Txt_Customer.Add_TextChanged({
            $SyncHash.WPF_Txt_Customer.Text = [Regex]::Replace($SyncHash.WPF_Txt_Customer.Text,'[^a-zA-Z0-9]', '')
            $SyncHash.ViewModel.CustomerName = $SyncHash.WPF_Txt_Customer.Text
        })
    $SyncHash.WPF_Rad_Small.Add_Checked({
            $SyncHash.ViewModel.CustomerSize = "small"
            Write-Log -Message "CustomerSize set to $($SyncHash.ViewModel.CustomerSize)"
        })
    $SyncHash.WPF_Rad_Medium.Add_Checked({
            $SyncHash.ViewModel.CustomerSize = "medium"
            Write-Log -Message "CustomerSize set to $($SyncHash.ViewModel.CustomerSize)"
        })
    $SyncHash.WPF_Rad_Large.Add_Checked({
            $SyncHash.ViewModel.CustomerSize = "large"
            Write-Log -Message "CustomerSize set to $($SyncHash.ViewModel.CustomerSize)"
        })

    $SyncHash.WPF_Cmb_ExtraVMSize.Add_SelectionChanged({
            $SyncHash.ViewModel.VMSize = $SyncHash.WPF_Cmb_ExtraVMSize.SelectedItem.Tag
            Write-Log -Message "ExtraVMSize set to $($SyncHash.ViewModel.VMSize)"
        })
    $SyncHash.WPF_Cmb_ExtraSQLSize.Add_SelectionChanged({
            $SyncHash.ViewModel.SQLSize = $SyncHash.WPF_Cmb_ExtraSQLSize.SelectedItem.Tag
            Write-Log -Message "ExtraSQLSize set to $($SyncHash.ViewModel.SQLSize)"
        })
    $SyncHash.WPF_Cmb_Subscriptions.Add_SelectionChanged({
            $SyncHash.ViewModel.ActiveSubscription = ($SyncHash.WPF_Cmb_Subscriptions.SelectedItem)
        })
    $SyncHash.WPF_Cmb_Backup.Add_SelectionChanged({
            $SyncHash.ViewModel.Backup = $SyncHash.WPF_Cmb_Backup.SelectedItem.Tag
            Write-Log -Message "Backup set to $($SyncHash.WPF_Cmb_Backup.SelectedItem.Tag)"
        })
    $SyncHash.WPF_Cmb_VPN.Add_SelectionChanged({
            $SyncHash.ViewModel.VPN = $SyncHash.WPF_Cmb_VPN.SelectedItem.Tag
            Write-Log -Message "VPN set to $($SyncHash.WPF_Cmb_VPN.SelectedItem.Tag)"
        })
    $SyncHash.WPF_Btn_CopyCredential.Add_Click({
            "User: sysadmin Password: $($SyncHash.ViewModel.Password)"|clip
            invoke-message "Credentials copied to clipboard"
        })
    $SyncHash.WPF_Btn_CopyCommand.Add_Click({
            if($SyncHash.ViewModel.CommandName -eq $null){
                invoke-message "Start the deployment to be able to obtain the code-behind"
            } else {
                $Command = $SyncHash.ViewModel.CommandName
                foreach($Item in $SyncHash.ViewModel.CommandParameters.Keys){
                    $Command += " -$($Item) $($SyncHash.ViewModel.CommandParameters[$Item])"
                }
                $Command|clip
                invoke-message "The command has been pasted to the clipboard:`r`n$Command"
            }
        })
    $SyncHash.WPF_Btn_OfficeDeploy.Add_Click({
            if(
                [string]::IsNullOrEmpty($SyncHash.ViewModel.ActiveTenant) -or
                $SyncHash.ViewModel.Users.Count -eq 0
            ){
                invoke-message "Not all parameters are present for deployment"
                return
            }
            $SyncHash.ViewModel.Password = $SyncHash.WPF_Txt_OfficePassword.Password
            if((Test-AADPasswordComplexity -MinimumLength 8 -Password $SyncHash.ViewModel.Password) -eq $false){
                invoke-message "Password does not meet complexity requirements"
                return
            }
				
            $Overview =  `
				"The deployment will be started with the following parameters:`r`n" +`
				"Target Tenant: $(($SyncHash.ViewModel.ActiveTenant.Name))`r`n" +`
				"Number of Groups: $($SyncHash.ViewModel.Groups.Count)`r`n" + `
				"Number of Users: $($SyncHash.ViewModel.Users.Count)`r`n" + `
				"Initial Password for login: $($SyncHash.ViewModel.Password)`r`n"
            [System.Windows.Forms.MessageBox]::Show($Overview,"Deployment Info")
            [System.Windows.Forms.DialogResult] $DialogResult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to deploy this Azure solution?","Confirm Deployment",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
            if($DialogResult -eq [System.Windows.Forms.DialogResult]::Yes){
                $SyncHash.GUI.Dispatcher.invoke(
                    "Render",
                    [action]{
                        $SyncHash.WPF_Tab_MainControl.SelectedItem = $SyncHash.WPF_Tab_Log
                        $SyncHash.WPF_Btn_O365Link.Visibility = [System.Windows.Visibility]::collapsed
                        $SyncHash.WPF_Btn_AzureLink.Visibility = [System.Windows.Visibility]::collapsed
                        $SyncHash.WPF_Btn_HomeLink.Visibility = [System.Windows.Visibility]::collapsed     
                    })
                $CSVLocation = "$env:TEMP\SMBUsers.csv"
                ConvertFrom-O365 -Users $SyncHash.ViewModel.Users -Path $CSVLocation
                $SyncHash.DeploymentJob = new-object psobject
                $Parameters = @{
                    Credential = $SyncHash.ViewModel.AzureCredential
                    CSV = $CSVLocation
                    TenantId = $SyncHash.ViewModel.ActiveTenant.Id
                    DefaultPassword = $SyncHash.ViewModel.Password
                    SyncHash= $SyncHash
                    Log=$Log
                    MailDomain = $SyncHash.ViewModel.MailDomain
                    NoUpdateCheck = $true
                }
                $SyncHash.ViewModel.CommandName = "New-SMBOfficeDeployment"
                $SyncHash.ViewModel.CommandParameters = $Parameters
                $job = invoke-operation -Parameters $Parameters -log $SyncHash.Log -root $SyncHash.Root -SyncHash $SyncHash -Code {
						
                    try{
							
                        $job = invoke-operation -Parameters $Parameters -log $SyncHash.Log -root $SyncHash.Root -SyncHash $SyncHash -Code {
                            try{
                                new-smbofficedeployment @Parameters
                            } catch {
                                write-log -type error -message "Error during Office Deployment: $_"
                            }
                        }
                        start-sleep 5
                        $DeploymentStart = get-date
                        while(($SyncHash.DeploymentJob.Completed -ne $true) -or (new-timespan -Start $DeploymentStart -End (get-date)).TotalMinutes -le 1){
                            $ErrorActionPreference = "Stop"
                            $DeploymentEnd = get-date
                            $DeploymentDuration = New-TimeSpan -Start $DeploymentStart -End $DeploymentEnd
                            $SyncHash.DeploymentJob.Duration = $("{0:HH:mm:ss}" -f ([datetime]$DeploymentDuration.Ticks))
                        $Status = "Please check the logging for progress"
                        $SyncHash.GUI.Dispatcher.invoke(
                            "Render",
                            [action]{
                                $SyncHash.WPF_Txt_DeploymentType.Text = $SyncHash.DeploymentJob.Type
                                $SyncHash.WPF_Txt_DeploymentStatus.Text = $Status
                                $SyncHash.WPF_Txt_DeploymentTime.Text = $SyncHash.DeploymentJob.Duration
                            })
								
								
                        start-sleep -Seconds 10
								
                    }
							
                    if($SyncHash.DeploymentJob.Error){
                        throw $SyncHash.DeploymentJob.Error
                    } else {
                        $Status = "Office Deployment Completed`r`n"
                        foreach($User in $SyncHash.DeploymentJob.Status.ProvisionedUsers){
                            $Status += "Login: $($User.Login) Password: $($User.Password)`r`n"
                        }
                        $SyncHash.GUI.Dispatcher.invoke(
                            "Render",
                            [action]{
									
                                $SyncHash.WPF_Txt_DeploymentStatus.Text = $Status
									
                            })
                    }

                } catch {
                    write-log -type error -message "Error during Office Deployment: $_"
                    return
                }


						

            }
        }

    })

$SyncHash.WPF_Cmb_PrimaryLocation.Add_SelectionChanged({
        $SyncHash.ViewModel.AzureLocation = $SyncHash.WPF_Cmb_PrimaryLocation.SelectedItem
        Write-Log -Type Information -Message "Azure Location changed to '$($SyncHash.ViewModel.AzureLocation)', checking compatibility using file '$($SyncHash.Root)\resources'"
        $Result = Test-AzureResourceLocation -Location $SyncHash.WPF_Cmb_PrimaryLocation.SelectedItem -ResourceFile "$($SyncHash.Root)\resources"
        if(((get-variable -Name Result -ErrorAction Ignore) -eq $null) -or ($Result -eq $null)){
            $Count = 0
        } else {
            $Count = $Result.Count
        }
        if($Count -gt 0){
            if($Result -contains "microsoft.automation" -or $Result -contains "microsoft.operationsmanagement" -or $Result -contains "microsoft.operationalinsights"){
                Invoke-Message "The location you selected does not support all services present in the deployment. Please choose a fallback action."
                $SyncHash.GUI.Dispatcher.Invoke(
                    'Render',
                    [action]{
                        $SyncHash.WPF_Spl_ServiceUnavailable.Visibility = [System.Windows.Visibility]::visible;
                        $SyncHash.WPF_Cmb_FallbackAction.SelectedIndex = 0
                        $SyncHash.ViewModel.FallbackAction = "westeurope"
                    }
                )
            } else {
                $SyncHash.ViewModel.FallbackAction = $null
                $SyncHash.GUI.Dispatcher.Invoke(
                    'Render',
                    [action]{
                        $SyncHash.WPF_Spl_ServiceUnavailable.Visibility = [System.Windows.Visibility]::collapsed;

                    }
                )

            }
            if($Result -contains "Microsoft.RecoveryServices"){
                Invoke-Message "Backup is not availabe at this location. The option will be disabled"
                $SyncHash.GUI.Dispatcher.Invoke(
                    'Render',
                    [action]{
                        $SyncHash.WPF_Cmb_Backup.SelectedIndex = 0
                        $SyncHash.ViewModel.Backup = 'none'
                        $SyncHash.WPF_Cmb_Backup.IsEnabled = $false

                    }
                )

            } else {
                $SyncHash.GUI.Dispatcher.Invoke(
                    'Render',
                    [action]{

                        $SyncHash.WPF_Cmb_Backup.IsEnabled = $true

                    }
                )

            }
        } else {
            $SyncHash.ViewModel.FallbackAction = $null
            $SyncHash.GUI.Dispatcher.Invoke(
                'Render',
                [action]{
                    $SyncHash.WPF_Spl_ServiceUnavailable.Visibility = [System.Windows.Visibility]::collapsed;
                    $SyncHash.WPF_Cmb_Backup.IsEnabled = $true

                }
            )

        }
    })
			

$SyncHash.WPF_Cmb_FallbackAction.Add_SelectionChanged({
        $SyncHash.ViewModel.FallbackAction = $SyncHash.WPF_Cmb_FallbackAction.SelectedItem.Tag
        Write-Log -Message "Fallback set to $($SyncHash.ViewModel.FallbackAction)"
    })
$SyncHash.WPF_Cmb_OS.Add_SelectionChanged({
        $SyncHash.ViewModel.OS = $SyncHash.WPF_Cmb_OS.SelectedItem.Tag
        Write-Log -Message "OS set to $($SyncHash.ViewModel.OS)"
    })
$SyncHash.WPF_Cmb_StorageType.Add_SelectionChanged({
        $SyncHash.ViewModel.StorageType = $SyncHash.WPF_Cmb_StorageType.SelectedItem.Tag
        Write-Log -Message "Storage Type set to $($SyncHash.ViewModel.StorageType)"
    })

$SyncHash.WPF_btn_Deploy.Add_Click( {
        if(
            ($SyncHash.ViewModel.CustomerName.length -eq 0) -or
            ($SyncHash.ViewModel.Subscriptions.Count -eq 0) -or
            (($SyncHash.ViewModel.ActiveSubscription) -eq $null) -or
            ($SyncHash.ViewModel.AzureLocation) -eq $null
        ){
            invoke-message "Not all parameters are provided for deployment"
            return
        }
        $SyncHash.ViewModel.Resourcegroup = "smb_rg_$($SyncHash.ViewModel.CustomerName)"
        Add-AzureRmAccount -Credential $SyncHash.ViewModel.AzureCredential -TenantId $SyncHash.ViewModel.ActiveTenant.Id -SubscriptionId $SyncHash.ViewModel.ActiveSubscription.Id
        if((($RG = Get-AzureRmResourceGroup -Name $SyncHash.ViewModel.ResourceGroup -ErrorAction SilentlyContinue)) -ne $null){
            Invoke-Message -Message "The target resource group $($SyncHash.ViewModel.ResourceGroup) already exists, please modify the customer prefix"
            return
        }
        if((Test-AzureRmDnsAvailability -DomainNameLabel $SyncHash.ViewModel.CustomerName.ToLower() -Location $SyncHash.ViewModel.AzureLocation) -eq $false){
            write-log -type error -Message "The public DNS record for this customer name is already taken, please choose another customer name"
            return
        }
        if($SyncHash.ViewModel.CustomerName -like "*microsoft*"){
            invoke-message -message "'Microsoft' can not be a part of the customer name, please choose another customer name"
            return
        }
        $SyncHash.ViewModel.Password = $SyncHash.WPF_Txt_AzurePassword.Password
        if((Test-AADPasswordComplexity -MinimumLength 12 -Password $SyncHash.ViewModel.Password) -eq $false){
            invoke-message "Password does not meet complexity requirements"
            return
        }
        $SyncHash.ViewModel.StorageType = $SyncHash.WPF_Cmb_StorageType.SelectedItem.Tag
				
				
        $Overview = `
				"The deployment will be started with the following parameters:`r`n" +`
				"Target Tenant: $(($SyncHash.ViewModel.ActiveTenant.Name))`r`n" +`
				"Target Subscription: $(($SyncHash.ViewModel.ActiveSubscription.Name))`r`n" +`
				"Target Group: $($SyncHash.ViewModel.ResourceGroup)`r`n" +`
				"Customer Prefix: $($SyncHash.ViewModel.CustomerName)`r`n" +`
				"Customer Size: $($SyncHash.ViewModel.CustomerSize)`r`n" +`
				"Extra SQL Size: $($SyncHash.ViewModel.SQLSize)`r`n" +`
				"Extra VM Size: $($SyncHash.ViewModel.VMSize)`r`n" +`
				"Backup Plan: $($SyncHash.ViewModel.Backup)`r`n" +`
				"VPN Plan: $($SyncHash.ViewModel.VPN)`r`n" +`
				"Management: $($SyncHash.viewModel.Management)`r`n" +
        "Location: $($SyncHash.viewModel.AzureLocation)`r`n" +
        "Fallback Action: $($SyncHash.viewModel.FallbackAction)`r`n" +
        "OS: $($SyncHash.viewModel.OS)`r`n" +
        "OS: $($SyncHash.viewModel.StorageType)`r`n" +
        "`r`n" +`
				"Please note this credential for use with the solution:`r`n" +`
				"User: sysadmin`r`n" +`
				"Password: $($SyncHash.ViewModel.Password)`r`n"

        [System.Windows.Forms.MessageBox]::Show($Overview,"Deployment Info")

        [System.Windows.Forms.DialogResult] $DialogResult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to deploy this Azure solution?","Confirm Deployment",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
				
        if($DialogResult -eq [System.Windows.Forms.DialogResult]::Yes){
            $DeploymentParameters = @{
                AdditionalSQLInstanceSize=$SyncHash.ViewModel.SQLSize
                AdditionalVMSize=$SyncHash.ViewModel.VMSize
                CustomerSize=$SyncHash.ViewModel.CustomerSize
                CustomerName=$SyncHash.ViewModel.CustomerName
                SysAdminPassword=$($SyncHash.ViewModel.Password)
            TenantId=$SyncHash.ViewModel.ActiveTenant.Id
            SubscriptionId=$SyncHash.ViewModel.ActiveSubscription.Id
            AsJob=$true
            Credential=$SyncHash.ViewModel.AzureCredential
            VPN=$SyncHash.ViewModel.VPN
            Backup=$SyncHash.ViewModel.Backup
            InstanceId=$SyncHash.InstanceId
            Location=$SyncHash.ViewModel.AzureLocation
            Management=$SyncHash.ViewModel.Management
            OS=$SyncHash.ViewModel.OS
            StorageType = $SyncHash.ViewModel.StorageType
            NoUpdateCheck = $true

        }
        if($SyncHash.ViewModel.FallbackAction -ne $null){
            $DeploymentParameters.Add("FallbackLocation",$SyncHash.ViewModel.FallbackAction)
        }
        $SyncHash.ViewModel.CommandName = "New-SMBAzureDeployment"
        $SyncHash.ViewModel.CommandParameters = $DeploymentParameters
        $SyncHash.GUI.Dispatcher.invoke(
            "Render",
            [action]{
                $SyncHash.WPF_Tab_MainControl.SelectedItem = $SyncHash.WPF_Tab_Log
                $SyncHash.WPF_Btn_O365Link.Visibility = [System.Windows.Visibility]::collapsed
                $SyncHash.WPF_Btn_AzureLink.Visibility = [System.Windows.Visibility]::collapsed
                $SyncHash.WPF_Btn_HomeLink.Visibility = [System.Windows.Visibility]::collapsed    
            })
					
        $job = invoke-operation -synchash $SyncHash -root $SyncHash.Root -log $SyncHash.Log -code {
            try {
							
                $SyncHash.DeploymentJob = New-SMBAzureDeployment @Parameters
                while($SyncHash.DeploymentJob.Completed -ne $true){
                    $SyncHash.GUI.Dispatcher.invoke(
                        "Render",
                        [action]{ $SyncHash.WPF_Txt_DeploymentType.Text = $SyncHash.DeploymentJob.Type })
                    $Status = ""
                    foreach($Item in $SyncHash.DeploymentJob.Status.Deployment){
                        $Status += "$($Item.Name): $($Item.Status)`r`n"
                    }
                    $SyncHash.GUI.Dispatcher.invoke(
                        "Render",
                        [action]{ 
                            $SyncHash.WPF_Txt_DeploymentType.Text = $SyncHash.DeploymentJob.Type
                            $SyncHash.WPF_Txt_DeploymentStatus.Text = $Status
                            $SyncHash.WPF_Txt_DeploymentTime.Text = $SyncHash.DeploymentJob.Duration
                        })
								
                    start-sleep -Seconds 10
                }
                if($SyncHash.DeploymentJob.Error){
                    throw $SyncHash.DeploymentJob.Error
                } else {
                    $Status = "The solution is available: $($SyncHash.DeploymentJob.Status.Configuration.Connection)`r`n" + `
								"Login: $($SyncHash.DeploymentJob.Status.Configuration.Domain)\$($SyncHash.DeploymentJob.Status.Configuration.Login)`r`n" + `
								"Password: $($SyncHash.DeploymentJob.Status.Configuration.Password)"

                    $SyncHash.GUI.Dispatcher.invoke(
                        "Render",
                        [action]{ $SyncHash.WPF_Txt_DeploymentStatus.Text = $Status })
                }
							
            } catch {
                invoke-message -message "Error while deploying solution: '$_' ($($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line))"
            }
        } -Parameters $DeploymentParameters
				}
}
			
			
			
)

			

###############################################################################################################################################
# Data grid

			
			
			
# Fill DataGrid - Users details in GUI
$Btn_AddUsers = $SyncHash.WPF_Btn_AddUser
$Btn_AddUsers.Add_Click( {
        try {
            $User = new-object User
            $User.First = $SyncHash.WPF_Txt_FirstName.Text
            $User.Last = $SyncHash.WPF_Txt_LastName.Text
            $User.Title = $SyncHash.WPF_Txt_Function.Text
            $User.Department = $SyncHash.WPF_Txt_Department.Text
            $User.Country = ([country]($SyncHash.WPF_Cmb_Country.SelectedItem)).Code
            $User.Office = $SyncHash.WPF_Txt_Office.Text
            $User.Mobile = $SyncHash.WPF_Txt_Mobile.Text
            $User.DisplayName = [Regex]::Replace($User.First,'[^a-zA-Z0-9]', '') + "." + [Regex]::Replace($User.Last,'[^a-zA-Z0-9]', '')
					
					
            ForEach($Item in $SyncHash.WPF_Lst_Licenses.SelectedItems){
			
                $User.Licenses.Add([License]$Item)
            }
					
            if(($SyncHash.WPF_Cmb_Groups.SelectedItem -eq $null) -and ([string]::IsNullOrEmpty($SyncHash.WPF_Cmb_Groups.Text) -ne $true)){
                if($Group = ($SyncHash.ViewModel.Groups.Where{$_.Name -eq $SyncHash.WPF_Cmb_Groups.Text})){
                    $User.Groups.Add($Group)
                } else {
                    $Group = new-object Group
                    $Group.Name = $SyncHash.WPF_Cmb_Groups.Text
                    $Group.Owner = $User
                    $SyncHash.ViewModel.Groups += $Group
                    $SyncHash.GUI.DataContext = $SyncHash.ViewModel
                    $User.Groups.Add($Group)
                    #invoke-message "new group"
                }
						
            } elseif(($SyncHash.WPF_Cmb_Groups.SelectedItem -ne $null) -and ($SyncHash.WPF_Cmb_Groups.SelectedItem.GetType() -eq [Group])){
                $User.Groups.Add([Group]$SyncHash.WPF_Cmb_Groups.SelectedItem)
                #invoke-message "existing group"
            } else {
                <#do nothinginvoke-message "do nothing"#>
            }
					
					
					
            $User.Mobile = $SyncHash.WPF_Txt_Mobile.Text
					
            if(
                [String]::IsNullOrEmpty($User.First) -or `
							[String]::IsNullOrEmpty($User.Last) -or `
							[String]::IsNullOrEmpty($User.Title) -or `
							[String]::IsNullOrEmpty($User.Department) -or `
							[String]::IsNullOrEmpty($User.Mobile) -or `
							[String]::IsNullOrEmpty($User.Office)

            ){
                invoke-message "Not all user properties were filled in"
                return
            }
            $Exists = $false
            if($SyncHash.ViewModel.Users -contains $User){
                invoke-message "The user already exists"
                $Exists = $true
						
            }
            if($Exists){
                return
            }
            $SyncHash.ViewModel.Users += $User
            $SyncHash.GUI.Dispatcher.Invoke(
                "Render",
                [action]{
                    $SyncHash.WPF_GroupGrid.ItemsSource = $SyncHash.ViewModel.Groups
                    $SyncHash.WPF_UserGrid.ItemsSource = $SyncHash.ViewModel.Users
                    $SyncHash.WPF_Cmb_Groups.ItemsSource = $SyncHash.ViewModel.Groups
                    $SyncHash.GUI.DataContext = $SyncHash.ViewModel
                }) 

					
					
        } catch {
            invoke-message "$_ @ $($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line))"
        }
				
    }
)

$SyncHash.WPF_Btn_DeleteUsers.Add_Click({
        $User = [User]$SyncHash.WPF_UserGrid.SelectedItem
        $UserArray = $SyncHash.ViewModel.Users.Where{$_ -ne $User}
        $GroupArray = $SyncHash.ViewModel.Groups
        $Flag = $false
        $SyncHash.ViewModel.Groups.ForEach{
            $Group = $_
            if($_.Owner -eq $User){
                $SyncHash.ViewModel.Users.ForEach{
                    if(($_.Groups[0] -eq $Group) -and $_ -ne $User){
                        $Group.Owner = $_
                        $GroupArray = $SyncHash.ViewModel.Groups.Where{$_ -ne $Group}
                        $GroupArray += $Group
								
                        $Flag = $true
                    }
                }
                if($Flag -eq $false){
                    $GroupArray = $SyncHash.ViewModel.Groups.Where{$_ -ne $Group}
                }
            }
        }
				
        $SyncHash.ViewModel.Users = $UserArray
        $SyncHash.ViewModel.Groups = $GroupArray
        $SyncHash.GUI.Dispatcher.Invoke(
            "Render",
            [action]{
                $SyncHash.WPF_GroupGrid.ItemsSource = $SyncHash.ViewModel.Groups
                $SyncHash.WPF_UserGrid.ItemsSource = $SyncHash.ViewModel.Users
                $SyncHash.WPF_Cmb_Groups.ItemsSource = $SyncHash.ViewModel.Groups
                $SyncHash.GUI.DataContext = $SyncHash.ViewModel
            }) 
    }   )

$SyncHash.WPF_Btn_ClearUsers.Add_Click({
        $SyncHash.ViewModel.Users = @()
        $SyncHash.ViewModel.Groups= @()
        $SyncHash.GUI.Dispatcher.Invoke(
            "Render",
            [action]{
                $SyncHash.WPF_GroupGrid.ItemsSource = $SyncHash.ViewModel.Groups
                $SyncHash.WPF_UserGrid.ItemsSource = $SyncHash.ViewModel.Users
                $SyncHash.WPF_Cmb_Groups.ItemsSource = $SyncHash.ViewModel.Groups
                $SyncHash.GUI.DataContext = $SyncHash.ViewModel
            }) 
    })
$TabControl = $SyncHash.WPF_Tab_MainControl
$Btn_HomeLink= $SyncHash.WPF_Btn_HomeLink
$Btn_HomeLink.Add_Click( {
        $TabControl.Items[0] | % {$_.IsSelected = $true}
				
    })
$Btn_O365Link= $SyncHash.WPF_Btn_O365Link
$Btn_O365Link.Add_Click( {
        $TabControl.Items[1] | % {$_.IsSelected = $true}
				
    })    
$Btn_AzureLink= $SyncHash.WPF_Btn_AzureLink
$Btn_AzureLink.Add_Click( {
        $TabControl.Items[2] | % {$_.IsSelected = $true}
				
    })
$SyncHash.WPF_Btn_LogLink.Add_Click({
        $TabControl.Items[3] | % {$_.IsSelected = $true}
    })
# Window Placement & Behavior
$SyncHash.GUI.Add_MouseLeftButtonDown( {
        $SyncHash.GUI.DragMove()
    }
)
$SyncHash.WPF_CloseButton.Add_Click( {
        $SyncHash.GUI.Close()
    }
)
$SyncHash.GUI.Add_Closing( {

        [System.Windows.Forms.DialogResult] $DialogResult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to exit?","Confirm Close",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
        if($DialogResult -ne [System.Windows.Forms.DialogResult]::Yes){
            $_.Cancel = $true
        }

    }

)

$SyncHash.WPF_Btn_ShowAzurePassword.Add_Click({
        $SyncHash.GUI.Dispatcher.Invoke(
            "Render",
            [action]{
                if($SyncHash.WPF_Btn_ShowAzurePassword.Content -eq "Show"){
                    $SyncHash.WPF_Txt_AzurePasswordVisible.Text = $SyncHash.WPF_Txt_AzurePassword.Password
                    $SyncHash.WPF_Txt_AzurePasswordVisible.Visibility = [System.Windows.Visibility]::visible
                    $SyncHash.WPF_Txt_AzurePassword.Visibility = [System.Windows.Visibility]::collapsed
                    $SyncHash.WPF_Btn_ShowAzurePassword.Content = "Hide"
                } else {
                    $SyncHash.WPF_Txt_AzurePassword.Password = $SyncHash.WPF_Txt_AzurePasswordVisible.Text
                    $SyncHash.WPF_Txt_AzurePasswordVisible.Text = ""
                    $SyncHash.WPF_Txt_AzurePasswordVisible.Visibility = [System.Windows.Visibility]::collapsed
                    $SyncHash.WPF_Txt_AzurePassword.Visibility = [System.Windows.Visibility]::visible
                    $SyncHash.WPF_Btn_ShowAzurePassword.Content = "Show"
                }
					
            }) 
				
    })

$SyncHash.WPF_Btn_ShowOfficePassword.Add_Click({
        $SyncHash.GUI.Dispatcher.Invoke(
            "Render",
            [action]{
                if($SyncHash.WPF_Btn_ShowOfficePassword.Content -eq "Show"){
                    $SyncHash.WPF_Txt_OfficePasswordVisible.Text = $SyncHash.WPF_Txt_OfficePassword.Password
                    $SyncHash.WPF_Txt_OfficePasswordVisible.Visibility = [System.Windows.Visibility]::visible
                    $SyncHash.WPF_Txt_OfficePassword.Visibility = [System.Windows.Visibility]::collapsed
                    $SyncHash.WPF_Btn_ShowOfficePassword.Content = "Hide"
                } else {
                    $SyncHash.WPF_Txt_OfficePassword.Password = $SyncHash.WPF_Txt_OfficePasswordVisible.Text
                    $SyncHash.WPF_Txt_OfficePasswordVisible.Visibility = [System.Windows.Visibility]::collapsed
                    $SyncHash.WPF_Txt_OfficePassword.Visibility = [System.Windows.Visibility]::visible
                    $SyncHash.WPF_Btn_ShowOfficePassword.Content = "Show"
                }
					
            }) 
				
    })
			

$SyncHash.WPF_btnImportCSV.Add_Click({
        [System.Windows.Forms.OpenFileDialog] $OpenFileDialog = new-object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Filter = "CSV-File (.csv)|*.csv"
        [System.Windows.Forms.DialogResult] $Result = $OpenFileDialog.ShowDialog()
        if($Result -eq [System.Windows.Forms.DialogResult]::OK){
            if((test-path $OpenFileDialog.FileName) -ne $true){
                invoke-message "File does not exist"
                return
            }
            try{
                $Inventory = ConvertTo-O365 -Path $OpenFileDialog.FileName -Licenses $SyncHash.ViewModel.Licenses -separator ','
                $SyncHash.ViewModel.Groups = $Inventory.Groups
                $SyncHash.ViewModel.Users = $Inventory.Users
						
                $SyncHash.GUI.Dispatcher.Invoke(
                    "Render",
                    [action]{
                        $SyncHash.WPF_GroupGrid.ItemsSource = $SyncHash.ViewModel.Groups
                        $SyncHash.WPF_UserGrid.ItemsSource = $SyncHash.ViewModel.Users
                        $SyncHash.WPF_Cmb_Groups.ItemsSource = $SyncHash.ViewModel.Groups
                        $SyncHash.GUI.DataContext = $SyncHash.ViewModel
                    }
                ) 
						
            } catch {
                invoke-message "$_"
                return
            }
        }
    })
# Setup Log Watcher
			
			
$SyncHash.LogWatcher = new-object timers.timer
$SyncHash.LogWatcher.Interval = 1000
			
			

if(Get-Event -SourceIdentifier FileChanged -ErrorAction Ignore){
				Unregister-Event -SourceIdentifier FileChanged -ErrorAction Ignore
}
$MessageData = new-object psobject -Property @{
				Log = $SyncHash.Log
				GUI = $SyncHash.GUI
}
			
$SyncHash.LogGUI = $true
invoke-operation -synchash $SyncHash -root $SyncHash.Root -Log $SyncHash.Log -Code {
				try{
        $Log = $SyncHash.Log
        $GUI = $syncHash.GUI
        $SyncHash.LogVisible = $false
        while($SyncHash.LogGUI -eq $true){
						
            $GUI.Dispatcher.Invoke(
                [action]{$GUI.FindName('Dgr_Log').ItemsSource = $Entries
                    $SyncHash.LogVisible = $GUI.FindName('Dgr_Log').IsVisible

                })
            if($SyncHash.LogVisible){
                $content = get-content $Log
							
                $Entries = @()
                foreach($line in $content){
                    if($line -match '<!\[LOG\[(.+?(?=]LOG))\]LOG\]\!><time="([^\"]+)" date="([^"]+)" component="([^"]+)" context="([^\"]+)" type="(\d)" thread="([0-9]+)">'){
									
                        $Entry = new-object psobject -Property @{
                            Severity=$Matches[6]
                            Message =$Matches[1]
                            TimeStamp=$Matches[2]
                            Component=$Matches[4]

                        }
                        $Entries += $Entry
									
									
                    }
                }

                $GUI.Dispatcher.Invoke(
                    "Render",
                    [action]{$GUI.FindName('Dgr_Log').ItemsSource = $Entries
                        if(($GUI.FindName('Dgr_Log').Items.Count -gt 0) -and ($GUI.FindName('Chk_AutoScroll').IsChecked)){
                            $GUI.FindName('Dgr_Log').ScrollIntoView($GUI.FindName('Dgr_Log').Items.GetItemAt($GUI.FindName('Dgr_Log').Items.Count-1));
                        }
								
                    }
                )
							
							
            }
            start-sleep -Seconds 1
        }

					
					
				} catch {
        write-log -type error -message "Log Watcher Error: $_"
				}
				
}
$SyncHash.WPF_Txb_LogName.Text = $Log
$SyncHash.WPF_Btn_OpenLog.Add_Click({
        Invoke-Expression "explorer.exe '/select,$Log'"
    })
$SyncHash.WPF_Btn_O365Link.Visibility = [System.Windows.Visibility]::collapsed
$SyncHash.WPF_Btn_AzureLink.Visibility = [System.Windows.Visibility]::collapsed
$SyncHash.WPF_Spl_ServiceUnavailable.Visibility = [System.Windows.Visibility]::collapsed
$SyncHash.GUI.DataContext = $SyncHash.ViewModel
$SyncHash.WPF_Cmb_Country.Items.Clear()
$SyncHash.WPF_Cmb_Country.ItemsSource = Get-Country
$SyncHash.WPF_Txt_OfficePassword.Password = $SyncHash.ViewModel.Password
$SyncHash.WPF_Txt_AzurePassword.Password = $SyncHash.ViewModel.Password
			
$SyncHash.GUI.ShowDialog()
			

} catch {
    invoke-message "$_ @ $($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line))"

}
finally {
    if($SyncHash.GUI.IsVisible){
        $SyncHash.GUI.Close()
    }
    $SyncHash.LogWatcher.Stop()
    $SyncHash.LogGUI = $false;
			
			
			
}

}
	



}


