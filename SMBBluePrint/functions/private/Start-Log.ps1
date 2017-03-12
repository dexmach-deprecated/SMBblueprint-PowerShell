function Start-Log{
	[OutputType([string])]
	[CmdletBinding()]
	param(
	[Parameter()]
	[ValidateNotNullOrEmpty()]
	[string] $LogName = "SMBBlueprint_$(([guid]::newguid().guid)).log",
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string] $InstanceId
	)
	# recreates the log file and sets the script parameter for use in the write-log function
	$LogName = "SMbBluePrint_$($InstanceId).log"
	$_Log = "$env:APPDATA\SMBBlueprint\logs\$($LogName)"
# if(Test-Path -Path $script:Log){
#     $null=remove-item -path $script:Log -force
		#}
	$LogDirectory = Split-Path $_Log
	if((Test-Path -Path $LogDirectory) -eq $false){
		$null = new-item -Path $LogDirectory -ItemType Directory -Force
	}
	$null= new-item -type file -path $_Log
	return $_Log
}