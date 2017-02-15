Function Set-ModuleVariable {
    [cmdletbinding()]
    param()
    $Config = Get-Content "$Root\config.json"|ConvertFrom-Json
    foreach($Property in ($Config.config|gm -MemberType NoteProperty).Name){
        $null = New-Variable -Scope Script -Name $Property -Value $($Config.config.$Property) -Force
        write-verbose "Creating property '$Property' with value '$($Config.config.$Property)'"
    }
   
}