function New-O365User
{
    param (
    [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]

        [string]$Username,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
     
        [string]$firstname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
 
        [string]$lastname,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
 
        [string]$Title,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
    
        [string]$password,

        [Parameter(
                   ValueFromPipelineByPropertyName=$true)]
       # [ValidateNotNullOrEmpty()]
     
        [string[]]$license,

 [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]

        [string]$mobilephone,

         [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
    
        [string]$country     

        )
            

    Try
        {
        #$userexists = Get-MsolUser -SearchString $UserName
        $userexists = Get-AzureADUser -SearchString $UserName
            if ($userexists)
                {
                write-log -Message "User $username already exists"  -Type information
                $userexists
                }
            Else
                {
                $newuser = $null
                $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
                $PasswordProfile.EnforceChangePasswordPolicy = $true
                $PasswordProfile.ForceChangePasswordNextLogin = $true
                $PasswordProfile.Password = $PassWord
                while($newuser -eq $null){
                    write-log -message "Creating user '$($userName)'"
                   # $newuser = New-Msoluser -DisplayName $username -UserPrincipalName $username -FirstName $firstname -lastname $lastname -Title $title -Password $password -MobilePhone $mobilephone -Country $country -UsageLocation $country
                    $newuser = New-AzureADUser -AccountEnabled $true -GivenName $firstname -Surname $lastname -Country $country -Mobile $mobilephone -UserPrincipalName $Username -PasswordProfile $PasswordProfile -DisplayName $Username -UsageLocation $country -MailNickName $($username.split('@')[0])
                    if($? -eq $false){
                        throw $Error[0]
                    }
                    if($license){
                        foreach($Item in $license){
                            try {
                                write-log -message "Assigning license '$Item' to user '$($newuser.ObjectId)'"
                                #$null = Set-MsolUserLicense -UserPrincipalName $Username -AddLicenses $Item
                                $LicenseObject = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense 
                                $LicenseObject.SkuId = $Item
                                $LicensesObject = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses 
                                $null = $LicensesObject.AddLicenses = $LicenseObject

                                $null = Set-AzureADUserLicense -ObjectId $newuser.ObjectId -AssignedLicenses $LicensesObject
                                if($? -eq $false){
                                    throw $Error[0]
                                }
                            } catch {
                                write-log -type warning -message "Could not apply license '$Item' to user '$username': $_"
                            } 
                        }
                    }
                    }
                    
                }
                write-log -Message "User $UserName created"
                $newuser
                
            


        } 

    Catch
        {
        throw "Cannot create User $($username): $_"

     }

}