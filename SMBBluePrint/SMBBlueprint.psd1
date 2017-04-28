@{

    RootModule = 'SMBBlueprint.psm1';

    ModuleVersion = '8.2.0.3';


    GUID = '83bc0698-c6b4-486a-a8e5-5e585038928d';

    Author = 'Jan Van Meirvenne', 'Stijn Callebaut';

    CompanyName = 'Inovativ BE';

    Copyright = '(c) 2017 Inovativ Belgium. All rights reserved.';

    Description = 'Deployment Framework for the Microsoft SMB Azure & O365 solution.';

    PowerShellVersion = '3.0';

    FunctionsToExport = '*'

    RequiredModules = @(
        @{ModuleName = "AzureRM.Profile"; RequiredVersion = "2.5.0"},
        @{ModuleName = "AzureRM.Resources"; RequiredVersion = "3.5.0"},
        @{ModuleName = "AzureRM.Network"; RequiredVersion = "3.4.0"},
        @{ModuleName = "AzureAD"; RequiredVersion = "2.0.0.55"}
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
            ReleaseNotes = "https://inovativ.github.io/SMBblueprint-Docs/changelog"
            
            #ExternalModuleDependencies = @('Microsoft.Online.SharePoint.PowerShell')

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}