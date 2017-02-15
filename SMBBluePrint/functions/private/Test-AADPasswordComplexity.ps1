Function Test-AADPasswordComplexity {
    [outputtype([string])]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$MinimumLength = 8
    )

    begin{
        $PasswordRegex = "(?=^.{$($MinimumLength),255}$)((?=.*\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^."
    }
    process{
            if($Password -match $PasswordRegex){
                return $true
            } else {
                return $false
            }
    }
    end{}
    
}