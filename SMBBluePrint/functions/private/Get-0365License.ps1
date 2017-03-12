function Get-O365License {
	[cmdletbinding()]
	[OutputType([HashTable])]
	param(
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string]$TenantId
	)
	$Licenses = @{};
	$Usage = (Get-AzureADUser -All $true).AssignedLicenses|group -Property SkuId
	(Get-AzureADSubscribedSku).foreach{
		$License = New-Object License
		$License.Id = $_.SkuId
		$License.Name = $_.SkuPartNumber
		$License.Available = ($_.PrePaidUnits.enabled - $($Usage.where{$_.Name -eq $License.Name}).Count)
		$Licenses.Add($License.Name,$License)
	}
	$Licenses
}