 function Invoke-Message {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string] $Message
            )
            Write-Log -Message $Message
            $null = Add-Type -AssemblyName System.Windows.Forms -ErrorAction Ignore -IgnoreWarnings
            [System.Windows.Forms.MessageBox]::Show($Message)
        }