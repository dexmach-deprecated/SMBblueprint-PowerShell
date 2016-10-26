function Connect-O365 {
	[cmdletbinding()]
	param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[pscredential] $Credential
	)
	try{
		$i= 0
		$session365 = $null
		while($session365 -eq $null -and ((get-command get-unifiedgroup -ErrorAction Ignore) -eq $null)){
			$i++
			write-log -message "Attempting Exchange Online Connection ($i)"
			$session365 = New-PSSession `
			-ConfigurationName Microsoft.Exchange `
			-ConnectionUri "https://ps.outlook.com/powershell/" `
			-Credential $Credential `
			-Authentication Basic `
			-AllowRedirection `
			-WarningAction Ignore
			if($? -eq $false){
				throw $Error[0]
			}
			start-sleep -Seconds 10
			if(!$session365){
				write-log -message "Null-Session received, retrying... ($i)"
			} else {
				$return = Invoke-Command -Session $session365 -ScriptBlock {get-command -Name get-unifiedgroup -ErrorAction Ignore}
				if($? -eq $false){
					throw $Error[0]
				}
				if(($return) -eq $null){
					write-log -message "Session Received, but no commands present ($i)"
					invoke-command -Session $session365 -ScriptBlock {Exit-PSSession}
					Remove-PSSession $session365
					$session365 = $null
				} else {
					#  Import-Module (Import-PSSession $session365 -AllowClobber) -Global
				}
			}
		}
		$null = Import-Module (Import-PSSession $session365 -AllowClobber) -Global
		$session365
	}
	catch {
		if($session365){
			remove-pssession $session365
		}
		throw "Error during Exchange Online Connection: $_"
	}
}