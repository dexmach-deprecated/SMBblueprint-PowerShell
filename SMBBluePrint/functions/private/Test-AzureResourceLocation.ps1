function Test-AzureResourceLocation {
    [OutputType([System.Collections.ArrayList])]
    [CmdletBinding(DefaultParameterSetName="Type")]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Location,
        [Parameter(Mandatory=$true,ParameterSetName="Type")]
        [ValidateNotNullOrEmpty()]
        [string[]] $ResourceType,
        [Parameter(Mandatory=$true,ParameterSetName="File")]
        [ValidateNotNullOrEmpty()]
        [string] $ResourceFile

    )
    
    begin {
        $ErrorString = "Error while checking Azure location compatibility: "
        try{
            $Resources = @()
            $InvalidResources = new-object System.Collections.ArrayList<String>
            $CompatibleResources = (Get-AzureRMLocation)|where{$_.Location -eq $Location}
            write-verbose "Found Location: $CompatibleResources"
            if(!$Location){
                throw "Invalid Azure location provided"
            }
            switch($PSCmdlet.ParameterSetName){
                "Type" {
                    foreach($String in $ResourceType){
                        $Resources += $String.Split('/')[0]
                    }
                }

                "File" {
                    foreach($String in (get-content $ResourceFile)){
                        $Resources += $String.Split('/')[0]
                    }
                }
            }
            $Resources = $Resources|select -Unique
        }
        catch{
            throw "$($ErrorString): $_"
        }
    }
    
    process {
        try{
            foreach($Resource in $Resources){
                if($CompatibleResources.Providers -contains $Resource){
                    write-verbose "$Resource OK"
                } else {
                    $InvalidResources.Add($Resource)
                    write-verbose "$Resource NOK"
                }
            }
        }
        catch {
            throw "$($ErrorString): $_"
        }

    }
    
    end {
        return $InvalidResources
    }
    
    
}