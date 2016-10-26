function Get-O365License {
	[cmdletbinding()]
	[OutputType([HashTable])]
	param(
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string]$TenantId
	)
	$Licenses = @{};
	
	(Get-MsolAccountSku -TenantId $TenantId).foreach{
		$License = New-Object License
		$License.Id = $_.AccountSkuId
		$License.Name = $_.SkuPartNumber
		$License.Available = ($_.ActiveUnits - $_.ConsumedUnits)
		$Licenses.Add($License.Name,$License)
	}
	$Licenses
}