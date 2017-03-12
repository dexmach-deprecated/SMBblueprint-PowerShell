function Write-Log {
    # write a message to the global log file
    [cmdletbinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string] $Message,
        [ValidateSet('Warning','Error','Verbose','Debug', 'Information')]
        [string] $Type = 'Information',
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Log
    )
    process {
       
        #Get the info about the calling script, function etc
        $callinginfo = (Get-PSCallStack)[1]
        #Set Source Information
        $Source = (Get-PSCallStack)[1].Location
        #Set Component Information
        $Component = (Get-Process -Id $PID).ProcessName
        #Set PID Information
        $ProcessID = $PID
        #Obtain UTC offset 
        $DateTime = New-Object -ComObject WbemScripting.SWbemDateTime
        $DateTime.SetVarDate($(Get-Date))
    $UtcValue = $DateTime.Value
    $UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21)
    #Set the order
    switch($Type){
        'Warning' {
            $Severity = 2
        }#Warning
        'Error' {
            $Severity = 3
        }#Error
        'Verbose' {
            $Severity = 4
        }#Verbose
        'Debug' {
            $Severity = 5
        }#Debug
        'Information' {
            $Severity = 6
        }#Information
    }#Switch
    $Line = "$Message"

    switch($Severity){
        2{
            Write-Warning $Line
        }
        3{
				
            <# if($Message.Exception.Message){
					$Line +=  = @"
					Command: $($Message.InvocationInfo.MyCommand)"
					                ScriptName: $($Message.InvocationInfo.Scriptname)"
	                Line Number: $($Message.InvocationInfo.ScriptLineNumber)"`
					                Column Number: $($Message.InvocationInfo.OffsetInLine)"
	                Line: $($Message.InvocationInfo.Line)
	"@
				} #>
            Write-Error $Line
        }
        4{
            Write-Verbose $Line
        }
        5{
            Write-Debug $Line
        }
        6{
            Write-Host $Line
        }
    }
    #$Message|out-file $script:Log -append -encoding default
    $LogEntry = `
		"<![LOG[$Line]LOG]!>" +` 
    "<time=""$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)"" " +`
		"date=""$(Get-Date -Format M-d-yyy)"" "  +`
		"component=""$($CallingInfo.FunctionName)"" " + `
		"context=""$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"" " +`
		"type=""$Severity"" " +`
		"thread=""$($ProcessID)"">"

    $Writer = new-object System.IO.StreamWriter $Log,$true
    $Writer.WriteLine($LogEntry.Replace("`r`n","`t"))
    $Writer.Close()
    $Writer.Dispose()
   
}
}