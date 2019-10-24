#region LAB 1 Pre-Reqs

#Enable PS remoting for the labs
$Nodes = 'DC01','DHCP01','Management01','Router01','S2D2019-1','S2D2019-2'
$DomainCred = Get-Credential


#In Building the lab this could take a minute or two so be patient please
Invoke-Command -VMName $Nodes -Credential $DomainCred {Enable-PSRemoting -Verbose}


#Installing the xActiveDirectory module
#when prompted say yes to the NUGET 

Invoke-Command -VMName DC01 -Credential $DomainCred {
Install-Module xActiveDirectory -Force -Verbose
Get-Module xActiveDirectory -ListAvailable

}

#Creating the required users and Groups for the lab

Invoke-Command -VMName DC01 -Credential $DomainCred {

#Create Groups
$NonAdminOperatorGroup = New-ADGroup -Name "JEA_NonAdmin_Operator" -GroupScope DomainLocal
$NonAdminHelpDeskGroup = New-ADGroup -Name "JEA_NonAdmin_HelpDesk" -Groupscope DomainLocal
$TestGroup = New-ADGroup -Name "Test_Group" -Groupscope DomainLocal
#Create Users
$OperatorUser = New-ADUser -Name "OperatorUser" -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
$OperatorUser = "OperatorUser"
Enable-ADAccount -Identity $OperatorUser
$HelpDeskUser = New-ADUser -Name "HelpDeskUser" -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
$HelpDeskUser = "HelpDeskUser"
Enable-ADAccount -Identity $HelpDeskUser
#Add Members to Groups
$NonAdminOperatorGroup = "JEA_NonAdmin_Operator"
$NonAdminHelpDeskGroup = "JEA_NonAdmin_HelpDesk"
Add-ADGroupMember -Identity $NonAdminOperatorGroup -Members $OperatorUser
Add-ADGroupMember -Identity $NonAdminHelpDeskGroup -Members $HelpDeskUser
New-ADGroup TestGroup -GroupScope DomainLocal

}

Invoke-Command -VMName DC01 -Credential $DomainCred {

Get-ADUser OperatorUser

}

#endregion