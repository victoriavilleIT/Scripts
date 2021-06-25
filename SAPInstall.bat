mkdir c:\temp
powershell.exe -command "Invoke-WebRequest https://raw.githubusercontent.com/victoriavilleIT/Scripts/main/DownloadSAP.ps1 -Outfile C:\Temp\sap.ps1"
ping -n 30 127.0.0.1 >NUL
powershell.exe -executionpolicy bypass -file C:\Temp\sap.ps1
ping -n 60 127.0.0.1 >NUL
START C:\Temp\SAP750\"SAP 750"\Setup\NwSapSetup.exe /product=SAPGUI /silent
ping -n 60 127.0.0.1 >NUL 
START C:\Temp\SAP750Patch12\"SAP 750 - Patch 12"\gui750_12-80001468.exe /Silent
ping -n 60 127.0.0.1 >NUL
START C:\Temp\SAP750Patchtext\"SAP Patch Text"\SCRLTESP00_0-80004046.EXE /Silent
ping -n 60 127.0.0.1 >NUL
