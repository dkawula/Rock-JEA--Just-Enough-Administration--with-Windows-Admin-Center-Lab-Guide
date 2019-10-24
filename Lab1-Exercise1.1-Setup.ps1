#region LAB 1 Exercise 1 - Trying out an existing Configuration of JEA
#We will Create a few Users and Groups for this lab
#OperatorUser and HelpDeskUser
#Each User will have different capabilities via Just Enough Administration
#Will will then take these techniques and use them throughout the labs
#The goal of this exercise is to simply show how JEA Works
#Don't worry about the specific details at this time as we will learn those through the configurations

#Enable PS remoting for the labs


#In Building the lab this could take a minute or two so be patient please
Enable-PSRemoting -Verbose


#Creating the required users and Groups for the lab
#These users will be created on this Hyper-V Host just as an example
#In the other Labs we will create them Active Directory Groups and User

#Create Groups
$NonAdminOperatorGroup = New-LocalGroup -Name "JEA_NonAdmin_Operator"
$NonAdminHelpDeskGroup = New-LocalGroup -Name "JEA_NonAdmin_HelpDesk" 
#Create Users
$OperatorUser = New-LocalUser -Name "OperatorUser" -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) 
$HelpDeskUser = New-LocalUser -Name "HelpDeskUser" -Password (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
#Add Members to Groups
$NonAdminOperatorGroup = "JEA_NonAdmin_Operator"
$NonAdminHelpDeskGroup = "JEA_NonAdmin_HelpDesk"
Add-LocalGroupMember -Name $NonAdminOperatorGroup -Member OperatorUser
Add-LocalGroupMember -Name $NonAdminHelpDeskGroup -Member HelpDeskUser


#Now we have two groups and two users created locally



#Setup Maintenance Role Capability File


$PowerShellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"


#Create the Demo Module that will contain the demo role Capability File

New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module" -ItemType Directory
New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module\Demo_Module.PSD1"
New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module\RoleCapabilities" -ItemType Directory

#Create the Role Capability File
$MaintenanceRoleCapabilityCreationParams = @{
Author = "Techmentor Admin"
ModulesToImport = "Microsoft.PowerShell.Core"
VisibleCmdlets = "Restart-Service"
CompanyName = "Techmentor"
FunctionDefinitions = @{ Name = 'Get-UserInfo'; ScriptBlock = {$PSSenderInfo}}


}

New-PSRoleCapabilityFile -Path "$env:ProgramFiles\WIndowsPowerShell\Modules\Demo_Module\RoleCapabilities\Maintenance.psrc" @MaintenanceRoleCapabilityCreationParams





$NonAdministrator = "JEA_NonAdmin_Operator"

$JEAConfigParams = @{
    SessionType = "RestrictedRemoteServer"
    RunAsVIrtualAccount = $true
    RoleDefinitions = @{ $NonAdministrator = @{RoleCapabilities = 'Maintenance'}}
    TranscriptDirectory = "$env:ProgramData\JEAConfiguration\Transcripts"
    }

if(-not (Test-Path "$env:ProgramData\JEAConfiguration"))

{ 
New-Item -Path "$env:programdata\JEAConfiguration" -ItemType Directory

}

$SessionName = "JEA_Demo"

if(Get-PSSessionConfiguration -Name $SessionName -ErrorAction SilentlyContinue)

{
Unregister-PSSessionConfiguration -Name $SessionName -ErrorAction Stop
}

New-PSSessionConfigurationFile -Path "$env:programdata\JeaConfiguration\JeaDemo.pssc" @JeaConfigParams


$SessionName = "JEA_Demo"
Register-PSSessionConfiguration -Name $SessionName -path "$env:Programdata\JeaConfiguration\JeaDemo.pssc"

Restart-Service WinRM

Get-PSSessionConfiguration | ft





<#>

Logon to Management01
Open Local Group Policy Editor
Navigate to "Computer Configuration\Administrative Templates\Windows Components\Windows PowerShell"
Double Click on "Turn on Module logging"
Click "Enabled"
In Options section click on "SHow" next to Module Names
Type "*" in the pop up window.   This means PowerShell will log commands from all modules
Click OK and apply the policy



</#>