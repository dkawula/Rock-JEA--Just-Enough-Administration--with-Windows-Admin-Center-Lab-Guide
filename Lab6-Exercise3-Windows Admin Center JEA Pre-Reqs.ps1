
#region Lab 6.3 Installing Windows Admin Center - Pre-Reqs for JEA

#Creating User Accounts

$DomainCred = Get-Credential

Invoke-Command -VMName DC01 -Credential $DomainCred {

#Create users with password P@ssw0rd
New-ADUser -Name SuperCristal -AccountPassword  (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -Enabled $True 
New-ADUser -Name JohnO -AccountPassword  (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -Enabled $True
New-ADUser -Name DaveK -AccountPassword  (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -Enabled $True
#Create domain groups and add users.
    #Admins
    New-ADGroup -Name "Windows Admin Center Administrators" -GroupScope Global
    Add-ADGroupMember -Identity "Windows Admin Center Administrators" -Members SuperCristal
    #Hyper-V Admins
    New-ADGroup -Name "Windows Admin Center Hyper-V Administrators" -GroupScope Global
    #Readers
    Add-ADGroupMember -Identity "Windows Admin Center Hyper-V Administrators" -Members JohnO
    New-ADGroup -Name "Windows Admin Center Readers" -GroupScope Global
    Add-ADGroupMember -Identity "Windows Admin Center Readers" -Members DaveK

    }




#Add The Active Directory JEA Groups to the Local Windows Admin Center Groups

 Invoke-Command -VMName Management01 -Credential $DomainCred {
 
    Add-LocalGroupMember -Group "Windows Admin Center Administrators"  -Member "Techmentor\Windows Admin Center Administrators"
    Add-LocalGroupMember -Group "Windows Admin Center Hyper-V Administrators"  -Member "TechMentor\Windows Admin Center Hyper-V Administrators"
    Add-LocalGroupMember -Group "Windows Admin Center Readers"  -Member "TechMentor\Windows Admin Center Readers"
}



#Review the Configured JEA Enpoint on Management01

Enter-PSSession -VMName Management01 -Credential $DomainCred

Get-PSSessionConfiguration | where Author -eq System

$PSSessionConf = Get-PSSessionConfiguration | where Author -eq System

Get-PSSessionCapability -ConfigurationName $PSSessionConf.Name -Username Techmentor\JohnO

Get-PSSessionCapability -ConfigurationName $PSSessionConf.Name -Username Techmentor\SuperCristal

Get-PSSessionCapability -ConfigurationName $PSSessionConf.Name -Username Techmentor\DaveK

#endregion