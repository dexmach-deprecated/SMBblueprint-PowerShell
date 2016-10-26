function New-O365Group
{
param (

[Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,
        [Parameter(Mandatory=$false)]
        [ValidateSet('office','security')]
        [string] $Type = 'security',
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Owner
		
)
process{
    Try
    {
        if($Type -eq 'security'){
        
            $groupexists = Get-MsolGroup -SearchString $GroupName
            if ($groupexists)
                {
                write-log -Message "Security Group $groupname already exists" -Type Information
                }
            Else
                {
                $newgroup = New-MsolGroup -DisplayName $groupname -Description $groupname
                write-log -Message "Security Group $GroupName created"
                $newgroup
                }
        } elseif($Type -eq 'office'){
            if($Group = get-unifiedgroup -identity $GroupName -ErrorAction Ignore){
                write-log -Message "Office Group $groupname already exists" -Type Information
                $Group
            } else {
                $OK = $false
                while((get-user -identity $Owner -ErrorAction SilentlyContinue) -eq $null){
                    write-log "Owner for group '$GroupName' is not yet provisioned. Retrying in 60 seconds..."
                    Start-Sleep -Seconds 60
                }
                $Group = new-unifiedGroup -displayname $GroupName -name $GroupName -owner $Owner -AccessType Private
                $Group          
                write-log -Message "Office Group $GroupName created with owner '$Owner'"
            }

        }

    }


    Catch 
    {
            throw "Can not create group $($GroupName): $_"


    }

}


    
		
}
