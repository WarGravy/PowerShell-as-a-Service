# Passing in arguments is supported via the config.
param([string] $EnvironmentVariableTarget = "Process")

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[string[]] $pathFolders = [Environment]::GetEnvironmentVariable( "Path", $EnvironmentVariableTarget) -Split ";"

try
{
    do
    {
        #Do some work.
        Wait-Event -Timeout 1
        If ($pathFolders -ne $null)
        {
            Write-Output $pathFolders
        }
    } while ($true) #When Powershell script finishes/exits we no longer want the windows service to show as running.
}
finally
{
    # this gets executed when user presses CTRL+C
    Write-Host "CTRL+C detected"
}