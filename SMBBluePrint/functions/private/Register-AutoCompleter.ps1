function Register-AutoCompleter {

    function StorageType {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $ARM = ((invoke-webrequest -Uri $function:TemplateUrl -UseBasicParsing).Content)|ConvertFrom-Json
    $ARM.Parameters.StorageType.AvailableValues|?{$_ -like "$wordToComplete*"}|%{new-completionresult -completionresult $_}
          
            
          

 
}

Register-AutoCompleter -CommandName New-SMBAzureDeployment -Parameter StorageType -ScriptBlock function:StorageType -Description "Azure Storage Type"
}