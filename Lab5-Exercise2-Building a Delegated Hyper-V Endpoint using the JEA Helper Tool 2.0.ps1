Set-Location -Path c:\labs\lab5
.\JEAHelperTool.ps1



#Now let's look at the locked down operator user that should only have the ability to run a handful of PowerShell Commands


#Logon as LocalHost\OperatorUser   P@ssw0rd

$NonAdminCred = Get-Credential




Enter-PSSession -ComputerName Localhost -ConfigurationName JEA_Demo -Credential $NonAdminCred

#What Modules and Commands do you see?
get-command

get-vm
get-vm S2D*
get-vm S2D* | Restart-VM -Force -verbose
get-vm

Exit-PSSession

Enter-PSSession -ComputerName . -Credential $NonAdminCred

