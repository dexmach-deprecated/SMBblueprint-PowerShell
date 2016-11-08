# work in progress
function New-AzureAutomationServicePrincipal {
    
    $pass = "Abcd.1234567890"

    $cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" -Subject "CN=SMBBluePrint" -KeySpec KeyExchange
    $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
    $app = New-AzureRmADApplication -DisplayName "exampleapp" -HomePage "https://www.microsoft.be" -IdentifierUris "https://www.contoso.be" -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore

    $null = New-AzureRmRoleAssignment -RoleDefinitionName Reader -ServicePrincipalName $app.ApplicationId.Guid

    $cred = new-object -TypeName pscredential $app.ApplicationId.Guid.ToString(),($pass|ConvertTo-SecureString -AsPlainText -force)

    $tenant = (Get-AzureRmSubscription).TenantId

    $null = Add-AzureRmAccount -ServicePrincipal -Credential $cred
}