@{

    RootModule = 'SMBBlueprint.psm1';

    ModuleVersion = '8.2.0.2';

    GUID = '83bc0698-c6b4-486a-a8e5-5e585038928d';

    Author = 'Jan Van Meirvenne', 'Stijn Callebaut';

    CompanyName = 'Inovativ BE';

    Copyright = '(c) 2017 Inovativ Belgium. All rights reserved.';

    Description = 'Deployment Framework for the Microsoft SMB Azure & O365 solution.';

    PowerShellVersion = '3.0';

    FunctionsToExport = '*'

    RequiredModules = @(
        "AzureRM.Profile",
        "AzureRM.Resources",
        "AzureAD",
        "AzureRM.Network"
    )

    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('SMB', 'Office365', 'Azure', 'AzureRM')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Inovativ/SMBblueprint-PowerShell'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @(
                '0.0.0.1: Initial preview, not production ready!',
                '0.0.0.3: Publishing test with VSO build automation. Logging capabilities optimized. Added -MailDomain switch to Office Deployment function.',
                '0.0.0.4: Publishing test with VSO build automation. Logging capabilities optimized. Added -MailDomain switch to Office Deployment function.',
                '0.0.0.5: Added missing AzureRM.Network requirement. Added additional checks for Azure Public DNS reserved keyword policy',
                '0.0.0.6: Fixed VM start/stop automation issues: Schedules are now enabled from the day after deployment / Variable<->Tag mismatch resolved / centralized the template URL in the ARM structure'
                '0.0.0.7: Added Multi-Region / Server 2016 support'
                '0.0.0.7: Check https://inovativ.github.io/SMBblueprint-Docs/',
                '8.2.0.0: Check https://inovativ.github.io/SMBblueprint-Docs/'
            )
            #ExternalModuleDependencies = @('Microsoft.Online.SharePoint.PowerShell')

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}