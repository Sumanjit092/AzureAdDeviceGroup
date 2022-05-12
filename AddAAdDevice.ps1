<#
.SYNOPSIS:
   Add Managed iOS & Android Device into Security Group with PowerShell Script.

.Description:
    AddAAdDevice.ps1 is a PowerShell script finds Managed iOS & Android devices from a User Security Group.
    Match if Device is alreday exist in Device Security Group. If not, it adds devices into the Device Security Group.

.AUTHOR:
    Sumanjit Pan

.VERSION:
    1.0 

.Date: 
    8th February, 2022
#>

Function CheckAzureAd{
''
Write-Host "Checking AzureAd Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable | where {$_.Name -like "*AzureAD*"}) 
    {
    Write-Host "AzureAD Module has installed." -ForegroundColor Green
    Import-Module AzureAD
    Write-Host "AzureAD Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else 
    {
    Write-Host "AzureAD Module is not installed." -ForegroundColor Red
    ''
    Write-Host "Installing AzureAD Module....." -ForegroundColor Yellow
    Install-Module AzureAD -Force
                                
    if (Get-Module -ListAvailable | where {$_.Name -like "*AzureAD*"}) {                                
    Write-Host "AzureAD Module has installed." -ForegroundColor Green
    Import-Module AzureAD
    Write-Host "AzureAD Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else
    {
    ''
    ''
    Write-Host "Operation aborted. AzureAD Module was not installed." -ForegroundColor Red
    Exit}
    }

Write-Host "Connecting to AzureAD PowerShell..." -ForegroundColor Magenta
$AzureAd = Connect-AzureAD
Write-Host "User $($AzureAd.Account) has connected to $($AzureAd.TenantDomain) AzureCloud tenant successfully." -ForegroundColor Green
}

Cls
'===================================================================================================='
Write-Host '                               Add Managed iOS & Android Device into a Group                                    ' -ForegroundColor Green 
'===================================================================================================='
''                    
Write-Host "                                          IMPORTANT NOTES                                           " -ForegroundColor Red 
Write-Host "===================================================================================================="
Write-Host "This source code is freeware and is provided on an 'as is' basis without warranties of any kind," -ForegroundColor Yellow 
Write-Host "whether express or implied, including without limitation warranties that the code is free of defect," -ForegroundColor Yellow 
Write-Host "fit for a particular purpose or non-infringing. The entire risk as to the quality and performance of" -ForegroundColor Yellow 
Write-Host "the code is with the end user." -ForegroundColor Yellow 
''
Write-Host "Intune uses Azure Active Directory (Azure AD) groups to manage devices and users. As an Intune admin," -ForegroundColor Yellow 
Write-Host "you can set up groups to suit your organizational needs. Create groups to organize devices by" -ForegroundColor Yellow
Write-Host "geographic location, department, hardware or Operating System characteristics." -ForegroundColor Yellow
''
Write-Host "For more information, kindly visit the link:" -ForegroundColor yellow 
Write-Host "https://docs.microsoft.com/en-us/mem/intune/fundamentals/groups-add" -ForegroundColor yellow 
''
"===================================================================================================="
''
CheckAzureAd

'' 
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

[string] $GrpName = Read-Host -Prompt "Enter the Security Group Display Name Containing Users Object"
$Group = (Get-AzureADGroup -SearchString "$GrpName").ObjectId
''
[string] $DeviceGrp = Read-Host -Prompt "Enter your iOS and Android Device Security Group Display Name"
$DeviceGroup = (Get-AzureADGroup -SearchString "$DeviceGrp").ObjectId
''
$Members = Get-AzureAdGroupMember -ObjectId $Group -All $true
foreach ($Member in $Members){
$Devices = Get-AzureADUserRegisteredDevice -ObjectId $Member.ObjectId | ? {($_.IsManaged -eq "True") -and ($_.DeviceOSType -notmatch "Windows*") -and ($_.DeviceOSType -notmatch "Mac*")}
foreach ($Device in $Devices) {
$GrpMember = Get-AzureADGroupMember -ObjectId $DeviceGroup | ? {$_.ObjectId -eq $Device.ObjectId}
if ($GrpMember) {
Write-Host "$($Device.DisplayName) Exist in Group" -ForegroundColor Yellow
}
Else {
Add-AzureADGroupMember -ObjectId $DeviceGroup -RefObjectId $Device.ObjectId
Write-Host "Added Device $($Device.DisplayName) in Group" -ForegroundColor Green
}}
}
Exit