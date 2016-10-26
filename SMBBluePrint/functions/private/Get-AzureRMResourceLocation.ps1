function Get-AzureRMResourceLocation {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Location,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Resource
    )

    begin{
        $RegionMap = @{
            RegionToLocation = @{
                uk=@('uksouth','ukwest')
                us=@('centralus')
            }
        }
    }


}