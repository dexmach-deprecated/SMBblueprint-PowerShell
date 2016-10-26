function ConvertTo-O365{
	[cmdletbinding()]
	param(
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $Path,
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string] $Separator = "`t",
	[Parameter(Mandatory=$true)]
	[hashtable] $Licenses
	)
	try{
		$Inventory = new-object -TypeName psobject -Property @{
			Users = @()
			Groups = @()
		}
		$Content = Import-CSV -Path $Path -Delimiter $Separator
		$CSVProperties = get-member -InputObject $Content -MemberType NoteProperty
		$UserProperties = @()
		[user]::new()|get-member -MemberType Property|%{$UserProperties += $_.Name}
		foreach($Property in $CSVProperties){
			if($UserProperties -notcontains $Property.Name){
				write-log -Type Error -Message "CSV was not in the correct format: '$($Property.Name)' is not recognized."
				return $null
			}
		}
		foreach($Item in $Content){
			$User = new-object User
			foreach($Property in $UserProperties){
				switch($Property){
					"DisplayName" {$User.DisplayName = [Regex]::Replace($Item.First,'[^a-zA-Z0-9]', '') + "." + [Regex]::Replace($Item.Last,'[^a-zA-Z0-9]', '')}
					"Password"{break;}
					"Login"{break;}
					"License" {
						if(($License = $Licenses[$Item.License]) -ne $null){
							
							if($License.Available -le 0){
								throw "There are not enough licenses available to provision the users ($($License.Name))"
							}
							$User.License = $License
							$License.Available--
						} else {
							Write-Log -Type Warning -Message "License $($Item.License) for user $($Item.DisplayName) not found in the subscription"
						}
						break;
					}
					"Groups" {
						$Group = new-object Group
						<#   if($Item.Groups.StartsWith('*')){
							$Group.Owner = ([ref]$User).value
							$Group.Name = $Item.Groups.substring(1,$Item.Groups.length - 1)
							$found = $false
							$Inventory.Groups.ForEach{
								if($_.Name -eq $Group.Name){
									$_.Owner = ([ref]$Group.Owner).value
									$found = $true
								}
							}
						} else { #>
							$Group.Name = $Item.Groups
							# }

						if((($Inventory.Groups).ForEach{$_.Name}) -notcontains $Group.Name){
							$Group.Owner = ([ref]$User).Value
							$Inventory.Groups += $Group
						} else {
							$Group = ($Inventory.Groups.Where{$_.Name -eq $Group.Name})[0]
						}
						$User.Groups.Add($Group);
						break;
						
					}
					
					default {$User.$_ = $Item.$_;break;}
				}
				
			}
			$Inventory.Users += $User
		}
		$global:a = $Inventory
		return $Inventory
		
	} catch {
		throw "Error while parsing CSV to O365 Inventory: '$_' @ $($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line)"
	}

}