function Test-ModuleVersion {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ModuleName
    )

    try{
        write-log -message "Checking if your $ModuleName module is up to date..."
        if($CurrentModule = (Get-Module -Name $ModuleName)){
            if($TargetModule = (find-module -name $ModuleName)){
                if($CurrentModule.Version -lt $TargetModule.Version){
                    Write-Log -Type Warning -Message "Your version of $ModuleName is out-of-date and might be unsupported (Installed: $($CurrentModule.Version) Available: $($TargetModule.Version)). Please check https://inovativ.github.io/SMBblueprint-Docs/changelog/ on how to update."
                } else {
                    Write-Log -Message "Congratulations. Your $ModuleName module is up-to-date! (Current Version: $($CurrentModule.Version))"
                }
            }
            else { throw "Module not present on the PSGallery"}
        } else {throw "Module not present on this system"}
    } catch {
        Write-Log -Type Warning -Message "Could not verify if the $ModuleName solution is up-to-date (Current Version: $($CurrentModule.Version): $_. Check the latest verion on https://inovativ.github.io/SMBblueprint-Docs/changelog/"
    }
}