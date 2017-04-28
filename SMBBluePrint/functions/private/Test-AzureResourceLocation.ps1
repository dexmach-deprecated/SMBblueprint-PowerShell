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
            $InvalidResources = new-object System.Collections.ArrayList
            $CompatibleResources = (Get-AzureRMLocation)
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
            $Resources = $Resources|Select-Object -Unique
        }
        catch{
            throw "$($ErrorString): $_"
        }
    }
    
    process {
        try{
            foreach($Resource in $Resources){
                if($($CompatibleResources|Where-Object{$_.Location -eq $Location}).Providers -contains $Resource){
                    write-verbose "$Resource OK"
                } else {
                    $hash = @{
                        Resource = $Resource
                        AvailableLocations = $($CompatibleResources|Where-Object{$_.Providers -contains $Resource})|Select-Object -ExpandProperty Location
                    }
                    $null = $InvalidResources.Add($hash)
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