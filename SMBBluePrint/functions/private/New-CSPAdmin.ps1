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
        $AdminRole = Get-MsolRole -RoleName 'Company Administrator'
        if(($User = get-msoluser -SearchString $AccountName)){
            if((Get-MsolRoleMember -RoleObjectId $AdminRole.ObjectId -MemberObjectTypes User).where{$_.EmailAddress -eq "$AccountName@$DomainName"}){
                write-log "The CSPAdmin account '$AccountName' already exists in the correct scope. Resetting password..."
                $PassWord = new-swrandompassword
                $null = Set-MsolUserPassword -ObjectId $User.ObjectId -NewPassword $PassWord -ForceChangePassword $false
                $cred = new-object pscredential $User.UserPrincipalName,($Password|ConvertTo-SecureString -AsPlainText -force)
                $cred
            } else {
                throw "the account '$AccountName' already exists in the wrong security scope"
            }
        } else {
            $PassWord = new-swrandompassword
            $User= New-MsolUser -DisplayName $AccountName -UserPrincipalName "$AccountName@$DomainName" -PasswordNeverExpires $true -Password $PassWord
            $null = Set-MsolUserPassword -ObjectId $User.ObjectId -NewPassword $PassWord -ForceChangePassword $false
            $null = Add-MsolRoleMember -RoleObjectId $AdminRole.ObjectId -RoleMemberType User -RoleMemberObjectId $User.ObjectId
            $cred = new-object pscredential $User.UserPrincipalName,($Password|ConvertTo-SecureString -AsPlainText -force)
            $cred
            write-log "Created CSP Admin Account '$AccountName'"
        }
    } catch {
        throw "Error during CSP Admin creation/retrieval: $_"
    }

}