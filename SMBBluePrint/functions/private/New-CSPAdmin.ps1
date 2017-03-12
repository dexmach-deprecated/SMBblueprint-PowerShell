function New-CSPAdmin {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $AccountName = "CSPAdmin",
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName

    )
    try{
        $UserName = "$AccountName@$DomainName"
        #$AdminRole = Get-MsolRole -RoleName 'Company Administrator'
        $AdminRole = (Get-AzureADDirectoryRole).where{$_.DisplayName -eq 'Company Administrator'}
        if(($User = get-azureaduser -SearchString $UserName)){
            if((Get-AzureADDirectoryRoleMember -ObjectId $AdminRole.ObjectId).where{$_.DisplayName -eq "$UserName"}){
                write-log "The CSPAdmin account '$AccountName' already exists in the correct scope. Resetting password..."
                $PassWord = new-swrandompassword
                $null = Set-AzureADUserPassword -ObjectId $User.ObjectId -Password $($PassWord|ConvertTo-SecureString -AsPlainText -Force) -ForceChangePasswordNextLogin $false -EnforceChangePasswordPolicy $false
                #$null = Set-MsolUserPassword -ObjectId $User.ObjectId -NewPassword $PassWord -ForceChangePassword $false
                $cred = new-object pscredential $User.UserPrincipalName,($Password|ConvertTo-SecureString -AsPlainText -force)
                $cred
            } else {
                throw "the account '$AccountName' already exists in the wrong security scope"
            }
        } else {
            $PassWord = new-swrandompassword
            
            #$User= New-AzureADUser -DisplayName $AccountName -UserPrincipalName "$AccountName@$DomainName" -PasswordNeverExpires $true -Password $PassWord
            $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
            $PasswordProfile.EnforceChangePasswordPolicy = $false
            $PasswordProfile.ForceChangePasswordNextLogin = $false
            $PasswordProfile.Password = $PassWord
            $User = New-AzureADUser -AccountEnabled $true -MailNickName $AccountName -UserPrincipalName $username -PasswordProfile $PasswordProfile -DisplayName $username
            if($? -eq $false){
                throw $Error[0]
            }
            $null = Set-AzureADUserPassword -ObjectId $User.ObjectId -Password $($PassWord|ConvertTo-SecureString -AsPlainText -Force) -ForceChangePasswordNextLogin $false -EnforceChangePasswordPolicy $false
            #$null = Set-MsolUserPassword -ObjectId $User.ObjectId -NewPassword $PassWord -ForceChangePassword $false
            #$null = Add-MsolRoleMember -RoleObjectId $AdminRole.ObjectId -RoleMemberType User -RoleMemberObjectId $User.ObjectId
            $null = Add-AzureADDirectoryRoleMember -ObjectId $AdminRole.ObjectId -RefObjectId $User.ObjectId
            $cred = new-object pscredential $User.UserPrincipalName,($Password|ConvertTo-SecureString -AsPlainText -force)
            $cred
            write-log "Created CSP Admin Account '$AccountName'"
        }
    } catch {
        throw "Error during CSP Admin creation/retrieval: $_"
    }

}