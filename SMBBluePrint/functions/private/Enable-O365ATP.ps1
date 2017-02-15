Function Enable-O365ATP {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $MailDomain
    )
    begin{
        $SafeLinkPolicyName = "$MailDomain Default SafeLink Policy"
        $SafeLinkRuleName = "$MailDomain Default SafeLink Rule"
        $SafeAttachmentPolicyName = "$MailDomain Default SafeAttachment Policy"
        $SafeAttachmentRuleName = "$MailDomain Default SafeAttachment Rule"
    }
    process{
        try{
            if(!(get-safelinkspolicy $SafeLinkPolicyName -ErrorAction SilentlyContinue)){
                New-SafeLinksPolicy $SafeLinkPolicyName -TrackClicks $true -IsEnabled $true -AllowClickThrough $false
                Write-Log "ATP Safe Link Policy '$($SafeLinkPolicyName)' created"
            } else {
                Write-Log "ATP Safe Link Policy '$($SafeLinkPolicyName)' already Exists"
            }
            if((get-safelinksrule $SafeLinkRuleName)){
                New-SafeLinksRule $SafeLinkRuleName -SafeLinksPolicy $SafeLinkPolicyName -RecipientDomainIs $MailDomain -Enabled $true
                Write-Log "ATP Safe Link Rule '$($SafeLinkRuleName)' created"
            } else {
                Write-Log "ATP Safe Link Rule '$($SafeLinkRuleName)' already exists"
            }
            
            
            if(!(get-safeattachmentpolicy $SafeAttachmentPolicyName)){
                New-SafeAttachmentPolicy $SafeAttachmentPolicyName -Enable $true -Redirect $false -Action Block
            }

            if(!(get-safeattachmentrule $SafeAttachmentRuleName)){
                New-SafeAttachmentRule $SafeAttachmentRuleName -RecipientDomainIs $MailDomain -SafeAttachmentPolicy $SafeAttachmentPolicyName -Enabled $true
            }
        } catch {
            throw "Error while enabling O365 ATP: $_"
        }
    }
    end{}

}