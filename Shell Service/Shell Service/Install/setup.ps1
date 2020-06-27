#https://docs.microsoft.com/en-us/archive/msdn-magazine/2016/may/windows-powershell-writing-windows-services-in-powershell
param([Switch]$Setup, [Switch]$Uninstall)
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location $dir

$AppName = "Shell Service.exe"
$dir = $dir.Replace("\Install", "")
$ApplicationExe = "$dir\$AppName"

$json = Get-Content '..\appsettings.json' | Out-String | ConvertFrom-Json
$ServiceName = $json.ServiceSettings.ServiceName

Write-Host "Service Name: $ServiceName"
Write-Host "Executable: $ApplicationExe"

if ($ServiceName -eq $Null -or $ServiceName -eq ""){
    Write-Error "Please add a service name to the Service Settings in appsettings.json"
    exit 1
}
if($Setup){
    New-Service -Name $ServiceName -BinaryPathName $ApplicationExe
    Start-Service -Name $ServiceName
}
if($Uninstall){
    Stop-Service -Name $ServiceName
    sc.exe delete $ServiceName
}