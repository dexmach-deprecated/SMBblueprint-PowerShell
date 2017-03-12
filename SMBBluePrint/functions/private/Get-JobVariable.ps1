function Get-JobVariable {
    [cmdletbinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Id
    )
    if((Get-Variable -Name SMBInstances -Scope Global -ErrorAction SilentlyContinue) -eq $null){
        $global:SMBInstances = [hashtable]::Synchronized(@{})
        
    }
    if(!$Id){
        $Id = [Guid]::NewGuid().ToString()
        $global:SMBInstances.Add($Id,[hashtable]::Synchronized(@{InstanceId=$Id;Root=$global:root}))
        $global:SMBInstances[$Id]
    } else {
        try{
            $global:SMBInstances[$Id]
            
        } catch {
            throw "SMBBluePrint Instance Id not found"
        }
    }
}