



$DomainCred = Get-Credential

Invoke-Command -VMName DHCP01 -Credential $DomainCred {


# Create a module in Program Files for the JEA roles
$modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoles_DHCP"
New-Item $modulePath -ItemType Directory -Force
New-ModuleManifest -Path (Join-Path $modulePath "JEARoles.psd1") -Description "Contains custom JEA Role Capabilities"
 
# Create a folder for the role capabilities
$roleCapabilityPath = Join-Path $modulePath "RoleCapabilities"
New-Item $roleCapabilityPath -ItemType Directory
 
# Define the function for getting only DHCP Server events
$DHCPEventFnDef = @{
    Name = 'Get-DHCPServerLog'
    ScriptBlock = { param([long]$MaxEvents = 100) Get-WinEvent -ProviderName "Microsoft-Windows-DHCP-Server" -MaxEvents $MaxEvents }
}
    
 
# Create the DHCP Viewer role capability
New-PSRoleCapabilityFile -Path (Join-Path $roleCapabilityPath "DHCPViewer.psrc") -VisibleCmdlets "DHCPServer\Get-*" -VisibleFunctions "Get-DHCPServerLog" -FunctionDefinitions $dhcpEventFnDef
 
# Create the DHCP admin role capability
New-PSRoleCapabilityFile -Path (Join-Path $roleCapabilityPath "DHCPAdmin.psrc") -VisibleCmdlets "DHCPServer\*", @{ Name = "Restart-Service"; Parameters = @{ Name = "Name"; ValidateSet = "DHCP" } }
}



Invoke-Command -VMName DHCP01 -Credential $DomainCred {

# Pick location for file and security groups
$jeaConfigPath = "$env:ProgramData\JEAConfiguration"
$viewerGroup   = "Techmentor\JEA_NonAdmin_HelpDesk"
$adminGroup    = "Techmentor\JEA_NonAdmin_Operator"
 
# Create the session configuration file
New-Item $jeaConfigPath -ItemType Directory -Force
New-PSSessionConfigurationFile -Path (Join-Path $jeaConfigPath "JeaDHCPConfig.pssc") -SessionType RestrictedRemoteServer -TranscriptDirectory (Join-Path $jeaConfigPath "Transcripts") -RunAsVirtualAccount -RoleDefinitions @{ $viewerGroup = @{ RoleCapabilities = 'DHCPViewer' }; $adminGroup = @{ RoleCapabilities = 'DHCPViewer', 'DHCPAdmin' } }
 
# Register the session configuration file
Register-PSSessionConfiguration -Name DHCPAdministration -Path (Join-Path $jeaConfigPath "JeaDHCPConfig.pssc") -Force


}


#Review the Configuration
Invoke-Command -VMName DHCP01 -Credential $DomainCred {

Get-ChildItem -Recurse -LiteralPath "${env:programfiles}\WindowsPowerShell\Modules\JEARoles_DHCP"

Get-PSSessionConfiguration | FT
}


#Run the following locally from Management01  // Logon to Management01 using Techmentor\Administrator P@ssw0rd

$NonAdminCred = Get-Credential

#Use Techmentor\OperatorUser P@ssw0rd

Enter-PSSession -ComputerName DHCP -ConfigurationName DHCPAdministration -Credential $NonAdminCred

Get-Command


Exit-PSSession



$HelpDeskUser = Get-Credential

#Use Techmentor\HelpDeskUser P@ssw0rd

Enter-PSSession -ComputerName DHCP -ConfigurationName DNSAdministration -Credential $NonAdminCred

Get-Command
ipconfig
netsh
Exit-PSSession