#Setup Maintenance Role Capability File

#Setup the Credentials

$DomainCred = Get-Credential




#Create the Demo Module that will contain the demo role Capability File

Invoke-Command -VMName Management01 -Credential $DomainCred {

$PowerShellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0"
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
}



#Review the Configuration
Invoke-Command -VMName Management01 -Credential $DomainCred {

Get-ChildItem -Recurse -LiteralPath "${env:programfiles}\WindowsPowerShell\Modules\Demo_Module"

Get-PSSessionConfiguration | FT
}



#Create and Register Demo Session Configuration File
Invoke-Command -VmName Management01 -Credential $DomainCred{
$Domain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
$NonAdministrator = "$Domain\JEA_NonAdmin_Operator"

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


}


#Reiger the JEA_Demo Endpoint

Invoke-Command -VMName Management01 -Credential $DomainCred {
$SessionName = "JEA_Demo"
Register-PSSessionConfiguration -Name $SessionName -path "$env:Programdata\JeaConfiguration\JeaDemo.pssc"

Restart-Service WinRM

}



#Review the Configuration
Invoke-Command -VMName Management01 -Credential $DomainCred {

Get-ChildItem -Recurse -LiteralPath "${env:programfiles}\WindowsPowerShell\Modules\Demo_Module"

Get-PSSessionConfiguration | FT
}


#Run the following locally from Management01  // Logon to Management01 using Techmentor\Administrator P@ssw0rd

$NonAdminCred = Get-Credential

#Use Techmentor\Administrator P@ssw0rd

Enter-PSSession -ComputerName . -ConfigurationName JEA_Demo -Credential $NonAdminCred

Get-Command
Get-Process
Restart-Service Spooler
ipconfig

Exit-PSSession