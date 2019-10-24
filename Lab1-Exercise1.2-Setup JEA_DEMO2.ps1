#region LAB 1 Exercise 1.2 - 

#In this exercise you will create and Test JEA_DEMO2

#Show the PowerShell Remoting endpoints that are available for connections
Get-PSSessionConfiguration | Select Name

#Unregister JEA_Demo Endpoint

Unregister-PSSessionConfiguration -Name JEA_Demo



Get-PSSessionConfiguration | Select Name

#Reregister JEA_Demo Enpoint so we can use it in later exercises

Register-PSSessionConfiguration -Name JEA_Demo -Path "${env:programdata}\JeaConfiguration\JeaDemo.pssc"

Restart-Service winRM

Get-PSSessionConfiguration | Select Name

#Create a new endpoint configuration file

New-PSSessionConfigurationFile -Path "${env:ProgramData}\JeaConfiguration\JeaDemo2.pssc" -Full

#Open the endpoint configuration file in PowerShell ISE

psedit "${env:programdata}\JeaConfiguration\JEADemo2.pssc"


#Register the new JEA Endpoint using the configuration file we just created


Register-PSSessionConfiguration -Name JEA_Demo2 -Path "${env:programdata}\Jeaconfiguration\JeaDemo2.pssc"

#Retreive the non-admin credentials for Operator User - P@ssw0rd

$nonAdminCred = Get-Credential localhost\operatoruser

#Get a list of the commands that OperatorUser can run in this JEA Endpoint

Invoke-Command -ComputerName . -ConfigurationName JEA_Demo2 -ScriptBlock {Get-Command} -Credential $nonAdminCred

#Show the Demo_Module file structure, and note the Maintenance.psrc file in the RoleCapabilities Folder

Get-ChildItem -Recurse -LiteralPath "${env:programfiles}\WindowsPowerShell\Modules\Demo_Module"

#Open the Maintenance role Capabilities file

psedit "${env:programfiles}\WindowsPowerShell\Modules\Demo_Module\RoleCapabilities\Maintenance.psrc"

#Connect to the local JEA Endpoint call JEA_Demo2

Enter-PSSession -ComputerName . -ConfigurationName JEA_DEMO2 -Credential $nonAdminCred

#Get the new list of commands the OperatorUser can now run in this JEA Endpoint

Get-Command -CommandType All

#Restart the Spooler Service

Restart-Service -Name Spooler -Verbose

#Try Restarting another Service

Restart-Service -Name wsearch -Verbose

#Invoke an executable program

ipconfig
whoami.exe

#Verify you can restart the computer
Restart-Computer -Whatif

Exit-PSSession



