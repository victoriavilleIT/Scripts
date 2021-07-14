mkdir c:\temp
powershell.exe -command "Invoke-WebRequest https://raw.githubusercontent.com/victoriavilleIT/Scripts/main/DownloadSAP.ps1 -Outfile C:\Temp\sap.ps1"
ping -n 30 127.0.0.1 >NUL
powershell.exe -executionpolicy bypass -file C:\Temp\sap.ps1
ping -n 60 127.0.0.1 >NUL
powershell.exe -command "Invoke-WebRequest https://raw.githubusercontent.com/victoriavilleIT/Scripts/main/SAPInstall2.bat -Outfile C:\Temp\SAPInstall2.bat
cd C:\Temp
SAPInstall2.bat
