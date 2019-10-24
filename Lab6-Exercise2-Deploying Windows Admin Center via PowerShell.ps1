#region Lab 7 - Installing Windows Admin Center with PowerShell

#Download and install Windows Admin Center on Management01 using PowerShell

$DomainCred = Get-Credential

#Copy windowsadmincenter.mvpdays.com cert into the lab using PowerShell Direct
$PSSession = New-PSSession -VMName Management01 -Credential $DomainCred
Copy-Item -ToSession $PSSession -Path C:\labs\lab6\windowsadmincenter.mvpdays.com.pfx c:\

#Install Certificate using PowerShell

Invoke-Command -VMName Management01 -Credential $DomainCred {

Get-Command -Module PKIClient;
Import-PfxCertificate -FilePath c:\windowsadmincenter.mvpdays.com.pfx Cert:\LocalMachine\my -Password (ConvertTo-SecureString -String "P@ssw0rd" -Force -AsPlainText)

}



Invoke-Command -VMName Management01 -Credential $DomainCred {

#Grab the installed Certificate Thumbprint
$Cert = Get-ChildItem Cert:\LocalMachine\my | Where-Object subject -eq CN=Windowsadmincenter.mvpdays.com
$Cert
$Cert.Certificate.Thumbprint

#Download Windows Admin Center to downloads
    Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"

#Install Windows Admin Center (https://docs.microsoft.com/en-us/windows-server/manage/windows-admin-center/deploy/install)
    Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v c:\log.txt SME_PORT=443 SME_THUMBPRINT=$($cert.Certificate.Thumbprint) SSL_CERTIFICATE_OPTION=Installed"

#Open Windows Admin Center
  #  Start-Process "C:\Program Files\Windows Admin Center\SmeDesktop.exe"
 }


 #Step 2 - Add DC01, DHCP01, Router01, S2D2019-1,S2D2019-2 to Windows Admin Center

#endregion



