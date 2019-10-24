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






