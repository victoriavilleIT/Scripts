mkdir c:\temp\CovalenceMDR
powershell.exe -command "Invoke-WebRequest https://faronicsdeploystorage.s3.ca-central-1.amazonaws.com/CovalenceMDR/covalence-endpoint-x64-2.1.1.msi -Outfile C:\Temp\CovalenceMDR\covalence-endpoint-x64-2.1.1.msi"
powershell.exe -command "Invoke-WebRequest https://faronicsdeploystorage.s3.ca-central-1.amazonaws.com/CovalenceMDR/license.txt -Outfile C:\Temp\CovalenceMDR\license.txt"
ping -n 20 127.0.0.1 >NUL
cd c:\temp\covalencemdr
msiexec.exe /i covalence-endpoint-x64-2.1.1.msi /qb
