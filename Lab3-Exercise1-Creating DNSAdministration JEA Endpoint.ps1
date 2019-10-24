



$DomainCred = Get-Credential

Invoke-Command -VMName DC01 -Credential $DomainCred {

Install-WindowsFeature RSAT-DNS-Server
# Create a module in Program Files for the JEA roles
$modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoles"
New-Item $modulePath -ItemType Directory -Force
New-ModuleManifest -Path (Join-Path $modulePath "JEARoles.psd1") -Description "Contains custom JEA Role Capabilities"
 
# Create a folder for the role capabilities
$roleCapabilityPath = Join-Path $modulePath "RoleCapabilities"
New-Item $roleCapabilityPath -ItemType Directory
 
# Define the function for getting only DNS Server events
$dnsEventFnDef = @{
    Name = 'Get-DnsServerLog'
    ScriptBlock = { param([long]$MaxEvents = 100) Get-WinEvent -ProviderName "Microsoft-Windows-Dns-Server-Service" -MaxEvents $MaxEvents }
}
    
 
# Create the DNS Viewer role capability
New-PSRoleCapabilityFile -Path (Join-Path $roleCapabilityPath "DnsViewer.psrc") -VisibleCmdlets "DnsServer\Get-*" -VisibleFunctions "Get-DnsServerLog" -FunctionDefinitions $dnsEventFnDef
 
# Create the DNS admin role capability
New-PSRoleCapabilityFile -Path (Join-Path $roleCapabilityPath "DnsAdmin.psrc") -VisibleCmdlets "DnsServer\*", @{ Name = "Restart-Service"; Parameters = @{ Name = "Name"; ValidateSet = "Dns" } }
}



Invoke-Command -VMName DC01 -Credential $DomainCred {

# Pick location for file and security groups
$jeaConfigPath = "$env:ProgramData\JEAConfiguration"
$viewerGroup   = "Techmentor\JEA_NonAdmin_HelpDesk"
$adminGroup    = "Techmentor\JEA_NonAdmin_Operator"
 
# Create the session configuration file
New-Item $jeaConfigPath -ItemType Directory -Force
New-PSSessionConfigurationFile -Path (Join-Path $jeaConfigPath "JeaDnsConfig.pssc") -SessionType RestrictedRemoteServer -TranscriptDirectory (Join-Path $jeaConfigPath "Transcripts") -RunAsVirtualAccount -RoleDefinitions @{ $viewerGroup = @{ RoleCapabilities = 'DnsViewer' }; $adminGroup = @{ RoleCapabilities = 'DnsViewer', 'DnsAdmin' } }
 
# Register the session configuration file
Register-PSSessionConfiguration -Name DnsAdministration -Path (Join-Path $jeaConfigPath "JeaDnsConfig.pssc") -Force


}


#Review the Configuration
Invoke-Command -VMName DC01 -Credential $DomainCred {

Get-ChildItem -Recurse -LiteralPath "${env:programfiles}\WindowsPowerShell\Modules\JEARoles"

Get-PSSessionConfiguration | FT
}


#Run the following locally from Management01  // Logon to Management01 using Techmentor\Administrator P@ssw0rd

$NonAdminCred = Get-Credential

#Use Techmentor\OperatorUser P@ssw0rd

Enter-PSSession -ComputerName DC01 -ConfigurationName DNSAdministration -Credential $NonAdminCred

Get-Command


Exit-PSSession



$HelpDeskUser = Get-Credential

#Use Techmentor\HelpDeskUser P@ssw0rd

Enter-PSSession -ComputerName DC01 -ConfigurationName DNSAdministration -Credential $NonAdminCred

Get-Command
Get-Process
Restart-Service Spooler
ipconfig

Exit-PSSession