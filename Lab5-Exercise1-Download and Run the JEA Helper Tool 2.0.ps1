

Invoke-WebRequest -Uri "https://gallery.technet.microsoft.com/JEA-Helper-Tool-20-6f9c49dd/file/146274/1/JEAHelperTool20.zip" -OutFile "C:\Labs\Lab5\JeaHelperTool2.0.zip"
Expand-Archive -LiteralPath "c:\labs\lab5\JeaHelperTool2.0.zip" -DestinationPath "c:\labs\lab5\" -Force
Set-Location -Path c:\labs\lab5
.\JEAHelperTool.ps1

