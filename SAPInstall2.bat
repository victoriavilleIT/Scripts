cd C:\Temp\SAP750\"SAP 750"\Setup
START NwSapSetup.exe /product=SAPGUI /silent
ping -n 60 127.0.0.1 >NUL
cd C:\Temp\SAP750Patch12\"SAP 750 - Patch 12"
START gui750_12-80001468.exe /Silent
ping -n 60 127.0.0.1 >NUL
cd C:\Temp\SAP750Patchtext\"SAP Patch Text"
START SCRLTESP00_0-80004046.EXE /Silent
ping -n 60 127.0.0.1 >NUL
