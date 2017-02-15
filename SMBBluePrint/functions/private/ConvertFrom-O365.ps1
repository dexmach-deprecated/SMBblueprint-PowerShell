function ConvertFrom-O365 {
	[cmdletbinding()]
	[outputtype([psobject[]])]
	param(
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[Array] $Users,
	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[string] $Path
	)
	begin{
		$CSVArray = @()
	}
	process {
		try{
			
			foreach($User in $Users){
				# First,Last,Title,DisplayName,Department,Office,Mobile,Country,Groups,License
			
				
				$CSVItem = new-object psobject -Property @{
					First = $User.First
					Last = $User.Last
					DisplayName = $User.DisplayName
					Department = $User.Department
					Office = $User.Office
					Mobile = $User.Mobile
					Country = $User.Country
					Groups = if($User.Groups[0].Owner.DisplayName -eq $User.DisplayName){"*$($User.Groups[0].Name)"} else {$User.Groups[0].Name}
					Licenses = $($User.Licenses.Name -join "|")
					Title = $User.Title
					
				}
				$CSVArray += $CSVItem
			}
		}
		catch {
			write-log -type error -message "Error while converting O365 information to CSV: '$_' @ $($_.InvocationInfo.ScriptLineNumber) - $($_.InvocationInfo.Line)"

		}
	}
	
	
	
	end{
		remove-item $Path -Force -ErrorAction Ignore
		$CSVArray|Export-Csv -Path $Path -Force -NoClobber -Encoding Default -Delimiter ',' -NoTypeInformation

	}

}