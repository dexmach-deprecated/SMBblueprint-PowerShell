function Get-O365OneDrive {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Credential = (Get-Credential -Message "Enter your Tenant Account credentials"),
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $SPOAdminUrl
    )
    try{

        # Begin the process

        $loadInfo1 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
        $loadInfo2 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
        $loadInfo3 = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.UserProfiles")

        $creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials $Credential.UserName, $Credential.Password


        # Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
        $proxyaddr = "$SPOAdminUrl/_vti_bin/UserProfileService.asmx?wsdl"
        $UserProfileService= New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential $False
        $UserProfileService.Credentials = $creds

        # Set variables for authentication cookies
        $strAuthCookie = $creds.GetAuthenticationCookie($SPOAdminUrl)
        $uri = New-Object System.Uri($SPOAdminUrl)
        $container = New-Object System.Net.CookieContainer
        $container.SetCookies($uri, $strAuthCookie)
        $UserProfileService.CookieContainer = $container

        $OneDrives = @()
        # Sets the first User profile, at index -1
        $UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)
        $UserProfileResult|fl *
        Write-Host "Starting- This could take a while."

        $NumProfiles = $UserProfileService.GetUserProfileCount()
        $i = 1

        # As long as the next User profile is NOT the one we started with (at -1)...
        While ($UserProfileResult.NextValue -ne -1) 
        {
        Write-Host "Examining profile $i of $NumProfiles"

        # Look for the Personal Space object in the User Profile and retrieve it
        # (PersonalSpace is the name of the path to a user's OneDrive for Business site. Users who have not yet created a 
        # OneDrive for Business site might not have this property set.)
        $Prop = $UserProfileResult.UserProfile | Where-Object { $_.Name -eq "PersonalSpace" }
        $Prop|fl *
        if($Prop -or ($Prop.Count -gt 0)){ 
            $Url= $Prop.Values[0].Value
        }

        # If "PersonalSpace" (which we've copied to $Url) exists, log it to our file...
        if ($Url) {
            $OneDrives += $Url
            write-host $Url
        }

        # And now we check the next profile the same way...
        $UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
        $i++
        }

        Write-Host "Done!"
        return $OneDrives
        } catch {
            throw "Error while validating OneDrive deployment: $_"
        }
}