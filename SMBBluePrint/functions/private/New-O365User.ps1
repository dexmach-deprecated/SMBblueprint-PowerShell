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

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
     
        [string]$license,

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
        $userexists = Get-MsolUser -SearchString $UserName

            if ($userexists)
                {
                write-log -Message "User $username already exists"  -Type information
                $userexists
                }
            Else
                {
                $newuser = $null
                while($newuser -eq $null){

                    $newuser = New-Msoluser -DisplayName $username -UserPrincipalName $username -FirstName $firstname -lastname $lastname -Title $title -Password $password -MobilePhone $mobilephone -Country $country -LicenseAssignment $license -UsageLocation $country
                    if($? -eq $false){
                        throw $Error[0]
                    }
                }
                write-log -Message "User $UserName created"
                $newuser
                
            }


        } 

    Catch
        {
        throw "Cannot create User $($username): $_"

     }

}