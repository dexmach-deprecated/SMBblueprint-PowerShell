Function Read-Choice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Title,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Choices
    )

    Try {
        if($Choices.Count -gt 26){
            Write-Error "More than 26 choices were passed for the question, unsupported"
        }
        $ascii = [char[]](65..90)
        $choiceArray = new-object System.Collections.ArrayList<System.Management.Automation.Host.ChoiceDescription>
                            
        $null = $choiceArray.Add($(New-Object System.Management.Automation.Host.ChoiceDescription "&0: CANCEL", ""))
        $choices = $choices | Sort-Object                   
        for($i = 0;$i -lt $Choices.Count;$i++) {
            $null = $choiceArray.Add($(New-Object System.Management.Automation.Host.ChoiceDescription "&$($ascii[$i]): $($Choices[$i])", ""))
        
        }
        $choiceArray = $choiceArray.ToArray([System.Management.Automation.Host.ChoiceDescription])	

        $result = $host.ui.PromptForChoice($Title, $Message, $choiceArray, 0)

        $null = $choiceArray[$result].Label -match "[0A-Z]\: (.*)"

        $Matches[1]

    } Catch {
        Write-Log -Type Error -Message "Error while creating question: $_"
    }

}