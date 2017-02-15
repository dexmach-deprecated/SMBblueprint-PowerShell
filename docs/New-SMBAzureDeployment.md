---
external help file: SMBBlueprint-help.xml
online version: 
schema: 2.0.0
---

# New-SMBAzureDeployment

## SYNOPSIS
This command serves as a public interface for the Azure part of the SMB solution.
It uses a set of given deployment parameters to start and monitor the ARM-based deployment in Azure.

## SYNTAX

### AzureTenantDomain (Default)
```
New-SMBAzureDeployment -Location <String> [-FallbackLocation <String>] [-AsJob] -CustomerName <String>
 -CustomerSize <String> [-AdditionalVMSize <String>] [-AdditionalSQLInstanceSize <String>] [-Backup <String>]
 [-VPN <String>] [-Management <String>] [-OS <String>] [-SysAdminPassword <String>] -Credential <PSCredential>
 -TenantDomain <String> [-SubscriptionId <String>] [-SubscriptionName <String>] [-ResourceGroupPrefix <String>]
 [-NoUpdateCheck] [-StorageType <String>] [-Log <String>] [<CommonParameters>]
```

### AzureTenantId
```
New-SMBAzureDeployment -Location <String> [-FallbackLocation <String>] [-AsJob] -CustomerName <String>
 -CustomerSize <String> [-AdditionalVMSize <String>] [-AdditionalSQLInstanceSize <String>] [-Backup <String>]
 [-VPN <String>] [-Management <String>] [-OS <String>] [-SysAdminPassword <String>] -Credential <PSCredential>
 -TenantId <String> [-SubscriptionId <String>] [-SubscriptionName <String>] [-ResourceGroupPrefix <String>]
 [-NoUpdateCheck] [-StorageType <String>] [-Log <String>] [<CommonParameters>]
```

## DESCRIPTION
This command can be used to deploy the Small & Medium Business ARM template towards a managed CSP customer.
Based on given parameters, the following steps are executed:

1. Connect to the target tenant's subscription
2. Verify that the naming convention is available foruse with the public DNS label and Azure resource group
3. The resource group is created based on a prefix and the customer-name
4. Initiates a new ARM-based deployment with a generated parameter-set to provision the chosen resources
5. While the deployment is occuring, the status is polled every 10 seconds and updated in the job-variable/progress
6. When the deployment is done, all connection and other deployment information is returned

## EXAMPLES

### Example 1
```
PS C:\> New-SMBAzureDeployment -AdditionalSQLInstanceSize small -AdditionalVMSize medium -TenantDomain Contoso.com -CustomerName Contoso -CustomerSize small -SysAdminPassword MySecretP@ssword1234 -Backup standard -Credential $MyCredential -SubscriptionId 3812cde5-cb5e-42de-a673-20228eed897f -VPN basic
```

This example will deploy a small SMB scenario to the Contoso.com CSP tenant with the following resources:
* 1 Essentials VM (small size)
* 1 Additional VM (medium size)
* 1 Additional Azure SQL instance (small size)
* 1 basic VPN gateway
* Backup of the essential and additional machines

## PARAMETERS

### -AdditionalSQLInstanceSize
Specifies the size of the Azure SQL instance to deploy. 'None' can be used to disable the deployment of this resource.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: none, small

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdditionalVMSize
Specifies the size of the additional Azure VM to deploy. 'None' can be used to disable the deployment of this resource.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: none, small, medium

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsJob
If you want to run the deployment as a background job, this switch can be specified. A job-variable will be returned which can be monitored for deployment progress.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Backup
Specifies the size of the backup vault to deploy. 'None' can be used to disable the deployment of this resource.
If the selected Azure location does not support the backup resource, it will not be deployed regardless of this setting.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: none, standard

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The CSP Administrator credentials to use. If this parameter is omitted, you wil be prompted to enter credentials.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomerName
The name of the customer. This parameter is used to generate the resource group and public DNS names.
Non-alphanumeric characters are stripped automatically. If the resulting resource-group or DNS label already exists, an error is generated and the deployment is aborted.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomerSize
The sizing of the customer. This determines the amount of subnets and the size of the essentials VM.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: small, medium, large

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Log
This parameter is for internal use. To prevent a new logfile from being created when running in GUI-mode, the existing log-file to use is passed.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupPrefix
The naming prefix to use for the Azure resource group to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
The GUID of the tenant subscription to use. If this parameter is omitted, the default subscription will be used.
Do not use in conjunction with the SubscriptionName parameter!

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionName
The name of the tenant subscription to use. If this parameter is omitted, the default subscription will be used.
Do not use in conjunction with the SubscriptionId parameter!

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SysAdminPassword
The password to use for the sysadmin account. The password must adhere to the Azure IaaS password requirements.
If this parameter is omitted, a random password is used. The password can be consulted in the GUI and return value of this function itself.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantDomain
The name of the Tenant Domain as it is displayed in the CSP portal (not to be confused with the tenant's own default domain).
This is used to select the target tenant for the deployment. Do not use in conjunction with the TenantId parameter!

```yaml
Type: String
Parameter Sets: AzureTenantDomain
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
The id of the Tenant.
This is used to select the target tenant for the deployment. Do not use in conjunction with the TenantDomain parameter!

```yaml
Type: String
Parameter Sets: AzureTenantId
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VPN
Specifies whether to deploy a basic VPN gateway or not. 'None' can be used to disable the deployment of this resource.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: none, basic

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FallbackLocation
The location to use for the monitoring- and automation services in case the primary region does not support them.
The supported fallback locations are:
* westeurope
* southeastasia
* australiasoutheast

When this parameter is omitted and the primary region is not supported, you will be prompted to choose one of the locations, or cancel the deployment.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: westeurope, southeastasia, australiasoutheast

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Location
The Azure location where the solution should be deployed. Some locations impose limits in regards to the backup, automation and monitoring capabilities. Check the 'Backup' and 'FallbackLocation' parameters for more information.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Management
Controls whether the monitoring and automation resources are deployed. In the current version, this option is not usable and the resources are always deployed.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: free
Accept pipeline input: False
Accept wildcard characters: False
```

### -OS
Determines the used operating system for the VM deployments. Currently '2012R2' and '2016' are the only supported parameters.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: '2012R2', '2016'

Required: False
Position: Named
Default value: '2012R2'
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoUpdateCheck
Skips the module version check when launching the command

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StorageType
Specifies the storage type to use for the virtual machines that are deployed

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted Values: Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
This function returns a job-variable with the folowing contents:
* Type (the deployment-type. This will be 'Azure' for deployments started with this function)
* Duration (the duration of the deployment)
* Status (Provides status-information for the deployment)
    * Configuration (contains several outputs of the deployment)
        * Domain (the domain of the solution)
        * Login (the username of the default admin account)
        *  Password (the password for the default admin account)
        * ResourceGroup (the name of the Azure resource group used for the deployment)
        * Connection (the url to the RDWeb endpoint for remote access)
* Completed (equals 'TRUE' if the deployment is done)
* Error (if an exception occured during the deployment, it will be stored here)
* Log (the full location of the logfile for the deployment)

## NOTES

## RELATED LINKS

[https://inovativ.github.io/SMBblueprint-Docs/](https://inovativ.github.io/SMBblueprint-Docs/)


