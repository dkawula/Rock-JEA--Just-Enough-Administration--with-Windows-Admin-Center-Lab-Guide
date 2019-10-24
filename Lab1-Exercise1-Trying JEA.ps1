#region Lab 1 Exercise 1 - Testing JEA as a Non-Administrator

#We will create an alternate PSSession for testing purposes
#PowerShell Direct cannot be used for this testing

#Once Logged in Open an Administrative PowerSHell Prompt

#Type the commands below


#First let's have a look at the commands that are avaialble without using JEA

get-command

get-command | Measure-Object

#Now let's look at the locked down operator user that should only have the ability to run a handful of PowerShell Commands


#Logon as LocalHost\OperatorUser   P@ssw0rd

$NonAdminCred = Get-Credential




Enter-PSSession -ComputerName Localhost -ConfigurationName JEA_Demo -Credential $NonAdminCred

#Now you have entered an interactive PowerSHell session against the local machine.  By using the "Credential parameter,
#you have connected as though you were the non-admin user.   THe change in the prompt indicates that you are operating against
#a remote session

#Run the following command in the remote session

Get-Command

#This shows the commands that are available to the operator connecting to this JEA endpoint.   As you can see things are very limited

#Run the following command in the remote session

Get-UserInfo

#The custom command shows the "ConnectedUser" as well as the "RunAsUser".  The connected user is the account that is connected to the
#remote session.   The connected user does not need to have admin privileges.   The "RunAs" account is the account actually performing the privileged actions
#By Connecting as one user, and running as a priviliged user, we allow non-priviliged user to perform specific administrative tasks without 
#Giing them administrative rights

#Try restarting the Spooler Service

Restart-Service -Name Spooler -Verbose

#This should Work

#Try Restarting the Computer

Restart-Computer -whatif

#This should NOT Work

#Try getting the list of processes
Get-Process

#Cool you got JEA Working

Exit-PSSession









#endregion

#region Lab 2.4  Viewing Registered PowerShell Session Configuration Files
 <#>
 When you used JEA in the above section, you started running the following command:

 Enter-PSSession -Computername Localhost -ConfigurationName JEA_DEMO -Credential $NonAdminCred

 While most of the parameters are self-explanatory, the "ConfigurationName" parameter may seem
 confusing at first.   This parameter specified the PowerShell Session Configuration, or Endpoint, to which you 
 were connecting

 PowerShell Session configuration is a fancy term for PowerShell Endpoint.  It is the figurative "Place" where
 users connect and get acces to PowerShell functionality.  Based on how you set up a Session Configuration,
 it can provide different functionality to connecting users.   For JEA, we use Session Configurations
 to restrict PowerShell to a limted set of functionality and to "RunAS" a privileged Virtual Account.

 You already have several registered PowerShell Session Configurations on your machine, each set up slightly differently.
 Most of them come with Windows, but the "JEADEMO" Session Configuration was set up in the earlier labs.   You can see all registered
 Sessions Configurations by running the following command.


 </#>

 $DomainCred = Get-Credential
 Invoke-Command -VMName Management01 -Credential $DomainCred {
 
 Get-PSSessionConfiguration | ft
 }


#endregion














#endregion