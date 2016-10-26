---
external help file: SMBBlueprint-help.xml
online version: 
schema: 2.0.0
---

# New-SMBOfficeDeployment

## SYNOPSIS
This command serves as a public interface for the O365 part of the SMB solution.
It uses a set of given deployment parameters to start and monitor the user/group-deployment in O365.

## SYNTAX

### TenantId (Default)
```
New-SMBOfficeDeployment -CSV <String> -TenantId <String> [-MailDomain <String>] [-DefaultPassword <String>]
 -Credential <PSCredential> [-SyncHash <Object>] [-Log <String>] [<CommonParameters>]
```

### TenantDomain
```
New-SMBOfficeDeployment -CSV <String> -TenantDomain <String> [-MailDomain <String>] [-DefaultPassword <String>]
 -Credential <PSCredential> [-SyncHash <Object>] [-Log <String>] [<CommonParameters>]
```

## DESCRIPTION
This command will use a given CSV file and Tenant Information to orchestrate the provisioning of O365 users and groups. The following steps are executed:
1. Create a local admin account in the O365 subscription of the tenant to bypass some CSP restrictions regarding Groups/Onedrive provisioning
1. Parse the CSV information and alert on licensing issues
2. Create the specified users in the tenant's Azure AD, and assign the appropriate licenses
3. Create the specified Office Groups in Exchange Online (part of O365), using the local admin account
4. Populate user/group owner/membership, using the local admin account
5. Pre-provision all user's Onedrives, using the local admin account in combination with Sharepoint Online
6. Output all provisioning info

## EXAMPLES

### Example 1
```
PS C:\> New-SMBOfficeDeployment -DefaultPassword MySecretPassword -Credential $MyCredential -MailDomain contoso.com -CSV C:\SMBUsers.csv -TenantId 95e2e584-5e01-4065-bcee-8203d1005a90
```

This example will use the information specified in the given CSV to provision a set of users and groups in the specified CSP tenant. The suffix '@Contoso.Com' will be used for the UPN of the users.

## PARAMETERS

### -Credential
The CSP Partner credential to use for the deployment

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

### -CSV
The location of the CSV file that contains the O365 inventory.
The following information must be present in this file:
* First (the first-name of the user)
* Last (the last-name of the user)
* Title (the user's title or function)
* DisplayName (currently not in use)
* Department (the user's department)
* Office (the user's office location)
* Mobile (the user's mobile phone number)
* Country (the user's country, expressed as an [ISO-code](https://www.iso.org/obp/ui/#search))
* Groups (the group to which the user should belong)
    * If the group is mentioned for the first time, the associated user will be set as owner. Subsequent users that have the same group specified will be a regular member.
    * The created groups will be private Office Groups
* License (the license to assign to the user, expressed as the SKU code, which can be found using get-msolaccountsku -TenantId \<ID of your CSP tenant\>)
    * You can get the tenant-id's under your CSP account by connecting to your root Azure AD with 'Connect-MSOLService' and then querying the tenants with 'Get-MSOLPartnerContract -All|select DefaultDomainName,TenantId'

>**Example CSV:**  
First,Last,Title,DisplayName,Department,Office,Mobile,Country,Groups,License  
Jan,Van Meirvenne,Consultant,Jan.VanMeirvenne,ICT,Inovativ,32478707741,BE,TestGroup1,O365_BUSINESS_PREMIUM  
Jin,Van Meirvenne,Consultant,Jin.VanMeirvenne,ICT,Inovativ,32478707741,BE,TestGroup10,O365_BUSINESS_PREMIUM  
Jon,Van Meirvenne,Consultant,Jon.VanMeirvenne,ICT,Inovativ,32478707741,BE,TestGroup10,O365_BUSINESS_PREMIUM  



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

### -DefaultPassword
The initial password to use for the users to provision. The password must adhere to the [Azure AD password policy](https://azure.microsoft.com/en-us/documentation/articles/active-directory-passwords-policy/).
If this parameter is omitted, a random password is generated. The password can be consulted from the function's job output.

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

### -MailDomain
The mail-suffix to use for the provisioned users. This domain must be a validated domain in the tenant.
If this parameter is omitted, the default tenant domain is used.

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

### -SyncHash
Internal parameter that provides integration with the GUI. Has no functional value and hence should not be used.

```yaml
Type: Object
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
Parameter Sets: TenantDomain
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
Parameter Sets: TenantId
Aliases: 

Required: True
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

### System.Management.Automation.PSObject
This function returns a job-variable with the folowing contents:
* Type (the deployment-type. This will be 'Office' for deployments started with this function)
* Duration (the duration of the deployment)
* Status (Provides status-information for the deployment)
    * Configuration (contains several outputs of the deployment)
        * ProvisionedUsers (a list of all provisioned users including login-information)
        * ProvisionedGroups (a list of all provisioned office groups)
* Completed (equals 'TRUE' if the deployment is done)
* Error (if an exception occured during the deployment, it will be stored here)
* Log (the full location of the logfile for the deployment)

## NOTES

## RELATED LINKS

[https://inovativ.github.io/SMBblueprint-Docs/](https://inovativ.github.io/SMBblueprint-Docs/)

